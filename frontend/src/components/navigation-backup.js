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
    const navbar = document.getElementById('navbar');
    if (!navbar) return;

    const scrollY = window.scrollY;

    // Add/remove scrolled class for styling
    if (scrollY > this.scrollThreshold) {
      navbar.classList.add('scrolled');
    } else {
      navbar.classList.remove('scrolled');
    }

    // Update active navigation based on scroll position
    this.updateActiveNavigation();
  }

  setupSmoothScrolling() {
    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', (e) => {
        e.preventDefault();
        
        const targetId = anchor.getAttribute('href');
        const targetElement = document.querySelector(targetId);
        
        if (targetElement) {
          const headerOffset = 80; // Account for fixed navbar
          const elementPosition = targetElement.offsetTop;
          const offsetPosition = elementPosition - headerOffset;

          window.scrollTo({
            top: offsetPosition,
            behavior: 'smooth'
          });

          // Track navigation clicks
          this.trackEvent('navigation_click', {
            target: targetId,
            source: 'navbar'
          });
        }
      });
    });
  }

  setupActiveNavigation() {
    // Create intersection observer for sections
    const sections = document.querySelectorAll('section[id]');
    const navLinks = document.querySelectorAll('.nav-link[href^="#"]');

    if (sections.length === 0 || navLinks.length === 0) return;

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            this.setActiveNavLink(entry.target.id);
          }
        });
      },
      {
        rootMargin: '-100px 0px -50% 0px',
        threshold: 0.1
      }
    );

    sections.forEach(section => {
      observer.observe(section);
    });
  }

  setActiveNavLink(activeId) {
    // Remove active class from all nav links
    document.querySelectorAll('.nav-link').forEach(link => {
      link.classList.remove('active');
    });

    // Add active class to current section link
    const activeLink = document.querySelector(`.nav-link[href="#${activeId}"]`);
    if (activeLink) {
      activeLink.classList.add('active');
    }
  }

  updateActiveNavigation() {
    // Alternative method for updating active navigation on scroll
    const sections = document.querySelectorAll('section[id]');
    const scrollPos = window.scrollY + 150; // Offset for better UX

    sections.forEach(section => {
      const sectionTop = section.offsetTop;
      const sectionHeight = section.offsetHeight;
      const sectionId = section.getAttribute('id');

      if (scrollPos >= sectionTop && scrollPos < sectionTop + sectionHeight) {
        this.setActiveNavLink(sectionId);
      }
    });
  }

  trackEvent(eventName, data = {}) {
    // Analytics tracking
    if (typeof gtag !== 'undefined') {
      gtag('event', eventName, {
        custom_parameter: JSON.stringify(data)
      });
    }
    
    console.log('📊 Navigation Event:', eventName, data);
  }
}

/**
 * Scroll to Top Button
 */
class ScrollToTop {
  constructor() {
    this.button = null;
    this.init();
  }

  init() {
    this.createButton();
    this.bindEvents();
  }

  createButton() {
    // Create scroll to top button
    this.button = document.createElement('button');
    this.button.innerHTML = '<i class="fas fa-arrow-up"></i>';
    this.button.className = 'scroll-to-top';
    this.button.setAttribute('aria-label', 'Scroll to top');
    
    // Styles
    this.button.style.cssText = `
      position: fixed;
      bottom: 80px;
      right: 20px;
      width: 50px;
      height: 50px;
      background: var(--primary-color);
      color: white;
      border: none;
      border-radius: 50%;
      cursor: pointer;
      opacity: 0;
      visibility: hidden;
      transition: all 0.3s ease;
      z-index: 999;
      box-shadow: 0 4px 12px rgba(37, 99, 235, 0.4);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 18px;
    `;

    document.body.appendChild(this.button);
  }

  bindEvents() {
    // Show/hide button based on scroll position
    window.addEventListener('scroll', () => {
      if (window.scrollY > 500) {
        this.button.style.opacity = '1';
        this.button.style.visibility = 'visible';
      } else {
        this.button.style.opacity = '0';
        this.button.style.visibility = 'hidden';
      }
    });

    // Scroll to top on click
    this.button.addEventListener('click', () => {
      window.scrollTo({
        top: 0,
        behavior: 'smooth'
      });

      // Track usage
      if (typeof gtag !== 'undefined') {
        gtag('event', 'scroll_to_top', {
          event_category: 'navigation'
        });
      }
    });

    // Hover effects
    this.button.addEventListener('mouseenter', () => {
      this.button.style.transform = 'translateY(-2px)';
      this.button.style.boxShadow = '0 6px 20px rgba(37, 99, 235, 0.5)';
    });

    this.button.addEventListener('mouseleave', () => {
      this.button.style.transform = 'translateY(0)';
      this.button.style.boxShadow = '0 4px 12px rgba(37, 99, 235, 0.4)';
    });
  }
}

/**
 * Loading Animation
 */
class PageLoader {
  constructor() {
    this.init();
  }

  init() {
    // Create loading overlay
    const loader = document.createElement('div');
    loader.id = 'page-loader';
    loader.innerHTML = `
      <div class="loader-content">
        <div class="loader-spinner"></div>
        <p>Loading your global career journey...</p>
      </div>
    `;
    
    loader.style.cssText = `
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: linear-gradient(135deg, var(--primary-color), #3b82f6);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 9999;
      opacity: 1;
      transition: opacity 0.5s ease;
    `;

    // Add styles for loader content
    const style = document.createElement('style');
    style.textContent = `
      .loader-content {
        text-align: center;
        color: white;
      }
      
      .loader-spinner {
        width: 50px;
        height: 50px;
        border: 4px solid rgba(255, 255, 255, 0.3);
        border-top: 4px solid white;
        border-radius: 50%;
        animation: spin 1s linear infinite;
        margin: 0 auto 20px;
      }
      
      @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
      }
      
      .loader-content p {
        font-size: 18px;
        font-weight: 500;
        margin: 0;
        opacity: 0.9;
      }
    `;
    
    document.head.appendChild(style);
    document.body.appendChild(loader);

    // Hide loader when page is fully loaded
    window.addEventListener('load', () => {
      setTimeout(() => {
        loader.style.opacity = '0';
        setTimeout(() => {
          loader.remove();
        }, 500);
      }, 1000); // Minimum loading time for better UX
    });
  }
}

// Initialize components when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  // Initialize navigation
  window.navigationController = new NavigationController();
  
  // Initialize scroll to top
  new ScrollToTop();
  
  // Initialize page loader
  new PageLoader();
  
  // Add CSS for scrolled navbar
  const style = document.createElement('style');
  style.textContent = `
    .navbar.scrolled {
      background: rgba(255, 255, 255, 0.98);
      box-shadow: 0 2px 20px rgba(0, 0, 0, 0.1);
    }
    
    .nav-link.active {
      color: var(--primary-color) !important;
      font-weight: 600;
    }
    
    @media (min-width: 768px) {
      .nav-link.active::after {
        content: '';
        position: absolute;
        bottom: -4px;
        left: 50%;
        transform: translateX(-50%);
        width: 20px;
        height: 2px;
        background: var(--primary-color);
        border-radius: 1px;
      }
      
      .nav-link {
        position: relative;
      }
    }
  `;
  
  document.head.appendChild(style);
});

// Keyboard navigation helpers
document.addEventListener('keydown', (e) => {
  // Skip to main content with Tab key
  if (e.key === 'Tab' && !e.shiftKey && document.activeElement === document.body) {
    e.preventDefault();
    const mainContent = document.querySelector('main') || document.querySelector('.hero');
    if (mainContent) {
      mainContent.focus();
    }
  }
});
