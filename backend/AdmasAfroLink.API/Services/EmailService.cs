using AdmasAfroLink.API.DTOs;

namespace AdmasAfroLink.API.Services
{
    public interface IEmailService
    {
        Task SendEmailConfirmationAsync(string email, string firstName, string token);
        Task SendPasswordResetAsync(string email, string firstName, string token);
        Task SendWelcomeEmailAsync(string email, string firstName);
        Task SendNotificationEmailAsync(string email, string firstName, string subject, string message);
    }

    public class EmailService : IEmailService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<EmailService> _logger;

        public EmailService(IConfiguration configuration, ILogger<EmailService> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        public async Task SendEmailConfirmationAsync(string email, string firstName, string token)
        {
            try
            {
                var confirmationLink = $"{_configuration["AppSettings:FrontendUrl"]}/confirm-email?token={Uri.EscapeDataString(token)}&email={Uri.EscapeDataString(email)}";
                
                var subject = "Confirm Your AdmasAfroLink Account";
                var body = $@"
                    <html>
                    <body style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>
                        <div style='background: linear-gradient(135deg, #FF6B35, #F7931E); padding: 30px; text-align: center;'>
                            <h1 style='color: white; margin: 0;'>Welcome to AdmasAfroLink!</h1>
                        </div>
                        <div style='padding: 30px; background-color: #f8f9fa;'>
                            <h2 style='color: #333;'>Hello {firstName},</h2>
                            <p style='color: #666; line-height: 1.6;'>
                                Thank you for joining the AdmasAfroLink community! We're excited to help you connect with 
                                Afrocentric professionals, creatives, and entrepreneurs across Africa and the diaspora.
                            </p>
                            <p style='color: #666; line-height: 1.6;'>
                                To complete your registration, please click the button below to confirm your email address:
                            </p>
                            <div style='text-align: center; margin: 30px 0;'>
                                <a href='{confirmationLink}' 
                                   style='background: #FF6B35; color: white; padding: 15px 30px; text-decoration: none; 
                                          border-radius: 5px; font-weight: bold; display: inline-block;'>
                                    Confirm Email Address
                                </a>
                            </div>
                            <p style='color: #666; line-height: 1.6;'>
                                If the button doesn't work, you can copy and paste this link into your browser:
                            </p>
                            <p style='color: #007bff; word-break: break-all;'>{confirmationLink}</p>
                            <p style='color: #666; line-height: 1.6;'>
                                This link will expire in 24 hours for security purposes.
                            </p>
                        </div>
                        <div style='background-color: #333; color: white; padding: 20px; text-align: center;'>
                            <p style='margin: 0;'>© 2025 AdmasAfroLink. Connecting Africa to the World.</p>
                        </div>
                    </body>
                    </html>";

                await SendEmailAsync(email, subject, body);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send email confirmation to {Email}", email);
                throw;
            }
        }

        public async Task SendPasswordResetAsync(string email, string firstName, string token)
        {
            try
            {
                var resetLink = $"{_configuration["AppSettings:FrontendUrl"]}/reset-password?token={Uri.EscapeDataString(token)}&email={Uri.EscapeDataString(email)}";
                
                var subject = "Reset Your AdmasAfroLink Password";
                var body = $@"
                    <html>
                    <body style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>
                        <div style='background: linear-gradient(135deg, #FF6B35, #F7931E); padding: 30px; text-align: center;'>
                            <h1 style='color: white; margin: 0;'>Password Reset Request</h1>
                        </div>
                        <div style='padding: 30px; background-color: #f8f9fa;'>
                            <h2 style='color: #333;'>Hello {firstName},</h2>
                            <p style='color: #666; line-height: 1.6;'>
                                We received a request to reset your password for your AdmasAfroLink account.
                            </p>
                            <p style='color: #666; line-height: 1.6;'>
                                Click the button below to reset your password:
                            </p>
                            <div style='text-align: center; margin: 30px 0;'>
                                <a href='{resetLink}' 
                                   style='background: #FF6B35; color: white; padding: 15px 30px; text-decoration: none; 
                                          border-radius: 5px; font-weight: bold; display: inline-block;'>
                                    Reset Password
                                </a>
                            </div>
                            <p style='color: #666; line-height: 1.6;'>
                                If the button doesn't work, you can copy and paste this link into your browser:
                            </p>
                            <p style='color: #007bff; word-break: break-all;'>{resetLink}</p>
                            <p style='color: #666; line-height: 1.6;'>
                                This link will expire in 1 hour for security purposes.
                            </p>
                            <p style='color: #666; line-height: 1.6;'>
                                If you didn't request this password reset, please ignore this email or contact our support team.
                            </p>
                        </div>
                        <div style='background-color: #333; color: white; padding: 20px; text-align: center;'>
                            <p style='margin: 0;'>© 2025 AdmasAfroLink. Connecting Africa to the World.</p>
                        </div>
                    </body>
                    </html>";

                await SendEmailAsync(email, subject, body);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send password reset email to {Email}", email);
                throw;
            }
        }

        public async Task SendWelcomeEmailAsync(string email, string firstName)
        {
            try
            {
                var subject = "Welcome to AdmasAfroLink Community!";
                var body = $@"
                    <html>
                    <body style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>
                        <div style='background: linear-gradient(135deg, #FF6B35, #F7931E); padding: 30px; text-align: center;'>
                            <h1 style='color: white; margin: 0;'>Welcome to AdmasAfroLink!</h1>
                        </div>
                        <div style='padding: 30px; background-color: #f8f9fa;'>
                            <h2 style='color: #333;'>Hello {firstName},</h2>
                            <p style='color: #666; line-height: 1.6;'>
                                Your email has been confirmed and your account is now active! 🎉
                            </p>
                            <p style='color: #666; line-height: 1.6;'>
                                AdmasAfroLink is your gateway to connecting with talented professionals, creatives, 
                                and entrepreneurs across Africa and the diaspora. Here's what you can do:
                            </p>
                            <ul style='color: #666; line-height: 1.8;'>
                                <li>Complete your profile to showcase your skills and interests</li>
                                <li>Browse and apply for exciting opportunities</li>
                                <li>Connect with like-minded professionals</li>
                                <li>Post your own gigs and collaborations</li>
                                <li>Join our vibrant community discussions</li>
                            </ul>
                            <div style='text-align: center; margin: 30px 0;'>
                                <a href='{_configuration["AppSettings:FrontendUrl"]}/profile' 
                                   style='background: #FF6B35; color: white; padding: 15px 30px; text-decoration: none; 
                                          border-radius: 5px; font-weight: bold; display: inline-block;'>
                                    Complete Your Profile
                                </a>
                            </div>
                            <p style='color: #666; line-height: 1.6;'>
                                If you have any questions, feel free to reach out to our support team.
                            </p>
                        </div>
                        <div style='background-color: #333; color: white; padding: 20px; text-align: center;'>
                            <p style='margin: 0;'>© 2025 AdmasAfroLink. Connecting Africa to the World.</p>
                        </div>
                    </body>
                    </html>";

                await SendEmailAsync(email, subject, body);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send welcome email to {Email}", email);
                throw;
            }
        }

        public async Task SendNotificationEmailAsync(string email, string firstName, string subject, string message)
        {
            try
            {
                var body = $@"
                    <html>
                    <body style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>
                        <div style='background: linear-gradient(135deg, #FF6B35, #F7931E); padding: 30px; text-align: center;'>
                            <h1 style='color: white; margin: 0;'>AdmasAfroLink</h1>
                        </div>
                        <div style='padding: 30px; background-color: #f8f9fa;'>
                            <h2 style='color: #333;'>Hello {firstName},</h2>
                            <div style='color: #666; line-height: 1.6;'>
                                {message}
                            </div>
                            <div style='text-align: center; margin: 30px 0;'>
                                <a href='{_configuration["AppSettings:FrontendUrl"]}/dashboard' 
                                   style='background: #FF6B35; color: white; padding: 15px 30px; text-decoration: none; 
                                          border-radius: 5px; font-weight: bold; display: inline-block;'>
                                    View Dashboard
                                </a>
                            </div>
                        </div>
                        <div style='background-color: #333; color: white; padding: 20px; text-align: center;'>
                            <p style='margin: 0;'>© 2025 AdmasAfroLink. Connecting Africa to the World.</p>
                        </div>
                    </body>
                    </html>";

                await SendEmailAsync(email, subject, body);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send notification email to {Email}", email);
                throw;
            }
        }

        private async Task SendEmailAsync(string email, string subject, string body)
        {
            // In a real implementation, you would use a service like SendGrid, AWS SES, etc.
            // For now, we'll just log the email content
            _logger.LogInformation("Email would be sent to {Email} with subject: {Subject}", email, subject);
            
            // Simulate email sending delay
            await Task.Delay(100);
            
            // TODO: Implement actual email sending logic
            // Example with SendGrid:
            // var client = new SendGridClient(_configuration["SendGrid:ApiKey"]);
            // var msg = MailHelper.CreateSingleEmail(
            //     new EmailAddress(_configuration["SendGrid:FromEmail"], "AdmasAfroLink"),
            //     new EmailAddress(email),
            //     subject,
            //     plainTextContent: null,
            //     htmlContent: body
            // );
            // await client.SendEmailAsync(msg);
        }
    }
}
