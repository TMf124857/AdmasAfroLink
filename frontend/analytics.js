/**
 * AdmasAfroLink Analytics & Optimization Framework
 * Comprehensive user behavior tracking, A/B testing, and conversion optimization
 */

class AdmasAnalytics {
    constructor() {
        this.sessionId = this.generateSessionId();
        this.userId = this.getUserId();
        this.startTime = Date.now();
        this.events = [];
        this.experiments = new Map();
        
        // Analytics configuration
        this.config = {
            trackingEnabled: true,
            debugMode: false,
            batchSize: 10,
            flushInterval: 30000, // 30 seconds
            storageKey: 'admas_analytics',
            apiEndpoint: '/api/analytics/track'
        };
        
        this.init();
    }
    
    init() {
        this.setupEventTracking();
        this.initializeExperiments();
        this.startSessionTracking();
        this.setupPerformanceTracking();
        this.initializeConversionFunnels();
        
        // Start periodic data flush
        setInterval(() => this.flushEvents(), this.config.flushInterval);
        
        // Track page load
        this.track('page_view', {
            url: window.location.href,
            title: document.title,
            referrer: document.referrer,
            userAgent: navigator.userAgent,
            timestamp: Date.now()
        });
    }
    
    generateSessionId() {
        return 'session_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }
    
    getUserId() {
        let userId = localStorage.getItem('admas_user_id');
        if (!userId) {
            userId = 'user_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
            localStorage.setItem('admas_user_id', userId);
        }
        return userId;
    }
    
    track(eventName, properties = {}) {
        if (!this.config.trackingEnabled) return;
        
        const event = {
            event: eventName,
            properties: {
                ...properties,
                session_id: this.sessionId,
                user_id: this.userId,
                timestamp: Date.now(),
                url: window.location.href,
                page_title: document.title
            }
        };
        
        this.events.push(event);
        
        if (this.config.debugMode) {
            console.log('Analytics Event:', event);
        }
        
        // Flush immediately for critical events
        const criticalEvents = ['form_submission', 'application_started', 'payment_initiated'];
        if (criticalEvents.includes(eventName)) {
            this.flushEvents();
        }
        
        // Auto-flush when batch size is reached
        if (this.events.length >= this.config.batchSize) {
            this.flushEvents();
        }
    }
    
    setupEventTracking() {
        // Form interaction tracking
        this.trackFormInteractions();
        
        // Button click tracking
        this.trackButtonClicks();
        
        // Scroll depth tracking
        this.trackScrollDepth();
        
        // Time on page tracking
        this.trackTimeOnPage();
        
        // Link click tracking
        this.trackLinkClicks();
        
        // Video interaction tracking
        this.trackVideoInteractions();
        
        // Search interactions
        this.trackSearchInteractions();
        
        // Pricing calculator usage
        this.trackPricingCalculator();
    }
    
    trackFormInteractions() {
        // Track form field focus and completion
        document.addEventListener('focusin', (e) => {
            if (e.target.tagName === 'INPUT' || e.target.tagName === 'SELECT' || e.target.tagName === 'TEXTAREA') {
                this.track('form_field_focus', {
                    field_name: e.target.name || e.target.id,
                    field_type: e.target.type || e.target.tagName.toLowerCase(),
                    form_name: this.getFormName(e.target)
                });
            }
        });
        
        // Track form completion
        document.addEventListener('change', (e) => {
            if (e.target.tagName === 'INPUT' || e.target.tagName === 'SELECT' || e.target.tagName === 'TEXTAREA') {
                this.track('form_field_completed', {
                    field_name: e.target.name || e.target.id,
                    field_type: e.target.type || e.target.tagName.toLowerCase(),
                    field_value_length: e.target.value.length,
                    form_name: this.getFormName(e.target)
                });
            }
        });
        
        // Track form submission
        document.addEventListener('submit', (e) => {
            const form = e.target;
            const formData = new FormData(form);
            const fields = {};
            for (let [key, value] of formData.entries()) {
                fields[key] = typeof value === 'string' ? value.length : 'file';
            }
            
            this.track('form_submission', {
                form_name: this.getFormName(form),
                fields_completed: Object.keys(fields),
                total_fields: form.querySelectorAll('input, select, textarea').length
            });
        });
    }
    
    trackButtonClicks() {
        document.addEventListener('click', (e) => {
            if (e.target.tagName === 'BUTTON' || e.target.classList.contains('btn')) {
                this.track('button_click', {
                    button_text: e.target.textContent.trim(),
                    button_class: e.target.className,
                    button_id: e.target.id,
                    section: this.getCurrentSection(e.target)
                });
            }
        });
    }
    
    trackScrollDepth() {
        let maxScroll = 0;
        const trackingPoints = [25, 50, 75, 90, 100];
        const tracked = new Set();
        
        const trackScroll = () => {
            const scrollPercent = Math.round((window.scrollY / (document.documentElement.scrollHeight - window.innerHeight)) * 100);
            
            if (scrollPercent > maxScroll) {
                maxScroll = scrollPercent;
            }
            
            trackingPoints.forEach(point => {
                if (scrollPercent >= point && !tracked.has(point)) {
                    tracked.add(point);
                    this.track('scroll_depth', {
                        depth_percent: point,
                        max_scroll: maxScroll
                    });
                }
            });
        };
        
        let scrollTimeout;
        window.addEventListener('scroll', () => {
            clearTimeout(scrollTimeout);
            scrollTimeout = setTimeout(trackScroll, 100);
        });
    }
    
    trackTimeOnPage() {
        const intervals = [30, 60, 120, 300, 600]; // 30s, 1m, 2m, 5m, 10m
        const tracked = new Set();
        
        setInterval(() => {
            const timeOnPage = Math.floor((Date.now() - this.startTime) / 1000);
            
            intervals.forEach(interval => {
                if (timeOnPage >= interval && !tracked.has(interval)) {
                    tracked.add(interval);
                    this.track('time_on_page', {
                        seconds: interval,
                        total_time: timeOnPage
                    });
                }
            });
        }, 1000);
    }
    
    trackLinkClicks() {
        document.addEventListener('click', (e) => {
            if (e.target.tagName === 'A') {
                this.track('link_click', {
                    link_text: e.target.textContent.trim(),
                    link_url: e.target.href,
                    link_target: e.target.target,
                    is_external: this.isExternalLink(e.target.href),
                    section: this.getCurrentSection(e.target)
                });
            }
        });
    }
    
    trackVideoInteractions() {
        document.querySelectorAll('video, iframe[src*="youtube"], iframe[src*="vimeo"]').forEach(video => {
            if (video.tagName === 'VIDEO') {
                video.addEventListener('play', () => {
                    this.track('video_play', {
                        video_src: video.src,
                        video_duration: video.duration
                    });
                });
                
                video.addEventListener('pause', () => {
                    this.track('video_pause', {
                        video_src: video.src,
                        current_time: video.currentTime,
                        progress_percent: (video.currentTime / video.duration) * 100
                    });
                });
                
                video.addEventListener('ended', () => {
                    this.track('video_completed', {
                        video_src: video.src,
                        video_duration: video.duration
                    });
                });
            }
        });
    }
    
    trackSearchInteractions() {
        document.querySelectorAll('input[type="search"], .search-input').forEach(searchInput => {
            let searchTimeout;
            
            searchInput.addEventListener('input', (e) => {
                clearTimeout(searchTimeout);
                searchTimeout = setTimeout(() => {
                    if (e.target.value.length >= 3) {
                        this.track('search_query', {
                            query: e.target.value,
                            query_length: e.target.value.length
                        });
                    }
                }, 1000);
            });
        });
    }
    
    trackPricingCalculator() {
        // Track calculator interactions
        document.querySelectorAll('#program-type, #industry-field, #support-level, #location-preference').forEach(select => {
            select.addEventListener('change', (e) => {
                this.track('pricing_calculator_change', {
                    field: e.target.id,
                    value: e.target.value,
                    total_cost: document.getElementById('total-cost')?.textContent
                });
            });
        });
        
        // Track payment plan selections
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('plan-option')) {
                this.track('payment_plan_selected', {
                    plan_type: e.target.querySelector('.plan-type')?.textContent,
                    plan_amount: e.target.querySelector('.plan-amount')?.textContent
                });
            }
        });
    }
    
    initializeExperiments() {
        // A/B Testing Framework
        this.experiments.set('pricing_display', this.runPricingExperiment());
        this.experiments.set('cta_text', this.runCTATextExperiment());
        this.experiments.set('form_layout', this.runFormLayoutExperiment());
        this.experiments.set('hero_message', this.runHeroMessageExperiment());
    }
    
    runPricingExperiment() {
        const variants = ['standard', 'discount_emphasis', 'value_emphasis'];
        const variant = this.getExperimentVariant('pricing_display', variants);
        
        this.track('experiment_exposure', {
            experiment: 'pricing_display',
            variant: variant
        });
        
        // Apply variant-specific changes
        switch (variant) {
            case 'discount_emphasis':
                this.emphasizeDiscounts();
                break;
            case 'value_emphasis':
                this.emphasizeValue();
                break;
        }
        
        return variant;
    }
    
    runCTATextExperiment() {
        const variants = ['standard', 'urgency', 'benefit_focused'];
        const variant = this.getExperimentVariant('cta_text', variants);
        
        const ctaTexts = {
            standard: 'Start Your Journey',
            urgency: 'Apply Today - Limited Spots',
            benefit_focused: 'Transform Your Career'
        };
        
        // Update CTA buttons
        document.querySelectorAll('.cta-primary').forEach(button => {
            if (ctaTexts[variant]) {
                button.textContent = ctaTexts[variant];
            }
        });
        
        this.track('experiment_exposure', {
            experiment: 'cta_text',
            variant: variant
        });
        
        return variant;
    }
    
    runFormLayoutExperiment() {
        const variants = ['single_column', 'multi_column', 'progressive'];
        const variant = this.getExperimentVariant('form_layout', variants);
        
        this.track('experiment_exposure', {
            experiment: 'form_layout',
            variant: variant
        });
        
        return variant;
    }
    
    runHeroMessageExperiment() {
        const variants = ['standard', 'benefit_focused', 'social_proof'];
        const variant = this.getExperimentVariant('hero_message', variants);
        
        const messages = {
            standard: 'Your European Internship Journey Starts Here',
            benefit_focused: 'Launch Your Career with a Guaranteed European Internship',
            social_proof: 'Join 2,000+ Africans Who Found Success in Europe'
        };
        
        const heroTitle = document.querySelector('.hero h1');
        if (heroTitle && messages[variant]) {
            heroTitle.textContent = messages[variant];
        }
        
        this.track('experiment_exposure', {
            experiment: 'hero_message',
            variant: variant
        });
        
        return variant;
    }
    
    getExperimentVariant(experimentName, variants) {
        const storageKey = `experiment_${experimentName}`;
        let variant = localStorage.getItem(storageKey);
        
        if (!variant) {
            // Assign user to variant based on user ID hash
            const hash = this.hashString(this.userId + experimentName);
            const index = hash % variants.length;
            variant = variants[index];
            localStorage.setItem(storageKey, variant);
        }
        
        return variant;
    }
    
    hashString(str) {
        let hash = 0;
        for (let i = 0; i < str.length; i++) {
            const char = str.charCodeAt(i);
            hash = ((hash << 5) - hash) + char;
            hash = hash & hash; // Convert to 32-bit integer
        }
        return Math.abs(hash);
    }
    
    initializeConversionFunnels() {
        // Define conversion funnel steps
        this.funnelSteps = [
            'page_view',
            'scroll_depth_25',
            'pricing_calculator_view',
            'application_started',
            'application_completed',
            'payment_initiated',
            'payment_completed'
        ];
        
        // Track funnel progression
        this.trackFunnelStep = (step) => {
            const funnelData = JSON.parse(localStorage.getItem('funnel_data') || '{}');
            funnelData[step] = Date.now();
            localStorage.setItem('funnel_data', JSON.stringify(funnelData));
            
            this.track('funnel_step', {
                step: step,
                funnel_position: this.funnelSteps.indexOf(step) + 1,
                time_since_start: Date.now() - this.startTime
            });
        };
    }
    
    setupPerformanceTracking() {
        // Page load performance
        window.addEventListener('load', () => {
            setTimeout(() => {
                const perfData = performance.getEntriesByType('navigation')[0];
                if (perfData) {
                    this.track('performance_metrics', {
                        load_time: perfData.loadEventEnd - perfData.loadEventStart,
                        dom_content_loaded: perfData.domContentLoadedEventEnd - perfData.domContentLoadedEventStart,
                        first_byte: perfData.responseStart - perfData.requestStart,
                        dns_lookup: perfData.domainLookupEnd - perfData.domainLookupStart
                    });
                }
            }, 1000);
        });
        
        // Core Web Vitals tracking
        if (typeof PerformanceObserver !== 'undefined') {
            this.trackCoreWebVitals();
        }
    }
    
    trackCoreWebVitals() {
        // Largest Contentful Paint (LCP)
        new PerformanceObserver((entryList) => {
            const entries = entryList.getEntries();
            const lastEntry = entries[entries.length - 1];
            this.track('core_web_vitals', {
                metric: 'LCP',
                value: lastEntry.startTime
            });
        }).observe({ entryTypes: ['largest-contentful-paint'] });
        
        // First Input Delay (FID)
        new PerformanceObserver((entryList) => {
            for (const entry of entryList.getEntries()) {
                this.track('core_web_vitals', {
                    metric: 'FID',
                    value: entry.processingStart - entry.startTime
                });
            }
        }).observe({ entryTypes: ['first-input'] });
        
        // Cumulative Layout Shift (CLS)
        let clsValue = 0;
        new PerformanceObserver((entryList) => {
            for (const entry of entryList.getEntries()) {
                if (!entry.hadRecentInput) {
                    clsValue += entry.value;
                }
            }
            this.track('core_web_vitals', {
                metric: 'CLS',
                value: clsValue
            });
        }).observe({ entryTypes: ['layout-shift'] });
    }
    
    // Helper methods
    getFormName(element) {
        const form = element.closest('form');
        return form ? (form.id || form.className || 'unnamed_form') : 'no_form';
    }
    
    getCurrentSection(element) {
        const section = element.closest('section, .section');
        return section ? (section.id || section.className.split(' ')[0] || 'unnamed_section') : 'no_section';
    }
    
    isExternalLink(url) {
        try {
            const link = new URL(url);
            return link.hostname !== window.location.hostname;
        } catch {
            return false;
        }
    }
    
    emphasizeDiscounts() {
        document.querySelectorAll('.original-price').forEach(element => {
            element.style.fontSize = '1.2rem';
            element.style.textDecoration = 'line-through';
            element.style.color = '#ef4444';
        });
        
        document.querySelectorAll('.price').forEach(element => {
            element.style.color = '#38a169';
            element.style.fontWeight = '800';
        });
    }
    
    emphasizeValue() {
        document.querySelectorAll('.roi-value').forEach(element => {
            element.style.fontSize = '1.8rem';
            element.style.color = '#3182ce';
        });
        
        document.querySelectorAll('.guarantee-stats').forEach(element => {
            element.style.background = 'linear-gradient(135deg, #38a169, #2d7d50)';
            element.style.padding = '20px';
            element.style.borderRadius = '10px';
        });
    }
    
    flushEvents() {
        if (this.events.length === 0) return;
        
        const eventsToSend = [...this.events];
        this.events = [];
        
        // Send to analytics service
        this.sendToAnalytics(eventsToSend);
        
        // Store locally as backup
        this.storeEventsLocally(eventsToSend);
    }
    
    async sendToAnalytics(events) {
        try {
            const response = await fetch(this.config.apiEndpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    events: events,
                    session_id: this.sessionId,
                    user_id: this.userId
                })
            });
            
            if (this.config.debugMode) {
                console.log('Analytics sent:', response.status);
            }
        } catch (error) {
            if (this.config.debugMode) {
                console.error('Analytics error:', error);
            }
            // Re-add events for retry
            this.events.unshift(...events);
        }
    }
    
    storeEventsLocally(events) {
        try {
            const stored = JSON.parse(localStorage.getItem(this.config.storageKey) || '[]');
            const combined = [...stored, ...events];
            
            // Keep only last 1000 events
            const trimmed = combined.slice(-1000);
            
            localStorage.setItem(this.config.storageKey, JSON.stringify(trimmed));
        } catch (error) {
            if (this.config.debugMode) {
                console.error('Local storage error:', error);
            }
        }
    }
    
    // Public API methods
    trackConversion(conversionType, value = null) {
        this.track('conversion', {
            type: conversionType,
            value: value,
            timestamp: Date.now()
        });
    }
    
    trackExperimentConversion(experimentName, variant) {
        this.track('experiment_conversion', {
            experiment: experimentName,
            variant: variant,
            timestamp: Date.now()
        });
    }
    
    setUserProperty(property, value) {
        this.track('user_property', {
            property: property,
            value: value
        });
    }
    
    getAnalyticsData() {
        return {
            sessionId: this.sessionId,
            userId: this.userId,
            events: this.events,
            experiments: Object.fromEntries(this.experiments)
        };
    }
}

// Initialize analytics when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    window.admasAnalytics = new AdmasAnalytics();
    
    // Make analytics methods available globally
    window.trackEvent = (event, properties) => window.admasAnalytics.track(event, properties);
    window.trackConversion = (type, value) => window.admasAnalytics.trackConversion(type, value);
});

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
    module.exports = AdmasAnalytics;
}
