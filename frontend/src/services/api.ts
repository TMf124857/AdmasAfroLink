import axios, { AxiosInstance, AxiosResponse } from 'axios';
import { 
  Student, 
  InternshipOpportunity, 
  Application, 
  ApiResponse, 
  PaginatedResponse,
  StudentRegistrationForm,
  ApplicationForm,
  SearchParams,
  DashboardStats,
  Notification,
  ChatMessage,
  ChatChannel,
  Document
} from '@/types';

// API Configuration
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

// Axios instance with default configuration
const apiClient: AxiosInstance = axios.create({
  baseURL: `${API_BASE_URL}/api/v1`,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('authToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor for error handling
apiClient.interceptors.response.use(
  (response: AxiosResponse) => {
    return response;
  },
  (error) => {
    if (error.response?.status === 401) {
      // Handle unauthorized access
      localStorage.removeItem('authToken');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Authentication Service
export const authService = {
  async login(email: string, password: string): Promise<ApiResponse<{ token: string; user: Student }>> {
    const response = await apiClient.post('/auth/login', { email, password });
    return response.data;
  },

  async register(data: StudentRegistrationForm): Promise<ApiResponse<{ token: string; user: Student }>> {
    const response = await apiClient.post('/auth/register', data);
    return response.data;
  },

  async logout(): Promise<ApiResponse<null>> {
    const response = await apiClient.post('/auth/logout');
    localStorage.removeItem('authToken');
    return response.data;
  },

  async forgotPassword(email: string): Promise<ApiResponse<null>> {
    const response = await apiClient.post('/auth/forgot-password', { email });
    return response.data;
  },

  async resetPassword(token: string, newPassword: string): Promise<ApiResponse<null>> {
    const response = await apiClient.post('/auth/reset-password', { token, newPassword });
    return response.data;
  },

  async verifyEmail(token: string): Promise<ApiResponse<null>> {
    const response = await apiClient.post('/auth/verify-email', { token });
    return response.data;
  },

  async refreshToken(): Promise<ApiResponse<{ token: string }>> {
    const response = await apiClient.post('/auth/refresh');
    return response.data;
  },
};

// Student Service
export const studentService = {
  async getProfile(): Promise<ApiResponse<Student>> {
    const response = await apiClient.get('/students/profile');
    return response.data;
  },

  async updateProfile(data: Partial<Student>): Promise<ApiResponse<Student>> {
    const response = await apiClient.put('/students/profile', data);
    return response.data;
  },

  async uploadProfilePhoto(file: File): Promise<ApiResponse<{ photoUrl: string }>> {
    const formData = new FormData();
    formData.append('photo', file);
    const response = await apiClient.post('/students/profile/photo', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },

  async getDashboardStats(): Promise<ApiResponse<DashboardStats>> {
    const response = await apiClient.get('/students/dashboard');
    return response.data;
  },

  async getApplicationTimeline(applicationId: string): Promise<ApiResponse<any[]>> {
    const response = await apiClient.get(`/students/applications/${applicationId}/timeline`);
    return response.data;
  },
};

// Opportunities Service
export const opportunitiesService = {
  async getOpportunities(params?: SearchParams): Promise<PaginatedResponse<InternshipOpportunity>> {
    const response = await apiClient.get('/opportunities', { params });
    return response.data;
  },

  async getOpportunity(id: string): Promise<ApiResponse<InternshipOpportunity>> {
    const response = await apiClient.get(`/opportunities/${id}`);
    return response.data;
  },

  async searchOpportunities(query: string, filters?: any): Promise<PaginatedResponse<InternshipOpportunity>> {
    const response = await apiClient.post('/opportunities/search', { query, filters });
    return response.data;
  },

  async getRecommendedOpportunities(): Promise<ApiResponse<InternshipOpportunity[]>> {
    const response = await apiClient.get('/opportunities/recommended');
    return response.data;
  },

  async saveOpportunity(opportunityId: string): Promise<ApiResponse<null>> {
    const response = await apiClient.post(`/opportunities/${opportunityId}/save`);
    return response.data;
  },

  async unsaveOpportunity(opportunityId: string): Promise<ApiResponse<null>> {
    const response = await apiClient.delete(`/opportunities/${opportunityId}/save`);
    return response.data;
  },

  async getSavedOpportunities(): Promise<ApiResponse<InternshipOpportunity[]>> {
    const response = await apiClient.get('/opportunities/saved');
    return response.data;
  },
};

// Applications Service
export const applicationsService = {
  async getApplications(): Promise<ApiResponse<Application[]>> {
    const response = await apiClient.get('/applications');
    return response.data;
  },

  async getApplication(id: string): Promise<ApiResponse<Application>> {
    const response = await apiClient.get(`/applications/${id}`);
    return response.data;
  },

  async createApplication(data: ApplicationForm): Promise<ApiResponse<Application>> {
    const formData = new FormData();
    Object.keys(data).forEach(key => {
      if (key === 'documents') {
        data.documents.forEach((file, index) => {
          formData.append(`documents[${index}]`, file);
        });
      } else {
        formData.append(key, (data as any)[key]);
      }
    });

    const response = await apiClient.post('/applications', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },

  async updateApplication(id: string, data: Partial<ApplicationForm>): Promise<ApiResponse<Application>> {
    const response = await apiClient.put(`/applications/${id}`, data);
    return response.data;
  },

  async withdrawApplication(id: string): Promise<ApiResponse<null>> {
    const response = await apiClient.post(`/applications/${id}/withdraw`);
    return response.data;
  },

  async getApplicationStatus(id: string): Promise<ApiResponse<{ stage: any; progress: number }>> {
    const response = await apiClient.get(`/applications/${id}/status`);
    return response.data;
  },
};

// Documents Service
export const documentsService = {
  async uploadDocument(file: File, type: string, applicationId?: string): Promise<ApiResponse<Document>> {
    const formData = new FormData();
    formData.append('document', file);
    formData.append('type', type);
    if (applicationId) {
      formData.append('applicationId', applicationId);
    }

    const response = await apiClient.post('/documents', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
      onUploadProgress: (progressEvent) => {
        const progress = progressEvent.total 
          ? Math.round((progressEvent.loaded * 100) / progressEvent.total)
          : 0;
        // You can emit progress events here if needed
        console.log(`Upload progress: ${progress}%`);
      },
    });
    return response.data;
  },

  async getDocuments(): Promise<ApiResponse<Document[]>> {
    const response = await apiClient.get('/documents');
    return response.data;
  },

  async getDocument(id: string): Promise<ApiResponse<Document>> {
    const response = await apiClient.get(`/documents/${id}`);
    return response.data;
  },

  async deleteDocument(id: string): Promise<ApiResponse<null>> {
    const response = await apiClient.delete(`/documents/${id}`);
    return response.data;
  },

  async downloadDocument(id: string): Promise<Blob> {
    const response = await apiClient.get(`/documents/${id}/download`, {
      responseType: 'blob',
    });
    return response.data;
  },

  async getDocumentPreview(id: string): Promise<string> {
    const response = await apiClient.get(`/documents/${id}/preview`);
    return response.data.previewUrl;
  },
};

// Interviews Service
export const interviewsService = {
  async getInterviews(): Promise<ApiResponse<any[]>> {
    const response = await apiClient.get('/interviews');
    return response.data;
  },

  async scheduleInterview(applicationId: string, dateTime: string, type: string): Promise<ApiResponse<any>> {
    const response = await apiClient.post('/interviews/schedule', {
      applicationId,
      dateTime,
      type,
    });
    return response.data;
  },

  async rescheduleInterview(interviewId: string, newDateTime: string): Promise<ApiResponse<any>> {
    const response = await apiClient.put(`/interviews/${interviewId}/reschedule`, {
      dateTime: newDateTime,
    });
    return response.data;
  },

  async cancelInterview(interviewId: string, reason: string): Promise<ApiResponse<null>> {
    const response = await apiClient.post(`/interviews/${interviewId}/cancel`, { reason });
    return response.data;
  },

  async joinInterview(interviewId: string): Promise<ApiResponse<{ meetingUrl: string }>> {
    const response = await apiClient.post(`/interviews/${interviewId}/join`);
    return response.data;
  },

  async submitInterviewFeedback(interviewId: string, feedback: any): Promise<ApiResponse<null>> {
    const response = await apiClient.post(`/interviews/${interviewId}/feedback`, feedback);
    return response.data;
  },
};

// Notifications Service
export const notificationsService = {
  async getNotifications(): Promise<ApiResponse<Notification[]>> {
    const response = await apiClient.get('/notifications');
    return response.data;
  },

  async markAsRead(notificationId: string): Promise<ApiResponse<null>> {
    const response = await apiClient.put(`/notifications/${notificationId}/read`);
    return response.data;
  },

  async markAllAsRead(): Promise<ApiResponse<null>> {
    const response = await apiClient.put('/notifications/read-all');
    return response.data;
  },

  async deleteNotification(notificationId: string): Promise<ApiResponse<null>> {
    const response = await apiClient.delete(`/notifications/${notificationId}`);
    return response.data;
  },

  async getUnreadCount(): Promise<ApiResponse<{ count: number }>> {
    const response = await apiClient.get('/notifications/unread-count');
    return response.data;
  },
};

// Communication Service
export const communicationService = {
  async getChannels(): Promise<ApiResponse<ChatChannel[]>> {
    const response = await apiClient.get('/communication/channels');
    return response.data;
  },

  async getChannel(channelId: string): Promise<ApiResponse<ChatChannel>> {
    const response = await apiClient.get(`/communication/channels/${channelId}`);
    return response.data;
  },

  async getMessages(channelId: string, page = 1, limit = 50): Promise<PaginatedResponse<ChatMessage>> {
    const response = await apiClient.get(`/communication/channels/${channelId}/messages`, {
      params: { page, limit },
    });
    return response.data;
  },

  async sendMessage(channelId: string, message: string): Promise<ApiResponse<ChatMessage>> {
    const response = await apiClient.post(`/communication/channels/${channelId}/messages`, {
      message,
    });
    return response.data;
  },

  async sendFile(channelId: string, file: File, message?: string): Promise<ApiResponse<ChatMessage>> {
    const formData = new FormData();
    formData.append('file', file);
    if (message) {
      formData.append('message', message);
    }

    const response = await apiClient.post(`/communication/channels/${channelId}/files`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },

  async createChannel(name: string, participants: string[], type: 'private' | 'group'): Promise<ApiResponse<ChatChannel>> {
    const response = await apiClient.post('/communication/channels', {
      name,
      participants,
      type,
    });
    return response.data;
  },
};

// Cultural Integration Service
export const culturalService = {
  async getOrientationModules(): Promise<ApiResponse<any[]>> {
    const response = await apiClient.get('/cultural/orientation-modules');
    return response.data;
  },

  async completeModule(moduleId: string): Promise<ApiResponse<null>> {
    const response = await apiClient.post(`/cultural/modules/${moduleId}/complete`);
    return response.data;
  },

  async getProgress(): Promise<ApiResponse<{ completed: number; total: number; percentage: number }>> {
    const response = await apiClient.get('/cultural/progress');
    return response.data;
  },

  async getCulturalResources(): Promise<ApiResponse<any[]>> {
    const response = await apiClient.get('/cultural/resources');
    return response.data;
  },

  async submitCulturalFeedback(feedback: any): Promise<ApiResponse<null>> {
    const response = await apiClient.post('/cultural/feedback', feedback);
    return response.data;
  },
};

// Settings Service
export const settingsService = {
  async getSettings(): Promise<ApiResponse<any>> {
    const response = await apiClient.get('/settings');
    return response.data;
  },

  async updateSettings(settings: any): Promise<ApiResponse<any>> {
    const response = await apiClient.put('/settings', settings);
    return response.data;
  },

  async updateNotificationPreferences(preferences: any): Promise<ApiResponse<null>> {
    const response = await apiClient.put('/settings/notifications', preferences);
    return response.data;
  },

  async updatePrivacySettings(privacySettings: any): Promise<ApiResponse<null>> {
    const response = await apiClient.put('/settings/privacy', privacySettings);
    return response.data;
  },

  async changePassword(currentPassword: string, newPassword: string): Promise<ApiResponse<null>> {
    const response = await apiClient.put('/settings/password', {
      currentPassword,
      newPassword,
    });
    return response.data;
  },

  async deleteAccount(password: string): Promise<ApiResponse<null>> {
    const response = await apiClient.delete('/settings/account', {
      data: { password },
    });
    return response.data;
  },

  async exportData(): Promise<Blob> {
    const response = await apiClient.get('/settings/export-data', {
      responseType: 'blob',
    });
    return response.data;
  },
};

// Analytics Service
export const analyticsService = {
  async trackEvent(eventName: string, properties?: Record<string, any>): Promise<void> {
    try {
      await apiClient.post('/analytics/events', {
        event: eventName,
        properties,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      console.error('Analytics tracking failed:', error);
    }
  },

  async getInsights(): Promise<ApiResponse<any>> {
    const response = await apiClient.get('/analytics/insights');
    return response.data;
  },
};

// Error handling utility
export const handleApiError = (error: any): string => {
  if (error.response?.data?.message) {
    return error.response.data.message;
  }
  if (error.message) {
    return error.message;
  }
  return 'An unexpected error occurred. Please try again.';
};

// Export all services
export default {
  auth: authService,
  student: studentService,
  opportunities: opportunitiesService,
  applications: applicationsService,
  documents: documentsService,
  interviews: interviewsService,
  notifications: notificationsService,
  communication: communicationService,
  cultural: culturalService,
  settings: settingsService,
  analytics: analyticsService,
  handleApiError,
};
