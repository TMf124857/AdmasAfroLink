using System.ComponentModel.DataAnnotations;
using AdmasAfroLink.API.Models;

namespace AdmasAfroLink.API.DTOs.Opportunity
{
    public class CreateOpportunityRequest
    {
        [Required]
        [StringLength(200, MinimumLength = 10)]
        public string Title { get; set; } = string.Empty;

        [Required]
        [StringLength(5000, MinimumLength = 50)]
        public string Description { get; set; } = string.Empty;

        [Required]
        public OpportunityType Type { get; set; } = OpportunityType.Gig;

        [StringLength(200)]
        public string Location { get; set; } = string.Empty;

        public bool IsRemote { get; set; } = false;

        [Range(0, 999999999)]
        public decimal? BudgetMin { get; set; }

        [Range(0, 999999999)]
        public decimal? BudgetMax { get; set; }

        [StringLength(10)]
        public string Currency { get; set; } = "USD";

        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public DateTime? ApplicationDeadline { get; set; }

        [EmailAddress]
        public string? ContactEmail { get; set; }

        [Phone]
        public string? ContactPhone { get; set; }

        [Url]
        public string? ExternalUrl { get; set; }

        public bool IsFeatured { get; set; } = false;
        public bool IsUrgent { get; set; } = false;

        public List<string>? Tags { get; set; }
        public List<string>? RequiredSkills { get; set; }
    }

    public class UpdateOpportunityRequest
    {
        [Required]
        [StringLength(200, MinimumLength = 10)]
        public string Title { get; set; } = string.Empty;

        [Required]
        [StringLength(5000, MinimumLength = 50)]
        public string Description { get; set; } = string.Empty;

        [Required]
        public OpportunityType Type { get; set; } = OpportunityType.Gig;

        [Required]
        public OpportunityStatus Status { get; set; } = OpportunityStatus.Draft;

        [StringLength(200)]
        public string Location { get; set; } = string.Empty;

        public bool IsRemote { get; set; } = false;

        [Range(0, 999999999)]
        public decimal? BudgetMin { get; set; }

        [Range(0, 999999999)]
        public decimal? BudgetMax { get; set; }

        [StringLength(10)]
        public string Currency { get; set; } = "USD";

        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public DateTime? ApplicationDeadline { get; set; }

        [EmailAddress]
        public string? ContactEmail { get; set; }

        [Phone]
        public string? ContactPhone { get; set; }

        [Url]
        public string? ExternalUrl { get; set; }

        public bool IsFeatured { get; set; } = false;
        public bool IsUrgent { get; set; } = false;

        public List<string>? Tags { get; set; }
        public List<string>? RequiredSkills { get; set; }
    }
}
