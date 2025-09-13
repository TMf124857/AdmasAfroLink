using AdmasAfroLink.API.DTOs.Opportunity;
using AdmasAfroLink.API.Models;

namespace AdmasAfroLink.API.Services.Interfaces
{
    public interface IOpportunityService
    {
        Task<OpportunityResponse?> CreateOpportunityAsync(string userId, CreateOpportunityRequest request);
        Task<OpportunityResponse?> GetOpportunityByIdAsync(int opportunityId);
        Task<OpportunityResponse?> UpdateOpportunityAsync(string userId, int opportunityId, UpdateOpportunityRequest request);
        Task<bool> DeleteOpportunityAsync(string userId, int opportunityId);
        
        Task<OpportunityListResponse> GetOpportunitiesAsync(
            string? searchQuery = null,
            OpportunityType? type = null,
            OpportunityStatus? status = null,
            string? location = null,
            bool? isRemote = null,
            decimal? minBudget = null,
            decimal? maxBudget = null,
            List<string>? tags = null,
            List<string>? skills = null,
            string? sortBy = null,
            bool sortDescending = true,
            int page = 1,
            int pageSize = 20);

        Task<OpportunityListResponse> GetUserOpportunitiesAsync(
            string userId,
            OpportunityStatus? status = null,
            int page = 1,
            int pageSize = 20);

        Task<OpportunityStatsResponse> GetOpportunityStatsAsync(string? userId = null);
        
        Task<bool> IncrementViewCountAsync(int opportunityId);
        Task<bool> ToggleFeaturedStatusAsync(string userId, int opportunityId);
        Task<bool> UpdateOpportunityStatusAsync(string userId, int opportunityId, OpportunityStatus status);
        
        Task<List<TagDto>> GetAvailableTagsAsync();
        Task<List<SkillDto>> GetAvailableSkillsAsync();
    }
}
