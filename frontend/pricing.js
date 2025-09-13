/**
 * AdmasAfroLink Pricing Transparency Calculator
 * Interactive pricing calculator with real-time updates and ROI calculation
 */

class PricingCalculator {
    constructor() {
        this.baseCosts = {
            standard: 2500,
            extended: 4200,
            premium: 6800
        };
        
        this.industryMultipliers = {
            tech: 1.2,
            business: 1.0,
            engineering: 1.1,
            healthcare: 1.3,
            marketing: 0.9
        };
        
        this.supportCosts = {
            basic: 0,
            enhanced: 400,
            premium: 800
        };
        
        this.locationCosts = {
            any: 0,
            belgium: 200,
            netherlands: 300,
            germany: 250
        };
        
        this.discountRate = 0.30; // 30% early bird discount
        this.paymentPlanFee = 0.05; // 5% fee for monthly payments
        this.fullPaymentDiscount = 0.10; // 10% discount for full payment
        
        this.init();
    }
    
    init() {
        this.updateCalculator();
        this.bindEvents();
        this.initializePricingFunctionality();
    }
    
    bindEvents() {
        // Calculator update events
        const selects = document.querySelectorAll('#program-type, #industry-field, #support-level, #location-preference');
        selects.forEach(select => {
            select.addEventListener('change', () => this.updateCalculator());
        });
        
        // Payment plan selection
        document.querySelectorAll('.plan-option').forEach(option => {
            option.addEventListener('click', (e) => {
                const planType = e.currentTarget.getAttribute('onclick')?.match(/'(\w+)'/)?.[1];
                if (planType) this.selectPaymentPlan(planType);
            });
        });
    }
    
    updateCalculator() {
        const programType = document.getElementById('program-type')?.value || 'standard';
        const industryField = document.getElementById('industry-field')?.value || 'business';
        const supportLevel = document.getElementById('support-level')?.value || 'basic';
        const locationPreference = document.getElementById('location-preference')?.value || 'any';
        
        // Calculate costs
        const baseCost = this.baseCosts[programType] || this.baseCosts.standard;
        const industryMultiplier = this.industryMultipliers[industryField] || 1.0;
        const industryCost = baseCost * (industryMultiplier - 1);
        const supportCost = this.supportCosts[supportLevel] || 0;
        const locationCost = this.locationCosts[locationPreference] || 0;
        
        const subtotal = baseCost + industryCost + supportCost + locationCost;
        const discountAmount = subtotal * this.discountRate;
        const totalCost = subtotal - discountAmount;
        
        // Update display
        this.updatePriceDisplay('base-cost', baseCost);
        this.updatePriceDisplay('industry-cost', industryCost);
        this.updatePriceDisplay('support-cost', supportCost);
        this.updatePriceDisplay('location-cost', locationCost);
        this.updatePriceDisplay('discount-amount', -discountAmount);
        this.updatePriceDisplay('total-cost', totalCost);
        
        // Update payment plans
        this.updatePaymentPlans(totalCost);
        
        // Update ROI metrics
        this.updateROIMetrics(totalCost, programType);
    }
    
    updatePriceDisplay(elementId, amount) {
        const element = document.getElementById(elementId);
        if (element) {
            const formattedAmount = this.formatCurrency(Math.abs(amount));
            element.textContent = amount < 0 ? `-${formattedAmount}` : formattedAmount;
        }
    }
    
    updatePaymentPlans(totalCost) {
        // Full payment (with 10% discount)
        const fullPaymentAmount = totalCost * (1 - this.fullPaymentDiscount);
        const fullPaymentElement = document.getElementById('full-payment');
        if (fullPaymentElement) {
            fullPaymentElement.textContent = this.formatCurrency(fullPaymentAmount);
        }
        
        // Split payment (no additional fees)
        const splitPaymentAmount = totalCost / 2;
        const splitPaymentElement = document.getElementById('split-payment');
        if (splitPaymentElement) {
            splitPaymentElement.textContent = `${this.formatCurrency(splitPaymentAmount)} × 2`;
        }
        
        // Monthly payment (with service fee)
        const monthlyPaymentAmount = (totalCost * (1 + this.paymentPlanFee)) / 6;
        const monthlyPaymentElement = document.getElementById('monthly-payment');
        if (monthlyPaymentElement) {
            monthlyPaymentElement.textContent = `${this.formatCurrency(monthlyPaymentAmount)} × 6`;
        }
    }
    
    updateROIMetrics(investment, programType) {
        // Calculate ROI based on program type
        const roiData = this.calculateROI(investment, programType);
        
        const salaryIncreaseElement = document.getElementById('salary-increase');
        if (salaryIncreaseElement) {
            salaryIncreaseElement.textContent = `+${roiData.salaryIncrease}%`;
        }
        
        const paybackTimeElement = document.getElementById('payback-time');
        if (paybackTimeElement) {
            paybackTimeElement.textContent = roiData.paybackTime;
        }
        
        const lifetimeValueElement = document.getElementById('lifetime-value');
        if (lifetimeValueElement) {
            lifetimeValueElement.textContent = this.formatCurrency(roiData.lifetimeValue);
        }
    }
    
    calculateROI(investment, programType) {
        const baseROI = {
            standard: { salaryIncrease: 250, paybackMonths: 5, lifetimeMultiplier: 100 },
            extended: { salaryIncrease: 300, paybackMonths: 4, lifetimeMultiplier: 120 },
            premium: { salaryIncrease: 400, paybackMonths: 3, lifetimeMultiplier: 150 }
        };
        
        const roi = baseROI[programType] || baseROI.standard;
        
        return {
            salaryIncrease: roi.salaryIncrease,
            paybackTime: `${roi.paybackMonths}-${roi.paybackMonths + 2} months`,
            lifetimeValue: investment * roi.lifetimeMultiplier
        };
    }
    
    selectPaymentPlan(planType) {
        // Remove active class from all plans
        document.querySelectorAll('.plan-option').forEach(option => {
            option.classList.remove('active');
        });
        
        // Add active class to selected plan
        const selectedPlan = document.querySelector(`.plan-option[onclick*="${planType}"]`);
        if (selectedPlan) {
            selectedPlan.classList.add('active');
        }
        
        // Show plan-specific messaging
        this.showPaymentPlanMessage(planType);
    }
    
    showPaymentPlanMessage(planType) {
        const messages = {
            full: "Great choice! You'll save 10% with full payment upfront.",
            split: "Perfect! Split your investment into two manageable payments.",
            monthly: "Flexible monthly payments make your investment more manageable."
        };
        
        // You can implement a notification system here
        console.log(messages[planType]);
    }
    
    formatCurrency(amount) {
        return new Intl.NumberFormat('en-EU', {
            style: 'currency',
            currency: 'EUR',
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        }).format(amount);
    }
    
    initializePricingFunctionality() {
        // Initialize other pricing-related functionality
        this.initializeComparisonTable();
        this.initializeFinancialAid();
        this.initializePricingCTA();
    }
    
    initializeComparisonTable() {
        // Add comparison table functionality
        window.selectProgram = (programType) => {
            // Update the calculator to reflect the selected program
            const programSelect = document.getElementById('program-type');
            if (programSelect) {
                programSelect.value = programType;
                this.updateCalculator();
            }
            
            // Scroll to calculator
            document.querySelector('.cost-calculator')?.scrollIntoView({
                behavior: 'smooth',
                block: 'center'
            });
            
            // Highlight the calculator
            this.highlightCalculator();
        };
    }
    
    highlightCalculator() {
        const calculator = document.querySelector('.cost-calculator');
        if (calculator) {
            calculator.style.transform = 'scale(1.02)';
            calculator.style.transition = 'transform 0.3s ease';
            
            setTimeout(() => {
                calculator.style.transform = 'scale(1)';
            }, 500);
        }
    }
    
    initializeFinancialAid() {
        window.applyForAid = (aidType) => {
            const aidApplications = {
                merit: {
                    title: 'Merit Scholarship Application',
                    requirements: [
                        'Academic transcripts (GPA 3.5+)',
                        'Leadership experience documentation',
                        'Personal statement essay (500 words)',
                        'Two academic references'
                    ]
                },
                need: {
                    title: 'Need-Based Aid Application',
                    requirements: [
                        'Family income verification',
                        'Financial hardship documentation',
                        'Bank statements (last 6 months)',
                        'Personal statement explaining need'
                    ]
                },
                sponsor: {
                    title: 'Industry Sponsorship Application',
                    requirements: [
                        'Skills assessment completion',
                        'Portfolio/project showcase',
                        'Career goals statement',
                        'Commitment agreement'
                    ]
                }
            };
            
            const application = aidApplications[aidType];
            if (application) {
                this.showAidApplicationModal(application);
            }
        };
    }
    
    showAidApplicationModal(application) {
        // Create and show modal for aid application
        const modal = document.createElement('div');
        modal.className = 'aid-application-modal';
        modal.innerHTML = `
            <div class="modal-overlay" onclick="this.parentElement.remove()">
                <div class="modal-content" onclick="event.stopPropagation()">
                    <div class="modal-header">
                        <h3>${application.title}</h3>
                        <button class="modal-close" onclick="this.closest('.aid-application-modal').remove()">×</button>
                    </div>
                    <div class="modal-body">
                        <p>To apply for this financial aid option, please prepare the following documents:</p>
                        <ul>
                            ${application.requirements.map(req => `<li>${req}</li>`).join('')}
                        </ul>
                        <div class="modal-actions">
                            <button class="btn btn-primary" onclick="this.closest('.aid-application-modal').remove(); window.openApplicationModal();">
                                Start Application
                            </button>
                            <button class="btn btn-outline" onclick="this.closest('.aid-application-modal').remove();">
                                Close
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        `;
        
        // Add modal styles
        const style = document.createElement('style');
        style.textContent = `
            .aid-application-modal {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                z-index: 10000;
            }
            .aid-application-modal .modal-overlay {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.5);
                display: flex;
                align-items: center;
                justify-content: center;
            }
            .aid-application-modal .modal-content {
                background: white;
                border-radius: 15px;
                max-width: 500px;
                width: 90%;
                max-height: 80vh;
                overflow-y: auto;
            }
            .aid-application-modal .modal-header {
                padding: 20px 30px;
                border-bottom: 1px solid #e2e8f0;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            .aid-application-modal .modal-header h3 {
                margin: 0;
                color: #2d3748;
            }
            .aid-application-modal .modal-close {
                background: none;
                border: none;
                font-size: 1.5rem;
                cursor: pointer;
                color: #4a5568;
            }
            .aid-application-modal .modal-body {
                padding: 30px;
            }
            .aid-application-modal ul {
                margin: 20px 0;
                padding-left: 20px;
            }
            .aid-application-modal li {
                margin: 10px 0;
                color: #4a5568;
            }
            .aid-application-modal .modal-actions {
                display: flex;
                gap: 15px;
                margin-top: 30px;
            }
            .aid-application-modal .btn {
                padding: 12px 25px;
                border-radius: 8px;
                font-weight: 600;
                cursor: pointer;
                border: 2px solid transparent;
                transition: all 0.3s ease;
            }
            .aid-application-modal .btn-primary {
                background: #3182ce;
                color: white;
                border-color: #3182ce;
            }
            .aid-application-modal .btn-outline {
                background: transparent;
                color: #3182ce;
                border-color: #3182ce;
            }
        `;
        
        document.head.appendChild(style);
        document.body.appendChild(modal);
    }
    
    initializePricingCTA() {
        window.openApplicationModal = () => {
            // Scroll to the application form or open application modal
            const applicationSection = document.querySelector('.application-section');
            if (applicationSection) {
                applicationSection.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            } else {
                // If no application section exists, show a coming soon message
                alert('Application form opening soon! Please use the contact form to get started.');
            }
        };
        
        window.scheduleConsultation = () => {
            // Open consultation scheduling
            const phone = '+32-2-123-4567';
            const email = 'consultation@admasafrolink.com';
            
            const consultationModal = document.createElement('div');
            consultationModal.className = 'consultation-modal';
            consultationModal.innerHTML = `
                <div class="modal-overlay" onclick="this.parentElement.remove()">
                    <div class="modal-content" onclick="event.stopPropagation()">
                        <div class="modal-header">
                            <h3>Schedule Your Free Consultation</h3>
                            <button class="modal-close" onclick="this.closest('.consultation-modal').remove()">×</button>
                        </div>
                        <div class="modal-body">
                            <p>Ready to discuss your internship journey? Contact us to schedule a free 30-minute consultation.</p>
                            <div class="contact-options">
                                <div class="contact-option">
                                    <strong>Phone:</strong>
                                    <a href="tel:${phone}">${phone}</a>
                                </div>
                                <div class="contact-option">
                                    <strong>Email:</strong>
                                    <a href="mailto:${email}">${email}</a>
                                </div>
                            </div>
                            <div class="modal-actions">
                                <button class="btn btn-primary" onclick="window.open('tel:${phone}')">
                                    Call Now
                                </button>
                                <button class="btn btn-outline" onclick="window.open('mailto:${email}')">
                                    Send Email
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            `;
            
            document.body.appendChild(consultationModal);
        };
    }
}

// Animation and interaction enhancements
class PricingAnimations {
    static initializeAnimations() {
        // Fade in animations for pricing cards
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };
        
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, observerOptions);
        
        // Observe pricing cards
        document.querySelectorAll('.aid-card, .comparison-item, .cost-calculator').forEach(card => {
            card.style.opacity = '0';
            card.style.transform = 'translateY(30px)';
            card.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
            observer.observe(card);
        });
        
        // Counter animation for ROI metrics
        this.animateCounters();
    }
    
    static animateCounters() {
        const counters = document.querySelectorAll('.roi-value, .guarantee-stats strong');
        
        counters.forEach(counter => {
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        this.animateNumber(entry.target);
                        observer.unobserve(entry.target);
                    }
                });
            });
            
            observer.observe(counter);
        });
    }
    
    static animateNumber(element) {
        const text = element.textContent;
        const number = parseFloat(text.replace(/[^\d.-]/g, ''));
        
        if (isNaN(number)) return;
        
        const duration = 1500;
        const start = performance.now();
        const startValue = 0;
        
        const animate = (currentTime) => {
            const elapsed = currentTime - start;
            const progress = Math.min(elapsed / duration, 1);
            
            const currentValue = startValue + (number - startValue) * this.easeOutCubic(progress);
            
            if (text.includes('%')) {
                element.textContent = `+${Math.round(currentValue)}%`;
            } else if (text.includes('€')) {
                element.textContent = `€${Math.round(currentValue).toLocaleString()}+`;
            } else {
                element.textContent = Math.round(currentValue);
            }
            
            if (progress < 1) {
                requestAnimationFrame(animate);
            }
        };
        
        requestAnimationFrame(animate);
    }
    
    static easeOutCubic(t) {
        return 1 - Math.pow(1 - t, 3);
    }
}

// Initialize pricing functionality when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    // Initialize pricing calculator
    new PricingCalculator();
    
    // Initialize animations
    PricingAnimations.initializeAnimations();
    
    // Add smooth scrolling for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
});

// Export for potential module usage
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { PricingCalculator, PricingAnimations };
}
