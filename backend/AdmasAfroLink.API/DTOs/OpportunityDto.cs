using System.ComponentModel.DataAnnotations;
using AdmasAfroLink.API.Models;

namespace AdmasAfroLink.API.DTOs
{
    public class OpportunityDto
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public OpportunityType Type { get; set; }
        public string TypeName => Type.ToString();
        public OpportunityStatus Status { get; set; }
        public string StatusName => Status.ToString();
        public string Location { get; set; } = string.Empty;
        public bool IsRemote { get; set; }
        public decimal? BudgetMin { get; set; }
        public decimal? BudgetMax { get; set; }
        public string Currency { get; set; } = "USD";
        public string BudgetRange => BudgetMin.HasValue && BudgetMax.HasValue 
            ? $"{Currency} {BudgetMin:N0} - {BudgetMax:N0}" 
            : BudgetMin.HasValue 
                ? $"{Currency} {BudgetMin:N0}+" 
                : "Negotiable";
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public DateTime? ApplicationDeadline { get; set; }
        public string UserId { get; set; } = string.Empty;
        public string UserName { get; set; } = string.Empty;
        public string UserProfilePicture { get; set; } = string.Empty;
        public string ContactEmail { get; set; } = string.Empty;
        public string ContactPhone { get; set; } = string.Empty;
        public string ExternalUrl { get; set; } = string.Empty;
        public int ViewCount { get; set; }
        public int ApplicationCount { get; set; }
        public bool IsFeatured { get; set; }
        public bool IsUrgent { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public List<TagDto> Tags { get; set; } = new List<TagDto>();
        public List<SkillDto> RequiredSkills { get; set; } = new List<SkillDto>();
        public bool HasApplied { get; set; } = false;
        public ApplicationStatus? UserApplicationStatus { get; set; }
    }

    public class CreateOpportunityDto
    {
        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;

        [Required]
        public string Description { get; set; } = string.Empty;

        [Required]
        public OpportunityType Type { get; set; }

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

        [MaxLength(200)]
        [EmailAddress]
        public string ContactEmail { get; set; } = string.Empty;

        [MaxLength(200)]
        public string ContactPhone { get; set; } = string.Empty;

        [MaxLength(255)]
        [Url]
        public string ExternalUrl { get; set; } = string.Empty;

        public bool IsFeatured { get; set; } = false;
        public bool IsUrgent { get; set; } = false;

        public List<int> TagIds { get; set; } = new List<int>();
        public List<OpportunitySkillRequirementDto> RequiredSkills { get; set; } = new List<OpportunitySkillRequirementDto>();
    }

    public class UpdateOpportunityDto : CreateOpportunityDto
    {
        public OpportunityStatus Status { get; set; }
    }

    public class OpportunitySkillRequirementDto
    {
        [Required]
        public int SkillId { get; set; }

        public bool IsRequired { get; set; } = true;

        [Range(1, 10)]
        public int RequiredLevel { get; set; } = 1;
    }

    public class OpportunityFilterDto
    {
        public string? SearchTerm { get; set; }
        public OpportunityType? Type { get; set; }
        public string? Location { get; set; }
        public bool? IsRemote { get; set; }
        public decimal? MinBudget { get; set; }
        public decimal? MaxBudget { get; set; }
        public List<int> TagIds { get; set; } = new List<int>();
        public List<int> SkillIds { get; set; } = new List<int>();
        public string? UserId { get; set; }
        public bool? IsFeatured { get; set; }
        public bool? IsUrgent { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string OrderBy { get; set; } = "CreatedAt"; // CreatedAt, ViewCount, ApplicationCount, BudgetMax
        public string OrderDirection { get; set; } = "DESC"; // ASC, DESC
        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 10;
    }

    public class OpportunityApplicationDto
    {
        public int Id { get; set; }
        public int OpportunityId { get; set; }
        public string OpportunityTitle { get; set; } = string.Empty;
        public string UserId { get; set; } = string.Empty;
        public string UserName { get; set; } = string.Empty;
        public string UserEmail { get; set; } = string.Empty;
        public string UserProfilePicture { get; set; } = string.Empty;
        public string CoverLetter { get; set; } = string.Empty;
        public string ResumeUrl { get; set; } = string.Empty;
        public string PortfolioUrl { get; set; } = string.Empty;
        public decimal? ProposedRate { get; set; }
        public ApplicationStatus Status { get; set; }
        public string StatusName => Status.ToString();
        public string ReviewNotes { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class CreateApplicationDto
    {
        [Required]
        public int OpportunityId { get; set; }

        [Required]
        public string CoverLetter { get; set; } = string.Empty;

        [MaxLength(255)]
        [Url]
        public string ResumeUrl { get; set; } = string.Empty;

        [MaxLength(255)]
        [Url]
        public string PortfolioUrl { get; set; } = string.Empty;

        [Range(0, double.MaxValue)]
        public decimal? ProposedRate { get; set; }
    }

    public class UpdateApplicationStatusDto
    {
        [Required]
        public ApplicationStatus Status { get; set; }

        public string ReviewNotes { get; set; } = string.Empty;
    }

    public class SkillDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;
        public bool IsActive { get; set; }
        public int UsageCount { get; set; } = 0;
        public bool IsRequired { get; set; } = false;
        public int RequiredLevel { get; set; } = 1;
    }

    public class TagDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;
        public string ColorCode { get; set; } = string.Empty;
        public bool IsActive { get; set; }
        public int UsageCount { get; set; } = 0;
    }

    public class InterestDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;
        public bool IsActive { get; set; }
    }

    public class PaginatedResultDto<T>
    {
        public List<T> Items { get; set; } = new List<T>();
        public int TotalCount { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
        public int TotalPages => (int)Math.Ceiling((double)TotalCount / PageSize);
        public bool HasNextPage => Page < TotalPages;
        public bool HasPreviousPage => Page > 1;
    }
}
