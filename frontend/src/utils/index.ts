import { WorkflowStage } from '@/types';

// Theme configuration for AdmasAfroLink
export const theme = {
  colors: {
    primary: {
      belgianBlue: '#003366',
      ugandaGold: '#FCDC00',
      main: '#003366',
      light: '#4d6b99',
      dark: '#001a33',
    },
    secondary: {
      main: '#FCDC00',
      light: '#ffeb33',
      dark: '#c7a900',
    },
    success: '#28A745',
    warning: '#FD7E14',
    error: '#DC3545',
    info: '#17A2B8',
    grey: {
      50: '#F8F9FA',
      100: '#E9ECEF',
      200: '#DEE2E6',
      300: '#CED4DA',
      400: '#ADB5BD',
      500: '#6C757D',
      600: '#495057',
      700: '#343A40',
      800: '#212529',
      900: '#000000',
    },
  },
  typography: {
    fontFamily: {
      heading: 'Poppins, sans-serif',
      body: 'Inter, sans-serif',
      mono: 'Fira Code, monospace',
    },
    fontSize: {
      xs: '0.75rem',
      sm: '0.875rem',
      base: '1rem',
      lg: '1.125rem',
      xl: '1.25rem',
      '2xl': '1.5rem',
      '3xl': '1.875rem',
      '4xl': '2.25rem',
      '5xl': '3rem',
    },
  },
  spacing: {
    xs: '0.25rem',
    sm: '0.5rem',
    md: '1rem',
    lg: '1.5rem',
    xl: '2rem',
    '2xl': '3rem',
    '3xl': '4rem',
  },
  borderRadius: {
    sm: '0.25rem',
    md: '0.375rem',
    lg: '0.5rem',
    xl: '0.75rem',
    '2xl': '1rem',
    full: '9999px',
  },
  shadows: {
    sm: '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
    md: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
    lg: '0 10px 15px -3px rgba(0, 0, 0, 0.1)',
    xl: '0 20px 25px -5px rgba(0, 0, 0, 0.1)',
  },
  breakpoints: {
    xs: '0px',
    sm: '600px',
    md: '960px',
    lg: '1280px',
    xl: '1920px',
  },
};

// Workflow stages configuration
export const WORKFLOW_STAGES: WorkflowStage[] = [
  {
    id: 1,
    name: 'New Application',
    status: 'pending',
    nextAction: 'Complete your application form',
    estimatedDuration: '1-2 days',
    description: 'Initial application submission',
    requirements: ['Personal information', 'Academic details', 'Contact information'],
  },
  {
    id: 2,
    name: 'Document Verification',
    status: 'pending',
    nextAction: 'Upload required documents',
    estimatedDuration: '3-5 days',
    description: 'Upload and verify all required documents',
    requirements: ['CV/Resume', 'Academic transcripts', 'Passport copy', 'Insurance documents'],
  },
  {
    id: 3,
    name: 'Belgian University Pre-approval',
    status: 'pending',
    nextAction: 'Wait for university coordinator approval',
    estimatedDuration: '5-7 days',
    description: 'Belgian university reviews and approves application',
    requirements: ['Academic eligibility', 'Program alignment', 'Credit requirements'],
  },
  {
    id: 4,
    name: 'Visa Processing',
    status: 'pending',
    nextAction: 'Submit visa application',
    estimatedDuration: '2-4 weeks',
    description: 'Apply for Uganda entry visa',
    requirements: ['Visa application form', 'Supporting documents', 'Medical certificates'],
  },
  {
    id: 5,
    name: 'Immigration Clearance',
    status: 'pending',
    nextAction: 'Await immigration approval',
    estimatedDuration: '1-2 weeks',
    description: 'Immigration authorities review application',
    requirements: ['Visa approval', 'Travel documents', 'Health clearance'],
  },
  {
    id: 6,
    name: 'Company Review',
    status: 'pending',
    nextAction: 'Company reviews your application',
    estimatedDuration: '1-2 weeks',
    description: 'Host company evaluates application',
    requirements: ['Skills assessment', 'Cultural fit evaluation', 'Position availability'],
  },
  {
    id: 7,
    name: 'Interview Scheduled',
    status: 'pending',
    nextAction: 'Prepare for your interview',
    estimatedDuration: '3-5 days',
    description: 'Interview scheduled with host company',
    requirements: ['Interview preparation', 'Technical setup', 'Cultural briefing'],
  },
  {
    id: 8,
    name: 'Interview Completed',
    status: 'pending',
    nextAction: 'Await interview results',
    estimatedDuration: '3-5 days',
    description: 'Interview completed, awaiting decision',
    requirements: ['Interview performance', 'Company evaluation', 'Feedback collection'],
  },
  {
    id: 9,
    name: 'Final Selection',
    status: 'pending',
    nextAction: 'Company makes final decision',
    estimatedDuration: '5-7 days',
    description: 'Final selection decision by company',
    requirements: ['Interview results', 'References check', 'Final approval'],
  },
  {
    id: 10,
    name: 'Placement Confirmed',
    status: 'pending',
    nextAction: 'Review placement terms',
    estimatedDuration: '2-3 days',
    description: 'Internship placement confirmed',
    requirements: ['Placement agreement', 'Terms acceptance', 'Start date confirmation'],
  },
  {
    id: 11,
    name: 'Contract Signed',
    status: 'pending',
    nextAction: 'Sign internship contract',
    estimatedDuration: '1-2 days',
    description: 'Legal contract signed by all parties',
    requirements: ['Contract review', 'Digital signature', 'Legal compliance'],
  },
  {
    id: 12,
    name: 'Pre-Departure Orientation',
    status: 'pending',
    nextAction: 'Complete orientation program',
    estimatedDuration: '1 week',
    description: 'Pre-departure preparation and orientation',
    requirements: ['Cultural training', 'Safety briefing', 'Travel preparation'],
  },
  {
    id: 13,
    name: 'Arrival & Immigration',
    status: 'pending',
    nextAction: 'Complete arrival procedures',
    estimatedDuration: '1-2 days',
    description: 'Arrival in Uganda and immigration processing',
    requirements: ['Airport pickup', 'Immigration clearance', 'Accommodation setup'],
  },
  {
    id: 14,
    name: 'Onboarding Started',
    status: 'pending',
    nextAction: 'Begin company onboarding',
    estimatedDuration: '1 week',
    description: 'Company onboarding and orientation',
    requirements: ['Company orientation', 'Team introduction', 'System access'],
  },
  {
    id: 15,
    name: 'Cultural Integration',
    status: 'pending',
    nextAction: 'Participate in cultural activities',
    estimatedDuration: '2-4 weeks',
    description: 'Cultural integration and adaptation',
    requirements: ['Cultural activities', 'Language practice', 'Local connections'],
  },
  {
    id: 16,
    name: 'Performance Monitoring',
    status: 'pending',
    nextAction: 'Regular performance reviews',
    estimatedDuration: 'Ongoing',
    description: 'Ongoing performance tracking and evaluation',
    requirements: ['Regular check-ins', 'Performance metrics', 'Feedback sessions'],
  },
];

// Utility functions
export const formatDate = (date: string | Date): string => {
  const dateObj = typeof date === 'string' ? new Date(date) : date;
  return dateObj.toLocaleDateString('en-GB', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  });
};

export const formatDateTime = (date: string | Date): string => {
  const dateObj = typeof date === 'string' ? new Date(date) : date;
  return dateObj.toLocaleString('en-GB', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
};

export const getTimeAgo = (date: string | Date): string => {
  const now = new Date();
  const dateObj = typeof date === 'string' ? new Date(date) : date;
  const diffInMs = now.getTime() - dateObj.getTime();
  const diffInMinutes = Math.floor(diffInMs / (1000 * 60));
  const diffInHours = Math.floor(diffInMinutes / 60);
  const diffInDays = Math.floor(diffInHours / 24);

  if (diffInMinutes < 1) return 'Just now';
  if (diffInMinutes < 60) return `${diffInMinutes}m ago`;
  if (diffInHours < 24) return `${diffInHours}h ago`;
  if (diffInDays < 7) return `${diffInDays}d ago`;
  return formatDate(dateObj);
};

export const getStatusColor = (status: string): string => {
  switch (status) {
    case 'completed':
      return theme.colors.success;
    case 'in_progress':
      return theme.colors.info;
    case 'pending':
      return theme.colors.warning;
    case 'blocked':
    case 'rejected':
      return theme.colors.error;
    default:
      return theme.colors.grey[500];
  }
};

export const getStageProgress = (currentStageId: number): number => {
  return Math.round((currentStageId / WORKFLOW_STAGES.length) * 100);
};

export const truncateText = (text: string, maxLength: number): string => {
  if (text.length <= maxLength) return text;
  return text.slice(0, maxLength) + '...';
};

export const validateEmail = (email: string): boolean => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

export const validatePhone = (phone: string): boolean => {
  const phoneRegex = /^[\+]?[1-9][\d]{0,15}$/;
  return phoneRegex.test(phone.replace(/\s/g, ''));
};

export const formatFileSize = (bytes: number): string => {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

export const getFileExtension = (filename: string): string => {
  return filename.slice((filename.lastIndexOf('.') - 1 >>> 0) + 2);
};

export const isImageFile = (filename: string): boolean => {
  const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
  return imageExtensions.indexOf(getFileExtension(filename).toLowerCase()) !== -1;
};

export const isPdfFile = (filename: string): boolean => {
  return getFileExtension(filename).toLowerCase() === 'pdf';
};

export const debounce = <T extends (...args: any[]) => any>(
  func: T,
  delay: number
): ((...args: Parameters<T>) => void) => {
  let timeoutId: number;
  return (...args: Parameters<T>) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => func(...args), delay);
  };
};

export const generateUniqueId = (): string => {
  return Date.now().toString(36) + Math.random().toString(36).substr(2);
};

export const copyToClipboard = async (text: string): Promise<boolean> => {
  try {
    await navigator.clipboard.writeText(text);
    return true;
  } catch (err) {
    console.error('Failed to copy to clipboard:', err);
    return false;
  }
};

export const downloadFile = (url: string, filename: string): void => {
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};

// Local storage utilities
export const storage = {
  get: <T>(key: string): T | null => {
    try {
      const item = localStorage.getItem(key);
      return item ? JSON.parse(item) : null;
    } catch (error) {
      console.error('Error reading from localStorage:', error);
      return null;
    }
  },
  set: <T>(key: string, value: T): void => {
    try {
      localStorage.setItem(key, JSON.stringify(value));
    } catch (error) {
      console.error('Error writing to localStorage:', error);
    }
  },
  remove: (key: string): void => {
    try {
      localStorage.removeItem(key);
    } catch (error) {
      console.error('Error removing from localStorage:', error);
    }
  },
  clear: (): void => {
    try {
      localStorage.clear();
    } catch (error) {
      console.error('Error clearing localStorage:', error);
    }
  },
};

// Time zone utilities for Belgium-Uganda coordination
export const timeZones = {
  belgium: 'Europe/Brussels',
  uganda: 'Africa/Kampala',
};

export const convertTimeZone = (date: Date, targetTimeZone: string): Date => {
  return new Date(date.toLocaleString('en-US', { timeZone: targetTimeZone }));
};

export const formatTimeForBothZones = (date: Date): string => {
  const belgiumTime = convertTimeZone(date, timeZones.belgium);
  const ugandaTime = convertTimeZone(date, timeZones.uganda);
  
  return `${formatDateTime(belgiumTime)} (Belgium) / ${formatDateTime(ugandaTime)} (Uganda)`;
};

// Cultural sensitivity helpers
export const culturalHelpers = {
  getGreeting: (timeOfDay: 'morning' | 'afternoon' | 'evening'): { en: string; fr: string } => {
    const greetings = {
      morning: { en: 'Good morning', fr: 'Bonjour' },
      afternoon: { en: 'Good afternoon', fr: 'Bon après-midi' },
      evening: { en: 'Good evening', fr: 'Bonsoir' },
    };
    return greetings[timeOfDay];
  },
  
  getBusinessHours: (country: 'belgium' | 'uganda'): string => {
    if (country === 'belgium') {
      return '9:00 AM - 5:00 PM (CET)';
    }
    return '8:00 AM - 5:00 PM (EAT)';
  },
  
  getCurrency: (country: 'belgium' | 'uganda'): { code: string; symbol: string } => {
    if (country === 'belgium') {
      return { code: 'EUR', symbol: '€' };
    }
    return { code: 'UGX', symbol: 'USh' };
  },
};

export default {
  theme,
  WORKFLOW_STAGES,
  formatDate,
  formatDateTime,
  getTimeAgo,
  getStatusColor,
  getStageProgress,
  truncateText,
  validateEmail,
  validatePhone,
  formatFileSize,
  debounce,
  storage,
  culturalHelpers,
};
