import axios from 'axios'

// Token stored in memory only — never localStorage
let _token = null

export const setToken = (t) => { _token = t }
export const getToken = () => _token
export const clearToken = () => { _token = null }

const ADMIN_PREFIX = import.meta.env.VITE_ADMIN_PREFIX || '/api/ops-4e9f2c1a'

const api = axios.create({ baseURL: ADMIN_PREFIX })

api.interceptors.request.use((config) => {
  if (_token) config.headers.Authorization = `Bearer ${_token}`
  return config
})

api.interceptors.response.use(
  (res) => res.data,
  (err) => {
    if (err.response?.status === 401) {
      clearToken()
      window.location.href = '/login'
    }
    return Promise.reject(err.response?.data || err)
  }
)

export default api
