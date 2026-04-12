import axios from 'axios';

const baseURL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000/api/v1';

const axiosClient = axios.create({
  baseURL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// We will maintain the token in memory
let accessToken: string | null = null;

export const setAccessToken = (token: string) => {
  accessToken = token;
};

// Add a request interceptor
axiosClient.interceptors.request.use(
  function (config) {
    if (accessToken && config.headers) {
      config.headers.Authorization = `Bearer ${accessToken}`;
    }
    return config;
  },
  function (error) {
    return Promise.reject(error);
  }
);

// Add a response interceptor
axiosClient.interceptors.response.use(
  function (response) {
    // Only return the data directly for easier handling
    return response.data;
  },
  function (error) {
    // Handle specific errors like 401 Unauthorized
    if (error.response?.status === 401) {
      console.warn('Unauthorized access. Might need to re-login.');
      // Optionally trigger something to clear user state
    }
    return Promise.reject(error.response?.data || error);
  }
);

export default axiosClient;
