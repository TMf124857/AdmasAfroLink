import React, { useState } from 'react';
import {
  Box,
  Card,
  CardContent,
  TextField,
  Button,
  Typography,
  Alert,
  Tabs,
  Tab,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Checkbox,
  FormControlLabel,
  Link,
  CircularProgress,
  Divider
} from '@mui/material';
import { Eye, EyeOff, MapPin, User, Mail, Lock, School } from 'lucide-react';
import { useTheme } from '@mui/material/styles';

interface AuthFormProps {
  onLogin: (credentials: LoginCredentials) => Promise<void>;
  onRegister: (userData: RegisterData) => Promise<void>;
  isLoading?: boolean;
}

interface LoginCredentials {
  email: string;
  password: string;
  rememberMe: boolean;
}

interface RegisterData {
  firstName: string;
  lastName: string;
  email: string;
  password: string;
  confirmPassword: string;
  university: string;
  studentId: string;
  fieldOfStudy: string;
  academicYear: string;
  language: 'en' | 'fr';
  agreeToTerms: boolean;
  agreeToPrivacy: boolean;
}

const AuthForm: React.FC<AuthFormProps> = ({ onLogin, onRegister, isLoading = false }) => {
  const theme = useTheme();
  const [tabValue, setTabValue] = useState(0);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  // Login form state
  const [loginData, setLoginData] = useState<LoginCredentials>({
    email: '',
    password: '',
    rememberMe: false
  });

  // Registration form state
  const [registerData, setRegisterData] = useState<RegisterData>({
    firstName: '',
    lastName: '',
    email: '',
    password: '',
    confirmPassword: '',
    university: '',
    studentId: '',
    fieldOfStudy: '',
    academicYear: '',
    language: 'en',
    agreeToTerms: false,
    agreeToPrivacy: false
  });

  const belgianUniversities = [
    'KU Leuven',
    'Ghent University',
    'University of Antwerp',
    'Vrije Universiteit Brussel',
    'Université catholique de Louvain',
    'Université libre de Bruxelles',
    'University of Liège',
    'Hasselt University',
    'University of Mons',
    'Other'
  ];

  const academicYears = [
    'Bachelor 1',
    'Bachelor 2',
    'Bachelor 3',
    'Master 1',
    'Master 2',
    'PhD'
  ];

  const handleTabChange = (event: React.SyntheticEvent, newValue: number) => {
    setTabValue(newValue);
    setError(null);
    setSuccess(null);
  };

  const validateEmail = (email: string): boolean => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };

  const validatePassword = (password: string): boolean => {
    return password.length >= 8;
  };

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (!validateEmail(loginData.email)) {
      setError('Please enter a valid email address');
      return;
    }

    if (!loginData.password) {
      setError('Password is required');
      return;
    }

    try {
      await onLogin(loginData);
      setSuccess('Login successful! Redirecting...');
    } catch (err) {
      setError('Invalid email or password. Please try again.');
    }
  };

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    // Validation
    if (!registerData.firstName || !registerData.lastName) {
      setError('First name and last name are required');
      return;
    }

    if (!validateEmail(registerData.email)) {
      setError('Please enter a valid email address');
      return;
    }

    if (!validatePassword(registerData.password)) {
      setError('Password must be at least 8 characters long');
      return;
    }

    if (registerData.password !== registerData.confirmPassword) {
      setError('Passwords do not match');
      return;
    }

    if (!registerData.university || !registerData.studentId || !registerData.fieldOfStudy) {
      setError('All academic information fields are required');
      return;
    }

    if (!registerData.agreeToTerms || !registerData.agreeToPrivacy) {
      setError('You must agree to the terms and privacy policy');
      return;
    }

    try {
      await onRegister(registerData);
      setSuccess('Registration successful! Please check your email for verification.');
      setTabValue(0); // Switch to login tab
    } catch (err) {
      setError('Registration failed. Please try again or contact support.');
    }
  };

  return (
    <Box
      sx={{
        minHeight: '100vh',
        background: 'linear-gradient(135deg, #003366 0%, #004080 100%)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: 2
      }}
    >
      <Card
        sx={{
          maxWidth: 500,
          width: '100%',
          boxShadow: '0 10px 30px rgba(0, 0, 0, 0.3)'
        }}
      >
        <CardContent sx={{ padding: 4 }}>
          {/* Header */}
          <Box sx={{ textAlign: 'center', mb: 3 }}>
            <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', mb: 2 }}>
              <Box
                sx={{
                  width: 24,
                  height: 16,
                  background: 'linear-gradient(to right, #000 33%, #fcdc00 33%, #fcdc00 66%, #ff0000 66%)',
                  borderRadius: '2px',
                  mr: 1
                }}
              />
              <Box
                sx={{
                  width: 24,
                  height: 16,
                  background: 'linear-gradient(to bottom, #000 16.66%, #fcdc00 16.66%, #fcdc00 33.33%, #ff0000 33.33%, #ff0000 50%, #000 50%, #000 66.66%, #fcdc00 66.66%, #fcdc00 83.33%, #ff0000 83.33%)',
                  borderRadius: '2px'
                }}
              />
            </Box>
            <Typography variant="h4" sx={{ color: '#003366', fontWeight: 'bold', mb: 1 }}>
              AdmasAfroLink
            </Typography>
            <Typography variant="body1" color="text.secondary">
              Belgian-Uganda Student Exchange Platform
            </Typography>
          </Box>

          {/* Alerts */}
          {error && (
            <Alert severity="error" sx={{ mb: 3 }}>
              {error}
            </Alert>
          )}
          {success && (
            <Alert severity="success" sx={{ mb: 3 }}>
              {success}
            </Alert>
          )}

          {/* Tabs */}
          <Tabs
            value={tabValue}
            onChange={handleTabChange}
            variant="fullWidth"
            sx={{ mb: 3 }}
          >
            <Tab label="Login" />
            <Tab label="Register" />
          </Tabs>

          {/* Login Form */}
          {tabValue === 0 && (
            <Box component="form" onSubmit={handleLogin}>
              <TextField
                fullWidth
                label="Email Address"
                type="email"
                value={loginData.email}
                onChange={(e) => setLoginData({ ...loginData, email: e.target.value })}
                InputProps={{
                  startAdornment: <Mail size={20} style={{ marginRight: 8, color: '#666' }} />
                }}
                sx={{ mb: 3 }}
                disabled={isLoading}
              />

              <TextField
                fullWidth
                label="Password"
                type={showPassword ? 'text' : 'password'}
                value={loginData.password}
                onChange={(e) => setLoginData({ ...loginData, password: e.target.value })}
                InputProps={{
                  startAdornment: <Lock size={20} style={{ marginRight: 8, color: '#666' }} />,
                  endAdornment: (
                    <Button
                      onClick={() => setShowPassword(!showPassword)}
                      sx={{ minWidth: 'auto', p: 1 }}
                    >
                      {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                    </Button>
                  )
                }}
                sx={{ mb: 2 }}
                disabled={isLoading}
              />

              <FormControlLabel
                control={
                  <Checkbox
                    checked={loginData.rememberMe}
                    onChange={(e) => setLoginData({ ...loginData, rememberMe: e.target.checked })}
                    disabled={isLoading}
                  />
                }
                label="Remember me"
                sx={{ mb: 3 }}
              />

              <Button
                type="submit"
                fullWidth
                variant="contained"
                size="large"
                disabled={isLoading}
                sx={{
                  backgroundColor: '#003366',
                  '&:hover': { backgroundColor: '#001a33' },
                  mb: 2
                }}
              >
                {isLoading ? <CircularProgress size={24} color="inherit" /> : 'Login'}
              </Button>

              <Box sx={{ textAlign: 'center' }}>
                <Link href="#" color="primary">
                  Forgot your password?
                </Link>
              </Box>
            </Box>
          )}

          {/* Registration Form */}
          {tabValue === 1 && (
            <Box component="form" onSubmit={handleRegister}>
              {/* Personal Information */}
              <Typography variant="h6" sx={{ mb: 2, color: '#003366' }}>
                Personal Information
              </Typography>

              <Box sx={{ display: 'flex', gap: 2, mb: 3 }}>
                <TextField
                  fullWidth
                  label="First Name"
                  value={registerData.firstName}
                  onChange={(e) => setRegisterData({ ...registerData, firstName: e.target.value })}
                  InputProps={{
                    startAdornment: <User size={20} style={{ marginRight: 8, color: '#666' }} />
                  }}
                  disabled={isLoading}
                />
                <TextField
                  fullWidth
                  label="Last Name"
                  value={registerData.lastName}
                  onChange={(e) => setRegisterData({ ...registerData, lastName: e.target.value })}
                  disabled={isLoading}
                />
              </Box>

              <TextField
                fullWidth
                label="Email Address"
                type="email"
                value={registerData.email}
                onChange={(e) => setRegisterData({ ...registerData, email: e.target.value })}
                InputProps={{
                  startAdornment: <Mail size={20} style={{ marginRight: 8, color: '#666' }} />
                }}
                sx={{ mb: 3 }}
                disabled={isLoading}
              />

              <FormControl fullWidth sx={{ mb: 3 }}>
                <InputLabel>Preferred Language</InputLabel>
                <Select
                  value={registerData.language}
                  onChange={(e) => setRegisterData({ ...registerData, language: e.target.value as 'en' | 'fr' })}
                  disabled={isLoading}
                >
                  <MenuItem value="en">English</MenuItem>
                  <MenuItem value="fr">Français</MenuItem>
                </Select>
              </FormControl>

              {/* Academic Information */}
              <Divider sx={{ my: 3 }} />
              <Typography variant="h6" sx={{ mb: 2, color: '#003366' }}>
                Academic Information
              </Typography>

              <FormControl fullWidth sx={{ mb: 3 }}>
                <InputLabel>University</InputLabel>
                <Select
                  value={registerData.university}
                  onChange={(e) => setRegisterData({ ...registerData, university: e.target.value })}
                  startAdornment={<School size={20} style={{ marginRight: 8, color: '#666' }} />}
                  disabled={isLoading}
                >
                  {belgianUniversities.map((uni) => (
                    <MenuItem key={uni} value={uni}>{uni}</MenuItem>
                  ))}
                </Select>
              </FormControl>

              <Box sx={{ display: 'flex', gap: 2, mb: 3 }}>
                <TextField
                  fullWidth
                  label="Student ID"
                  value={registerData.studentId}
                  onChange={(e) => setRegisterData({ ...registerData, studentId: e.target.value })}
                  disabled={isLoading}
                />
                <FormControl fullWidth>
                  <InputLabel>Academic Year</InputLabel>
                  <Select
                    value={registerData.academicYear}
                    onChange={(e) => setRegisterData({ ...registerData, academicYear: e.target.value })}
                    disabled={isLoading}
                  >
                    {academicYears.map((year) => (
                      <MenuItem key={year} value={year}>{year}</MenuItem>
                    ))}
                  </Select>
                </FormControl>
              </Box>

              <TextField
                fullWidth
                label="Field of Study"
                value={registerData.fieldOfStudy}
                onChange={(e) => setRegisterData({ ...registerData, fieldOfStudy: e.target.value })}
                placeholder="e.g., Computer Science, Business Administration, Medicine"
                sx={{ mb: 3 }}
                disabled={isLoading}
              />

              {/* Password */}
              <Divider sx={{ my: 3 }} />
              <Typography variant="h6" sx={{ mb: 2, color: '#003366' }}>
                Security
              </Typography>

              <TextField
                fullWidth
                label="Password"
                type={showPassword ? 'text' : 'password'}
                value={registerData.password}
                onChange={(e) => setRegisterData({ ...registerData, password: e.target.value })}
                InputProps={{
                  startAdornment: <Lock size={20} style={{ marginRight: 8, color: '#666' }} />,
                  endAdornment: (
                    <Button
                      onClick={() => setShowPassword(!showPassword)}
                      sx={{ minWidth: 'auto', p: 1 }}
                    >
                      {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                    </Button>
                  )
                }}
                helperText="Minimum 8 characters"
                sx={{ mb: 3 }}
                disabled={isLoading}
              />

              <TextField
                fullWidth
                label="Confirm Password"
                type={showConfirmPassword ? 'text' : 'password'}
                value={registerData.confirmPassword}
                onChange={(e) => setRegisterData({ ...registerData, confirmPassword: e.target.value })}
                InputProps={{
                  startAdornment: <Lock size={20} style={{ marginRight: 8, color: '#666' }} />,
                  endAdornment: (
                    <Button
                      onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                      sx={{ minWidth: 'auto', p: 1 }}
                    >
                      {showConfirmPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                    </Button>
                  )
                }}
                sx={{ mb: 3 }}
                disabled={isLoading}
              />

              {/* Agreements */}
              <FormControlLabel
                control={
                  <Checkbox
                    checked={registerData.agreeToTerms}
                    onChange={(e) => setRegisterData({ ...registerData, agreeToTerms: e.target.checked })}
                    disabled={isLoading}
                  />
                }
                label={
                  <Typography variant="body2">
                    I agree to the{' '}
                    <Link href="#" color="primary">Terms of Service</Link>
                  </Typography>
                }
                sx={{ mb: 1 }}
              />

              <FormControlLabel
                control={
                  <Checkbox
                    checked={registerData.agreeToPrivacy}
                    onChange={(e) => setRegisterData({ ...registerData, agreeToPrivacy: e.target.checked })}
                    disabled={isLoading}
                  />
                }
                label={
                  <Typography variant="body2">
                    I agree to the{' '}
                    <Link href="#" color="primary">Privacy Policy</Link>
                  </Typography>
                }
                sx={{ mb: 3 }}
              />

              <Button
                type="submit"
                fullWidth
                variant="contained"
                size="large"
                disabled={isLoading}
                sx={{
                  backgroundColor: '#003366',
                  '&:hover': { backgroundColor: '#001a33' }
                }}
              >
                {isLoading ? <CircularProgress size={24} color="inherit" /> : 'Create Account'}
              </Button>
            </Box>
          )}
        </CardContent>
      </Card>
    </Box>
  );
};

export default AuthForm;
