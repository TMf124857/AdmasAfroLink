/**
 * Enhanced Alumni Stories Functionality
 * Handles video playback, story modals, and interactive elements
 */

// Initialize Stories functionality
function initializeStories() {
    // Initialize story cards hover effects
    const storyCards = document.querySelectorAll('.story-card');
    storyCards.forEach(card => {
        card.addEventListener('mouseenter', () => {
            card.style.transform = 'translateY(-8px)';
        });
        
        card.addEventListener('mouseleave', () => {
            card.style.transform = 'translateY(0)';
        });
    });
    
    // Initialize featured video
    const playBtn = document.querySelector('.play-btn');
    if (playBtn) {
        playBtn.addEventListener('click', playFeaturedVideo);
    }
    
    // Initialize success stats animations
    initializeStatsAnimations();
    
    // Initialize impact chain animations
    initializeImpactAnimations();
}

// Play featured video
function playFeaturedVideo() {
    const thumbnail = document.querySelector('.video-thumbnail');
    const video = document.getElementById('featured-video');
    
    if (thumbnail && video) {
        // Fade out thumbnail
        thumbnail.style.opacity = '0';
        thumbnail.style.transition = 'opacity 0.3s ease';
        
        setTimeout(() => {
            thumbnail.style.display = 'none';
            video.style.display = 'block';
            video.style.opacity = '0';
            video.style.transition = 'opacity 0.3s ease';
            
            // Fade in video
            setTimeout(() => {
                video.style.opacity = '1';
                video.play();
            }, 50);
        }, 300);
    }
}

// Story modal functionality
function openStoryModal(storyId) {
    const stories = {
        james: {
            title: "From Street Vendor to Business Analyst",
            category: "💼 Business Transformation",
            image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&h=400&fit=crop",
            content: `
                <div class="story-detail">
                    <div class="story-timeline">
                        <h4>James's Journey Timeline</h4>
                        <div class="timeline-item">
                            <div class="timeline-date">2019</div>
                            <div class="timeline-content">
                                <h5>Starting Point</h5>
                                <p>Selling phone cards on Kampala streets, earning $50/month</p>
                            </div>
                        </div>
                        <div class="timeline-item">
                            <div class="timeline-date">2020</div>
                            <div class="timeline-content">
                                <h5>AdmasAfroLink Application</h5>
                                <p>Applied for business internship program, completed preparation courses</p>
                            </div>
                        </div>
                        <div class="timeline-item">
                            <div class="timeline-date">2021</div>
                            <div class="timeline-content">
                                <h5>Belgium Internship</h5>
                                <p>Secured internship at major consulting firm in Brussels</p>
                            </div>
                        </div>
                        <div class="timeline-item">
                            <div class="timeline-date">2022</div>
                            <div class="timeline-content">
                                <h5>Career Success</h5>
                                <p>Promoted to Business Analyst, earning €4,200/month</p>
                            </div>
                        </div>
                        <div class="timeline-item">
                            <div class="timeline-date">2023</div>
                            <div class="timeline-content">
                                <h5>Giving Back</h5>
                                <p>Built primary school in home village, mentoring new students</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="story-metrics">
                        <h4>Impact Metrics</h4>
                        <div class="metrics-grid">
                            <div class="metric">
                                <div class="metric-value">8,400%</div>
                                <div class="metric-label">Income Increase</div>
                            </div>
                            <div class="metric">
                                <div class="metric-value">180</div>
                                <div class="metric-label">Children Educated</div>
                            </div>
                            <div class="metric">
                                <div class="metric-value">5</div>
                                <div class="metric-label">Students Sponsored</div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="story-quote">
                        <blockquote>
                            "The hardest part wasn't learning the business skills - it was believing I deserved this opportunity. AdmasAfroLink didn't just teach me analytics; they taught me to dream bigger than I ever thought possible."
                        </blockquote>
                        <cite>- James Mukasa</cite>
                    </div>
                </div>
            `
        },
        grace: {
            title: "Single Mother Becomes EU Nurse",
            category: "🏥 Healthcare Excellence",
            image: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=600&h=400&fit=crop",
            content: `
                <div class="story-detail">
                    <div class="story-timeline">
                        <h4>Grace's Transformation Journey</h4>
                        <div class="timeline-item">
                            <div class="timeline-date">2018</div>
                            <div class="timeline-content">
                                <h5>The Challenge</h5>
                                <p>Single mother of 3, working as village health aide, struggling financially</p>
                            </div>
                        </div>
                        <div class="timeline-item">
                            <div class="timeline-date">2019</div>
                            <div class="timeline-content">
                                <h5>The Decision</h5>
                                <p>Applied to AdmasAfroLink nursing program while managing family responsibilities</p>
                            </div>
                        </div>
                        <div class="timeline-item">
                            <div class="timeline-date">2020-2021</div>
                            <div class="timeline-content">
                                <h5>Preparation & Training</h5>
                                <p>Completed intensive nursing certification and language training</p>
                            </div>
                        </div>
                        <div class="timeline-item">
                            <div class="timeline-date">2022</div>
                            <div class="timeline-content">
                                <h5>EU Nursing License</h5>
                                <p>Passed European nursing exams, secured position in Belgian hospital</p>
                            </div>
                        </div>
                        <div class="timeline-item">
                            <div class="timeline-date">2023</div>
                            <div class="timeline-content">
                                <h5>Family Reunion</h5>
                                <p>Brought all three children to Belgium, pursuing nursing specialization</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="story-challenges">
                        <h4>Overcoming Challenges</h4>
                        <div class="challenge-item">
                            <div class="challenge-icon">👶</div>
                            <div class="challenge-content">
                                <h5>Balancing Motherhood & Studies</h5>
                                <p>Studied at night while caring for three young children during the day</p>
                            </div>
                        </div>
                        <div class="challenge-item">
                            <div class="challenge-icon">💰</div>
                            <div class="challenge-content">
                                <h5>Financial Constraints</h5>
                                <p>AdmasAfroLink provided full scholarship and living stipend during training</p>
                            </div>
                        </div>
                        <div class="challenge-item">
                            <div class="challenge-icon">🗣️</div>
                            <div class="challenge-content">
                                <h5>Language Barrier</h5>
                                <p>Mastered medical Dutch and French through intensive language program</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="story-quote">
                        <blockquote>
                            "Every night when my children were asleep, I would study by candlelight. I wasn't just learning nursing - I was building a future for my family. Now my children see that dreams have no limits."
                        </blockquote>
                        <cite>- Grace Nalule</cite>
                    </div>
                </div>
            `
        },
        peter: {
            title: "Mechanical Engineer's European Dream",
            category: "⚙️ Engineering Excellence",
            image: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=600&h=400&fit=crop",
            content: `
                <div class="story-detail">
                    <div class="story-timeline">
                        <h4>Peter's Engineering Journey</h4>
                        <div class="timeline-item">
                            <div class="timeline-date">2017</div>
                            <div class="timeline-content">
                                <h5>Technical Foundation</h5>
                                <p>Graduated with mechanical engineering degree from Makerere University</p>
                            </div>
                        </div>
                        <div class="timeline-item">
                            <div class="timeline-date">2018</div>
                            <div class="timeline-content">
                                <h5>Limited Opportunities</h5>
                                <p>Struggled to find engineering work matching his qualifications in Uganda</p>
                            </div>
                        </div>
                        <div class="timeline-item">
                            <div class="timeline-date">2019</div>
                            <div class="timeline-content">
                                <h5>AdmasAfroLink Program</h5>
                                <p>Joined engineering track, completed European standards certification</p>
                            </div>
                        </div>
                        <div class="timeline-item">
                            <div class="timeline-date">2020</div>
                            <div class="timeline-content">
                                <h5>Belgium Internship</h5>
                                <p>Secured internship at leading automotive manufacturing company</p>
                            </div>
                        </div>
                        <div class="timeline-item">
                            <div class="timeline-date">2023</div>
                            <div class="timeline-content">
                                <h5>Team Leadership</h5>
                                <p>Promoted to Lead Engineer, managing team of 12 engineers</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="technical-achievements">
                        <h4>Technical Achievements</h4>
                        <div class="achievement-item">
                            <div class="achievement-icon">🔧</div>
                            <div class="achievement-content">
                                <h5>Process Innovation</h5>
                                <p>Developed manufacturing process that reduced production time by 23%</p>
                            </div>
                        </div>
                        <div class="achievement-item">
                            <div class="achievement-icon">📊</div>
                            <div class="achievement-content">
                                <h5>Quality Improvement</h5>
                                <p>Led quality initiative that achieved 99.7% defect-free production</p>
                            </div>
                        </div>
                        <div class="achievement-item">
                            <div class="achievement-icon">🏆</div>
                            <div class="achievement-content">
                                <h5>Industry Recognition</h5>
                                <p>Received European Engineering Excellence Award for innovation</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="story-quote">
                        <blockquote>
                            "I had the technical knowledge, but AdmasAfroLink gave me the confidence and European industry insights I needed. Now I'm not just applying engineering principles - I'm innovating them."
                        </blockquote>
                        <cite>- Peter Ssali</cite>
                    </div>
                </div>
            `
        },
        maria: {
            title: "Accountant to Financial Advisor",
            category: "💰 Financial Excellence",
            image: "https://images.unsplash.com/photo-1580489944761-15a19d654956?w=600&h=400&fit=crop",
            content: `
                <div class="story-detail">
                    <div class="story-timeline">
                        <h4>Maria's Financial Journey</h4>
                        <div class="timeline-item">
                            <div class="timeline-date">2016</div>
                            <div class="timeline-content">
                                <h5>Accounting Background</h5>
                                <p>Working as accountant for small business, earning limited income</p>
                            </div>
                        </div>
                        <div class="timeline-item">
                            <div class="timeline-date">2018</div>
                            <div class="timeline-content">
                                <h5>AdmasAfroLink Finance Track</h5>
                                <p>Enrolled in financial advisory program with CFA preparation</p>
                            </div>
                        </div>
                        <div class="timeline-item">
                            <div class="timeline-date">2019</div>
                            <div class="timeline-content">
                                <h5>European Internship</h5>
                                <p>Secured internship at premier investment firm in Brussels</p>
                            </div>
                        </div>
                        <div class="timeline-item">
                            <div class="timeline-date">2021</div>
                            <div class="timeline-content">
                                <h5>CFA Certification</h5>
                                <p>Passed all three levels of CFA exam, became chartered financial analyst</p>
                            </div>
                        </div>
                        <div class="timeline-item">
                            <div class="timeline-date">2023</div>
                            <div class="timeline-content">
                                <h5>Independent Practice</h5>
                                <p>Launched own financial advisory firm specializing in African diaspora</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="business-impact">
                        <h4>Business Impact</h4>
                        <div class="impact-stat">
                            <div class="stat-value">€50M+</div>
                            <div class="stat-label">Assets Under Management</div>
                        </div>
                        <div class="impact-stat">
                            <div class="stat-value">200+</div>
                            <div class="stat-label">Active Clients</div>
                        </div>
                        <div class="impact-stat">
                            <div class="stat-value">15%</div>
                            <div class="stat-label">Average Annual Returns</div>
                        </div>
                    </div>
                    
                    <div class="story-quote">
                        <blockquote>
                            "I didn't just learn about European financial markets - I learned how to help my community build generational wealth. Every client I serve is someone taking control of their financial future."
                        </blockquote>
                        <cite>- Maria Nakku</cite>
                    </div>
                </div>
            `
        }
    };
    
    const story = stories[storyId];
    if (!story) return;
    
    // Create detailed story modal
    const modalHtml = `
        <div id="story-modal" class="modal" style="display: flex;">
            <div class="modal-content story-modal-content">
                <div class="modal-header">
                    <div class="story-modal-header">
                        <img src="${story.image}" alt="${story.title}" class="story-modal-image">
                        <div class="story-modal-title">
                            <span class="story-modal-category">${story.category}</span>
                            <h2>${story.title}</h2>
                        </div>
                    </div>
                    <button class="modal-close" onclick="closeStoryModal()">&times;</button>
                </div>
                <div class="story-modal-body">
                    ${story.content}
                    <div class="story-modal-actions">
                        <button class="btn btn-primary" onclick="openApplicationModal(); closeStoryModal();">
                            <i class="fas fa-rocket"></i>
                            Start Your Own Journey
                        </button>
                        <button class="btn btn-outline" onclick="shareStory('${storyId}')">
                            <i class="fas fa-share"></i>
                            Share Story
                        </button>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    // Remove existing modal if present
    closeStoryModal();
    
    // Add new modal
    document.body.insertAdjacentHTML('beforeend', modalHtml);
    document.body.style.overflow = 'hidden';
    
    // Animate modal entrance
    setTimeout(() => {
        const modal = document.getElementById('story-modal');
        if (modal) {
            modal.style.opacity = '1';
        }
    }, 10);
}

// Close story modal
function closeStoryModal() {
    const modal = document.getElementById('story-modal');
    if (modal) {
        modal.style.opacity = '0';
        setTimeout(() => {
            modal.remove();
            document.body.style.overflow = 'auto';
        }, 200);
    }
}

// Share story functionality
function shareStory(storyId) {
    if (navigator.share) {
        navigator.share({
            title: 'AdmasAfroLink Success Story',
            text: 'Check out this inspiring transformation story!',
            url: window.location.href + '#story-' + storyId
        });
    } else {
        // Fallback: copy to clipboard
        const url = window.location.href + '#story-' + storyId;
        navigator.clipboard.writeText(url).then(() => {
            showNotification('Story link copied to clipboard!');
        });
    }
}

// Initialize success stats animations
function initializeStatsAnimations() {
    const statItems = document.querySelectorAll('.stat-item');
    
    const statsObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.transform = 'translateY(0)';
                entry.target.style.opacity = '1';
            }
        });
    }, {
        threshold: 0.2
    });
    
    statItems.forEach((item, index) => {
        item.style.transform = 'translateY(20px)';
        item.style.opacity = '0';
        item.style.transition = `transform 0.6s ease ${index * 0.1}s, opacity 0.6s ease ${index * 0.1}s`;
        statsObserver.observe(item);
    });
}

// Initialize impact chain animations
function initializeImpactAnimations() {
    const impactSteps = document.querySelectorAll('.impact-step');
    
    const impactObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const steps = entry.target.closest('.impact-chain').querySelectorAll('.impact-step');
                steps.forEach((step, index) => {
                    setTimeout(() => {
                        step.style.transform = 'translateX(0)';
                        step.style.opacity = '1';
                    }, index * 200);
                });
            }
        });
    }, {
        threshold: 0.3
    });
    
    if (impactSteps.length > 0) {
        impactSteps.forEach(step => {
            step.style.transform = 'translateX(-20px)';
            step.style.opacity = '0';
            step.style.transition = 'transform 0.6s ease, opacity 0.6s ease';
        });
        
        impactObserver.observe(impactSteps[0]);
    }
}

// Show notification
function showNotification(message) {
    const notification = document.createElement('div');
    notification.className = 'notification';
    notification.textContent = message;
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: var(--secondary-color);
        color: white;
        padding: 1rem 1.5rem;
        border-radius: 8px;
        z-index: 10000;
        transform: translateX(100%);
        transition: transform 0.3s ease;
    `;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.style.transform = 'translateX(0)';
    }, 100);
    
    setTimeout(() => {
        notification.style.transform = 'translateX(100%)';
        setTimeout(() => {
            notification.remove();
        }, 300);
    }, 3000);
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', initializeStories);

// Export functions for global access
window.playFeaturedVideo = playFeaturedVideo;
window.openStoryModal = openStoryModal;
window.closeStoryModal = closeStoryModal;
window.shareStory = shareStory;
