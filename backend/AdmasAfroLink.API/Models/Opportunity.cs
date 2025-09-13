using System.ComponentModel.DataAnnotations;

namespace AdmasAfroLink.API.Models
{
    public enum OpportunityType
    {
        Gig = 1,
        Collaboration = 2,
        Investment = 3,
        Job = 4,
        Internship = 5,
        Mentorship = 6,
        Partnership = 7,
        Event = 8
    }

    public enum OpportunityStatus
    {
        Draft = 1,
        Published = 2,
        Closed = 3,
        Cancelled = 4
    }

    public class Opportunity
    {
        public int Id { get; set; }

        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;

        [Required]
        public string Description { get; set; } = string.Empty;

        public OpportunityType Type { get; set; } = OpportunityType.Gig;

        public OpportunityStatus Status { get; set; } = OpportunityStatus.Draft;

        [MaxLength(200)]
        public string Location { get; set; } = string.Empty;

        public bool IsRemote { get; set; } = false;

        [Range(0, double.MaxValue)]
        public decimal? BudgetMin { get; set; }

        [Range(0, double.MaxValue)]
        public decimal? BudgetMax { get; set; }

        [MaxLength(10)]
        public string Currency { get; set; } = "USD";

        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public DateTime? ApplicationDeadline { get; set; }

        [Required]
        public string UserId { get; set; } = string.Empty;

        [MaxLength(200)]
        public string ContactEmail { get; set; } = string.Empty;

        [MaxLength(200)]
        public string ContactPhone { get; set; } = string.Empty;

        [MaxLength(255)]
        public string ExternalUrl { get; set; } = string.Empty;

        public int ViewCount { get; set; } = 0;
        public int ApplicationCount { get; set; } = 0;

        public bool IsFeatured { get; set; } = false;
        public bool IsUrgent { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual User User { get; set; } = null!;
        public virtual ICollection<OpportunityTag> Tags { get; set; } = new List<OpportunityTag>();
        public virtual ICollection<OpportunitySkill> RequiredSkills { get; set; } = new List<OpportunitySkill>();
        public virtual ICollection<OpportunityApplication> Applications { get; set; } = new List<OpportunityApplication>();
    }

    public class Tag
    {
        public int Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(100)]
        public string Category { get; set; } = string.Empty;

        [MaxLength(20)]
        public string ColorCode { get; set; } = "#007bff";

        public bool IsActive { get; set; } = true;
        public int UsageCount { get; set; } = 0;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual ICollection<OpportunityTag> OpportunityTags { get; set; } = new List<OpportunityTag>();
    }

    public class OpportunityTag
    {
        public int OpportunityId { get; set; }
        public int TagId { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual Opportunity Opportunity { get; set; } = null!;
        public virtual Tag Tag { get; set; } = null!;
    }

    public class OpportunitySkill
    {
        public int OpportunityId { get; set; }
        public int SkillId { get; set; }

        public bool IsRequired { get; set; } = true;

        [Range(1, 10)]
        public int RequiredLevel { get; set; } = 1;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual Opportunity Opportunity { get; set; } = null!;
        public virtual Skill Skill { get; set; } = null!;
    }

    public enum ApplicationStatus
    {
        Submitted = 1,
        UnderReview = 2,
        Shortlisted = 3,
        Interviewed = 4,
        Accepted = 5,
        Rejected = 6,
        Withdrawn = 7
    }

    public class OpportunityApplication
    {
        public int Id { get; set; }

        public int OpportunityId { get; set; }

        [Required]
        public string UserId { get; set; } = string.Empty;

        [Required]
        public string CoverLetter { get; set; } = string.Empty;

        [MaxLength(255)]
        public string ResumeUrl { get; set; } = string.Empty;

        [MaxLength(255)]
        public string PortfolioUrl { get; set; } = string.Empty;

        [Range(0, double.MaxValue)]
        public decimal? ProposedRate { get; set; }

        public ApplicationStatus Status { get; set; } = ApplicationStatus.Submitted;

        public string ReviewNotes { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual Opportunity Opportunity { get; set; } = null!;
        public virtual User User { get; set; } = null!;
    }
}
