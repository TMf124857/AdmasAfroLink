using AdmasAfroLink.API.Models;

namespace AdmasAfroLink.API.DTOs.Opportunity
{
    public class OpportunityResponse
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public OpportunityType Type { get; set; }
        public OpportunityStatus Status { get; set; }
        public string Location { get; set; } = string.Empty;
        public bool IsRemote { get; set; }
        public decimal? BudgetMin { get; set; }
        public decimal? BudgetMax { get; set; }
        public string Currency { get; set; } = string.Empty;
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public DateTime? ApplicationDeadline { get; set; }
        public string UserId { get; set; } = string.Empty;
        public string? ContactEmail { get; set; }
        public string? ContactPhone { get; set; }
        public string? ExternalUrl { get; set; }
        public int ViewCount { get; set; }
        public int ApplicationCount { get; set; }
        public bool IsFeatured { get; set; }
        public bool IsUrgent { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }

        // Related data
        public OpportunityUserResponse User { get; set; } = new();
        public List<TagDto> Tags { get; set; } = new();
        public List<SkillDto> RequiredSkills { get; set; } = new();
    }

    public class OpportunitySearchResponse
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public OpportunityType Type { get; set; }
        public OpportunityStatus Status { get; set; }
        public string Location { get; set; } = string.Empty;
        public bool IsRemote { get; set; }
        public decimal? BudgetMin { get; set; }
        public decimal? BudgetMax { get; set; }
        public string Currency { get; set; } = string.Empty;
        public DateTime? ApplicationDeadline { get; set; }
        public int ViewCount { get; set; }
        public int ApplicationCount { get; set; }
        public bool IsFeatured { get; set; }
        public bool IsUrgent { get; set; }
        public DateTime CreatedAt { get; set; }

        // Related data
        public OpportunityUserResponse User { get; set; } = new();
        public List<TagDto> Tags { get; set; } = new();
        public List<SkillDto> RequiredSkills { get; set; } = new();
    }

    public class OpportunityListResponse
    {
        public List<OpportunitySearchResponse> Opportunities { get; set; } = new();
        public int TotalCount { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
        public int TotalPages { get; set; }
        public bool HasNextPage { get; set; }
        public bool HasPreviousPage { get; set; }
    }

    public class OpportunityUserResponse
    {
        public string Id { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string? Company { get; set; }
        public string? JobTitle { get; set; }
        public string? ProfilePictureUrl { get; set; }
        public bool IsVerified { get; set; }
    }

    public class TagDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;
        public string ColorCode { get; set; } = string.Empty;
    }

    public class SkillDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
    }

    public class OpportunityStatsResponse
    {
        public int TotalOpportunities { get; set; }
        public int ActiveOpportunities { get; set; }
        public int DraftOpportunities { get; set; }
        public int ClosedOpportunities { get; set; }
        public int TotalViews { get; set; }
        public int TotalApplications { get; set; }
        public Dictionary<OpportunityType, int> OpportunitiesByType { get; set; } = new();
        public Dictionary<string, int> OpportunitiesByLocation { get; set; } = new();
    }
}
