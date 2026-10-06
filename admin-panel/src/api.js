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

export const getToken = () => {
  if (!_token) {
    try {
      _token = sessionStorage.getItem(TOKEN_KEY) || null
    } catch {}
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
  (err) => {
    // Only redirect to /login on 401 if it's NOT an auth endpoint attempt (e.g. login credentials check)
    // and only if we are not already on the login page
    const isAuthEndpoint = err.config?.url?.includes('/auth/login')
    if (err.response?.status === 401 && !isAuthEndpoint) {
      clearToken()
      if (typeof window !== 'undefined' && window.location.pathname !== '/login') {
        window.location.href = '/login'
      }
    }
    return Promise.reject(err.response?.data || err)
  }
)

export default api
