using Microsoft.AspNetCore.Identity;
using AutoMapper;
using AdmasAfroLink.API.Models;
using AdmasAfroLink.API.DTOs;
using System.Security.Claims;

namespace AdmasAfroLink.API.Services
{
    public interface IAuthService
    {
        Task<AuthResponseDto> RegisterAsync(UserRegistrationDto request);
        Task<AuthResponseDto> LoginAsync(UserLoginDto request);
        Task<AuthResponseDto> ExternalLoginAsync(ExternalLoginDto request);
        Task<AuthResponseDto> RefreshTokenAsync(string token, string refreshToken);
        Task<bool> LogoutAsync(string userId);
        Task<bool> ChangePasswordAsync(string userId, ChangePasswordDto request);
        Task<bool> ForgotPasswordAsync(ForgotPasswordDto request);
        Task<bool> ResetPasswordAsync(ResetPasswordDto request);
        Task<bool> ConfirmEmailAsync(string userId, string token);
        Task<bool> ResendEmailConfirmationAsync(string email);
    }

    public class AuthService : IAuthService
    {
        private readonly UserManager<User> _userManager;
        private readonly SignInManager<User> _signInManager;
        private readonly ITokenService _tokenService;
        private readonly IMapper _mapper;
        private readonly ILogger<AuthService> _logger;
        private readonly IEmailService _emailService;

        public AuthService(
            UserManager<User> userManager,
            SignInManager<User> signInManager,
            ITokenService tokenService,
            IMapper mapper,
            ILogger<AuthService> logger,
            IEmailService emailService)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _tokenService = tokenService;
            _mapper = mapper;
            _logger = logger;
            _emailService = emailService;
        }

        public async Task<AuthResponseDto> RegisterAsync(UserRegistrationDto request)
        {
            try
            {
                // Check if user already exists
                var existingUser = await _userManager.FindByEmailAsync(request.Email);
                if (existingUser != null)
                {
                    return new AuthResponseDto
                    {
                        Success = false,
                        Message = "User with this email already exists."
                    };
                }

                // Create new user
                var user = new User
                {
                    UserName = request.Email,
                    Email = request.Email,
                    FirstName = request.FirstName,
                    LastName = request.LastName,
                    Location = request.Location,
                    Country = request.Country,
                    School = request.School,
                    Major = request.Major,
                    GraduationYear = request.GraduationYear,
                    RoleType = request.RoleType,
                    EmployerApprovalStatus = request.RoleType == UserRoleType.Employer
                        ? EmployerApprovalStatus.Pending
                        : EmployerApprovalStatus.NotRequired,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };

                var result = await _userManager.CreateAsync(user, request.Password);
                if (!result.Succeeded)
                {
                    return new AuthResponseDto
                    {
                        Success = false,
                        Message = string.Join(", ", result.Errors.Select(e => e.Description))
                    };
                }

                // Add user to role
                var roleName = request.RoleType switch
                {
                    UserRoleType.Employer => "Employer",
                    UserRoleType.Admin => "Admin",
                    _ => "User"
                };
                await _userManager.AddToRoleAsync(user, roleName);

                // Generate email confirmation token
                var emailToken = await _userManager.GenerateEmailConfirmationTokenAsync(user);
                await _emailService.SendEmailConfirmationAsync(user.Email, user.FirstName, emailToken);

                // Generate JWT token
                var roles = await _userManager.GetRolesAsync(user);
                var jwtToken = _tokenService.GenerateJwtToken(user, roles);
                var refreshToken = _tokenService.GenerateRefreshToken();

                var userProfile = _mapper.Map<UserProfileDto>(user);

                return new AuthResponseDto
                {
                    Success = true,
                    Message = "Registration successful. Please check your email to confirm your account.",
                    Token = jwtToken,
                    RefreshToken = refreshToken,
                    Expiration = DateTime.UtcNow.AddMinutes(60),
                    User = userProfile
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during user registration");
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "An error occurred during registration."
                };
            }
        }

        public async Task<AuthResponseDto> LoginAsync(UserLoginDto request)
        {
            try
            {
                var user = await _userManager.FindByEmailAsync(request.Email);
                if (user == null)
                {
                    return new AuthResponseDto
                    {
                        Success = false,
                        Message = "Invalid email or password."
                    };
                }

                if (!user.IsActive)
                {
                    return new AuthResponseDto
                    {
                        Success = false,
                        Message = "Your account has been deactivated. Please contact support."
                    };
                }

                if (user.RoleType == UserRoleType.Employer && user.EmployerApprovalStatus != EmployerApprovalStatus.Approved)
                {
                    return new AuthResponseDto
                    {
                        Success = false,
                        Message = "Employer account is pending approval."
                    };
                }

                var result = await _signInManager.CheckPasswordSignInAsync(user, request.Password, false);
                if (!result.Succeeded)
                {
                    return new AuthResponseDto
                    {
                        Success = false,
                        Message = "Invalid email or password."
                    };
                }

                // Generate tokens
                var roles = await _userManager.GetRolesAsync(user);
                var jwtToken = _tokenService.GenerateJwtToken(user, roles);
                var refreshToken = _tokenService.GenerateRefreshToken();

                var userProfile = _mapper.Map<UserProfileDto>(user);

                return new AuthResponseDto
                {
                    Success = true,
                    Message = "Login successful.",
                    Token = jwtToken,
                    RefreshToken = refreshToken,
                    Expiration = DateTime.UtcNow.AddMinutes(60),
                    User = userProfile
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during user login");
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "An error occurred during login."
                };
            }
        }

        public async Task<AuthResponseDto> ExternalLoginAsync(ExternalLoginDto request)
        {
            try
            {
                // Check if user exists
                var user = await _userManager.FindByEmailAsync(request.Email);
                if (user == null)
                {
                    // Create new user for external login
                    user = new User
                    {
                        UserName = request.Email,
                        Email = request.Email,
                        FirstName = request.FirstName,
                        LastName = request.LastName,
                        ProfilePictureUrl = request.ProfilePictureUrl,
                        RoleType = UserRoleType.Student,
                        EmployerApprovalStatus = EmployerApprovalStatus.NotRequired,
                        EmailConfirmed = true, // Trust external provider
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    };

                    var createResult = await _userManager.CreateAsync(user);
                    if (!createResult.Succeeded)
                    {
                        return new AuthResponseDto
                        {
                            Success = false,
                            Message = "Failed to create user account."
                        };
                    }

                    await _userManager.AddToRoleAsync(user, "User");
                }

                // Add external login info
                var loginInfo = new UserLoginInfo(request.Provider, request.Token, request.Provider);
                var addLoginResult = await _userManager.AddLoginAsync(user, loginInfo);

                // Generate tokens
                var roles = await _userManager.GetRolesAsync(user);
                var jwtToken = _tokenService.GenerateJwtToken(user, roles);
                var refreshToken = _tokenService.GenerateRefreshToken();

                var userProfile = _mapper.Map<UserProfileDto>(user);

                return new AuthResponseDto
                {
                    Success = true,
                    Message = "External login successful.",
                    Token = jwtToken,
                    RefreshToken = refreshToken,
                    Expiration = DateTime.UtcNow.AddMinutes(60),
                    User = userProfile
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during external login");
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "An error occurred during external login."
                };
            }
        }

        public async Task<AuthResponseDto> RefreshTokenAsync(string token, string refreshToken)
        {
            try
            {
                var principal = _tokenService.GetPrincipalFromExpiredToken(token);
                var userId = principal.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                if (string.IsNullOrEmpty(userId))
                {
                    return new AuthResponseDto
                    {
                        Success = false,
                        Message = "Invalid token."
                    };
                }

                var user = await _userManager.FindByIdAsync(userId);
                if (user == null || !user.IsActive)
                {
                    return new AuthResponseDto
                    {
                        Success = false,
                        Message = "User not found or inactive."
                    };
                }

                // Generate new tokens
                var roles = await _userManager.GetRolesAsync(user);
                var newJwtToken = _tokenService.GenerateJwtToken(user, roles);
                var newRefreshToken = _tokenService.GenerateRefreshToken();

                var userProfile = _mapper.Map<UserProfileDto>(user);

                return new AuthResponseDto
                {
                    Success = true,
                    Message = "Token refreshed successfully.",
                    Token = newJwtToken,
                    RefreshToken = newRefreshToken,
                    Expiration = DateTime.UtcNow.AddMinutes(60),
                    User = userProfile
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during token refresh");
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "Failed to refresh token."
                };
            }
        }

        public async Task<bool> LogoutAsync(string userId)
        {
            try
            {
                await _signInManager.SignOutAsync();
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during logout for user {UserId}", userId);
                return false;
            }
        }

        public async Task<bool> ChangePasswordAsync(string userId, ChangePasswordDto request)
        {
            try
            {
                var user = await _userManager.FindByIdAsync(userId);
                if (user == null)
                    return false;

                var result = await _userManager.ChangePasswordAsync(user, request.CurrentPassword, request.NewPassword);
                return result.Succeeded;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error changing password for user {UserId}", userId);
                return false;
            }
        }

        public async Task<bool> ForgotPasswordAsync(ForgotPasswordDto request)
        {
            try
            {
                var user = await _userManager.FindByEmailAsync(request.Email);
                if (user == null)
                    return true; // Don't reveal if email exists

                var token = await _userManager.GeneratePasswordResetTokenAsync(user);
                await _emailService.SendPasswordResetAsync(user.Email, user.FirstName, token);

                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending password reset email");
                return false;
            }
        }

        public async Task<bool> ResetPasswordAsync(ResetPasswordDto request)
        {
            try
            {
                var user = await _userManager.FindByEmailAsync(request.Email);
                if (user == null)
                    return false;

                var result = await _userManager.ResetPasswordAsync(user, request.Token, request.NewPassword);
                return result.Succeeded;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error resetting password");
                return false;
            }
        }

        public async Task<bool> ConfirmEmailAsync(string userId, string token)
        {
            try
            {
                var user = await _userManager.FindByIdAsync(userId);
                if (user == null)
                    return false;

                var result = await _userManager.ConfirmEmailAsync(user, token);
                return result.Succeeded;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error confirming email for user {UserId}", userId);
                return false;
            }
        }

        public async Task<bool> ResendEmailConfirmationAsync(string email)
        {
            try
            {
                var user = await _userManager.FindByEmailAsync(email);
                if (user == null || user.EmailConfirmed)
                    return true; // Don't reveal if email exists or is already confirmed

                var token = await _userManager.GenerateEmailConfirmationTokenAsync(user);
                await _emailService.SendEmailConfirmationAsync(user.Email, user.FirstName, token);

                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error resending email confirmation");
                return false;
            }
        }
    }
}
