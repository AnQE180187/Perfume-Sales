// API Client for Backend Integration
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api/v1';

interface ApiResponse<T> {
  data?: T;
  error?: string;
  message?: string;
}

class ApiClient {
  private baseUrl: string;

  constructor(baseUrl: string = API_BASE_URL) {
    this.baseUrl = baseUrl;
  }

  // Get token from localStorage
  getToken(): string | null {
    if (typeof window === 'undefined') return null;
    return localStorage.getItem('accessToken');
  }

  // Set token in localStorage
  setToken(accessToken: string, refreshToken?: string): void {
    if (typeof window === 'undefined') return;
    localStorage.setItem('accessToken', accessToken);
    if (refreshToken) {
      localStorage.setItem('refreshToken', refreshToken);
    }
  }

  // Clear tokens
  clearTokens(): void {
    if (typeof window === 'undefined') return;
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
  }

  // Refresh access token
  async refreshAccessToken(): Promise<string | null> {
    if (typeof window === 'undefined') return null;
    const refreshToken = localStorage.getItem('refreshToken');
    if (!refreshToken) return null;

    try {
      const response = await fetch(`${this.baseUrl}/auth/refresh`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken }),
      });

      if (!response.ok) {
        this.clearTokens();
        return null;
      }

      const data = await response.json();
      this.setToken(data.accessToken, data.refreshToken);
      return data.accessToken;
    } catch (error) {
      console.error('Failed to refresh token:', error);
      this.clearTokens();
      return null;
    }
  }

  // Make authenticated request
  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<ApiResponse<T>> {
    const token = this.getToken();
    const url = `${this.baseUrl}${endpoint}`;

    const headers: HeadersInit = {
      'Content-Type': 'application/json',
      ...options.headers,
    };

    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    try {
      let response = await fetch(url, {
        ...options,
        headers,
      });

      // If 401, try to refresh token
      if (response.status === 401 && token) {
        const newToken = await this.refreshAccessToken();
        if (newToken) {
          headers['Authorization'] = `Bearer ${newToken}`;
          response = await fetch(url, {
            ...options,
            headers,
          });
        }
      }

      const data = await response.json();

      if (!response.ok) {
        return {
          error: data.message || data.error || 'Request failed',
        };
      }

      return { data };
    } catch (error: any) {
      return {
        error: error.message || 'Network error',
      };
    }
  }

  // Auth methods
  async login(email: string, password: string) {
    const response = await this.request<{
      accessToken: string;
      refreshToken: string;
    }>('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });

    if (response.data) {
      this.setToken(response.data.accessToken, response.data.refreshToken);
    }

    return response;
  }

  async register(email: string, password: string, fullName?: string, phone?: string) {
    return this.request('/auth/register', {
      method: 'POST',
      body: JSON.stringify({ email, password, fullName, phone }),
    });
  }

  async logout() {
    const response = await this.request('/auth/logout', {
      method: 'POST',
    });
    this.clearTokens();
    return response;
  }

  // User methods
  async getMe() {
    return this.request('/users/me');
  }

  async updateMe(data: any) {
    return this.request('/users/me', {
      method: 'PATCH',
      body: JSON.stringify(data),
    });
  }

  // Product methods
  async getProducts(filters?: { gender?: string; brandId?: string; categoryId?: string }) {
    const params = new URLSearchParams();
    if (filters?.gender) params.append('gender', filters.gender);
    if (filters?.brandId) params.append('brandId', filters.brandId);
    if (filters?.categoryId) params.append('categoryId', filters.categoryId);

    const query = params.toString();
    return this.request(`/products${query ? `?${query}` : ''}`);
  }

  async getProduct(id: string) {
    return this.request(`/products/${id}`);
  }

  // Cart methods
  async getCart() {
    return this.request('/cart');
  }

  async addToCart(productId: string, quantity: number) {
    return this.request('/cart/items', {
      method: 'POST',
      body: JSON.stringify({ productId, quantity }),
    });
  }

  async updateCartItem(id: string, quantity: number) {
    return this.request(`/cart/items/${id}`, {
      method: 'PATCH',
      body: JSON.stringify({ quantity }),
    });
  }

  async removeCartItem(id: string) {
    return this.request(`/cart/items/${id}`, {
      method: 'DELETE',
    });
  }

  // Order methods
  async createOrder(data: any) {
    return this.request('/orders', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async getOrders() {
    return this.request('/orders');
  }

  async getOrder(id: string) {
    return this.request(`/orders/${id}`);
  }

  // Catalog methods (using admin endpoints - may need public endpoints later)
  async getBrands() {
    return this.request('/admin/brands');
  }

  async getCategories() {
    return this.request('/admin/categories');
  }
}

export const apiClient = new ApiClient();
export default apiClient;
