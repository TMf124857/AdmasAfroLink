/**
 * AdmasAfroLink API Service - Unified Frontend-Backend Integration
 * Handles all API communications for both website and app
 */

class AdmasAfroLinkAPI {
  constructor() {
    // Dynamic API URL based on environment
    this.baseURL = this.getApiUrl();
    this.endpoints = {
      // Authentication
      auth: {
        login: '/api/auth/login',
        register: '/api/auth/register',
        refresh: '/api/auth/refresh',
        logout: '/api/auth/logout',
        forgotPassword: '/api/auth/forgot-password',
        resetPassword: '/api/auth/reset-password',
        verify: '/api/auth/verify-email'
      },
      
      // User Management
      users: {
        profile: '/api/users/profile',
        update: '/api/users/update',
        delete: '/api/users/delete',
        preferences: '/api/users/preferences'
      },
      
      // Applications
      applications: {
        submit: '/api/applications',
        list: '/api/applications',
        get: '/api/applications/{id}',
        update: '/api/applications/{id}',
        status: '/api/applications/{id}/status',
        documents: '/api/applications/{id}/documents'
      },
      
      // Internship Programs
      programs: {
        list: '/api/programs',
        get: '/api/programs/{id}',
        search: '/api/programs/search',
        fields: '/api/programs/fields',
        requirements: '/api/programs/{id}/requirements'
      },
      
      // Team & Organization
      team: {
        members: '/api/team/members',
        structure: '/api/team/structure',
        contact: '/api/team/contact'
      },
      
      // Analytics & Tracking
      analytics: {
        track: '/api/analytics/track',
        conversion: '/api/analytics/conversion',
        engagement: '/api/analytics/engagement'
      },
      
      // File Management
      files: {
        upload: '/api/files/upload',
        download: '/api/files/{id}',
        delete: '/api/files/{id}'
      },
      
      // Contact & Communication
      contact: {
        submit: '/api/contact/submit',
        newsletter: '/api/contact/newsletter',
        chat: '/api/contact/chat'
      }
    };
    
    this.init();
  }

  getApiUrl() {
    // Check if we're in a containerized environment
    if (typeof window !== 'undefined') {
      // Browser environment
      const hostname = window.location.hostname;
      
      if (hostname === 'localhost' || hostname === '127.0.0.1') {
        // Local development
        return 'http://localhost:7001';
      } else if (hostname.includes('docker') || hostname.includes('container')) {
        // Docker environment
        return 'http://admasafrolink-api:8080';
      } else {
        // Production environment
        return 'https://api.admasafrolink.com';
      }
    } else {
      // Node.js environment (SSR)
      return process.env.NEXT_PUBLIC_API_URL || 'http://localhost:7001';
    }
  }

  init() {
    this.setupDefaults();
    this.setupInterceptors();
  }

  setupDefaults() {
    this.defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
  }

  setupInterceptors() {
    // Add auth token to requests if available
    this.addAuthInterceptor();
    
    // Handle response errors globally
    this.addResponseInterceptor();
  }

  addAuthInterceptor() {
    const token = this.getAuthToken();
    if (token) {
      this.defaultHeaders['Authorization'] = `Bearer ${token}`;
    }
  }

  addResponseInterceptor() {
    // This will be handled in the request method
  }

  getAuthToken() {
    if (typeof window !== 'undefined') {
      return localStorage.getItem('admasafrolink_token') || 
             sessionStorage.getItem('admasafrolink_token');
    }
    return null;
  }

  setAuthToken(token, remember = false) {
    if (typeof window !== 'undefined') {
      const storage = remember ? localStorage : sessionStorage;
      storage.setItem('admasafrolink_token', token);
      this.defaultHeaders['Authorization'] = `Bearer ${token}`;
    }
  }

  removeAuthToken() {
    if (typeof window !== 'undefined') {
      localStorage.removeItem('admasafrolink_token');
      sessionStorage.removeItem('admasafrolink_token');
      delete this.defaultHeaders['Authorization'];
    }
  }

  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    const config = {
      method: 'GET',
      headers: { ...this.defaultHeaders },
      ...options
    };

    // Add body if provided
    if (options.body && typeof options.body === 'object') {
      config.body = JSON.stringify(options.body);
    }

    try {
      console.log(`API Request: ${config.method} ${url}`);
      
      const response = await fetch(url, config);
      
      // Handle response
      if (!response.ok) {
        await this.handleErrorResponse(response);
      }

      // Parse response
      const contentType = response.headers.get('content-type');
      let data;
      
      if (contentType && contentType.includes('application/json')) {
        data = await response.json();
      } else {
        data = await response.text();
      }

      console.log(`API Response: ${response.status}`, data);
      return data;

    } catch (error) {
      console.error(`API Error: ${config.method} ${url}`, error);
      throw this.handleNetworkError(error);
    }
  }

  async handleErrorResponse(response) {
    const contentType = response.headers.get('content-type');
    let errorData;
    
    if (contentType && contentType.includes('application/json')) {
      errorData = await response.json();
    } else {
      errorData = { message: await response.text() };
    }

    // Handle specific error cases
    switch (response.status) {
      case 401:
        this.removeAuthToken();
        if (typeof window !== 'undefined') {
          window.location.href = '/login';
        }
        break;
      case 403:
        throw new Error('Access denied. You do not have permission to perform this action.');
      case 404:
        throw new Error('The requested resource was not found.');
      case 500:
        throw new Error('Server error. Please try again later.');
      default:
        throw new Error(errorData.message || `HTTP ${response.status}: ${response.statusText}`);
    }
  }

  handleNetworkError(error) {
    if (error.name === 'TypeError' && error.message.includes('fetch')) {
      return new Error('Network error. Please check your internet connection and try again.');
    }
    return error;
  }

  // ==========================================
  // Authentication Methods
  // ==========================================

  async login(email, password, remember = false) {
    const response = await this.request(this.endpoints.auth.login, {
      method: 'POST',
      body: { email, password }
    });
    
    if (response.token) {
      this.setAuthToken(response.token, remember);
    }
    
    return response;
  }

  async register(userData) {
    return await this.request(this.endpoints.auth.register, {
      method: 'POST',
      body: userData
    });
  }

  async logout() {
    try {
      await this.request(this.endpoints.auth.logout, {
        method: 'POST'
      });
    } finally {
      this.removeAuthToken();
    }
  }

  async refreshToken() {
    const response = await this.request(this.endpoints.auth.refresh, {
      method: 'POST'
    });
    
    if (response.token) {
      this.setAuthToken(response.token);
    }
    
    return response;
  }

  // ==========================================
  // Application Methods
  // ==========================================

  async submitApplication(applicationData) {
    return await this.request(this.endpoints.applications.submit, {
      method: 'POST',
      body: applicationData
    });
  }

  async getApplications(userId = null) {
    const endpoint = userId ? 
      `${this.endpoints.applications.list}?userId=${userId}` : 
      this.endpoints.applications.list;
    
    return await this.request(endpoint);
  }

  async getApplication(id) {
    const endpoint = this.endpoints.applications.get.replace('{id}', id);
    return await this.request(endpoint);
  }

  async updateApplicationStatus(id, status, notes = '') {
    const endpoint = this.endpoints.applications.status.replace('{id}', id);
    return await this.request(endpoint, {
      method: 'PUT',
      body: { status, notes }
    });
  }

  // ==========================================
  // Program Methods
  // ==========================================

  async getPrograms() {
    return await this.request(this.endpoints.programs.list);
  }

  async getProgram(id) {
    const endpoint = this.endpoints.programs.get.replace('{id}', id);
    return await this.request(endpoint);
  }

  async searchPrograms(criteria) {
    return await this.request(this.endpoints.programs.search, {
      method: 'POST',
      body: criteria
    });
  }

  async getProgramFields() {
    return await this.request(this.endpoints.programs.fields);
  }

  // ==========================================
  // Team Methods
  // ==========================================

  async getTeamMembers() {
    return await this.request(this.endpoints.team.members);
  }

  async getOrganizationStructure() {
    return await this.request(this.endpoints.team.structure);
  }

  // ==========================================
  // File Upload Methods
  // ==========================================

  async uploadFile(file, metadata = {}) {
    const formData = new FormData();
    formData.append('file', file);
    
    Object.keys(metadata).forEach(key => {
      formData.append(key, metadata[key]);
    });

    const headers = { ...this.defaultHeaders };
    delete headers['Content-Type']; // Let browser set it for FormData

    return await this.request(this.endpoints.files.upload, {
      method: 'POST',
      headers,
      body: formData
    });
  }

  async downloadFile(id) {
    const endpoint = this.endpoints.files.download.replace('{id}', id);
    const response = await fetch(`${this.baseURL}${endpoint}`, {
      headers: this.defaultHeaders
    });
    
    if (!response.ok) {
      throw new Error('Failed to download file');
    }
    
    return response.blob();
  }

  // ==========================================
  // Analytics Methods
  // ==========================================

  async trackEvent(eventName, properties = {}) {
    try {
      await this.request(this.endpoints.analytics.track, {
        method: 'POST',
        body: {
          event: eventName,
          properties: {
            ...properties,
            timestamp: new Date().toISOString(),
            url: typeof window !== 'undefined' ? window.location.href : '',
            userAgent: typeof navigator !== 'undefined' ? navigator.userAgent : ''
          }
        }
      });
    } catch (error) {
      console.warn('Analytics tracking failed:', error);
    }
  }

  async trackConversion(type, value = 0) {
    try {
      await this.request(this.endpoints.analytics.conversion, {
        method: 'POST',
        body: {
          type,
          value,
          timestamp: new Date().toISOString()
        }
      });
    } catch (error) {
      console.warn('Conversion tracking failed:', error);
    }
  }

  // ==========================================
  // Contact Methods
  // ==========================================

  async submitContactForm(contactData) {
    return await this.request(this.endpoints.contact.submit, {
      method: 'POST',
      body: contactData
    });
  }

  async subscribeNewsletter(email) {
    return await this.request(this.endpoints.contact.newsletter, {
      method: 'POST',
      body: { email }
    });
  }

  // ==========================================
  // Utility Methods
  // ==========================================

  async healthCheck() {
    try {
      const response = await fetch(`${this.baseURL}/api/health`);
      return response.ok;
    } catch (error) {
      return false;
    }
  }

  async getServerInfo() {
    return await this.request('/api/info');
  }
}

// Create singleton instance
const apiService = new AdmasAfroLinkAPI();

// Export for use in modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = apiService;
}

// Make available globally in browser
if (typeof window !== 'undefined') {
  window.AdmasAfroLinkAPI = apiService;
}

// Export default
window.apiService = apiService;
