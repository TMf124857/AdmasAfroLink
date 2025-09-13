using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;

namespace AdmasAfroLink.API.Models
{
    public class User : IdentityUser
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
        public string ProfilePictureUrl { get; set; } = string.Empty;

        [MaxLength(255)]
        public string CoverImageUrl { get; set; } = string.Empty;

        [MaxLength(255)]
        public string Website { get; set; } = string.Empty;

        [MaxLength(255)]
        public string LinkedIn { get; set; } = string.Empty;

        [MaxLength(255)]
        public string Twitter { get; set; } = string.Empty;

        [MaxLength(255)]
        public string Instagram { get; set; } = string.Empty;

        [MaxLength(100)]
        public string Company { get; set; } = string.Empty;

        [MaxLength(100)]
        public string JobTitle { get; set; } = string.Empty;

        [MaxLength(255)]
        public string LinkedInProfile { get; set; } = string.Empty;

        [MaxLength(255)]
        public string GitHubProfile { get; set; } = string.Empty;

        public bool IsProfilePublic { get; set; } = true;

        public bool IsAvailableForOpportunities { get; set; } = true;

        public DateTime? LastLoginAt { get; set; }

        public bool IsVerified { get; set; } = false;
        
        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual ICollection<UserSkill> Skills { get; set; } = new List<UserSkill>();
        public virtual ICollection<UserInterest> Interests { get; set; } = new List<UserInterest>();
        public virtual ICollection<Opportunity> Opportunities { get; set; } = new List<Opportunity>();
        public virtual ICollection<Message> SentMessages { get; set; } = new List<Message>();
        public virtual ICollection<Message> ReceivedMessages { get; set; } = new List<Message>();
        public virtual ICollection<UserConnection> Connections { get; set; } = new List<UserConnection>();
        public virtual ICollection<UserConnection> ConnectedUsers { get; set; } = new List<UserConnection>();
    }
}
