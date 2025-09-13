/**
 * Enhanced Application Form Controller - Low-Friction Multi-Step Journey
 * Implements strategic UI/UX principles for conversion optimization
 */

class ApplicationForm {
  constructor() {
    this.currentStep = 1;
    this.totalSteps = 5;
    this.formData = {
      careerFields: [],
      primaryGoal: '',
      timeline: '',
      educationLevel: '',
      experienceLevel: '',
      currentSituation: '',
      skills: '',
      firstName: '',
      lastName: '',
      email: '',
      phone: '',
      location: '',
      marketingConsent: false
    };
    
    this.stepTimes = [30, 45, 60, 30, 5]; // seconds for each step
    this.startTime = Date.now();
    this.timeSpentPerStep = [];
    
    this.init();
  }

  init() {
    this.bindEvents();
    this.updateProgress();
    this.addValidation();
    this.setupAutoSave();
    this.initializeAnimations();
    this.loadSavedProgress();
  }

  bindEvents() {
    // Modal controls
    document.addEventListener('click', (e) => {
      if (e.target.matches('[onclick*="openApplication"]') || 
          e.target.matches('[onclick*="openFullApplication"]')) {
        e.preventDefault();
        this.openModal();
      }
      
      if (e.target.matches('[onclick*="closeApplication"]')) {
        e.preventDefault();
        this.closeModal();
      }
    });

    // Form navigation
    const nextBtns = document.querySelectorAll('.next-btn');
    const prevBtns = document.querySelectorAll('.prev-btn');
    
    nextBtns.forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        this.nextStep();
      });
    });
    
    prevBtns.forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        this.previousStep();
      });
    });

    // Option selection with enhanced UX
    document.addEventListener('change', (e) => {
      if (e.target.name === 'career-fields') {
        this.handleCareerFieldSelection(e);
      }
      if (e.target.name === 'primary-goal') {
        this.handleGoalSelection(e);
      }
      if (e.target.name === 'timeline') {
        this.handleTimelineSelection(e);
      }
      
      // Auto-advance for single selections
      if (e.target.type === 'radio' && this.currentStep < 3) {
        setTimeout(() => {
          if (this.validateCurrentStep()) {
            this.nextStep();
          }
        }, 800);
      }
    });

    // Form inputs with real-time validation
    document.addEventListener('input', (e) => {
      if (e.target.matches('.application-form input, .application-form select')) {
        this.validateField(e.target);
        this.saveProgress();
      }
    });

    // Keyboard navigation
    document.addEventListener('keydown', (e) => {
      if (document.getElementById('application-modal').style.display !== 'none') {
        if (e.key === 'Enter' && !e.shiftKey) {
          e.preventDefault();
          this.nextStep();
        }
        if (e.key === 'Escape') {
          this.closeModal();
        }
      }
    });

    // Help system
    const helpBtn = document.querySelector('.help-btn');
    if (helpBtn) {
      helpBtn.addEventListener('click', () => this.toggleHelp());
    }

    // Save progress button
    const saveBtn = document.querySelector('.save-progress');
    if (saveBtn) {
      saveBtn.addEventListener('click', () => this.saveAndExit());
    }
  }

  openModal() {
    const modal = document.getElementById('application-modal');
    if (modal) {
      modal.style.display = 'flex';
      document.body.style.overflow = 'hidden';
      
      // Reset form if starting fresh
      if (this.currentStep === 1 && !this.hasProgress()) {
        this.resetForm();
      }
      
      // Analytics tracking
      this.trackEvent('application_modal_opened', {
        step: this.currentStep,
        source: this.getTrafficSource()
      });
      
      // Focus management
      setTimeout(() => {
        const firstInput = modal.querySelector('input:not([type="hidden"]), select, textarea');
        if (firstInput) firstInput.focus();
      }, 300);
    }
  }

  closeModal() {
    const modal = document.getElementById('application-modal');
    if (modal) {
      modal.style.display = 'none';
      document.body.style.overflow = '';
      
      // Save progress if user has started
      if (this.currentStep > 1 || this.hasFormData()) {
        this.saveProgress();
        this.showExitIntent();
      }
    }
  }

  nextStep() {
    if (!this.validateCurrentStep()) {
      this.showValidationErrors();
      return;
    }

    this.collectCurrentStepData();
    this.timeSpentPerStep[this.currentStep - 1] = Date.now() - this.startTime;
    
    if (this.currentStep < this.totalSteps) {
      this.currentStep++;
      this.updateProgress();
      this.showStep(this.currentStep);
      this.updateNavigation();
      this.updateTimeRemaining();
      
      // Special handling for final step
      if (this.currentStep === this.totalSteps) {
        this.generateMatches();
      }
      
      this.trackStepCompletion();
    } else {
      this.submitForm();
    }
    
    this.startTime = Date.now(); // Reset timer for next step
  }

  previousStep() {
    if (this.currentStep > 1) {
      this.currentStep--;
      this.updateProgress();
      this.showStep(this.currentStep);
      this.updateNavigation();
      this.updateTimeRemaining();
    }
  }

  showStep(stepNumber) {
    // Hide all steps
    document.querySelectorAll('.form-step').forEach(step => {
      step.classList.remove('active');
      step.style.opacity = '0';
      step.style.transform = 'translateX(20px)';
    });

    // Show current step with animation
    setTimeout(() => {
      const currentStepEl = document.querySelector(`[data-step="${stepNumber}"]`);
      if (currentStepEl) {
        currentStepEl.classList.add('active');
        currentStepEl.style.opacity = '1';
        currentStepEl.style.transform = 'translateX(0)';
        
        // Focus management
        const firstInput = currentStepEl.querySelector('input:not([type="hidden"]), select, textarea');
        if (firstInput) {
          setTimeout(() => firstInput.focus(), 200);
        }
      }
    }, 150);
  }

  updateProgress() {
    const progressFill = document.querySelector('.progress-fill-modal');
    const progressSteps = document.querySelectorAll('.progress-step');
    const currentStepText = document.querySelector('.current-step');
    
    if (progressFill) {
      const percentage = (this.currentStep / this.totalSteps) * 100;
      progressFill.style.width = `${percentage}%`;
    }
    
    // Update step indicators
    progressSteps.forEach((step, index) => {
      const stepNumber = index + 1;
      step.classList.remove('active', 'completed');
      
      if (stepNumber < this.currentStep) {
        step.classList.add('completed');
      } else if (stepNumber === this.currentStep) {
        step.classList.add('active');
      }
    });
    
    if (currentStepText) {
      currentStepText.textContent = `Step ${this.currentStep} of ${this.totalSteps}`;
    }
  }

  updateNavigation() {
    const prevBtn = document.querySelector('.prev-btn');
    const nextBtn = document.querySelector('.next-btn');
    const saveBtn = document.querySelector('.save-progress');
    
    // Previous button
    if (prevBtn) {
      prevBtn.style.display = this.currentStep > 1 ? 'flex' : 'none';
    }
    
    // Save progress button
    if (saveBtn) {
      saveBtn.style.display = this.currentStep > 1 && this.currentStep < this.totalSteps ? 'flex' : 'none';
    }
    
    // Next button text
    if (nextBtn) {
      const btnText = nextBtn.querySelector('.btn-text');
      if (btnText) {
        if (this.currentStep === this.totalSteps) {
          btnText.textContent = 'Get My Matches';
          nextBtn.classList.add('btn-success');
        } else if (this.currentStep === this.totalSteps - 1) {
          btnText.textContent = 'Find Matches';
        } else {
          btnText.textContent = 'Continue';
          nextBtn.classList.remove('btn-success');
        }
      }
    }
  }

  updateTimeRemaining() {
    const timeRemainingEl = document.getElementById('time-remaining');
    if (timeRemainingEl) {
      const remainingSteps = this.totalSteps - this.currentStep;
      const remainingTime = this.stepTimes.slice(this.currentStep - 1).reduce((a, b) => a + b, 0);
      const minutes = Math.ceil(remainingTime / 60);
      
      timeRemainingEl.textContent = `${minutes} minute${minutes !== 1 ? 's' : ''}`;
    }
  }

  validateCurrentStep() {
    const currentStepEl = document.querySelector(`[data-step="${this.currentStep}"].active`);
    if (!currentStepEl) return false;

    let isValid = true;
    const errors = [];

    switch (this.currentStep) {
      case 1:
        const careerFields = currentStepEl.querySelectorAll('input[name="career-fields"]:checked');
        if (careerFields.length === 0) {
          errors.push('Please select at least one area of interest');
          isValid = false;
        }
        break;
        
      case 2:
        const primaryGoal = currentStepEl.querySelector('input[name="primary-goal"]:checked');
        const timeline = currentStepEl.querySelector('input[name="timeline"]:checked');
        if (!primaryGoal) {
          errors.push('Please select your primary goal');
          isValid = false;
        }
        if (!timeline) {
          errors.push('Please select your preferred timeline');
          isValid = false;
        }
        break;
        
      case 3:
        const educationLevel = currentStepEl.querySelector('#education-level').value;
        const experienceLevel = currentStepEl.querySelector('#experience-level').value;
        const currentSituation = currentStepEl.querySelector('input[name="current-situation"]:checked');
        
        if (!educationLevel) {
          errors.push('Please select your education level');
          isValid = false;
        }
        if (!experienceLevel) {
          errors.push('Please select your experience level');
          isValid = false;
        }
        if (!currentSituation) {
          errors.push('Please select your current situation');
          isValid = false;
        }
        break;
        
      case 4:
        const firstName = currentStepEl.querySelector('#first-name').value.trim();
        const lastName = currentStepEl.querySelector('#last-name').value.trim();
        const email = currentStepEl.querySelector('#email').value.trim();
        const location = currentStepEl.querySelector('#location').value.trim();
        
        if (!firstName) {
          errors.push('Please enter your first name');
          isValid = false;
        }
        if (!lastName) {
          errors.push('Please enter your last name');
          isValid = false;
        }
        if (!email || !this.isValidEmail(email)) {
          errors.push('Please enter a valid email address');
          isValid = false;
        }
        if (!location) {
          errors.push('Please enter your current location');
          isValid = false;
        }
        break;
    }

    if (!isValid) {
      this.showErrors(errors);
    }

    return isValid;
  }

  showErrors(errors) {
    // Remove existing error messages
    document.querySelectorAll('.error-message').forEach(el => el.remove());
    
    // Create error container
    const errorContainer = document.createElement('div');
    errorContainer.className = 'error-message';
    errorContainer.innerHTML = `
      <div class="error-content">
        <i class="fas fa-exclamation-triangle"></i>
        <div class="error-text">
          ${errors.map(error => `<p>${error}</p>`).join('')}
        </div>
      </div>
    `;
    
    // Insert error message
    const currentStep = document.querySelector(`[data-step="${this.currentStep}"].active`);
    if (currentStep) {
      currentStep.insertBefore(errorContainer, currentStep.querySelector('.form-navigation') || currentStep.lastElementChild);
      
      // Auto-remove after 5 seconds
      setTimeout(() => {
        if (errorContainer.parentNode) {
          errorContainer.remove();
        }
      }, 5000);
    }
  }

  collectCurrentStepData() {
    const currentStepEl = document.querySelector(`[data-step="${this.currentStep}"].active`);
    if (!currentStepEl) return;

    switch (this.currentStep) {
      case 1:
        this.formData.careerFields = Array.from(
          currentStepEl.querySelectorAll('input[name="career-fields"]:checked')
        ).map(input => input.value);
        break;
        
      case 2:
        const primaryGoal = currentStepEl.querySelector('input[name="primary-goal"]:checked');
        const timeline = currentStepEl.querySelector('input[name="timeline"]:checked');
        this.formData.primaryGoal = primaryGoal ? primaryGoal.value : '';
        this.formData.timeline = timeline ? timeline.value : '';
        break;
        
      case 3:
        this.formData.educationLevel = currentStepEl.querySelector('#education-level').value;
        this.formData.experienceLevel = currentStepEl.querySelector('#experience-level').value;
        const currentSituation = currentStepEl.querySelector('input[name="current-situation"]:checked');
        this.formData.currentSituation = currentSituation ? currentSituation.value : '';
        this.formData.skills = currentStepEl.querySelector('#skills').value;
        break;
        
      case 4:
        this.formData.firstName = currentStepEl.querySelector('#first-name').value.trim();
        this.formData.lastName = currentStepEl.querySelector('#last-name').value.trim();
        this.formData.email = currentStepEl.querySelector('#email').value.trim();
        this.formData.phone = currentStepEl.querySelector('#phone').value.trim();
        this.formData.location = currentStepEl.querySelector('#location').value.trim();
        const marketingConsent = currentStepEl.querySelector('input[name="marketing-consent"]:checked');
        this.formData.marketingConsent = !!marketingConsent;
        break;
    }
  }

  generateMatches() {
    // Simulate AI matching based on form data
    const matches = [
      {
        id: 1,
        company: 'Google',
        position: 'Software Engineering Intern',
        location: 'Mountain View, CA',
        salary: '$8,000/month',
        matchScore: 98,
        highlights: ['Remote-friendly', 'Mentorship program', 'Full-time offer potential'],
        logo: 'src/assets/company-google.png',
        featured: true
      },
      {
        id: 2,
        company: 'Microsoft',
        position: 'Product Management Intern',
        location: 'Seattle, WA',
        salary: '$7,500/month',
        matchScore: 94,
        highlights: ['Housing assistance', 'International friendly'],
        logo: 'src/assets/company-microsoft.png'
      },
      {
        id: 3,
        company: 'Amazon',
        position: 'Data Science Intern',
        location: 'Various Locations',
        salary: '$7,000/month',
        matchScore: 91,
        highlights: ['Fast track hiring', 'Global teams'],
        logo: 'src/assets/company-amazon.png'
      }
    ];

    // Customize matches based on career fields
    if (this.formData.careerFields.includes('technology')) {
      matches[0].position = 'Software Engineering Intern';
    } else if (this.formData.careerFields.includes('business')) {
      matches[0].position = 'Business Strategy Intern';
    } else if (this.formData.careerFields.includes('marketing')) {
      matches[0].position = 'Digital Marketing Intern';
    }

    this.renderMatches(matches);
  }

  renderMatches(matches) {
    const resultsContainer = document.querySelector('.matching-results');
    if (!resultsContainer) return;

    resultsContainer.innerHTML = matches.map(match => `
      <div class="match-item ${match.featured ? 'featured' : ''}">
        ${match.featured ? '<div class="match-badge">Perfect Match</div>' : ''}
        <div class="match-content">
          <div class="company-info">
            <img src="${match.logo}" alt="${match.company}" class="company-logo">
            <div class="company-details">
              <h4>${match.position}</h4>
              <p class="company-name">${match.company} • ${match.location}</p>
              <div class="match-stats">
                <span class="match-score">${match.matchScore}% Match</span>
                <span class="salary-range">${match.salary}</span>
              </div>
            </div>
          </div>
          <div class="match-highlights">
            ${match.highlights.map(highlight => `<span class="highlight">${highlight}</span>`).join('')}
          </div>
        </div>
      </div>
    `).join('');
  }

  submitForm() {
    this.collectCurrentStepData();
    
    // Show loading state
    this.showLoadingState();
    
    // Simulate API call
    setTimeout(() => {
      this.handleFormSubmission();
    }, 2000);
  }

  showLoadingState() {
    const nextBtn = document.querySelector('.next-btn');
    if (nextBtn) {
      nextBtn.innerHTML = `
        <span class="loading-spinner"></span>
        Processing...
      `;
      nextBtn.disabled = true;
    }
  }

  handleFormSubmission() {
    // Track conversion
    this.trackEvent('application_completed', {
      total_time: Date.now() - this.startTime,
      career_fields: this.formData.careerFields,
      primary_goal: this.formData.primaryGoal,
      timeline: this.formData.timeline
    });

    // Show success message
    this.showSuccessMessage();
    
    // Clean up
    setTimeout(() => {
      this.resetForm();
      this.closeModal();
    }, 5000);
  }

  showSuccessMessage() {
    const modal = document.querySelector('.modal-content');
    if (modal) {
      modal.innerHTML = `
        <div class="success-message">
          <div class="success-icon">
            <i class="fas fa-check-circle"></i>
          </div>
          <h2>Application Submitted Successfully! 🎉</h2>
          <p>We'll email you your personalized matches within 24 hours.</p>
          <div class="success-actions">
            <button class="btn-primary" onclick="window.location.href='mailto:${this.formData.email}'">
              Check Your Email
            </button>
            <button class="btn-secondary" onclick="this.closeModal()">
              Continue Browsing
            </button>
          </div>
        </div>
      `;
    }
  }

  // Utility methods
  isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  hasProgress() {
    return localStorage.getItem('application_progress') !== null;
  }

  hasFormData() {
    return Object.values(this.formData).some(value => 
      Array.isArray(value) ? value.length > 0 : value !== '' && value !== false
    );
  }

  saveProgress() {
    localStorage.setItem('application_progress', JSON.stringify({
      currentStep: this.currentStep,
      formData: this.formData,
      timestamp: Date.now()
    }));
  }

  loadSavedProgress() {
    const saved = localStorage.getItem('application_progress');
    if (saved) {
      try {
        const progress = JSON.parse(saved);
        const hoursSinceLastSave = (Date.now() - progress.timestamp) / (1000 * 60 * 60);
        
        // Only restore if saved within last 24 hours
        if (hoursSinceLastSave < 24) {
          this.currentStep = progress.currentStep;
          this.formData = { ...this.formData, ...progress.formData };
          this.restoreFormFields();
        } else {
          localStorage.removeItem('application_progress');
        }
      } catch (e) {
        console.error('Error loading saved progress:', e);
        localStorage.removeItem('application_progress');
      }
    }
  }

  restoreFormFields() {
    // Restore career fields
    this.formData.careerFields.forEach(field => {
      const checkbox = document.querySelector(`input[name="career-fields"][value="${field}"]`);
      if (checkbox) checkbox.checked = true;
    });

    // Restore other fields
    Object.entries(this.formData).forEach(([key, value]) => {
      if (key === 'careerFields' || !value) return;
      
      const field = document.querySelector(`[name="${key}"], #${key.replace(/([A-Z])/g, '-$1').toLowerCase()}`);
      if (field) {
        if (field.type === 'checkbox') {
          field.checked = value;
        } else {
          field.value = value;
        }
      }
    });
  }

  saveAndExit() {
    this.saveProgress();
    this.showSaveConfirmation();
    setTimeout(() => this.closeModal(), 2000);
  }

  showSaveConfirmation() {
    const notification = document.createElement('div');
    notification.className = 'save-notification';
    notification.innerHTML = `
      <i class="fas fa-check"></i>
      Progress saved! Continue anytime in the next 24 hours.
    `;
    document.body.appendChild(notification);
    
    setTimeout(() => notification.remove(), 3000);
  }

  showExitIntent() {
    if (this.currentStep > 1 && !this.hasShownExitIntent) {
      this.hasShownExitIntent = true;
      
      const exitModal = document.createElement('div');
      exitModal.className = 'exit-intent-modal';
      exitModal.innerHTML = `
        <div class="exit-content">
          <h3>Don't lose your progress!</h3>
          <p>Your application is ${Math.round((this.currentStep / this.totalSteps) * 100)}% complete.</p>
          <div class="exit-actions">
            <button class="btn-primary" onclick="this.saveAndContinue()">Save & Continue</button>
            <button class="btn-ghost" onclick="this.confirmExit()">Exit Anyway</button>
          </div>
        </div>
      `;
      
      document.body.appendChild(exitModal);
      setTimeout(() => exitModal.remove(), 10000);
    }
  }

  trackEvent(eventName, properties = {}) {
    // Analytics tracking
    if (typeof gtag !== 'undefined') {
      gtag('event', eventName, properties);
    }
    
    // Custom analytics
    if (window.analytics) {
      window.analytics.track(eventName, properties);
    }
    
    console.log('Event tracked:', eventName, properties);
  }

  trackStepCompletion() {
    this.trackEvent('application_step_completed', {
      step: this.currentStep - 1,
      time_spent: this.timeSpentPerStep[this.currentStep - 2] || 0,
      total_time: Date.now() - this.startTime
    });
  }

  getTrafficSource() {
    const params = new URLSearchParams(window.location.search);
    return params.get('utm_source') || params.get('ref') || 'direct';
  }

  resetForm() {
    this.currentStep = 1;
    this.formData = {
      careerFields: [],
      primaryGoal: '',
      timeline: '',
      educationLevel: '',
      experienceLevel: '',
      currentSituation: '',
      skills: '',
      firstName: '',
      lastName: '',
      email: '',
      phone: '',
      location: '',
      marketingConsent: false
    };
    this.timeSpentPerStep = [];
    this.startTime = Date.now();
    localStorage.removeItem('application_progress');
  }

  initializeAnimations() {
    // Add smooth transitions to form steps
    const style = document.createElement('style');
    style.textContent = `
      .form-step {
        transition: all 0.3s ease-in-out;
        opacity: 0;
        transform: translateX(20px);
      }
      
      .form-step.active {
        opacity: 1;
        transform: translateX(0);
      }
      
      .loading-spinner {
        width: 16px;
        height: 16px;
        border: 2px solid #ffffff40;
        border-top: 2px solid #ffffff;
        border-radius: 50%;
        animation: spin 1s linear infinite;
        margin-right: 8px;
      }
      
      @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
      }
    `;
    document.head.appendChild(style);
  }

  // Helper methods for event handlers
  handleCareerFieldSelection(e) {
    const option = e.target.closest('.interest-option');
    if (option) {
      option.classList.toggle('selected', e.target.checked);
    }
  }

  handleGoalSelection(e) {
    document.querySelectorAll('.goal-option').forEach(opt => opt.classList.remove('selected'));
    e.target.closest('.goal-option').classList.add('selected');
  }

  handleTimelineSelection(e) {
    document.querySelectorAll('.timeline-option').forEach(opt => opt.classList.remove('selected'));
    e.target.closest('.timeline-option').classList.add('selected');
  }

  validateField(field) {
    const errorEl = field.parentNode.querySelector('.field-error');
    if (errorEl) errorEl.remove();

    let isValid = true;
    let errorMessage = '';

    switch (field.type) {
      case 'email':
        if (field.value && !this.isValidEmail(field.value)) {
          isValid = false;
          errorMessage = 'Please enter a valid email address';
        }
        break;
      case 'tel':
        if (field.value && field.value.length < 10) {
          isValid = false;
          errorMessage = 'Please enter a valid phone number';
        }
        break;
    }

    if (!isValid) {
      const error = document.createElement('span');
      error.className = 'field-error';
      error.textContent = errorMessage;
      field.parentNode.appendChild(error);
    }

    return isValid;
  }

  toggleHelp() {
    // Implementation for help system
    console.log('Help toggled for step:', this.currentStep);
  }
}

// Global functions for onclick handlers
function openApplication() {
  if (window.applicationForm) {
    window.applicationForm.openModal();
  }
}

function openFullApplication() {
  if (window.applicationForm) {
    window.applicationForm.openModal();
  }
}

function closeApplication() {
  if (window.applicationForm) {
    window.applicationForm.closeModal();
  }
}

function nextStep() {
  if (window.applicationForm) {
    window.applicationForm.nextStep();
  }
}

function previousStep() {
  if (window.applicationForm) {
    window.applicationForm.previousStep();
  }
}

function saveProgress() {
  if (window.applicationForm) {
    window.applicationForm.saveAndExit();
  }
}

function toggleHelp() {
  if (window.applicationForm) {
    window.applicationForm.toggleHelp();
  }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  window.applicationForm = new ApplicationForm();
});

// Auto-save on page unload
window.addEventListener('beforeunload', () => {
  if (window.applicationForm && window.applicationForm.hasFormData()) {
    window.applicationForm.saveProgress();
  }
});
      btn.addEventListener('click', () => this.nextStep());
    });
    
    prevBtns.forEach(btn => {
      btn.addEventListener('click', () => this.previousStep());
    });

    // Form input tracking
    this.trackFormInputs();
    
    // Keyboard navigation
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        this.closeModal();
      }
    });
  }

  openModal() {
    const modal = document.getElementById('application-modal');
    modal.classList.add('active');
    document.body.style.overflow = 'hidden';
    
    // Analytics tracking
    this.trackEvent('application_started', {
      step: 1,
      source: 'modal_open'
    });
    
    // Focus management for accessibility
    setTimeout(() => {
      const firstInput = modal.querySelector('input[type="radio"]');
      if (firstInput) firstInput.focus();
    }, 300);
  }

  closeModal() {
    const modal = document.getElementById('application-modal');
    modal.classList.remove('active');
    document.body.style.overflow = '';
    
    // Track abandonment for optimization
    this.trackEvent('application_abandoned', {
      step: this.currentStep,
      form_data: this.getFormCompleteness()
    });
  }

  nextStep() {
    if (!this.validateCurrentStep()) {
      return;
    }

    this.saveCurrentStepData();
    
    if (this.currentStep < this.totalSteps) {
      this.currentStep++;
      this.updateStepDisplay();
      this.updateProgress();
      
      // Track step completion
      this.trackEvent('application_step_completed', {
        step: this.currentStep - 1,
        form_data: this.formData
      });
      
      // Special handling for final step
      if (this.currentStep === this.totalSteps) {
        this.showFinalStep();
      }
    } else {
      this.submitApplication();
    }
  }

  previousStep() {
    if (this.currentStep > 1) {
      this.currentStep--;
      this.updateStepDisplay();
      this.updateProgress();
      
      this.trackEvent('application_step_back', {
        step: this.currentStep + 1
      });
    }
  }

  updateStepDisplay() {
    // Hide all steps
    document.querySelectorAll('.form-step').forEach(step => {
      step.classList.remove('active');
    });
    
    // Show current step with animation
    const currentStepEl = document.querySelector(`[data-step="${this.currentStep}"]`);
    if (currentStepEl) {
      setTimeout(() => {
        currentStepEl.classList.add('active');
      }, 150);
    }
    
    // Update navigation buttons
    this.updateNavigationButtons();
  }

  updateProgress() {
    const progressPercentage = (this.currentStep / this.totalSteps) * 100;
    
    // Update progress bar
    const progressFill = document.querySelector('.progress-fill-modal');
    if (progressFill) {
      progressFill.style.width = `${progressPercentage}%`;
    }
    
    // Update step indicators
    document.querySelectorAll('.progress-step').forEach((step, index) => {
      const stepNumber = index + 1;
      step.classList.remove('active', 'completed');
      
      if (stepNumber < this.currentStep) {
        step.classList.add('completed');
      } else if (stepNumber === this.currentStep) {
        step.classList.add('active');
      }
    });
  }

  updateNavigationButtons() {
    const prevBtn = document.querySelector('.prev-btn');
    const nextBtn = document.querySelector('.next-btn');
    
    if (prevBtn) {
      prevBtn.style.display = this.currentStep === 1 ? 'none' : 'flex';
    }
    
    if (nextBtn) {
      if (this.currentStep === this.totalSteps) {
        nextBtn.innerHTML = '<i class="fas fa-rocket"></i> Submit Application';
        nextBtn.classList.add('btn-success');
      } else {
        nextBtn.innerHTML = 'Continue <i class="fas fa-arrow-right"></i>';
        nextBtn.classList.remove('btn-success');
      }
    }
  }

  validateCurrentStep() {
    switch (this.currentStep) {
      case 1:
        return this.validateCareerField();
      case 2:
        return this.validateDestination();
      case 3:
        return this.validateContactInfo();
      default:
        return true;
    }
  }

  validateCareerField() {
    const selectedField = document.querySelector('input[name="career-field"]:checked');
    if (!selectedField) {
      this.showValidationError('Please select your career interest to continue.');
      return false;
    }
    return true;
  }

  validateDestination() {
    // This will be implemented when step 2 is created
    return true;
  }

  validateContactInfo() {
    const requiredFields = ['firstName', 'lastName', 'email'];
    let isValid = true;
    
    requiredFields.forEach(field => {
      const input = document.querySelector(`[name="${field}"]`);
      if (input && !input.value.trim()) {
        this.showFieldError(input, 'This field is required');
        isValid = false;
      }
    });
    
    // Email validation
    const emailInput = document.querySelector('[name="email"]');
    if (emailInput && emailInput.value && !this.isValidEmail(emailInput.value)) {
      this.showFieldError(emailInput, 'Please enter a valid email address');
      isValid = false;
    }
    
    return isValid;
  }

  isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  showValidationError(message) {
    // Create or update validation message
    let errorEl = document.querySelector('.validation-error');
    if (!errorEl) {
      errorEl = document.createElement('div');
      errorEl.className = 'validation-error';
      errorEl.style.cssText = `
        background: #fef2f2;
        border: 1px solid #fecaca;
        color: #dc2626;
        padding: 12px 16px;
        border-radius: 8px;
        margin-top: 16px;
        display: flex;
        align-items: center;
        gap: 8px;
      `;
      
      const currentStep = document.querySelector('.form-step.active');
      if (currentStep) {
        currentStep.appendChild(errorEl);
      }
    }
    
    errorEl.innerHTML = `<i class="fas fa-exclamation-triangle"></i> ${message}`;
    
    // Remove after 5 seconds
    setTimeout(() => {
      errorEl.remove();
    }, 5000);
  }

  showFieldError(input, message) {
    // Remove existing error
    const existingError = input.parentNode.querySelector('.form-error');
    if (existingError) {
      existingError.remove();
    }
    
    // Add error styling
    input.classList.add('error');
    
    // Create error message
    const errorEl = document.createElement('div');
    errorEl.className = 'form-error';
    errorEl.innerHTML = `<i class="fas fa-exclamation-circle"></i> ${message}`;
    
    input.parentNode.appendChild(errorEl);
    
    // Remove error on input
    input.addEventListener('input', () => {
      input.classList.remove('error');
      errorEl.remove();
    }, { once: true });
  }

  saveCurrentStepData() {
    switch (this.currentStep) {
      case 1:
        const careerField = document.querySelector('input[name="career-field"]:checked');
        if (careerField) {
          this.formData.careerField = careerField.value;
        }
        break;
      case 2:
        // Save destination data when implemented
        break;
      case 3:
        // Save contact information
        const contactFields = ['firstName', 'lastName', 'email', 'phone', 'university', 'graduationYear'];
        contactFields.forEach(field => {
          const input = document.querySelector(`[name="${field}"]`);
          if (input) {
            this.formData[field] = input.value;
          }
        });
        break;
    }
    
    // Auto-save to localStorage
    localStorage.setItem('admasafrolink_application', JSON.stringify(this.formData));
  }

  setupAutoSave() {
    // Restore saved data
    const savedData = localStorage.getItem('admasafrolink_application');
    if (savedData) {
      try {
        this.formData = { ...this.formData, ...JSON.parse(savedData) };
        this.restoreFormData();
      } catch (e) {
        console.warn('Could not restore form data:', e);
      }
    }
  }

  restoreFormData() {
    // Restore career field selection
    if (this.formData.careerField) {
      const careerRadio = document.querySelector(`input[name="career-field"][value="${this.formData.careerField}"]`);
      if (careerRadio) {
        careerRadio.checked = true;
      }
    }
    
    // Restore contact information
    Object.keys(this.formData).forEach(key => {
      const input = document.querySelector(`[name="${key}"]`);
      if (input && this.formData[key]) {
        input.value = this.formData[key];
      }
    });
  }

  trackFormInputs() {
    // Track user interactions for optimization
    document.addEventListener('input', (e) => {
      if (e.target.closest('.application-form')) {
        this.trackEvent('form_interaction', {
          field: e.target.name,
          step: this.currentStep,
          value_length: e.target.value.length
        });
      }
    });
    
    // Track time spent on each step
    this.stepStartTime = Date.now();
  }

  getFormCompleteness() {
    const totalFields = Object.keys(this.formData).length;
    const completedFields = Object.values(this.formData).filter(value => value.trim()).length;
    return Math.round((completedFields / totalFields) * 100);
  }

  showFinalStep() {
    // Create completion step content
    const finalStepHtml = `
      <div class="completion-step">
        <div class="completion-icon">
          <i class="fas fa-check"></i>
        </div>
        <h3 class="completion-title">You're All Set!</h3>
        <p class="completion-message">
          Thank you for starting your global career journey with AdmasAfroLink. 
          We're matching you with the perfect internship opportunity right now.
        </p>
        
        <div class="next-steps">
          <h4>What happens next:</h4>
          <ul>
            <li><i class="fas fa-search"></i> We match you with opportunities (24-48 hours)</li>
            <li><i class="fas fa-phone"></i> Our team calls to discuss your options</li>
            <li><i class="fas fa-handshake"></i> We help you select the perfect program</li>
            <li><i class="fas fa-plane"></i> Start your life-changing journey!</li>
          </ul>
        </div>
        
        <div class="completion-cta">
          <p style="margin-bottom: 16px;"><strong>Questions? Text us at +1 (555) 123-4567</strong></p>
          <button class="btn-primary btn-large" onclick="applicationForm.completeApplication()">
            <i class="fas fa-rocket"></i> Complete Application
          </button>
        </div>
      </div>
    `;
    
    const currentStep = document.querySelector('.form-step.active');
    if (currentStep) {
      currentStep.innerHTML = finalStepHtml;
    }
  }

  async submitApplication() {
    this.trackEvent('application_submitted', {
      form_data: this.formData,
      time_to_complete: Date.now() - this.applicationStartTime
    });
    
    // Show loading state
    const submitBtn = document.querySelector('.next-btn');
    if (submitBtn) {
      submitBtn.classList.add('btn-loading');
      submitBtn.disabled = true;
    }
    
    try {
      // Simulate API call
      await this.sendApplicationData();
      
      // Show success and close modal
      this.showSuccessMessage();
      
      // Clean up
      localStorage.removeItem('admasafrolink_application');
      
      setTimeout(() => {
        this.closeModal();
        this.resetForm();
      }, 3000);
      
    } catch (error) {
      console.error('Application submission failed:', error);
      this.showErrorMessage();
    }
  }

  async sendApplicationData() {
    try {
      // Use the API service to submit application
      const response = await window.apiService.submitApplication(this.formData);
      
      // Track successful submission
      this.trackEvent('application_api_success', {
        applicationId: response.id,
        formData: this.formData
      });
      
      return response;
    } catch (error) {
      // Track API errors
      this.trackEvent('application_api_error', {
        error: error.message,
        formData: this.formData
      });
      
      throw error;
    }
  }

  completeApplication() {
    this.submitApplication();
  }

  showSuccessMessage() {
    const currentStep = document.querySelector('.form-step.active');
    if (currentStep) {
      currentStep.innerHTML = `
        <div class="completion-step">
          <div class="completion-icon" style="background: #10b981;">
            <i class="fas fa-rocket"></i>
          </div>
          <h3 class="completion-title">Application Submitted Successfully!</h3>
          <p class="completion-message">
            🎉 Welcome to the AdmasAfroLink family! Check your email for next steps 
            and expect a call from our team within 24 hours.
          </p>
        </div>
      `;
    }
  }

  showErrorMessage() {
    this.showValidationError('Something went wrong. Please try again or contact our support team.');
    
    // Reset button
    const submitBtn = document.querySelector('.next-btn');
    if (submitBtn) {
      submitBtn.classList.remove('btn-loading');
      submitBtn.disabled = false;
    }
  }

  resetForm() {
    this.currentStep = 1;
    this.formData = {
      careerField: '',
      destination: '',
      firstName: '',
      lastName: '',
      email: '',
      phone: '',
      university: '',
      graduationYear: '',
      motivation: '',
      startDate: ''
    };
    
    this.updateStepDisplay();
    this.updateProgress();
    
    // Clear form inputs
    document.querySelectorAll('.application-form input, .application-form select, .application-form textarea').forEach(input => {
      input.value = '';
      input.checked = false;
      input.classList.remove('error');
    });
  }

  trackEvent(eventName, data = {}) {
    // Integration with analytics (Google Analytics, Mixpanel, etc.)
    if (typeof gtag !== 'undefined') {
      gtag('event', eventName, {
        custom_parameter: JSON.stringify(data)
      });
    }
    
    // Console log for development
    console.log('📊 Event:', eventName, data);
  }
}

// Initialize the application form when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  window.applicationForm = new ApplicationForm();
});

// Global functions for onclick handlers
function openApplication() {
  if (window.applicationForm) {
    window.applicationForm.openModal();
  }
}

function openFullApplication() {
  if (window.applicationForm) {
    window.applicationForm.openModal();
  }
}

function closeApplication() {
  if (window.applicationForm) {
    window.applicationForm.closeModal();
  }
}

function nextStep() {
  if (window.applicationForm) {
    window.applicationForm.nextStep();
  }
}

function previousStep() {
  if (window.applicationForm) {
    window.applicationForm.previousStep();
  }
}
