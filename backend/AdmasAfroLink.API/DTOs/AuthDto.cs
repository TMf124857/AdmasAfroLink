using System.ComponentModel.DataAnnotations;
using AdmasAfroLink.API.Models;

namespace AdmasAfroLink.API.DTOs
{
    public class UserRegistrationDto
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MinLength(6)]
        public string Password { get; set; } = string.Empty;

        [Required]
        [Compare("Password")]
        public string ConfirmPassword { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string LastName { get; set; } = string.Empty;

        [MaxLength(200)]
        public string Location { get; set; } = string.Empty;

        [MaxLength(200)]
        public string Country { get; set; } = string.Empty;

        [Required]
        public UserRoleType RoleType { get; set; } = UserRoleType.Student;

        [MaxLength(150)]
        public string School { get; set; } = string.Empty;

        [MaxLength(150)]
        public string Major { get; set; } = string.Empty;

        [Range(2000, 2100)]
        public int? GraduationYear { get; set; }
    }

    public class UserLoginDto
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        public string Password { get; set; } = string.Empty;

        public bool RememberMe { get; set; } = false;
    }

    public class ExternalLoginDto
    {
        [Required]
        public string Provider { get; set; } = string.Empty;

        [Required]
        public string Token { get; set; } = string.Empty;

        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        public string LastName { get; set; } = string.Empty;

        public string ProfilePictureUrl { get; set; } = string.Empty;
    }

    public class UserProfileDto
    {
        public string Id { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string FullName => $"{FirstName} {LastName}";
        public string Bio { get; set; } = string.Empty;
        public string Location { get; set; } = string.Empty;
        public string Country { get; set; } = string.Empty;
        public string ProfilePictureUrl { get; set; } = string.Empty;
        public string CoverImageUrl { get; set; } = string.Empty;
        public string Website { get; set; } = string.Empty;
        public string LinkedIn { get; set; } = string.Empty;
        public string Twitter { get; set; } = string.Empty;
        public string Instagram { get; set; } = string.Empty;
        public string School { get; set; } = string.Empty;
        public string Major { get; set; } = string.Empty;
        public int? GraduationYear { get; set; }
        public UserRoleType RoleType { get; set; }
        public EmployerApprovalStatus EmployerApprovalStatus { get; set; }
        public bool IsVerified { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public List<UserSkillDto> Skills { get; set; } = new List<UserSkillDto>();
        public List<UserInterestDto> Interests { get; set; } = new List<UserInterestDto>();
        public int ConnectionCount { get; set; }
        public int OpportunityCount { get; set; }
    }

    public class UpdateUserProfileDto
    {
        [Required]
        [MaxLength(100)]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string LastName { get; set; } = string.Empty;

        [MaxLength(500)]
        public string Bio { get; set; } = string.Empty;

        [MaxLength(200)]
        public string Location { get; set; } = string.Empty;

        [MaxLength(200)]
        public string Country { get; set; } = string.Empty;

        [MaxLength(255)]
        [Url]
        public string Website { get; set; } = string.Empty;

        [MaxLength(255)]
        public string LinkedIn { get; set; } = string.Empty;

        [MaxLength(255)]
        public string Twitter { get; set; } = string.Empty;

        [MaxLength(255)]
        public string Instagram { get; set; } = string.Empty;

        public List<int> SkillIds { get; set; } = new List<int>();
        public List<int> InterestIds { get; set; } = new List<int>();
    }

    public class UserSkillDto
    {
        public int SkillId { get; set; }
        public string SkillName { get; set; } = string.Empty;
        public string SkillCategory { get; set; } = string.Empty;
        public int ProficiencyLevel { get; set; }
        public bool IsEndorsed { get; set; }
        public int EndorsementCount { get; set; }
    }

    public class UserInterestDto
    {
        public int InterestId { get; set; }
        public string InterestName { get; set; } = string.Empty;
        public string InterestCategory { get; set; } = string.Empty;
    }

    public class AuthResponseDto
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public string Token { get; set; } = string.Empty;
        public string RefreshToken { get; set; } = string.Empty;
        public DateTime Expiration { get; set; }
        public UserProfileDto? User { get; set; }
    }

    public class ChangePasswordDto
    {
        [Required]
        public string CurrentPassword { get; set; } = string.Empty;

        [Required]
        [MinLength(6)]
        public string NewPassword { get; set; } = string.Empty;

        [Required]
        [Compare("NewPassword")]
        public string ConfirmNewPassword { get; set; } = string.Empty;
    }

    public class ForgotPasswordDto
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;
    }

    public class ResetPasswordDto
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        public string Token { get; set; } = string.Empty;

        [Required]
        [MinLength(6)]
        public string NewPassword { get; set; } = string.Empty;

        [Required]
        [Compare("NewPassword")]
        public string ConfirmNewPassword { get; set; } = string.Empty;
    }
}
