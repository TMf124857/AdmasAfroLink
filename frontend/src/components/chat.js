/**
 * Chat Widget Controller - Contextual Support System
 * Provides instant help and reduces user anxiety through real-time assistance
 */

class ChatWidget {
  constructor() {
    this.isOpen = false;
    this.messages = [];
    this.currentStep = 'greeting';
    this.userContext = {
      visitedSections: [],
      timeOnPage: 0,
      showedInterest: false,
      askedQuestions: []
    };
    
    this.init();
  }

  init() {
    this.createChatInterface();
    this.bindEvents();
    this.startContextualTriggers();
    this.loadPresetResponses();
  }

  createChatInterface() {
    // Enhanced chat widget HTML
    const chatHtml = `
      <div class="chat-widget" id="chat-widget">
        <div class="chat-toggle" id="chat-toggle">
          <div class="chat-icon">
            <i class="fas fa-comments"></i>
          </div>
          <div class="chat-notification" id="chat-notification">
            <div class="notification-content">
              <span class="notification-text">Need help? We're here! 👋</span>
              <button class="notification-close">×</button>
            </div>
          </div>
        </div>
        
        <div class="chat-window" id="chat-window">
          <div class="chat-header">
            <div class="agent-info">
              <img src="src/assets/chat-agent.jpg" alt="Support Agent" class="agent-avatar">
              <div class="agent-details">
                <span class="agent-name">Sarah</span>
                <span class="agent-status">
                  <span class="status-dot"></span>
                  Online now
                </span>
              </div>
            </div>
            <button class="chat-close" id="chat-close">
              <i class="fas fa-times"></i>
            </button>
          </div>
          
          <div class="chat-messages" id="chat-messages">
            <!-- Messages will be inserted here -->
          </div>
          
          <div class="chat-quick-actions" id="chat-quick-actions">
            <!-- Quick action buttons will be inserted here -->
          </div>
          
          <div class="chat-input-area">
            <div class="chat-input-container">
              <input type="text" id="chat-input" placeholder="Type your question..." autocomplete="off">
              <button class="chat-send" id="chat-send">
                <i class="fas fa-paper-plane"></i>
              </button>
            </div>
            <div class="chat-suggestions" id="chat-suggestions">
              <!-- Suggested questions will appear here -->
            </div>
          </div>
        </div>
      </div>
    `;

    // Inject chat widget into page
    document.body.insertAdjacentHTML('beforeend', chatHtml);
    
    // Add chat widget styles
    this.addChatStyles();
  }

  addChatStyles() {
    const styles = `
      .chat-widget {
        position: fixed;
        bottom: 20px;
        right: 20px;
        z-index: 10000;
        font-family: var(--font-family);
      }
      
      .chat-toggle {
        position: relative;
        width: 60px;
        height: 60px;
        background: linear-gradient(135deg, var(--primary-color), #3b82f6);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        box-shadow: 0 4px 20px rgba(37, 99, 235, 0.4);
        transition: all 0.3s ease;
        animation: pulse 2s infinite;
      }
      
      .chat-toggle:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 25px rgba(37, 99, 235, 0.5);
        animation: none;
      }
      
      .chat-icon {
        color: white;
        font-size: 24px;
        transition: transform 0.3s ease;
      }
      
      .chat-toggle.active .chat-icon {
        transform: scale(0);
      }
      
      .chat-notification {
        position: absolute;
        bottom: 70px;
        right: 0;
        background: white;
        border-radius: 12px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
        padding: 0;
        min-width: 250px;
        opacity: 0;
        visibility: hidden;
        transform: translateY(10px);
        transition: all 0.3s ease;
      }
      
      .chat-notification.show {
        opacity: 1;
        visibility: visible;
        transform: translateY(0);
      }
      
      .notification-content {
        padding: 16px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
      }
      
      .notification-text {
        color: var(--neutral-700);
        font-size: 14px;
        font-weight: 500;
      }
      
      .notification-close {
        background: none;
        border: none;
        color: var(--neutral-500);
        cursor: pointer;
        padding: 4px;
        border-radius: 4px;
        transition: background 0.2s ease;
      }
      
      .notification-close:hover {
        background: var(--neutral-100);
      }
      
      .chat-window {
        position: absolute;
        bottom: 70px;
        right: 0;
        width: 350px;
        height: 500px;
        background: white;
        border-radius: 16px;
        box-shadow: 0 8px 40px rgba(0, 0, 0, 0.2);
        display: flex;
        flex-direction: column;
        opacity: 0;
        visibility: hidden;
        transform: translateY(20px) scale(0.95);
        transition: all 0.3s ease;
      }
      
      .chat-window.show {
        opacity: 1;
        visibility: visible;
        transform: translateY(0) scale(1);
      }
      
      .chat-header {
        background: var(--primary-color);
        color: white;
        padding: 16px;
        border-radius: 16px 16px 0 0;
        display: flex;
        align-items: center;
        justify-content: space-between;
      }
      
      .agent-info {
        display: flex;
        align-items: center;
        gap: 12px;
      }
      
      .agent-avatar {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        object-fit: cover;
      }
      
      .agent-name {
        font-weight: 600;
        font-size: 16px;
      }
      
      .agent-status {
        display: flex;
        align-items: center;
        gap: 6px;
        font-size: 12px;
        opacity: 0.9;
      }
      
      .status-dot {
        width: 8px;
        height: 8px;
        background: #10b981;
        border-radius: 50%;
      }
      
      .chat-close {
        background: none;
        border: none;
        color: white;
        cursor: pointer;
        padding: 8px;
        border-radius: 6px;
        transition: background 0.2s ease;
      }
      
      .chat-close:hover {
        background: rgba(255, 255, 255, 0.2);
      }
      
      .chat-messages {
        flex: 1;
        padding: 16px;
        overflow-y: auto;
        display: flex;
        flex-direction: column;
        gap: 12px;
      }
      
      .message {
        max-width: 80%;
        padding: 12px 16px;
        border-radius: 18px;
        font-size: 14px;
        line-height: 1.4;
        word-wrap: break-word;
      }
      
      .message.agent {
        align-self: flex-start;
        background: var(--neutral-100);
        color: var(--neutral-800);
        border-bottom-left-radius: 6px;
      }
      
      .message.user {
        align-self: flex-end;
        background: var(--primary-color);
        color: white;
        border-bottom-right-radius: 6px;
      }
      
      .message.typing {
        background: var(--neutral-100);
        padding: 16px;
        align-self: flex-start;
        display: flex;
        align-items: center;
        gap: 4px;
      }
      
      .typing-dots {
        display: flex;
        gap: 4px;
      }
      
      .typing-dot {
        width: 6px;
        height: 6px;
        background: var(--neutral-500);
        border-radius: 50%;
        animation: typing 1.4s infinite ease-in-out both;
      }
      
      .typing-dot:nth-child(1) { animation-delay: -0.32s; }
      .typing-dot:nth-child(2) { animation-delay: -0.16s; }
      
      @keyframes typing {
        0%, 80%, 100% { transform: scale(0.8); opacity: 0.5; }
        40% { transform: scale(1); opacity: 1; }
      }
      
      .chat-quick-actions {
        padding: 0 16px;
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-bottom: 12px;
      }
      
      .quick-action {
        background: var(--neutral-100);
        border: 1px solid var(--neutral-300);
        color: var(--neutral-700);
        padding: 8px 12px;
        border-radius: 20px;
        font-size: 12px;
        cursor: pointer;
        transition: all 0.2s ease;
        white-space: nowrap;
      }
      
      .quick-action:hover {
        background: var(--primary-color);
        color: white;
        border-color: var(--primary-color);
      }
      
      .chat-input-area {
        border-top: 1px solid var(--neutral-200);
        padding: 16px;
      }
      
      .chat-input-container {
        display: flex;
        gap: 8px;
        align-items: center;
      }
      
      #chat-input {
        flex: 1;
        border: 1px solid var(--neutral-300);
        border-radius: 20px;
        padding: 10px 16px;
        font-size: 14px;
        outline: none;
        transition: border-color 0.2s ease;
      }
      
      #chat-input:focus {
        border-color: var(--primary-color);
      }
      
      .chat-send {
        background: var(--primary-color);
        color: white;
        border: none;
        width: 36px;
        height: 36px;
        border-radius: 50%;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.2s ease;
      }
      
      .chat-send:hover {
        background: var(--primary-hover);
        transform: scale(1.1);
      }
      
      .chat-suggestions {
        margin-top: 8px;
        display: flex;
        flex-wrap: wrap;
        gap: 6px;
      }
      
      .suggestion {
        background: var(--neutral-50);
        border: 1px solid var(--neutral-200);
        color: var(--neutral-600);
        padding: 6px 10px;
        border-radius: 12px;
        font-size: 12px;
        cursor: pointer;
        transition: all 0.2s ease;
      }
      
      .suggestion:hover {
        background: var(--primary-color);
        color: white;
        border-color: var(--primary-color);
      }
      
      @keyframes pulse {
        0%, 100% { transform: scale(1); }
        50% { transform: scale(1.05); }
      }
      
      @media (max-width: 480px) {
        .chat-window {
          width: calc(100vw - 40px);
          right: 20px;
        }
        
        .chat-notification {
          width: calc(100vw - 100px);
        }
      }
    `;
    
    const styleSheet = document.createElement('style');
    styleSheet.textContent = styles;
    document.head.appendChild(styleSheet);
  }

  bindEvents() {
    // Toggle chat window
    document.getElementById('chat-toggle').addEventListener('click', () => {
      this.toggleChat();
    });

    // Close chat
    document.getElementById('chat-close').addEventListener('click', () => {
      this.closeChat();
    });

    // Send message
    document.getElementById('chat-send').addEventListener('click', () => {
      this.sendMessage();
    });

    // Enter key to send
    document.getElementById('chat-input').addEventListener('keypress', (e) => {
      if (e.key === 'Enter') {
        this.sendMessage();
      }
    });

    // Close notification
    document.querySelector('.notification-close').addEventListener('click', (e) => {
      e.stopPropagation();
      this.hideNotification();
    });

    // Quick action clicks
    document.getElementById('chat-quick-actions').addEventListener('click', (e) => {
      if (e.target.classList.contains('quick-action')) {
        this.handleQuickAction(e.target.dataset.action, e.target.textContent);
      }
    });

    // Suggestion clicks
    document.getElementById('chat-suggestions').addEventListener('click', (e) => {
      if (e.target.classList.contains('suggestion')) {
        document.getElementById('chat-input').value = e.target.textContent;
        this.sendMessage();
      }
    });
  }

  startContextualTriggers() {
    // Show notification after 30 seconds
    setTimeout(() => {
      if (!this.isOpen) {
        this.showNotification();
      }
    }, 30000);

    // Show help based on user behavior
    this.setupBehaviorTriggers();
    
    // Track user context
    this.trackUserContext();
  }

  setupBehaviorTriggers() {
    // Trigger when user hovers over pricing
    document.querySelector('.pricing-transparency')?.addEventListener('mouseenter', () => {
      if (!this.userContext.askedQuestions.includes('pricing')) {
        setTimeout(() => {
          if (!this.isOpen) {
            this.showContextualNotification("Questions about pricing? I'm here to help! 💰");
          }
        }, 3000);
      }
    });

    // Trigger when user spends time on application section
    let applicationTime = 0;
    const applicationObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const timer = setInterval(() => {
            applicationTime += 1000;
            if (applicationTime > 15000 && !this.userContext.askedQuestions.includes('application')) {
              this.showContextualNotification("Need help with the application? I can guide you through it! 📝");
              clearInterval(timer);
            }
          }, 1000);
          
          // Clear timer when leaving section
          const stopTimer = () => {
            clearInterval(timer);
            applicationObserver.disconnect();
          };
          entry.target.addEventListener('mouseleave', stopTimer, { once: true });
        }
      });
    });

    const applicationSection = document.querySelector('.application-preview');
    if (applicationSection) {
      applicationObserver.observe(applicationSection);
    }
  }

  trackUserContext() {
    // Track which sections user visits
    const sections = document.querySelectorAll('section[id]');
    const sectionObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const sectionId = entry.target.id;
          if (!this.userContext.visitedSections.includes(sectionId)) {
            this.userContext.visitedSections.push(sectionId);
          }
        }
      });
    });

    sections.forEach(section => sectionObserver.observe(section));

    // Track time on page
    setInterval(() => {
      this.userContext.timeOnPage += 1000;
    }, 1000);
  }

  loadPresetResponses() {
    this.responses = {
      greeting: [
        "Hi there! 👋 I'm Sarah from AdmasAfroLink. How can I help you start your global career journey today?",
        "Welcome! I'm here to answer any questions about our international internship programs. What would you like to know?"
      ],
      
      pricing: [
        "Great question about pricing! Our programs start at $3,470 total, which includes program fees, visa support, and housing assistance. This typically pays for itself within 4 months through increased salary. Would you like a detailed breakdown?",
        "I'd be happy to explain our transparent pricing. Unlike other programs, we show you exactly what you'll invest upfront - no hidden fees! The average salary increase our interns see is $15,000/year. Want to see how this works for your field?"
      ],
      
      application: [
        "The application process is super simple! It takes just 3 minutes and starts with telling us about your career interests. No essays or lengthy forms required. Would you like me to walk you through it?",
        "I can help guide you through the application! We've made it as easy as possible - just a few quick questions about your goals and interests. Ready to get started?"
      ],
      
      programs: [
        "We offer internships in Technology, Business & Finance, Marketing & Sales, and Design & Creative fields across 50+ countries. What type of role interests you most?",
        "Our programs are available in major cities worldwide including London, Tokyo, Sydney, Berlin, and many more. Each comes with guaranteed housing, visa support, and 24/7 local assistance. Which destination excites you?"
      ],
      
      support: [
        "We provide comprehensive support including visa assistance, housing placement, cultural orientation, and 24/7 local coordinators in every city. You'll never feel alone! Our support team has helped over 10,000 students successfully complete their internships.",
        "Support is our specialty! From the moment you apply until you return home, we handle everything - visas, housing, airport pickup, cultural training, and ongoing mentorship. What specific support question do you have?"
      ],
      
      visa: [
        "Visa support is included in your program fee! Our expert team handles the entire process and has a 99% approval rate. We'll guide you through every step and provide all necessary documentation. Which country are you interested in?"
      ],
      
      housing: [
        "All our programs include guaranteed housing in safe, convenient locations. You'll typically share with other international interns in fully furnished apartments or homestays. Housing is arranged before you arrive, so no stress!"
      ],
      
      timeline: [
        "Most programs start every 6-8 weeks throughout the year. The application to departure process typically takes 4-6 weeks. Our next cohort starts in 6 weeks - perfect timing to secure your spot!"
      ],
      
      safety: [
        "Safety is our top priority. All housing is pre-screened, you'll have 24/7 emergency support, comprehensive insurance, and regular check-ins. We've maintained a perfect safety record across all our programs."
      ]
    };

    this.quickActions = [
      { text: "💰 Pricing & Costs", action: "pricing" },
      { text: "📝 Application Process", action: "application" },
      { text: "🌍 Available Programs", action: "programs" },
      { text: "🛟 Support & Safety", action: "support" },
      { text: "📞 Talk to an Advisor", action: "callback" }
    ];

    this.suggestions = [
      "How much does it cost?",
      "What's included in the program?",
      "How long is the application?",
      "When can I start?",
      "Is it safe?"
    ];
  }

  toggleChat() {
    if (this.isOpen) {
      this.closeChat();
    } else {
      this.openChat();
    }
  }

  openChat() {
    this.isOpen = true;
    
    document.getElementById('chat-window').classList.add('show');
    document.getElementById('chat-toggle').classList.add('active');
    
    this.hideNotification();
    
    // Initialize chat if first time
    if (this.messages.length === 0) {
      this.initializeChat();
    }
    
    // Focus input
    setTimeout(() => {
      document.getElementById('chat-input').focus();
    }, 300);

    // Track chat open
    if (window.analytics) {
      window.analytics.trackEvent('chat_opened', {
        user_context: this.userContext
      });
    }
  }

  closeChat() {
    this.isOpen = false;
    
    document.getElementById('chat-window').classList.remove('show');
    document.getElementById('chat-toggle').classList.remove('active');

    // Track chat close
    if (window.analytics) {
      window.analytics.trackEvent('chat_closed', {
        messages_sent: this.messages.filter(m => m.sender === 'user').length,
        session_duration: Date.now() - this.chatStartTime
      });
    }
  }

  initializeChat() {
    this.chatStartTime = Date.now();
    
    // Welcome message
    const welcomeMessage = this.getRandomResponse('greeting');
    this.addMessage(welcomeMessage, 'agent');
    
    // Show quick actions
    setTimeout(() => {
      this.showQuickActions();
      this.showSuggestions();
    }, 1000);
  }

  addMessage(text, sender, options = {}) {
    const message = {
      text,
      sender,
      timestamp: Date.now(),
      ...options
    };
    
    this.messages.push(message);
    
    const messagesContainer = document.getElementById('chat-messages');
    const messageEl = document.createElement('div');
    messageEl.className = `message ${sender}`;
    messageEl.textContent = text;
    
    messagesContainer.appendChild(messageEl);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
    
    return messageEl;
  }

  showTyping() {
    const messagesContainer = document.getElementById('chat-messages');
    const typingEl = document.createElement('div');
    typingEl.className = 'message typing';
    typingEl.innerHTML = `
      <div class="typing-dots">
        <div class="typing-dot"></div>
        <div class="typing-dot"></div>
        <div class="typing-dot"></div>
      </div>
    `;
    
    messagesContainer.appendChild(typingEl);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
    
    return typingEl;
  }

  sendMessage() {
    const input = document.getElementById('chat-input');
    const message = input.value.trim();
    
    if (!message) return;
    
    // Add user message
    this.addMessage(message, 'user');
    input.value = '';
    
    // Show typing indicator
    const typingEl = this.showTyping();
    
    // Generate response
    setTimeout(() => {
      typingEl.remove();
      const response = this.generateResponse(message);
      this.addMessage(response, 'agent');
      
      // Update suggestions based on response
      this.updateSuggestions(message);
    }, 1000 + Math.random() * 2000); // Realistic typing delay

    // Track message
    if (window.analytics) {
      window.analytics.trackEvent('chat_message_sent', {
        message_length: message.length,
        message_intent: this.classifyMessage(message)
      });
    }
  }

  generateResponse(userMessage) {
    const message = userMessage.toLowerCase();
    
    // Simple keyword matching for responses
    if (message.includes('price') || message.includes('cost') || message.includes('money') || message.includes('expensive')) {
      this.userContext.askedQuestions.push('pricing');
      return this.getRandomResponse('pricing');
    }
    
    if (message.includes('application') || message.includes('apply') || message.includes('how to') || message.includes('start')) {
      this.userContext.askedQuestions.push('application');
      return this.getRandomResponse('application');
    }
    
    if (message.includes('program') || message.includes('internship') || message.includes('available') || message.includes('countries')) {
      return this.getRandomResponse('programs');
    }
    
    if (message.includes('support') || message.includes('help') || message.includes('assistance') || message.includes('safety')) {
      return this.getRandomResponse('support');
    }
    
    if (message.includes('visa') || message.includes('passport') || message.includes('document')) {
      return this.getRandomResponse('visa');
    }
    
    if (message.includes('housing') || message.includes('accommodation') || message.includes('place to stay')) {
      return this.getRandomResponse('housing');
    }
    
    if (message.includes('when') || message.includes('timeline') || message.includes('start date')) {
      return this.getRandomResponse('timeline');
    }
    
    // Default helpful response
    return "That's a great question! Let me connect you with one of our advisors who can give you detailed information. In the meantime, would you like to know about our pricing, application process, or available programs?";
  }

  classifyMessage(message) {
    const keywords = {
      pricing: ['price', 'cost', 'money', 'expensive', 'cheap', 'fee'],
      application: ['apply', 'application', 'how to', 'start', 'begin'],
      programs: ['program', 'internship', 'available', 'countries', 'locations'],
      support: ['support', 'help', 'assistance', 'safety', 'safe'],
      timeline: ['when', 'timeline', 'start date', 'how long']
    };
    
    const messageLower = message.toLowerCase();
    
    for (const [intent, words] of Object.entries(keywords)) {
      if (words.some(word => messageLower.includes(word))) {
        return intent;
      }
    }
    
    return 'general';
  }

  getRandomResponse(type) {
    const responses = this.responses[type] || ["I'd be happy to help! Let me connect you with an advisor for detailed information."];
    return responses[Math.floor(Math.random() * responses.length)];
  }

  showQuickActions() {
    const container = document.getElementById('chat-quick-actions');
    container.innerHTML = '';
    
    this.quickActions.forEach(action => {
      const button = document.createElement('button');
      button.className = 'quick-action';
      button.textContent = action.text;
      button.dataset.action = action.action;
      container.appendChild(button);
    });
  }

  handleQuickAction(action, text) {
    // Add user message
    this.addMessage(text, 'user');
    
    // Show typing and respond
    const typingEl = this.showTyping();
    
    setTimeout(() => {
      typingEl.remove();
      
      if (action === 'callback') {
        this.addMessage("I'd love to have an advisor call you! Please fill out our quick application and someone will reach out within 24 hours. Or text us at +1 (555) 123-4567 for immediate assistance.", 'agent');
        
        // Track callback request
        if (window.analytics) {
          window.analytics.trackEvent('callback_requested', {
            source: 'chat_widget'
          });
        }
      } else {
        const response = this.getRandomResponse(action);
        this.addMessage(response, 'agent');
      }
    }, 1000);
  }

  showSuggestions() {
    const container = document.getElementById('chat-suggestions');
    container.innerHTML = '';
    
    this.suggestions.forEach(suggestion => {
      const button = document.createElement('button');
      button.className = 'suggestion';
      button.textContent = suggestion;
      container.appendChild(button);
    });
  }

  updateSuggestions(lastMessage) {
    const newSuggestions = [
      "Tell me more",
      "What about safety?",
      "Can I see examples?",
      "How do I apply?",
      "Talk to an advisor"
    ];
    
    const container = document.getElementById('chat-suggestions');
    container.innerHTML = '';
    
    newSuggestions.forEach(suggestion => {
      const button = document.createElement('button');
      button.className = 'suggestion';
      button.textContent = suggestion;
      container.appendChild(button);
    });
  }

  showNotification() {
    const notification = document.getElementById('chat-notification');
    notification.classList.add('show');
    
    // Auto-hide after 10 seconds
    setTimeout(() => {
      this.hideNotification();
    }, 10000);
  }

  showContextualNotification(message) {
    const notification = document.getElementById('chat-notification');
    const textEl = notification.querySelector('.notification-text');
    
    textEl.textContent = message;
    notification.classList.add('show');
    
    setTimeout(() => {
      this.hideNotification();
    }, 8000);
  }

  hideNotification() {
    const notification = document.getElementById('chat-notification');
    notification.classList.remove('show');
  }
}

// Initialize chat widget
document.addEventListener('DOMContentLoaded', () => {
  window.chatWidget = new ChatWidget();
});

// Global function for triggering chat
window.toggleChat = function() {
  if (window.chatWidget) {
    window.chatWidget.toggleChat();
  }
};
