using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using AdmasAfroLink.API.DTOs.UserProfile;
using AdmasAfroLink.API.Services.Interfaces;

namespace AdmasAfroLink.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UserProfileController : ControllerBase
    {
        private readonly IUserProfileService _userProfileService;
        private readonly ILogger<UserProfileController> _logger;

        public UserProfileController(
            IUserProfileService userProfileService,
            ILogger<UserProfileController> logger)
        {
            _userProfileService = userProfileService;
            _logger = logger;
        }

        /// <summary>
        /// Get current user's profile
        /// </summary>
        [HttpGet("me")]
        public async Task<ActionResult<UserProfileResponse>> GetMyProfile()
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("User ID not found in token");
                }

                var profile = await _userProfileService.GetUserProfileAsync(userId);
                if (profile == null)
                {
                    return NotFound("User profile not found");
                }

                return Ok(profile);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting user profile");
                return StatusCode(500, "An error occurred while retrieving the profile");
            }
        }

        /// <summary>
        /// Update current user's profile
        /// </summary>
        [HttpPut("me")]
        public async Task<ActionResult<UserProfileResponse>> UpdateMyProfile([FromBody] UpdateProfileRequest request)
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

                var updatedProfile = await _userProfileService.UpdateUserProfileAsync(userId, request);
                if (updatedProfile == null)
                {
                    return NotFound("User profile not found");
                }

                return Ok(updatedProfile);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating user profile");
                return StatusCode(500, "An error occurred while updating the profile");
            }
        }

        /// <summary>
        /// Get public user profile by user ID
        /// </summary>
        [HttpGet("{userId}/public")]
        [AllowAnonymous]
        public async Task<ActionResult<PublicUserProfileResponse>> GetPublicProfile(string userId)
        {
            try
            {
                var profile = await _userProfileService.GetPublicUserProfileAsync(userId);
                if (profile == null)
                {
                    return NotFound("Public user profile not found");
                }

                return Ok(profile);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting public user profile for user {UserId}", userId);
                return StatusCode(500, "An error occurred while retrieving the public profile");
            }
        }

        /// <summary>
        /// Search for users
        /// </summary>
        [HttpGet("search")]
        [AllowAnonymous]
        public async Task<ActionResult<IEnumerable<UserSearchResponse>>> SearchUsers(
            [FromQuery] string? query = null,
            [FromQuery] string? location = null,
            [FromQuery] List<string>? skills = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            try
            {
                if (pageSize > 100)
                {
                    pageSize = 100; // Limit page size to prevent abuse
                }

                var users = await _userProfileService.SearchUsersAsync(query, location, skills, page, pageSize);
                return Ok(users);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching users");
                return StatusCode(500, "An error occurred while searching for users");
            }
        }

        /// <summary>
        /// Update current user's skills
        /// </summary>
        [HttpPut("me/skills")]
        public async Task<ActionResult> UpdateMySkills([FromBody] List<string> skills)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("User ID not found in token");
                }

                if (skills == null || !skills.Any())
                {
                    return BadRequest("Skills list cannot be empty");
                }

                var success = await _userProfileService.UpdateSkillsAsync(userId, skills);
                if (!success)
                {
                    return NotFound("User not found");
                }

                return Ok(new { message = "Skills updated successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating user skills");
                return StatusCode(500, "An error occurred while updating skills");
            }
        }

        /// <summary>
        /// Update current user's interests
        /// </summary>
        [HttpPut("me/interests")]
        public async Task<ActionResult> UpdateMyInterests([FromBody] List<string> interests)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("User ID not found in token");
                }

                if (interests == null || !interests.Any())
                {
                    return BadRequest("Interests list cannot be empty");
                }

                var success = await _userProfileService.UpdateInterestsAsync(userId, interests);
                if (!success)
                {
                    return NotFound("User not found");
                }

                return Ok(new { message = "Interests updated successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating user interests");
                return StatusCode(500, "An error occurred while updating interests");
            }
        }

        /// <summary>
        /// Upload profile picture
        /// </summary>
        [HttpPost("me/profile-picture")]
        public async Task<ActionResult> UploadProfilePicture(IFormFile file)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("User ID not found in token");
                }

                if (file == null || file.Length == 0)
                {
                    return BadRequest("No file provided");
                }

                var profilePictureUrl = await _userProfileService.UploadProfilePictureAsync(userId, file);
                if (profilePictureUrl == null)
                {
                    return BadRequest("Failed to upload profile picture. Please check file type and size.");
                }

                return Ok(new { profilePictureUrl, message = "Profile picture uploaded successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error uploading profile picture");
                return StatusCode(500, "An error occurred while uploading the profile picture");
            }
        }

        /// <summary>
        /// Delete profile picture
        /// </summary>
        [HttpDelete("me/profile-picture")]
        public async Task<ActionResult> DeleteProfilePicture()
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("User ID not found in token");
                }

                var success = await _userProfileService.DeleteProfilePictureAsync(userId);
                if (!success)
                {
                    return NotFound("User not found");
                }

                return Ok(new { message = "Profile picture deleted successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting profile picture");
                return StatusCode(500, "An error occurred while deleting the profile picture");
            }
        }
    }
}
