using System.ComponentModel.DataAnnotations;

namespace AdmasAfroLink.API.DTOs.UserProfile
{
    public class UpdateProfileRequest
    {
        [Required]
        [StringLength(100)]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        [StringLength(100)]
        public string LastName { get; set; } = string.Empty;

        [StringLength(500)]
        public string? Bio { get; set; }

        [StringLength(100)]
        public string? Company { get; set; }

        [StringLength(100)]
        public string? JobTitle { get; set; }

        [StringLength(200)]
        public string? Location { get; set; }

        [StringLength(100)]
        public string? Country { get; set; }

        [Phone]
        public string? PhoneNumber { get; set; }

        [Url]
        public string? Website { get; set; }

        [Url]
        public string? LinkedInProfile { get; set; }

        [Url]
        public string? GitHubProfile { get; set; }

        public bool IsProfilePublic { get; set; } = true;

        public bool IsAvailableForOpportunities { get; set; } = true;

        public List<string>? Skills { get; set; }

        public List<string>? Interests { get; set; }
    }
}
