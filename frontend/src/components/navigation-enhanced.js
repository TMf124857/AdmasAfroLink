/**
 * Enhanced Mobile-First Navigation System
 * Handles responsive navigation, mobile menu, search, and scroll effects
 */

// Navigation state
let mobileMenuOpen = false;
let mobileSearchOpen = false;
let lastScrollY = 0;

// Initialize navigation when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    initializeEnhancedNavigation();
    initializeScrollEffects();
    initializeDropdowns();
    initializeMobileNavigation();
    initializeSearch();
});

// Initialize core navigation functionality
function initializeEnhancedNavigation() {
    // Smooth scrolling for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                // Close mobile menu if open
                if (mobileMenuOpen) {
                    closeMobileMenu();
                }
                
                // Smooth scroll to target
                const navHeight = document.querySelector('.navbar').offsetHeight;
                const targetPosition = target.offsetTop - navHeight - 20;
                
                window.scrollTo({
                    top: targetPosition,
                    behavior: 'smooth'
                });
            }
        });
    });
    
    // Handle escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            if (mobileMenuOpen) closeMobileMenu();
            if (mobileSearchOpen) closeMobileSearch();
        }
    });
}

// Initialize scroll effects
function initializeScrollEffects() {
    const navbar = document.querySelector('.navbar');
    
    window.addEventListener('scroll', () => {
        const currentScrollY = window.scrollY;
        
        // Add/remove scrolled class
        if (currentScrollY > 50) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
        
        // Hide/show navbar on scroll (mobile)
        if (window.innerWidth <= 768) {
            if (currentScrollY > lastScrollY && currentScrollY > 100) {
                // Scrolling down - hide navbar
                navbar.style.transform = 'translateY(-100%)';
            } else {
                // Scrolling up - show navbar
                navbar.style.transform = 'translateY(0)';
            }
        } else {
            navbar.style.transform = 'translateY(0)';
        }
        
        lastScrollY = currentScrollY;
    });
}

// Initialize desktop dropdowns
function initializeDropdowns() {
    const portalTrigger = document.getElementById('portal-trigger');
    const portalMenu = document.getElementById('portal-menu');
    
    if (portalTrigger && portalMenu) {
        let portalTimeout;
        
        portalTrigger.addEventListener('mouseenter', () => {
            clearTimeout(portalTimeout);
            portalMenu.style.opacity = '1';
            portalMenu.style.visibility = 'visible';
            portalMenu.style.transform = 'translateY(0)';
        });
        
        portalTrigger.addEventListener('mouseleave', () => {
            portalTimeout = setTimeout(() => {
                portalMenu.style.opacity = '0';
                portalMenu.style.visibility = 'hidden';
                portalMenu.style.transform = 'translateY(-10px)';
            }, 100);
        });
        
        portalMenu.addEventListener('mouseenter', () => {
            clearTimeout(portalTimeout);
        });
        
        portalMenu.addEventListener('mouseleave', () => {
            portalTimeout = setTimeout(() => {
                portalMenu.style.opacity = '0';
                portalMenu.style.visibility = 'hidden';
                portalMenu.style.transform = 'translateY(-10px)';
            }, 100);
        });
    }
    
    // Navigation dropdown hover effects
    const navDropdowns = document.querySelectorAll('.nav-dropdown');
    navDropdowns.forEach(dropdown => {
        const menu = dropdown.querySelector('.dropdown-menu');
        if (!menu) return;
        
        let dropdownTimeout;
        
        dropdown.addEventListener('mouseenter', () => {
            clearTimeout(dropdownTimeout);
            menu.style.opacity = '1';
            menu.style.visibility = 'visible';
            menu.style.transform = 'translateY(0)';
        });
        
        dropdown.addEventListener('mouseleave', () => {
            dropdownTimeout = setTimeout(() => {
                menu.style.opacity = '0';
                menu.style.visibility = 'hidden';
                menu.style.transform = 'translateY(-10px)';
            }, 150);
        });
    });
}

// Initialize mobile navigation
function initializeMobileNavigation() {
    const navToggle = document.getElementById('nav-toggle');
    const mobileMenu = document.getElementById('mobile-menu');
    const mobileMenuOverlay = document.getElementById('mobile-menu-overlay');
    
    if (navToggle) {
        navToggle.addEventListener('click', toggleMobileMenu);
    }
    
    if (mobileMenuOverlay) {
        mobileMenuOverlay.addEventListener('click', closeMobileMenu);
    }
    
    // Handle window resize
    window.addEventListener('resize', () => {
        if (window.innerWidth > 768 && mobileMenuOpen) {
            closeMobileMenu();
        }
    });
}

// Toggle mobile menu
function toggleMobileMenu() {
    if (mobileMenuOpen) {
        closeMobileMenu();
    } else {
        openMobileMenu();
    }
}

// Open mobile menu
function openMobileMenu() {
    const mobileMenu = document.getElementById('mobile-menu');
    const mobileMenuOverlay = document.getElementById('mobile-menu-overlay');
    const navToggle = document.getElementById('nav-toggle');
    
    if (mobileMenu && mobileMenuOverlay && navToggle) {
        mobileMenu.classList.add('active');
        mobileMenuOverlay.classList.add('active');
        navToggle.classList.add('active');
        document.body.style.overflow = 'hidden';
        mobileMenuOpen = true;
        
        // Animate menu items
        const menuItems = mobileMenu.querySelectorAll('.mobile-nav-link, .quick-action-btn');
        menuItems.forEach((item, index) => {
            item.style.opacity = '0';
            item.style.transform = 'translateX(20px)';
            setTimeout(() => {
                item.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
                item.style.opacity = '1';
                item.style.transform = 'translateX(0)';
            }, index * 50);
        });
    }
}

// Close mobile menu
function closeMobileMenu() {
    const mobileMenu = document.getElementById('mobile-menu');
    const mobileMenuOverlay = document.getElementById('mobile-menu-overlay');
    const navToggle = document.getElementById('nav-toggle');
    
    if (mobileMenu && mobileMenuOverlay && navToggle) {
        mobileMenu.classList.remove('active');
        mobileMenuOverlay.classList.remove('active');
        navToggle.classList.remove('active');
        document.body.style.overflow = 'auto';
        mobileMenuOpen = false;
    }
}

// Initialize search functionality
function initializeSearch() {
    const searchInput = document.querySelector('.mobile-search-input');
    const searchSuggestions = document.querySelector('.search-suggestions');
    
    if (searchInput) {
        searchInput.addEventListener('input', handleSearchInput);
        searchInput.addEventListener('focus', showSearchSuggestions);
        searchInput.addEventListener('blur', hideSearchSuggestions);
    }
    
    // Handle search suggestions clicks
    if (searchSuggestions) {
        searchSuggestions.addEventListener('click', (e) => {
            const suggestionItem = e.target.closest('.suggestion-item');
            if (suggestionItem) {
                const searchTerm = suggestionItem.querySelector('span').textContent;
                searchInput.value = searchTerm;
                performSearch(searchTerm);
                closeMobileSearch();
            }
        });
    }
}

// Handle search input
function handleSearchInput(e) {
    const query = e.target.value.toLowerCase();
    const suggestions = document.querySelector('.search-suggestions');
    
    if (query.length > 2) {
        // Filter and show relevant suggestions
        updateSearchSuggestions(query);
        suggestions.style.display = 'flex';
    } else {
        suggestions.style.display = 'none';
    }
}

// Update search suggestions based on query
function updateSearchSuggestions(query) {
    const suggestions = [
        'Tech internships Belgium',
        'Engineering opportunities',
        'Business analyst positions',
        'Healthcare internships',
        'Success stories',
        'Application process',
        'Salary information',
        'Student support'
    ];
    
    const filteredSuggestions = suggestions.filter(suggestion => 
        suggestion.toLowerCase().includes(query)
    );
    
    const suggestionsContainer = document.querySelector('.search-suggestions');
    suggestionsContainer.innerHTML = '';
    
    filteredSuggestions.slice(0, 4).forEach(suggestion => {
        const suggestionElement = document.createElement('div');
        suggestionElement.className = 'suggestion-item';
        suggestionElement.innerHTML = `
            <i class="fas fa-search"></i>
            <span>${suggestion}</span>
        `;
        suggestionsContainer.appendChild(suggestionElement);
    });
}

// Show search suggestions
function showSearchSuggestions() {
    const suggestions = document.querySelector('.search-suggestions');
    if (suggestions) {
        suggestions.style.display = 'flex';
    }
}

// Hide search suggestions
function hideSearchSuggestions() {
    setTimeout(() => {
        const suggestions = document.querySelector('.search-suggestions');
        if (suggestions) {
            suggestions.style.display = 'none';
        }
    }, 150);
}

// Toggle mobile search
function toggleMobileSearch() {
    if (mobileSearchOpen) {
        closeMobileSearch();
    } else {
        openMobileSearch();
    }
}

// Open mobile search
function openMobileSearch() {
    const mobileSearch = document.getElementById('mobile-search');
    const searchInput = document.querySelector('.mobile-search-input');
    
    if (mobileSearch) {
        mobileSearch.classList.add('active');
        mobileSearchOpen = true;
        
        // Focus search input
        setTimeout(() => {
            if (searchInput) {
                searchInput.focus();
            }
        }, 300);
    }
}

// Close mobile search
function closeMobileSearch() {
    const mobileSearch = document.getElementById('mobile-search');
    
    if (mobileSearch) {
        mobileSearch.classList.remove('active');
        mobileSearchOpen = false;
    }
}

// Perform search
function performSearch(query) {
    console.log('Searching for:', query);
    
    // This would integrate with your actual search functionality
    // For now, we'll simulate navigation to relevant sections
    const searchMappings = {
        'tech': '#opportunities',
        'engineering': '#opportunities',
        'business': '#opportunities',
        'stories': '#success-stories',
        'process': '#how-it-works',
        'support': '#support'
    };
    
    const lowerQuery = query.toLowerCase();
    let targetSection = null;
    
    for (const [keyword, section] of Object.entries(searchMappings)) {
        if (lowerQuery.includes(keyword)) {
            targetSection = section;
            break;
        }
    }
    
    if (targetSection) {
        const target = document.querySelector(targetSection);
        if (target) {
            const navHeight = document.querySelector('.navbar').offsetHeight;
            const targetPosition = target.offsetTop - navHeight - 20;
            
            window.scrollTo({
                top: targetPosition,
                behavior: 'smooth'
            });
        }
    }
}

// Active navigation highlighting
function updateActiveNavigation() {
    const sections = document.querySelectorAll('section[id]');
    const navLinks = document.querySelectorAll('.nav-link[href^="#"]');
    
    let currentSection = '';
    
    sections.forEach(section => {
        const sectionTop = section.offsetTop;
        const sectionHeight = section.clientHeight;
        
        if (window.scrollY >= sectionTop - 100) {
            currentSection = section.getAttribute('id');
        }
    });
    
    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href') === '#' + currentSection) {
            link.classList.add('active');
        }
    });
}

// Initialize active navigation on scroll
window.addEventListener('scroll', updateActiveNavigation);

// Touch gestures for mobile menu
let touchStartX = 0;
let touchEndX = 0;

document.addEventListener('touchstart', function(e) {
    touchStartX = e.changedTouches[0].screenX;
});

document.addEventListener('touchend', function(e) {
    touchEndX = e.changedTouches[0].screenX;
    handleSwipeGesture();
});

function handleSwipeGesture() {
    const swipeThreshold = 100;
    const swipeDistance = touchEndX - touchStartX;
    
    // Swipe right to open menu (only near left edge)
    if (swipeDistance > swipeThreshold && touchStartX < 50 && !mobileMenuOpen) {
        openMobileMenu();
    }
    
    // Swipe left to close menu
    if (swipeDistance < -swipeThreshold && mobileMenuOpen) {
        closeMobileMenu();
    }
}

// Export functions for global access
window.toggleMobileMenu = toggleMobileMenu;
window.closeMobileMenu = closeMobileMenu;
window.toggleMobileSearch = toggleMobileSearch;
window.closeMobileSearch = closeMobileSearch;
window.performSearch = performSearch;
