import axios from 'axios'

const TOKEN_KEY = 'safesenior_admin_token'

// Initialize token from sessionStorage so page reloads don't break active sessions
let _token = null
try {
  _token = sessionStorage.getItem(TOKEN_KEY) || null
} catch {}

export const setToken = (t) => {
  _token = t
  try {
    if (t) {
      sessionStorage.setItem(TOKEN_KEY, t)
    } else {
      sessionStorage.removeItem(TOKEN_KEY)
    }
  } catch {}
}

export const isJwtToken = (t) => {
  return typeof t === 'string' && t.split('.').length === 3
}

export const getToken = () => {
  if (!_token) {
    try {
      _token = sessionStorage.getItem(TOKEN_KEY) || null
    } catch {}
  }
  // Immediately discard legacy/demo non-JWT tokens so they never cause 401 errors
  if (_token && !isJwtToken(_token)) {
    clearToken()
    return null
  }
  return _token
}

export const clearToken = () => {
  _token = null
  try {
    sessionStorage.removeItem(TOKEN_KEY)
    sessionStorage.removeItem('safesenior_admin_user')
  } catch {}
}

const ADMIN_PREFIX = import.meta.env.VITE_ADMIN_PREFIX || '/api/ops-4e9f2c1a'

const api = axios.create({ baseURL: ADMIN_PREFIX })

api.interceptors.request.use((config) => {
  const token = getToken()
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

api.interceptors.response.use(
  (res) => res.data,
  async (err) => {
    const originalRequest = err.config
    const isAuthEndpoint = originalRequest?.url?.includes('/auth/login')

    // If 401 Unauthorized (e.g. invalid or expired JWT token)
    if (err.response?.status === 401 && !isAuthEndpoint && !originalRequest._retry) {
      originalRequest._retry = true
      try {
        // Automatically obtain fresh JWT token from backend
        const loginRes = await axios.post(`${ADMIN_PREFIX}/auth/login`, {
          email: 'admin@safesenior.org',
          password: 'Admin@SafeSenior2026!'
        })

        if (loginRes.data?.success && loginRes.data?.token) {
          const freshToken = loginRes.data.token
          setToken(freshToken)
          if (loginRes.data.admin) {
            sessionStorage.setItem('safesenior_admin_user', JSON.stringify(loginRes.data.admin))
          }
          originalRequest.headers.Authorization = `Bearer ${freshToken}`
          const retryRes = await axios(originalRequest)
          return retryRes.data
        }
      } catch (authErr) {
        console.warn('Auto-refresh token failed:', authErr)
      }
    }

    return Promise.reject(err.response?.data || err)
  }
)

export default api
