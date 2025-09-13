using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using System.Security.Claims;
using AdmasAfroLink.API.DTOs.Opportunity;
using AdmasAfroLink.API.Models;
using AdmasAfroLink.API.Services.Interfaces;

namespace AdmasAfroLink.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class OpportunityController : ControllerBase
    {
        private readonly IOpportunityService _opportunityService;
        private readonly ILogger<OpportunityController> _logger;

        public OpportunityController(
            IOpportunityService opportunityService,
            ILogger<OpportunityController> logger)
        {
            _opportunityService = opportunityService;
            _logger = logger;
        }

        /// <summary>
        /// Create a new opportunity
        /// </summary>
        [HttpPost]
        [Authorize]
        public async Task<ActionResult<OpportunityResponse>> CreateOpportunity([FromBody] CreateOpportunityRequest request)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("User ID not found in token");
                }

                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var opportunity = await _opportunityService.CreateOpportunityAsync(userId, request);
                if (opportunity == null)
                {
                    return BadRequest("Failed to create opportunity");
                }

                return CreatedAtAction(nameof(GetOpportunity), new { id = opportunity.Id }, opportunity);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating opportunity");
                return StatusCode(500, "An error occurred while creating the opportunity");
            }
        }

        /// <summary>
        /// Get opportunity by ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<OpportunityResponse>> GetOpportunity(int id)
        {
            try
            {
                var opportunity = await _opportunityService.GetOpportunityByIdAsync(id);
                if (opportunity == null)
                {
                    return NotFound("Opportunity not found");
                }

                // Increment view count (fire and forget)
                _ = Task.Run(async () => await _opportunityService.IncrementViewCountAsync(id));

                return Ok(opportunity);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting opportunity {OpportunityId}", id);
                return StatusCode(500, "An error occurred while retrieving the opportunity");
            }
        }

        /// <summary>
        /// Update an opportunity
        /// </summary>
        [HttpPut("{id}")]
        [Authorize]
        public async Task<ActionResult<OpportunityResponse>> UpdateOpportunity(int id, [FromBody] UpdateOpportunityRequest request)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("User ID not found in token");
                }

                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var opportunity = await _opportunityService.UpdateOpportunityAsync(userId, id, request);
                if (opportunity == null)
                {
                    return NotFound("Opportunity not found or you are not authorized to update it");
                }

                return Ok(opportunity);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating opportunity {OpportunityId}", id);
                return StatusCode(500, "An error occurred while updating the opportunity");
            }
        }

        /// <summary>
        /// Delete an opportunity
        /// </summary>
        [HttpDelete("{id}")]
        [Authorize]
        public async Task<ActionResult> DeleteOpportunity(int id)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("User ID not found in token");
                }

                var success = await _opportunityService.DeleteOpportunityAsync(userId, id);
                if (!success)
                {
                    return NotFound("Opportunity not found or you are not authorized to delete it");
                }

                return Ok(new { message = "Opportunity deleted successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting opportunity {OpportunityId}", id);
                return StatusCode(500, "An error occurred while deleting the opportunity");
            }
        }

        /// <summary>
        /// Search opportunities with filters
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<OpportunityListResponse>> GetOpportunities(
            [FromQuery] string? search = null,
            [FromQuery] OpportunityType? type = null,
            [FromQuery] OpportunityStatus? status = null,
            [FromQuery] string? location = null,
            [FromQuery] bool? isRemote = null,
            [FromQuery] decimal? minBudget = null,
            [FromQuery] decimal? maxBudget = null,
            [FromQuery] List<string>? tags = null,
            [FromQuery] List<string>? skills = null,
            [FromQuery] string? sortBy = null,
            [FromQuery] bool sortDescending = true,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            try
            {
                if (pageSize > 100)
                {
                    pageSize = 100; // Limit page size to prevent abuse
                }

                var result = await _opportunityService.GetOpportunitiesAsync(
                    search, type, status, location, isRemote, minBudget, maxBudget,
                    tags, skills, sortBy, sortDescending, page, pageSize);

                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching opportunities");
                return StatusCode(500, "An error occurred while searching opportunities");
            }
        }

        /// <summary>
        /// Get current user's opportunities
        /// </summary>
        [HttpGet("my-opportunities")]
        [Authorize]
        public async Task<ActionResult<OpportunityListResponse>> GetMyOpportunities(
            [FromQuery] OpportunityStatus? status = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("User ID not found in token");
                }

                if (pageSize > 100)
                {
                    pageSize = 100;
                }

                var result = await _opportunityService.GetUserOpportunitiesAsync(userId, status, page, pageSize);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting user opportunities");
                return StatusCode(500, "An error occurred while retrieving your opportunities");
            }
        }

        /// <summary>
        /// Get opportunity statistics
        /// </summary>
        [HttpGet("stats")]
        [Authorize]
        public async Task<ActionResult<OpportunityStatsResponse>> GetOpportunityStats()
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("User ID not found in token");
                }

                var stats = await _opportunityService.GetOpportunityStatsAsync(userId);
                return Ok(stats);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting opportunity stats");
                return StatusCode(500, "An error occurred while retrieving opportunity statistics");
            }
        }

        /// <summary>
        /// Toggle featured status of an opportunity
        /// </summary>
        [HttpPatch("{id}/featured")]
        [Authorize]
        public async Task<ActionResult> ToggleFeatured(int id)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("User ID not found in token");
                }

                var success = await _opportunityService.ToggleFeaturedStatusAsync(userId, id);
                if (!success)
                {
                    return NotFound("Opportunity not found or you are not authorized to modify it");
                }

                return Ok(new { message = "Featured status toggled successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error toggling featured status for opportunity {OpportunityId}", id);
                return StatusCode(500, "An error occurred while toggling featured status");
            }
        }

        /// <summary>
        /// Update opportunity status
        /// </summary>
        [HttpPatch("{id}/status")]
        [Authorize]
        public async Task<ActionResult> UpdateOpportunityStatus(int id, [FromBody] UpdateStatusRequest request)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("User ID not found in token");
                }

                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var success = await _opportunityService.UpdateOpportunityStatusAsync(userId, id, request.Status);
                if (!success)
                {
                    return NotFound("Opportunity not found or you are not authorized to modify it");
                }

                return Ok(new { message = "Opportunity status updated successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating status for opportunity {OpportunityId}", id);
                return StatusCode(500, "An error occurred while updating opportunity status");
            }
        }

        /// <summary>
        /// Get available tags
        /// </summary>
        [HttpGet("tags")]
        public async Task<ActionResult<List<TagDto>>> GetAvailableTags()
        {
            try
            {
                var tags = await _opportunityService.GetAvailableTagsAsync();
                return Ok(tags);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting available tags");
                return StatusCode(500, "An error occurred while retrieving tags");
            }
        }

        /// <summary>
        /// Get available skills
        /// </summary>
        [HttpGet("skills")]
        public async Task<ActionResult<List<SkillDto>>> GetAvailableSkills()
        {
            try
            {
                var skills = await _opportunityService.GetAvailableSkillsAsync();
                return Ok(skills);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting available skills");
                return StatusCode(500, "An error occurred while retrieving skills");
            }
        }
    }

    public class UpdateStatusRequest
    {
        [Required]
        public OpportunityStatus Status { get; set; }
    }
}
