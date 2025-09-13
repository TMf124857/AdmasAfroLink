using AutoMapper;
using Microsoft.EntityFrameworkCore;
using AdmasAfroLink.API.Data;
using AdmasAfroLink.API.DTOs.Opportunity;
using AdmasAfroLink.API.Models;
using AdmasAfroLink.API.Services.Interfaces;

namespace AdmasAfroLink.API.Services
{
    public class OpportunityService : IOpportunityService
    {
        private readonly ApplicationDbContext _context;
        private readonly IMapper _mapper;
        private readonly ILogger<OpportunityService> _logger;

        public OpportunityService(
            ApplicationDbContext context,
            IMapper mapper,
            ILogger<OpportunityService> logger)
        {
            _context = context;
            _mapper = mapper;
            _logger = logger;
        }

        public async Task<OpportunityResponse?> CreateOpportunityAsync(string userId, CreateOpportunityRequest request)
        {
            try
            {
                var opportunity = _mapper.Map<Opportunity>(request);
                opportunity.UserId = userId;
                opportunity.CreatedAt = DateTime.UtcNow;
                opportunity.UpdatedAt = DateTime.UtcNow;

                _context.Opportunities.Add(opportunity);
                await _context.SaveChangesAsync();

                // Add tags if provided
                if (request.Tags != null && request.Tags.Any())
                {
                    await AddOpportunityTagsAsync(opportunity.Id, request.Tags);
                }

                // Add required skills if provided
                if (request.RequiredSkills != null && request.RequiredSkills.Any())
                {
                    await AddOpportunitySkillsAsync(opportunity.Id, request.RequiredSkills);
                }

                await _context.SaveChangesAsync();

                _logger.LogInformation("Opportunity created successfully with ID {OpportunityId} by user {UserId}", 
                    opportunity.Id, userId);

                return await GetOpportunityByIdAsync(opportunity.Id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating opportunity for user {UserId}", userId);
                throw;
            }
        }

        public async Task<OpportunityResponse?> GetOpportunityByIdAsync(int opportunityId)
        {
            try
            {
                var opportunity = await _context.Opportunities
                    .Include(o => o.User)
                    .Include(o => o.Tags)
                        .ThenInclude(ot => ot.Tag)
                    .Include(o => o.RequiredSkills)
                        .ThenInclude(os => os.Skill)
                    .FirstOrDefaultAsync(o => o.Id == opportunityId);

                if (opportunity == null)
                {
                    _logger.LogWarning("Opportunity with ID {OpportunityId} not found", opportunityId);
                    return null;
                }

                return _mapper.Map<OpportunityResponse>(opportunity);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting opportunity with ID {OpportunityId}", opportunityId);
                throw;
            }
        }

        public async Task<OpportunityResponse?> UpdateOpportunityAsync(string userId, int opportunityId, UpdateOpportunityRequest request)
        {
            try
            {
                var opportunity = await _context.Opportunities
                    .Include(o => o.Tags)
                    .Include(o => o.RequiredSkills)
                    .FirstOrDefaultAsync(o => o.Id == opportunityId && o.UserId == userId);

                if (opportunity == null)
                {
                    _logger.LogWarning("Opportunity with ID {OpportunityId} not found or user {UserId} not authorized", 
                        opportunityId, userId);
                    return null;
                }

                _mapper.Map(request, opportunity);
                opportunity.UpdatedAt = DateTime.UtcNow;

                // Update tags
                if (request.Tags != null)
                {
                    // Remove existing tags
                    _context.OpportunityTags.RemoveRange(opportunity.Tags);
                    await _context.SaveChangesAsync();

                    // Add new tags
                    if (request.Tags.Any())
                    {
                        await AddOpportunityTagsAsync(opportunity.Id, request.Tags);
                    }
                }

                // Update required skills
                if (request.RequiredSkills != null)
                {
                    // Remove existing skills
                    _context.OpportunitySkills.RemoveRange(opportunity.RequiredSkills);
                    await _context.SaveChangesAsync();

                    // Add new skills
                    if (request.RequiredSkills.Any())
                    {
                        await AddOpportunitySkillsAsync(opportunity.Id, request.RequiredSkills);
                    }
                }

                await _context.SaveChangesAsync();

                _logger.LogInformation("Opportunity {OpportunityId} updated successfully by user {UserId}", 
                    opportunityId, userId);

                return await GetOpportunityByIdAsync(opportunityId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating opportunity {OpportunityId} for user {UserId}", 
                    opportunityId, userId);
                throw;
            }
        }

        public async Task<bool> DeleteOpportunityAsync(string userId, int opportunityId)
        {
            try
            {
                var opportunity = await _context.Opportunities
                    .FirstOrDefaultAsync(o => o.Id == opportunityId && o.UserId == userId);

                if (opportunity == null)
                {
                    _logger.LogWarning("Opportunity with ID {OpportunityId} not found or user {UserId} not authorized", 
                        opportunityId, userId);
                    return false;
                }

                _context.Opportunities.Remove(opportunity);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Opportunity {OpportunityId} deleted successfully by user {UserId}", 
                    opportunityId, userId);

                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting opportunity {OpportunityId} for user {UserId}", 
                    opportunityId, userId);
                throw;
            }
        }

        public async Task<OpportunityListResponse> GetOpportunitiesAsync(
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
            int pageSize = 20)
        {
            try
            {
                var query = _context.Opportunities
                    .Include(o => o.User)
                    .Include(o => o.Tags)
                        .ThenInclude(ot => ot.Tag)
                    .Include(o => o.RequiredSkills)
                        .ThenInclude(os => os.Skill)
                    .AsQueryable();

                // Apply filters
                if (!string.IsNullOrWhiteSpace(searchQuery))
                {
                    query = query.Where(o => 
                        o.Title.Contains(searchQuery) ||
                        o.Description.Contains(searchQuery));
                }

                if (type.HasValue)
                {
                    query = query.Where(o => o.Type == type.Value);
                }

                if (status.HasValue)
                {
                    query = query.Where(o => o.Status == status.Value);
                }
                else
                {
                    // Default to only published opportunities if no status specified
                    query = query.Where(o => o.Status == OpportunityStatus.Published);
                }

                if (!string.IsNullOrWhiteSpace(location))
                {
                    query = query.Where(o => o.Location.Contains(location));
                }

                if (isRemote.HasValue)
                {
                    query = query.Where(o => o.IsRemote == isRemote.Value);
                }

                if (minBudget.HasValue)
                {
                    query = query.Where(o => o.BudgetMin >= minBudget.Value || o.BudgetMax >= minBudget.Value);
                }

                if (maxBudget.HasValue)
                {
                    query = query.Where(o => o.BudgetMax <= maxBudget.Value || o.BudgetMin <= maxBudget.Value);
                }

                if (tags != null && tags.Any())
                {
                    query = query.Where(o => o.Tags.Any(ot => tags.Contains(ot.Tag.Name)));
                }

                if (skills != null && skills.Any())
                {
                    query = query.Where(o => o.RequiredSkills.Any(os => skills.Contains(os.Skill.Name)));
                }

                // Apply sorting
                query = sortBy?.ToLower() switch
                {
                    "title" => sortDescending ? query.OrderByDescending(o => o.Title) : query.OrderBy(o => o.Title),
                    "type" => sortDescending ? query.OrderByDescending(o => o.Type) : query.OrderBy(o => o.Type),
                    "location" => sortDescending ? query.OrderByDescending(o => o.Location) : query.OrderBy(o => o.Location),
                    "budget" => sortDescending ? query.OrderByDescending(o => o.BudgetMax) : query.OrderBy(o => o.BudgetMax),
                    "deadline" => sortDescending ? query.OrderByDescending(o => o.ApplicationDeadline) : query.OrderBy(o => o.ApplicationDeadline),
                    "views" => sortDescending ? query.OrderByDescending(o => o.ViewCount) : query.OrderBy(o => o.ViewCount),
                    _ => sortDescending ? query.OrderByDescending(o => o.CreatedAt) : query.OrderBy(o => o.CreatedAt)
                };

                // Get total count
                var totalCount = await query.CountAsync();

                // Apply pagination
                var opportunities = await query
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .ToListAsync();

                var totalPages = (int)Math.Ceiling((double)totalCount / pageSize);

                var result = new OpportunityListResponse
                {
                    Opportunities = _mapper.Map<List<OpportunitySearchResponse>>(opportunities),
                    TotalCount = totalCount,
                    Page = page,
                    PageSize = pageSize,
                    TotalPages = totalPages,
                    HasNextPage = page < totalPages,
                    HasPreviousPage = page > 1
                };

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting opportunities with filters");
                throw;
            }
        }

        public async Task<OpportunityListResponse> GetUserOpportunitiesAsync(
            string userId,
            OpportunityStatus? status = null,
            int page = 1,
            int pageSize = 20)
        {
            try
            {
                var query = _context.Opportunities
                    .Include(o => o.User)
                    .Include(o => o.Tags)
                        .ThenInclude(ot => ot.Tag)
                    .Include(o => o.RequiredSkills)
                        .ThenInclude(os => os.Skill)
                    .Where(o => o.UserId == userId);

                if (status.HasValue)
                {
                    query = query.Where(o => o.Status == status.Value);
                }

                query = query.OrderByDescending(o => o.CreatedAt);

                var totalCount = await query.CountAsync();

                var opportunities = await query
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .ToListAsync();

                var totalPages = (int)Math.Ceiling((double)totalCount / pageSize);

                var result = new OpportunityListResponse
                {
                    Opportunities = _mapper.Map<List<OpportunitySearchResponse>>(opportunities),
                    TotalCount = totalCount,
                    Page = page,
                    PageSize = pageSize,
                    TotalPages = totalPages,
                    HasNextPage = page < totalPages,
                    HasPreviousPage = page > 1
                };

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting opportunities for user {UserId}", userId);
                throw;
            }
        }

        public async Task<OpportunityStatsResponse> GetOpportunityStatsAsync(string? userId = null)
        {
            try
            {
                var query = _context.Opportunities.AsQueryable();

                if (!string.IsNullOrEmpty(userId))
                {
                    query = query.Where(o => o.UserId == userId);
                }

                var opportunities = await query.ToListAsync();

                var stats = new OpportunityStatsResponse
                {
                    TotalOpportunities = opportunities.Count,
                    ActiveOpportunities = opportunities.Count(o => o.Status == OpportunityStatus.Published),
                    DraftOpportunities = opportunities.Count(o => o.Status == OpportunityStatus.Draft),
                    ClosedOpportunities = opportunities.Count(o => o.Status == OpportunityStatus.Closed),
                    TotalViews = opportunities.Sum(o => o.ViewCount),
                    TotalApplications = opportunities.Sum(o => o.ApplicationCount),
                    OpportunitiesByType = opportunities
                        .GroupBy(o => o.Type)
                        .ToDictionary(g => g.Key, g => g.Count()),
                    OpportunitiesByLocation = opportunities
                        .Where(o => !string.IsNullOrEmpty(o.Location))
                        .GroupBy(o => o.Location)
                        .ToDictionary(g => g.Key, g => g.Count())
                };

                return stats;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting opportunity stats for user {UserId}", userId);
                throw;
            }
        }

        public async Task<bool> IncrementViewCountAsync(int opportunityId)
        {
            try
            {
                var opportunity = await _context.Opportunities.FindAsync(opportunityId);
                if (opportunity == null)
                {
                    return false;
                }

                opportunity.ViewCount++;
                await _context.SaveChangesAsync();

                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error incrementing view count for opportunity {OpportunityId}", opportunityId);
                throw;
            }
        }

        public async Task<bool> ToggleFeaturedStatusAsync(string userId, int opportunityId)
        {
            try
            {
                var opportunity = await _context.Opportunities
                    .FirstOrDefaultAsync(o => o.Id == opportunityId && o.UserId == userId);

                if (opportunity == null)
                {
                    return false;
                }

                opportunity.IsFeatured = !opportunity.IsFeatured;
                opportunity.UpdatedAt = DateTime.UtcNow;
                await _context.SaveChangesAsync();

                _logger.LogInformation("Featured status toggled for opportunity {OpportunityId} by user {UserId}", 
                    opportunityId, userId);

                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error toggling featured status for opportunity {OpportunityId}", opportunityId);
                throw;
            }
        }

        public async Task<bool> UpdateOpportunityStatusAsync(string userId, int opportunityId, OpportunityStatus status)
        {
            try
            {
                var opportunity = await _context.Opportunities
                    .FirstOrDefaultAsync(o => o.Id == opportunityId && o.UserId == userId);

                if (opportunity == null)
                {
                    return false;
                }

                opportunity.Status = status;
                opportunity.UpdatedAt = DateTime.UtcNow;
                await _context.SaveChangesAsync();

                _logger.LogInformation("Status updated to {Status} for opportunity {OpportunityId} by user {UserId}", 
                    status, opportunityId, userId);

                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating status for opportunity {OpportunityId}", opportunityId);
                throw;
            }
        }

        public async Task<List<TagDto>> GetAvailableTagsAsync()
        {
            try
            {
                var tags = await _context.Tags
                    .Where(t => t.IsActive)
                    .OrderBy(t => t.Name)
                    .ToListAsync();

                return _mapper.Map<List<TagDto>>(tags);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting available tags");
                throw;
            }
        }

        public async Task<List<SkillDto>> GetAvailableSkillsAsync()
        {
            try
            {
                var skills = await _context.Skills
                    .OrderBy(s => s.Name)
                    .ToListAsync();

                return _mapper.Map<List<SkillDto>>(skills);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting available skills");
                throw;
            }
        }

        private async Task AddOpportunityTagsAsync(int opportunityId, List<string> tagNames)
        {
            foreach (var tagName in tagNames.Distinct())
            {
                var tag = await _context.Tags
                    .FirstOrDefaultAsync(t => t.Name.ToLower() == tagName.ToLower());

                if (tag == null)
                {
                    tag = new Tag { Name = tagName, IsActive = true };
                    _context.Tags.Add(tag);
                    await _context.SaveChangesAsync();
                }

                var opportunityTag = new OpportunityTag
                {
                    OpportunityId = opportunityId,
                    TagId = tag.Id
                };

                _context.OpportunityTags.Add(opportunityTag);
            }
        }

        private async Task AddOpportunitySkillsAsync(int opportunityId, List<string> skillNames)
        {
            foreach (var skillName in skillNames.Distinct())
            {
                var skill = await _context.Skills
                    .FirstOrDefaultAsync(s => s.Name.ToLower() == skillName.ToLower());

                if (skill == null)
                {
                    skill = new Skill { Name = skillName };
                    _context.Skills.Add(skill);
                    await _context.SaveChangesAsync();
                }

                var opportunitySkill = new OpportunitySkill
                {
                    OpportunityId = opportunityId,
                    SkillId = skill.Id
                };

                _context.OpportunitySkills.Add(opportunitySkill);
            }
        }
    }
}
