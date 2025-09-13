import React from 'react';
import { 
  Box, 
  Card, 
  CardContent, 
  Typography, 
  Grid, 
  LinearProgress, 
  Avatar,
  Chip,
  Button,
  List,
  ListItem,
  ListItemText,
  ListItemIcon,
  Divider
} from '@mui/material';
import {
  School as SchoolIcon,
  Business as BusinessIcon,
  Timeline as TimelineIcon,
  Notifications as NotificationsIcon,
  Assignment as AssignmentIcon,
  Flight as FlightIcon,
  LocationOn as LocationIcon,
  CalendarToday as CalendarIcon
} from '@mui/icons-material';
import { Student, DashboardStats, ProgressMetrics, Notification } from '@/types';
import { getStageProgress, getStatusColor, formatDate } from '@/utils';

interface StudentDashboardProps {
  student: Student;
  stats: DashboardStats;
  metrics: ProgressMetrics;
  notifications: Notification[];
  onNotificationClick: (notification: Notification) => void;
}

const StudentDashboard: React.FC<StudentDashboardProps> = ({
  student,
  stats,
  metrics,
  notifications,
  onNotificationClick
}) => {
  const currentStageProgress = getStageProgress(student.applicationStage.id);

  return (
    <Box sx={{ padding: 3 }}>
      {/* Welcome Header */}
      <Box sx={{ marginBottom: 4 }}>
        <Grid container spacing={3} alignItems="center">
          <Grid item>
            <Avatar 
              src={student.profilePhoto} 
              sx={{ width: 80, height: 80 }}
            >
              {student.name.split(' ').map(n => n[0]).join('')}
            </Avatar>
          </Grid>
          <Grid item xs>
            <Typography variant="h4" gutterBottom>
              Welcome back, {student.name.split(' ')[0]}!
            </Typography>
            <Typography variant="subtitle1" color="text.secondary" gutterBottom>
              {student.university} • {student.studyProgram}
            </Typography>
            <Box sx={{ display: 'flex', gap: 1, marginTop: 1 }}>
              <Chip 
                icon={<SchoolIcon />}
                label={student.academicLevel}
                size="small"
                color="primary"
              />
              <Chip 
                icon={<LocationIcon />}
                label="Belgium → Uganda"
                size="small"
                variant="outlined"
              />
              <Chip 
                label={`${student.ectsCreditsRequired} ECTS`}
                size="small"
                variant="outlined"
              />
            </Box>
          </Grid>
        </Grid>
      </Box>

      <Grid container spacing={3}>
        {/* Progress Overview */}
        <Grid item xs={12} md={8}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Application Progress
              </Typography>
              <Box sx={{ marginBottom: 2 }}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', marginBottom: 1 }}>
                  <Typography variant="body2">
                    Current Stage: {student.applicationStage.name}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    {currentStageProgress}% Complete
                  </Typography>
                </Box>
                <LinearProgress 
                  variant="determinate" 
                  value={currentStageProgress}
                  sx={{ height: 8, borderRadius: 4 }}
                />
              </Box>
              
              <Box sx={{ 
                padding: 2, 
                backgroundColor: 'rgba(0, 51, 102, 0.05)',
                borderRadius: 1,
                marginBottom: 2
              }}>
                <Typography variant="subtitle2" gutterBottom>
                  Next Action Required:
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  {student.applicationStage.nextAction}
                </Typography>
                <Typography variant="caption" color="text.secondary">
                  Estimated Duration: {student.applicationStage.estimatedDuration}
                </Typography>
              </Box>

              <Button 
                variant="contained" 
                startIcon={<AssignmentIcon />}
                sx={{ marginTop: 1 }}
              >
                Continue Application
              </Button>
            </CardContent>
          </Card>
        </Grid>

        {/* Quick Stats */}
        <Grid item xs={12} md={4}>
          <Grid container spacing={2}>
            <Grid item xs={6} md={12}>
              <Card>
                <CardContent sx={{ textAlign: 'center' }}>
                  <BusinessIcon sx={{ fontSize: 40, color: 'primary.main', marginBottom: 1 }} />
                  <Typography variant="h4" color="primary">
                    {stats.totalApplications}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Applications
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
            <Grid item xs={6} md={12}>
              <Card>
                <CardContent sx={{ textAlign: 'center' }}>
                  <TimelineIcon sx={{ fontSize: 40, color: 'success.main', marginBottom: 1 }} />
                  <Typography variant="h4" color="success.main">
                    {stats.placementRate}%
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Success Rate
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        </Grid>

        {/* Recent Notifications */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Recent Updates
              </Typography>
              <List dense>
                {notifications.slice(0, 5).map((notification, index) => (
                  <React.Fragment key={notification.id}>
                    <ListItem
                      button
                      onClick={() => onNotificationClick(notification)}
                      sx={{
                        backgroundColor: notification.read ? 'transparent' : 'rgba(0, 51, 102, 0.05)',
                        borderRadius: 1,
                        marginBottom: 1
                      }}
                    >
                      <ListItemIcon>
                        <NotificationsIcon 
                          color={notification.read ? 'action' : 'primary'}
                        />
                      </ListItemIcon>
                      <ListItemText
                        primary={notification.title}
                        secondary={
                          <Box>
                            <Typography variant="body2" color="text.secondary">
                              {notification.message}
                            </Typography>
                            <Typography variant="caption" color="text.secondary">
                              {formatDate(notification.createdAt)}
                            </Typography>
                          </Box>
                        }
                      />
                    </ListItem>
                    {index < notifications.length - 1 && <Divider />}
                  </React.Fragment>
                ))}
              </List>
              {notifications.length > 5 && (
                <Button size="small" sx={{ marginTop: 1 }}>
                  View All Notifications
                </Button>
              )}
            </CardContent>
          </Card>
        </Grid>

        {/* Important Dates */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Important Dates
              </Typography>
              <List dense>
                <ListItem>
                  <ListItemIcon>
                    <CalendarIcon color="primary" />
                  </ListItemIcon>
                  <ListItemText
                    primary="Expected Graduation"
                    secondary={formatDate(student.expectedGraduationDate)}
                  />
                </ListItem>
                <Divider />
                <ListItem>
                  <ListItemIcon>
                    <FlightIcon color="warning" />
                  </ListItemIcon>
                  <ListItemText
                    primary="Visa Status"
                    secondary={
                      <Chip 
                        label={student.visaStatus.status.replace('_', ' ').toUpperCase()}
                        size="small"
                        color={student.visaStatus.status === 'approved' ? 'success' : 'warning'}
                      />
                    }
                  />
                </ListItem>
                <Divider />
                <ListItem>
                  <ListItemIcon>
                    <SchoolIcon color="info" />
                  </ListItemIcon>
                  <ListItemText
                    primary="Cultural Orientation"
                    secondary={
                      <Chip 
                        label={student.culturalOrientationStatus.replace('_', ' ').toUpperCase()}
                        size="small"
                        color={student.culturalOrientationStatus === 'completed' ? 'success' : 'default'}
                      />
                    }
                  />
                </ListItem>
              </List>
            </CardContent>
          </Card>
        </Grid>

        {/* Skills & Performance Metrics */}
        <Grid item xs={12}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Performance Metrics
              </Typography>
              <Grid container spacing={3}>
                <Grid item xs={12} sm={6} md={3}>
                  <Box sx={{ textAlign: 'center' }}>
                    <Typography variant="h4" color="primary.main">
                      {metrics.applicationProgress}%
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      Application Progress
                    </Typography>
                    <LinearProgress 
                      variant="determinate" 
                      value={metrics.applicationProgress}
                      sx={{ marginTop: 1, height: 4 }}
                    />
                  </Box>
                </Grid>
                <Grid item xs={12} sm={6} md={3}>
                  <Box sx={{ textAlign: 'center' }}>
                    <Typography variant="h4" color="success.main">
                      {metrics.documentCompletionRate}%
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      Documents Complete
                    </Typography>
                    <LinearProgress 
                      variant="determinate" 
                      value={metrics.documentCompletionRate}
                      color="success"
                      sx={{ marginTop: 1, height: 4 }}
                    />
                  </Box>
                </Grid>
                <Grid item xs={12} sm={6} md={3}>
                  <Box sx={{ textAlign: 'center' }}>
                    <Typography variant="h4" color="info.main">
                      {metrics.culturalIntegrationScore}%
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      Cultural Integration
                    </Typography>
                    <LinearProgress 
                      variant="determinate" 
                      value={metrics.culturalIntegrationScore}
                      color="info"
                      sx={{ marginTop: 1, height: 4 }}
                    />
                  </Box>
                </Grid>
                <Grid item xs={12} sm={6} md={3}>
                  <Box sx={{ textAlign: 'center' }}>
                    <Typography variant="h4" color="warning.main">
                      {metrics.overallScore}%
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      Overall Score
                    </Typography>
                    <LinearProgress 
                      variant="determinate" 
                      value={metrics.overallScore}
                      color="warning"
                      sx={{ marginTop: 1, height: 4 }}
                    />
                  </Box>
                </Grid>
              </Grid>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
};

export default StudentDashboard;
