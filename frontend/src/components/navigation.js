/**
 * Enhanced Navigation Controller - Multi-Stakeholder Platform
 * Implements smooth scrolling, mobile menu, portal dropdowns, and responsive behavior
 */

class NavigationController {
  constructor() {
    this.isMenuOpen = false;
    this.scrollThreshold = 100;
    this.init();
  }

  init() {
    this.bindEvents();
    this.setupSmoothScrolling();
    this.handleScroll();
    this.setupActiveNavigation();
    this.setupPortalDropdown();
    this.setupWorkflowTabs();
  }

  bindEvents() {
    // Mobile menu toggle
    const navToggle = document.getElementById('nav-toggle');
    const navMenu = document.getElementById('nav-menu');

    if (navToggle && navMenu) {
      navToggle.addEventListener('click', () => {
        this.toggleMobileMenu();
      });
    }

    // Close menu when clicking on links
    document.querySelectorAll('.nav-link').forEach(link => {
      link.addEventListener('click', () => {
        this.closeMobileMenu();
      });
    });

    // Close menu when clicking outside
    document.addEventListener('click', (e) => {
      if (this.isMenuOpen && !e.target.closest('.navbar')) {
        this.closeMobileMenu();
      }
    });

    // Handle window resize
    window.addEventListener('resize', () => {
      if (window.innerWidth >= 768 && this.isMenuOpen) {
        this.closeMobileMenu();
      }
    });

    // Scroll event for navbar effects
    window.addEventListener('scroll', () => {
      this.handleScroll();
    });

    // Escape key to close menu
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && this.isMenuOpen) {
        this.closeMobileMenu();
      }
    });
  }

  setupPortalDropdown() {
    const portalTrigger = document.getElementById('portal-trigger');
    const portalMenu = document.getElementById('portal-menu');
    
    if (portalTrigger && portalMenu) {
      portalTrigger.addEventListener('click', (e) => {
        e.preventDefault();
        portalMenu.classList.toggle('show');
      });

      // Close dropdown when clicking outside
      document.addEventListener('click', (e) => {
        if (!portalTrigger.contains(e.target) && !portalMenu.contains(e.target)) {
          portalMenu.classList.remove('show');
        }
      });

      // Handle portal link clicks
      const portalLinks = portalMenu.querySelectorAll('.portal-link');
      portalLinks.forEach(link => {
        link.addEventListener('click', (e) => {
          e.preventDefault();
          const href = link.getAttribute('href');
          this.handlePortalRedirect(href);
          portalMenu.classList.remove('show');
        });
      });
    }
  }

  handlePortalRedirect(href) {
    // Track portal access for analytics
    if (window.trackEvent) {
      const portalType = href.replace('#', '').replace('-login', '');
      window.trackEvent('portal_access_attempt', {
        portal_type: portalType,
        source: 'navigation_dropdown'
      });
    }

    // Portal redirect logic
    const portalInfo = {
      '#student-login': {
        title: 'Student Portal Access',
        description: 'Access your student dashboard to apply for internships, track progress, and manage your profile.',
        url: '/portal/student'
      },
      '#company-login': {
        title: 'Company Portal Access', 
        description: 'Post internship opportunities, review applications, and manage your intern relationships.',
        url: '/portal/company'
      },
      '#university-login': {
        title: 'University Portal Access',
        description: 'Oversee student placements, manage partnerships, and track academic outcomes.',
        url: '/portal/university'
      }
    };

    const portal = portalInfo[href];
    if (portal) {
      // For demo purposes, show modal instead of redirect
      this.showPortalModal(portal);
    }
  }

  showPortalModal(portal) {
    // Create and show modal
    alert(`${portal.title}\n\n${portal.description}\n\nThis would redirect to ${portal.url} in a live system.`);
  }

  setupWorkflowTabs() {
    const tabButtons = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');

    tabButtons.forEach(button => {
      button.addEventListener('click', () => {
        const targetTab = button.getAttribute('data-tab');
        
        // Remove active class from all buttons and contents
        tabButtons.forEach(btn => btn.classList.remove('active'));
        tabContents.forEach(content => content.classList.remove('active'));
        
        // Add active class to clicked button and corresponding content
        button.classList.add('active');
        const targetContent = document.getElementById(`${targetTab}-tab`);
        if (targetContent) {
          targetContent.classList.add('active');
        }

        // Track tab interaction
        if (window.trackEvent) {
          window.trackEvent('workflow_tab_click', {
            tab: targetTab,
            section: 'platform_overview'
          });
        }
      });
    });
  }

  toggleMobileMenu() {
    const navToggle = document.getElementById('nav-toggle');
    const navMenu = document.getElementById('nav-menu');

    if (!navToggle || !navMenu) return;

    this.isMenuOpen = !this.isMenuOpen;

    navToggle.classList.toggle('active', this.isMenuOpen);
    navMenu.classList.toggle('active', this.isMenuOpen);

    // Prevent scrolling when menu is open
    document.body.style.overflow = this.isMenuOpen ? 'hidden' : '';

    // Track menu usage
    this.trackEvent('mobile_menu_toggle', { 
      action: this.isMenuOpen ? 'open' : 'close' 
    });
  }

  closeMobileMenu() {
    if (!this.isMenuOpen) return;

    const navToggle = document.getElementById('nav-toggle');
    const navMenu = document.getElementById('nav-menu');

    this.isMenuOpen = false;

    if (navToggle) navToggle.classList.remove('active');
    if (navMenu) navMenu.classList.remove('active');

    document.body.style.overflow = '';
  }

  handleScroll() {
    const navbar = document.querySelector('.navbar');
    if (!navbar) return;

    const isScrolled = window.pageYOffset > this.scrollThreshold;
    navbar.classList.toggle('scrolled', isScrolled);

    // Update active navigation
    this.updateActiveNavigation();
  }

  setupSmoothScrolling() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', (e) => {
        const href = anchor.getAttribute('href');
        
        // Skip portal links and application CTA
        if (href.includes('login') || href === '#application') {
          return;
        }

        e.preventDefault();
        const target = document.querySelector(href);
        
        if (target) {
          const navbar = document.querySelector('.navbar');
          const navbarHeight = navbar ? navbar.offsetHeight : 80;
          const targetPosition = target.offsetTop - navbarHeight - 20;
          
          window.scrollTo({
            top: targetPosition,
            behavior: 'smooth'
          });

          // Close mobile menu if open
          this.closeMobileMenu();

          // Track navigation
          this.trackEvent('smooth_scroll', {
            target: href,
            from_mobile: this.isMenuOpen
          });
        }
      });
    });
  }

  setupActiveNavigation() {
    // Setup intersection observer for section visibility
    const sections = document.querySelectorAll('section[id]');
    const navLinks = document.querySelectorAll('.nav-link[href^="#"]');

    if (sections.length === 0 || navLinks.length === 0) return;

    const observerOptions = {
      threshold: 0.3,
      rootMargin: '-100px 0px -50% 0px'
    };

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const id = entry.target.getAttribute('id');
          this.setActiveNavLink(id);
        }
      });
    }, observerOptions);

    sections.forEach(section => observer.observe(section));
  }

  setActiveNavLink(activeId) {
    const navLinks = document.querySelectorAll('.nav-link[href^="#"]');
    
    navLinks.forEach(link => {
      const href = link.getAttribute('href');
      link.classList.toggle('active', href === `#${activeId}`);
    });
  }

  updateActiveNavigation() {
    // Fallback for browsers that don't support Intersection Observer
    if ('IntersectionObserver' in window) return;

    const sections = document.querySelectorAll('section[id]');
    const scrollPos = window.pageYOffset + 150;

    sections.forEach(section => {
      const top = section.offsetTop;
      const bottom = top + section.offsetHeight;

      if (scrollPos >= top && scrollPos <= bottom) {
        const id = section.getAttribute('id');
        this.setActiveNavLink(id);
      }
    });
  }

  trackEvent(eventName, data = {}) {
    if (typeof window.trackEvent === 'function') {
      window.trackEvent(eventName, {
        timestamp: new Date().toISOString(),
        ...data
      });
    }
  }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  new NavigationController();
});

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = NavigationController;
}
