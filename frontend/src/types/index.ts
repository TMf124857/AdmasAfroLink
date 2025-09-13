// Core Types for AdmasAfroLink Platform

export interface Student {
  id: string;
  name: string;
  email: string;
  university: string;
  belgianUniversityPartner: string;
  studyProgram: string;
  academicLevel: 'Bachelor' | 'Master' | 'PhD';
  expectedGraduationDate: string;
  academicSupervisorContact: string;
  universityCoordinator: string;
  visaStatus: VisaStatus;
  immigrationDocuments: Document[];
  emergencyContactBelgium: EmergencyContact;
  ectsCreditsRequired: number;
  culturalOrientationStatus: 'not_started' | 'in_progress' | 'completed';
  applicationStage: WorkflowStage;
  documents: Document[];
  profilePhoto?: string;
  languageProficiency: LanguageProficiency;
  skills: string[];
  certifications: string[];
  createdAt: string;
  updatedAt: string;
}

export interface WorkflowStage {
  id: number;
  name: string;
  status: 'pending' | 'in_progress' | 'completed' | 'blocked' | 'rejected';
  nextAction: string;
  estimatedDuration: string;
  description: string;
  requirements: string[];
  completedAt?: string;
  blockedReason?: string;
}

export interface InternshipOpportunity {
  id: string;
  title: string;
  company: Company;
  description: string;
  requirements: string[];
  learningObjectives: string[];
  duration: number; // in months
  startDate: string;
  applicationDeadline: string;
  location: Location;
  academicLevel: string[];
  requiredSkills: string[];
  language: string[];
  compensation?: number;
  benefits: string[];
  culturalConsiderations: string[];
  supervisionDetails: SupervisionDetails;
  applicationCount: number;
  isActive: boolean;
  createdAt: string;
}

export interface Company {
  id: string;
  name: string;
  industry: string;
  size: string;
  description: string;
  location: Location;
  website?: string;
  logo?: string;
  departments: Department[];
  supervisionCapacity: number;
  pastInternFeedback: number; // rating out of 5
  complianceStatus: 'compliant' | 'pending' | 'non_compliant';
  culturalSupport: CulturalSupport;
  safetyMeasures: string[];
}

export interface Application {
  id: string;
  studentId: string;
  opportunityId: string;
  currentStage: WorkflowStage;
  submittedAt: string;
  lastUpdated: string;
  motivationLetter: string;
  documents: Document[];
  interviewScheduled?: Interview;
  feedback: Feedback[];
  timeline: TimelineEvent[];
  priority: 'low' | 'medium' | 'high';
  notes: string;
}

export interface Document {
  id: string;
  name: string;
  type: DocumentType;
  fileUrl: string;
  uploadedAt: string;
  status: 'uploaded' | 'verified' | 'rejected';
  verificationNotes?: string;
  isRequired: boolean;
  category: 'student' | 'legal' | 'evaluation';
}

export interface Interview {
  id: string;
  scheduledAt: string;
  duration: number; // in minutes
  type: 'video' | 'phone' | 'in_person';
  interviewerName: string;
  interviewerEmail: string;
  meetingLink?: string;
  notes?: string;
  feedback?: InterviewFeedback;
  status: 'scheduled' | 'completed' | 'cancelled' | 'rescheduled';
}

export interface Location {
  city: string;
  region: string;
  country: string;
  coordinates?: {
    lat: number;
    lng: number;
  };
  timeZone: string;
  safetyRating: number; // 1-5 scale
}

export interface Notification {
  id: string;
  title: string;
  message: string;
  type: 'info' | 'success' | 'warning' | 'error';
  read: boolean;
  createdAt: string;
  actionUrl?: string;
  priority: 'low' | 'medium' | 'high';
}

export interface ChatMessage {
  id: string;
  senderId: string;
  senderName: string;
  message: string;
  timestamp: string;
  channelId: string;
  type: 'text' | 'file' | 'system';
  fileUrl?: string;
  isTranslated?: boolean;
  originalLanguage?: string;
}

export interface ChatChannel {
  id: string;
  name: string;
  type: 'private' | 'group' | 'official';
  participants: Participant[];
  lastMessage?: ChatMessage;
  unreadCount: number;
  createdAt: string;
}

// Supporting Types
export interface VisaStatus {
  status: 'not_applied' | 'applied' | 'approved' | 'rejected' | 'expired';
  applicationDate?: string;
  approvalDate?: string;
  expiryDate?: string;
  visaNumber?: string;
}

export interface EmergencyContact {
  name: string;
  relationship: string;
  phone: string;
  email: string;
  address: string;
}

export interface LanguageProficiency {
  english: 'beginner' | 'intermediate' | 'advanced' | 'native';
  french: 'beginner' | 'intermediate' | 'advanced' | 'native';
  luganda?: 'beginner' | 'intermediate' | 'advanced' | 'native';
  other?: {
    language: string;
    level: 'beginner' | 'intermediate' | 'advanced' | 'native';
  }[];
}

export interface Department {
  id: string;
  name: string;
  description: string;
  headOfDepartment: string;
  availablePositions: number;
}

export interface SupervisionDetails {
  supervisorName: string;
  supervisorTitle: string;
  supervisorEmail: string;
  supervisionStyle: string;
  meetingFrequency: string;
  evaluationCriteria: string[];
}

export interface CulturalSupport {
  orientationProgram: boolean;
  mentorAssignment: boolean;
  languageSupport: boolean;
  culturalActivities: boolean;
  accommodationAssistance: boolean;
}

export interface Feedback {
  id: string;
  fromId: string;
  fromName: string;
  message: string;
  rating?: number;
  category: 'academic' | 'cultural' | 'technical' | 'general';
  createdAt: string;
}

export interface InterviewFeedback {
  technicalSkills: number; // 1-5 rating
  communicationSkills: number;
  culturalFit: number;
  motivation: number;
  overallRating: number;
  comments: string;
  recommendation: 'proceed' | 'reject' | 'reconsider';
}

export interface TimelineEvent {
  id: string;
  title: string;
  description: string;
  timestamp: string;
  type: 'milestone' | 'action' | 'update' | 'issue';
  actor: string;
}

export interface Participant {
  id: string;
  name: string;
  role: 'student' | 'coordinator' | 'supervisor' | 'admin';
  avatar?: string;
  isOnline: boolean;
}

export type DocumentType =
  | 'cv'
  | 'transcript'
  | 'recommendation_letter'
  | 'portfolio'
  | 'passport'
  | 'visa'
  | 'insurance'
  | 'contract'
  | 'nda'
  | 'consent_form'
  | 'performance_review'
  | 'academic_report'
  | 'completion_certificate';

// API Response Types
export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
  errors?: string[];
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

// Form Types
export interface StudentRegistrationForm {
  personalInfo: {
    firstName: string;
    lastName: string;
    email: string;
    phone: string;
    dateOfBirth: string;
    nationality: string;
  };
  academicInfo: {
    university: string;
    belgianUniversityPartner: string;
    studyProgram: string;
    academicLevel: string;
    expectedGraduationDate: string;
    gpa?: number;
  };
  contactInfo: {
    emergencyContactBelgium: EmergencyContact;
    currentAddress: string;
  };
  preferences: {
    preferredIndustries: string[];
    preferredLocations: string[];
    internshipDuration: number;
    startDate: string;
  };
}

export interface ApplicationForm {
  opportunityId: string;
  motivationLetter: string;
  availabilityDate: string;
  additionalNotes?: string;
  documents: File[];
}

// Filter and Search Types
export interface OpportunityFilters {
  industry?: string[];
  location?: string[];
  duration?: [number, number]; // min, max months
  academicLevel?: string[];
  startDate?: string;
  company?: string[];
  skills?: string[];
}

export interface SearchParams {
  query?: string;
  filters?: OpportunityFilters;
  sortBy?: 'relevance' | 'date' | 'company' | 'location';
  sortOrder?: 'asc' | 'desc';
  page?: number;
  limit?: number;
}

// Dashboard Analytics Types
export interface DashboardStats {
  totalApplications: number;
  activeApplications: number;
  completedStages: number;
  averageProcessingTime: number; // in days
  upcomingDeadlines: number;
  placementRate: number; // percentage
}

export interface ProgressMetrics {
  applicationProgress: number; // percentage
  documentCompletionRate: number;
  interviewSuccessRate: number;
  culturalIntegrationScore: number;
  overallScore: number;
}
