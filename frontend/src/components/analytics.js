/**
 * Analytics & Optimization Controller
 * Implements user behavior tracking, A/B testing, and conversion optimization
 */

class AnalyticsController {
  constructor() {
    this.sessionId = this.generateSessionId();
    this.startTime = Date.now();
    this.events = [];
    this.userBehavior = {
      scrollDepth: 0,
      timeOnPage: 0,
      clicks: 0,
      formInteractions: 0,
      rageClicks: 0,
      deadClicks: 0
    };
    
    this.init();
  }

  init() {
    this.setupUserBehaviorTracking();
    this.setupFormAnalytics();
    this.setupPerformanceTracking();
    this.setupConversionTracking();
    this.setupHeatmapTracking();
    this.startSessionTracking();
  }

  generateSessionId() {
    return 'AFL_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
  }

  setupUserBehaviorTracking() {
    // Scroll depth tracking
    let maxScrollDepth = 0;
    let scrollCheckpoints = [25, 50, 75, 100];
    let reachedCheckpoints = [];

    window.addEventListener('scroll', () => {
      const scrollPercent = Math.round(
        (window.scrollY / (document.documentElement.scrollHeight - window.innerHeight)) * 100
      );
      
      if (scrollPercent > maxScrollDepth) {
        maxScrollDepth = scrollPercent;
        this.userBehavior.scrollDepth = maxScrollDepth;
      }

      // Track scroll milestones
      scrollCheckpoints.forEach(checkpoint => {
        if (scrollPercent >= checkpoint && !reachedCheckpoints.includes(checkpoint)) {
          reachedCheckpoints.push(checkpoint);
          this.trackEvent('scroll_depth', {
            depth: checkpoint,
            time_to_reach: Date.now() - this.startTime
          });
        }
      });
    });

    // Click tracking with rage click detection
    let clickTimestamps = [];
    document.addEventListener('click', (e) => {
      const now = Date.now();
      clickTimestamps.push(now);
      
      // Clean old timestamps (older than 3 seconds)
      clickTimestamps = clickTimestamps.filter(timestamp => now - timestamp < 3000);
      
      this.userBehavior.clicks++;
      
      // Detect rage clicks (4+ clicks in 3 seconds on same element)
      if (clickTimestamps.length >= 4) {
        this.userBehavior.rageClicks++;
        this.trackEvent('rage_click', {
          element: this.getElementSelector(e.target),
          click_count: clickTimestamps.length
        });
      }

      // Track dead clicks (clicks that don't trigger any action)
      setTimeout(() => {
        if (!this.elementHasAction(e.target)) {
          this.userBehavior.deadClicks++;
          this.trackEvent('dead_click', {
            element: this.getElementSelector(e.target)
          });
        }
      }, 100);

      // Track CTA clicks
      if (e.target.matches('.btn-primary, .btn-secondary, .nav-cta')) {
        this.trackEvent('cta_click', {
          button_text: e.target.textContent.trim(),
          button_type: e.target.className,
          position: this.getElementPosition(e.target)
        });
      }
    });

    // Mouse movement tracking for user engagement
    let mouseMovements = 0;
    let lastMouseMove = 0;
    
    document.addEventListener('mousemove', () => {
      const now = Date.now();
      if (now - lastMouseMove > 100) { // Throttle to every 100ms
        mouseMovements++;
        lastMouseMove = now;
      }
    });

    // Track user engagement every 30 seconds
    setInterval(() => {
      this.trackEvent('user_engagement', {
        mouse_movements: mouseMovements,
        time_active: Date.now() - this.startTime,
        scroll_depth: this.userBehavior.scrollDepth
      });
      mouseMovements = 0; // Reset counter
    }, 30000);
  }

  setupFormAnalytics() {
    // Form abandonment tracking
    const forms = document.querySelectorAll('form, .application-form');
    
    forms.forEach(form => {
      let formStarted = false;
      let formFields = {};
      
      form.addEventListener('input', (e) => {
        if (!formStarted) {
          formStarted = true;
          this.trackEvent('form_started', {
            form_id: form.id || 'unknown',
            first_field: e.target.name
          });
        }
        
        formFields[e.target.name] = e.target.value.length;
        this.userBehavior.formInteractions++;
        
        // Track field completion
        if (e.target.value.trim()) {
          this.trackEvent('form_field_completed', {
            field: e.target.name,
            form_id: form.id || 'unknown'
          });
        }
      });

      // Track form abandonment on page unload
      window.addEventListener('beforeunload', () => {
        if (formStarted && !this.isFormSubmitted) {
          this.trackEvent('form_abandoned', {
            form_id: form.id || 'unknown',
            fields_completed: Object.keys(formFields).length,
            completion_percentage: this.calculateFormCompletion(formFields)
          });
        }
      });
    });

    // Form error tracking
    document.addEventListener('DOMNodeInserted', (e) => {
      if (e.target.classList && e.target.classList.contains('form-error')) {
        this.trackEvent('form_error', {
          error_message: e.target.textContent,
          field: e.target.previousElementSibling?.name || 'unknown'
        });
      }
    });
  }

  setupPerformanceTracking() {
    // Page load performance
    window.addEventListener('load', () => {
      setTimeout(() => {
        const perfData = performance.getEntriesByType('navigation')[0];
        
        this.trackEvent('page_performance', {
          load_time: perfData.loadEventEnd - perfData.loadEventStart,
          dom_ready: perfData.domContentLoadedEventEnd - perfData.domContentLoadedEventStart,
          first_paint: performance.getEntriesByType('paint')[0]?.startTime || 0,
          connection_type: navigator.connection?.effectiveType || 'unknown'
        });
      }, 0);
    });

    // Core Web Vitals tracking
    this.trackCoreWebVitals();
  }

  setupConversionTracking() {
    // Conversion funnel tracking
    const conversionSteps = [
      { selector: '.hero', step: 'landing_view' },
      { selector: '.anxiety-address', step: 'problem_awareness' },
      { selector: '.application-preview', step: 'solution_interest' },
      { selector: '.success-stories', step: 'social_proof' },
      { selector: '.pricing-transparency', step: 'pricing_view' },
      { selector: '.final-cta', step: 'final_cta_view' }
    ];

    // Track when user reaches each funnel step
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const step = conversionSteps.find(s => entry.target.matches(s.selector));
          if (step) {
            this.trackEvent('funnel_step', {
              step: step.step,
              time_to_reach: Date.now() - this.startTime
            });
          }
        }
      });
    }, { threshold: 0.5 });

    conversionSteps.forEach(step => {
      const element = document.querySelector(step.selector);
      if (element) observer.observe(element);
    });

    // Track micro-conversions
    this.trackMicroConversions();
  }

  setupHeatmapTracking() {
    // Simple click heatmap data collection
    document.addEventListener('click', (e) => {
      const rect = e.target.getBoundingClientRect();
      const viewportWidth = window.innerWidth;
      const viewportHeight = window.innerHeight;
      
      this.trackEvent('click_heatmap', {
        x: Math.round((e.clientX / viewportWidth) * 100),
        y: Math.round((e.clientY / viewportHeight) * 100),
        element: this.getElementSelector(e.target),
        viewport_width: viewportWidth,
        viewport_height: viewportHeight
      });
    });
  }

  trackMicroConversions() {
    // Email hover (interest in contact)
    document.querySelectorAll('[href^="mailto:"]').forEach(link => {
      link.addEventListener('mouseenter', () => {
        this.trackEvent('email_hover', { email: link.href });
      });
    });

    // Phone number hover
    document.querySelectorAll('[href^="tel:"]').forEach(link => {
      link.addEventListener('mouseenter', () => {
        this.trackEvent('phone_hover', { phone: link.href });
      });
    });

    // Video play tracking
    document.querySelectorAll('video').forEach(video => {
      video.addEventListener('play', () => {
        this.trackEvent('video_play', { video_src: video.src });
      });
    });

    // Social media link clicks
    document.querySelectorAll('.social-links a').forEach(link => {
      link.addEventListener('click', () => {
        this.trackEvent('social_click', { 
          platform: this.getSocialPlatform(link.href),
          position: 'footer'
        });
      });
    });
  }

  startSessionTracking() {
    // Track session duration every minute
    setInterval(() => {
      this.userBehavior.timeOnPage = Date.now() - this.startTime;
      this.trackEvent('session_ping', {
        duration: this.userBehavior.timeOnPage,
        engagement_score: this.calculateEngagementScore()
      });
    }, 60000);

    // Track session end
    window.addEventListener('beforeunload', () => {
      this.trackEvent('session_end', {
        total_time: Date.now() - this.startTime,
        final_engagement_score: this.calculateEngagementScore(),
        user_behavior: this.userBehavior
      });
    });

    // Track tab visibility changes
    document.addEventListener('visibilitychange', () => {
      this.trackEvent('tab_visibility', {
        visible: !document.hidden,
        time: Date.now() - this.startTime
      });
    });
  }

  trackCoreWebVitals() {
    // Largest Contentful Paint
    new PerformanceObserver((entryList) => {
      const entries = entryList.getEntries();
      const lastEntry = entries[entries.length - 1];
      this.trackEvent('core_web_vital', {
        metric: 'LCP',
        value: lastEntry.startTime,
        rating: lastEntry.startTime > 4000 ? 'poor' : lastEntry.startTime > 2500 ? 'needs_improvement' : 'good'
      });
    }).observe({entryTypes: ['largest-contentful-paint']});

    // First Input Delay
    new PerformanceObserver((entryList) => {
      const firstInput = entryList.getEntries()[0];
      this.trackEvent('core_web_vital', {
        metric: 'FID',
        value: firstInput.processingStart - firstInput.startTime,
        rating: firstInput.processingStart - firstInput.startTime > 300 ? 'poor' : 
                firstInput.processingStart - firstInput.startTime > 100 ? 'needs_improvement' : 'good'
      });
    }).observe({entryTypes: ['first-input']});
  }

  calculateEngagementScore() {
    // Simple engagement scoring algorithm
    let score = 0;
    
    // Time on page (max 30 points)
    const timeMinutes = (Date.now() - this.startTime) / 60000;
    score += Math.min(timeMinutes * 2, 30);
    
    // Scroll depth (max 25 points)
    score += (this.userBehavior.scrollDepth / 100) * 25;
    
    // Form interactions (max 20 points)
    score += Math.min(this.userBehavior.formInteractions * 2, 20);
    
    // Clicks (max 15 points)
    score += Math.min(this.userBehavior.clicks, 15);
    
    // Penalties for negative behaviors
    score -= this.userBehavior.rageClicks * 5;
    score -= this.userBehavior.deadClicks * 2;
    
    return Math.max(0, Math.round(score));
  }

  calculateFormCompletion(formFields) {
    const totalFields = Object.keys(formFields).length;
    const completedFields = Object.values(formFields).filter(value => value > 0).length;
    return totalFields > 0 ? Math.round((completedFields / totalFields) * 100) : 0;
  }

  getElementSelector(element) {
    if (element.id) return `#${element.id}`;
    if (element.className) return `.${element.className.split(' ')[0]}`;
    return element.tagName.toLowerCase();
  }

  getElementPosition(element) {
    const rect = element.getBoundingClientRect();
    return {
      x: Math.round(rect.left + rect.width / 2),
      y: Math.round(rect.top + rect.height / 2),
      section: this.getCurrentSection(element)
    };
  }

  getCurrentSection(element) {
    const section = element.closest('section');
    return section ? section.id || section.className.split(' ')[0] : 'unknown';
  }

  elementHasAction(element) {
    return element.matches('a, button, [onclick], [href], input, select, textarea') ||
           element.closest('a, button, [onclick], [href]');
  }

  getSocialPlatform(url) {
    if (url.includes('facebook')) return 'facebook';
    if (url.includes('twitter')) return 'twitter';
    if (url.includes('linkedin')) return 'linkedin';
    if (url.includes('instagram')) return 'instagram';
    return 'unknown';
  }

  trackEvent(eventName, data = {}) {
    const event = {
      event: eventName,
      timestamp: Date.now(),
      session_id: this.sessionId,
      user_agent: navigator.userAgent,
      viewport: {
        width: window.innerWidth,
        height: window.innerHeight
      },
      url: window.location.href,
      ...data
    };

    this.events.push(event);

    // Send to analytics platforms
    this.sendToAnalytics(event);
    
    // Console log for development
    console.log('📊 Analytics:', eventName, data);
  }

  sendToAnalytics(event) {
    // Google Analytics 4
    if (typeof gtag !== 'undefined') {
      gtag('event', event.event, {
        custom_parameter: JSON.stringify(event),
        engagement_time_msec: Date.now() - this.startTime
      });
    }

    // Custom analytics endpoint
    if (window.ANALYTICS_ENDPOINT) {
      fetch(window.ANALYTICS_ENDPOINT, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(event)
      }).catch(err => console.warn('Analytics send failed:', err));
    }

    // Local storage for development/testing
    if (process.env.NODE_ENV === 'development') {
      const stored = JSON.parse(localStorage.getItem('admasafrolink_analytics') || '[]');
      stored.push(event);
      localStorage.setItem('admasafrolink_analytics', JSON.stringify(stored.slice(-100))); // Keep last 100 events
    }
  }

  // A/B Testing framework
  abTest(testName, variants, callback) {
    const userId = this.getUserId();
    const variantIndex = this.hashCode(userId + testName) % variants.length;
    const selectedVariant = variants[variantIndex];
    
    this.trackEvent('ab_test_assigned', {
      test_name: testName,
      variant: selectedVariant,
      variant_index: variantIndex
    });
    
    callback(selectedVariant);
    return selectedVariant;
  }

  getUserId() {
    let userId = localStorage.getItem('admasafrolink_user_id');
    if (!userId) {
      userId = 'user_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
      localStorage.setItem('admasafrolink_user_id', userId);
    }
    return userId;
  }

  hashCode(str) {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32-bit integer
    }
    return Math.abs(hash);
  }

  // Export analytics data for analysis
  exportData() {
    return {
      session_id: this.sessionId,
      start_time: this.startTime,
      events: this.events,
      user_behavior: this.userBehavior,
      engagement_score: this.calculateEngagementScore()
    };
  }
}

// Initialize analytics when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  window.analytics = new AnalyticsController();
  
  // Example A/B tests
  // Test hero headline
  window.analytics.abTest('hero_headline', [
    'Transform Your Career with Global Internships',
    'Launch Your International Career Today',
    'Get Your Dream Job with Global Experience'
  ], (variant) => {
    const heroTitle = document.querySelector('.hero-title');
    if (heroTitle) {
      heroTitle.innerHTML = variant + ' <span class="highlight">Global Internships</span>';
    }
  });
  
  // Test CTA button text
  window.analytics.abTest('cta_button', [
    'Start Your Global Career',
    'Begin Your Journey',
    'Get Started Now'
  ], (variant) => {
    document.querySelectorAll('.btn-primary').forEach(btn => {
      if (btn.textContent.includes('Start Your')) {
        btn.innerHTML = `${variant} <i class="fas fa-arrow-right"></i>`;
      }
    });
  });
});

// Global function to track custom events
window.trackEvent = function(eventName, data = {}) {
  if (window.analytics) {
    window.analytics.trackEvent(eventName, data);
  }
};
