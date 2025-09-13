using AutoMapper;
using Microsoft.EntityFrameworkCore;
using AdmasAfroLink.API.Data;
using AdmasAfroLink.API.DTOs.UserProfile;
using AdmasAfroLink.API.Models;
using AdmasAfroLink.API.Services.Interfaces;

namespace AdmasAfroLink.API.Services
{
    public class UserProfileService : IUserProfileService
    {
        private readonly ApplicationDbContext _context;
        private readonly IMapper _mapper;
        private readonly ILogger<UserProfileService> _logger;

        public UserProfileService(
            ApplicationDbContext context,
            IMapper mapper,
            ILogger<UserProfileService> logger)
        {
            _context = context;
            _mapper = mapper;
            _logger = logger;
        }

        public async Task<UserProfileResponse?> GetUserProfileAsync(string userId)
        {
            try
            {
                var user = await _context.Users
                    .Include(u => u.Skills)
                        .ThenInclude(us => us.Skill)
                    .Include(u => u.Interests)
                        .ThenInclude(ui => ui.Interest)
                    .FirstOrDefaultAsync(u => u.Id == userId);

                if (user == null)
                {
                    _logger.LogWarning("User with ID {UserId} not found", userId);
                    return null;
                }

                return _mapper.Map<UserProfileResponse>(user);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting user profile for user {UserId}", userId);
                throw;
            }
        }

        public async Task<PublicUserProfileResponse?> GetPublicUserProfileAsync(string userId)
        {
            try
            {
                var user = await _context.Users
                    .Include(u => u.Skills)
                        .ThenInclude(us => us.Skill)
                    .Include(u => u.Interests)
                        .ThenInclude(ui => ui.Interest)
                    .FirstOrDefaultAsync(u => u.Id == userId && u.IsProfilePublic);

                if (user == null)
                {
                    _logger.LogWarning("Public user profile with ID {UserId} not found or not public", userId);
                    return null;
                }

                return _mapper.Map<PublicUserProfileResponse>(user);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting public user profile for user {UserId}", userId);
                throw;
            }
        }

        public async Task<UserProfileResponse?> UpdateUserProfileAsync(string userId, UpdateProfileRequest request)
        {
            try
            {
                var user = await _context.Users
                    .Include(u => u.Skills)
                        .ThenInclude(us => us.Skill)
                    .Include(u => u.Interests)
                        .ThenInclude(ui => ui.Interest)
                    .FirstOrDefaultAsync(u => u.Id == userId);

                if (user == null)
                {
                    _logger.LogWarning("User with ID {UserId} not found for update", userId);
                    return null;
                }

                // Update user properties
                _mapper.Map(request, user);
                user.UpdatedAt = DateTime.UtcNow;

                // Update skills if provided
                if (request.Skills != null)
                {
                    await UpdateUserSkillsAsync(user, request.Skills);
                }

                // Update interests if provided
                if (request.Interests != null)
                {
                    await UpdateUserInterestsAsync(user, request.Interests);
                }

                await _context.SaveChangesAsync();

                _logger.LogInformation("User profile updated successfully for user {UserId}", userId);
                return _mapper.Map<UserProfileResponse>(user);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating user profile for user {UserId}", userId);
                throw;
            }
        }

        public async Task<IEnumerable<UserSearchResponse>> SearchUsersAsync(string? query = null, string? location = null, 
            List<string>? skills = null, int page = 1, int pageSize = 20)
        {
            try
            {
                var usersQuery = _context.Users
                    .Include(u => u.Skills)
                        .ThenInclude(us => us.Skill)
                    .Include(u => u.Interests)
                        .ThenInclude(ui => ui.Interest)
                    .Where(u => u.IsProfilePublic);

                // Apply search filters
                if (!string.IsNullOrWhiteSpace(query))
                {
                    usersQuery = usersQuery.Where(u => 
                        u.FirstName.Contains(query) ||
                        u.LastName.Contains(query) ||
                        u.Company!.Contains(query) ||
                        u.JobTitle!.Contains(query) ||
                        u.Bio!.Contains(query));
                }

                if (!string.IsNullOrWhiteSpace(location))
                {
                    usersQuery = usersQuery.Where(u => 
                        u.Location!.Contains(location) ||
                        u.Country!.Contains(location));
                }

                if (skills != null && skills.Any())
                {
                    usersQuery = usersQuery.Where(u => 
                        u.Skills.Any(us => skills.Contains(us.Skill.Name)));
                }

                var users = await usersQuery
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .ToListAsync();

                return _mapper.Map<IEnumerable<UserSearchResponse>>(users);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching users with query: {Query}, location: {Location}", query, location);
                throw;
            }
        }

        public async Task<bool> UpdateSkillsAsync(string userId, List<string> skillNames)
        {
            try
            {
                var user = await _context.Users
                    .Include(u => u.Skills)
                    .FirstOrDefaultAsync(u => u.Id == userId);

                if (user == null)
                {
                    _logger.LogWarning("User with ID {UserId} not found for skills update", userId);
                    return false;
                }

                await UpdateUserSkillsAsync(user, skillNames);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Skills updated successfully for user {UserId}", userId);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating skills for user {UserId}", userId);
                throw;
            }
        }

        public async Task<bool> UpdateInterestsAsync(string userId, List<string> interestNames)
        {
            try
            {
                var user = await _context.Users
                    .Include(u => u.Interests)
                    .FirstOrDefaultAsync(u => u.Id == userId);

                if (user == null)
                {
                    _logger.LogWarning("User with ID {UserId} not found for interests update", userId);
                    return false;
                }

                await UpdateUserInterestsAsync(user, interestNames);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Interests updated successfully for user {UserId}", userId);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating interests for user {UserId}", userId);
                throw;
            }
        }

        public async Task<string?> UploadProfilePictureAsync(string userId, IFormFile file)
        {
            try
            {
                // Validate file
                if (file == null || file.Length == 0)
                {
                    _logger.LogWarning("No file provided for profile picture upload for user {UserId}", userId);
                    return null;
                }

                // Validate file type
                var allowedTypes = new[] { "image/jpeg", "image/jpg", "image/png", "image/gif" };
                if (!allowedTypes.Contains(file.ContentType.ToLower()))
                {
                    _logger.LogWarning("Invalid file type {ContentType} for profile picture upload for user {UserId}", 
                        file.ContentType, userId);
                    return null;
                }

                // Validate file size (5MB max)
                if (file.Length > 5 * 1024 * 1024)
                {
                    _logger.LogWarning("File size {FileSize} exceeds maximum for profile picture upload for user {UserId}", 
                        file.Length, userId);
                    return null;
                }

                var user = await _context.Users.FindAsync(userId);
                if (user == null)
                {
                    _logger.LogWarning("User with ID {UserId} not found for profile picture upload", userId);
                    return null;
                }

                // Generate unique filename
                var fileExtension = Path.GetExtension(file.FileName);
                var fileName = $"{userId}_{Guid.NewGuid()}{fileExtension}";
                var uploadPath = Path.Combine("wwwroot", "uploads", "profile-pictures");
                
                // Create directory if it doesn't exist
                Directory.CreateDirectory(uploadPath);
                
                var filePath = Path.Combine(uploadPath, fileName);

                // Save file
                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }

                // Update user profile picture URL
                var profilePictureUrl = $"/uploads/profile-pictures/{fileName}";
                user.ProfilePictureUrl = profilePictureUrl;
                user.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();

                _logger.LogInformation("Profile picture uploaded successfully for user {UserId}: {FileName}", 
                    userId, fileName);

                return profilePictureUrl;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error uploading profile picture for user {UserId}", userId);
                throw;
            }
        }

        public async Task<bool> DeleteProfilePictureAsync(string userId)
        {
            try
            {
                var user = await _context.Users.FindAsync(userId);
                if (user == null)
                {
                    _logger.LogWarning("User with ID {UserId} not found for profile picture deletion", userId);
                    return false;
                }

                if (!string.IsNullOrEmpty(user.ProfilePictureUrl))
                {
                    // Delete file from disk
                    var fileName = Path.GetFileName(user.ProfilePictureUrl);
                    var filePath = Path.Combine("wwwroot", "uploads", "profile-pictures", fileName);
                    
                    if (File.Exists(filePath))
                    {
                        File.Delete(filePath);
                    }

                    // Clear profile picture URL
                    user.ProfilePictureUrl = string.Empty;
                    user.UpdatedAt = DateTime.UtcNow;

                    await _context.SaveChangesAsync();
                }

                _logger.LogInformation("Profile picture deleted successfully for user {UserId}", userId);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting profile picture for user {UserId}", userId);
                throw;
            }
        }

        private async Task UpdateUserSkillsAsync(User user, List<string> skillNames)
        {
            // Remove existing skills
            _context.UserSkills.RemoveRange(user.Skills);

            // Add new skills
            foreach (var skillName in skillNames.Distinct())
            {
                var skill = await _context.Skills
                    .FirstOrDefaultAsync(s => s.Name.ToLower() == skillName.ToLower());

                if (skill == null)
                {
                    // Create new skill if it doesn't exist
                    skill = new Skill { Name = skillName };
                    _context.Skills.Add(skill);
                    await _context.SaveChangesAsync(); // Save to get the ID
                }

                var userSkill = new UserSkill
                {
                    UserId = user.Id,
                    SkillId = skill.Id
                };

                _context.UserSkills.Add(userSkill);
            }
        }

        private async Task UpdateUserInterestsAsync(User user, List<string> interestNames)
        {
            // Remove existing interests
            _context.UserInterests.RemoveRange(user.Interests);

            // Add new interests
            foreach (var interestName in interestNames.Distinct())
            {
                var interest = await _context.Interests
                    .FirstOrDefaultAsync(i => i.Name.ToLower() == interestName.ToLower());

                if (interest == null)
                {
                    // Create new interest if it doesn't exist
                    interest = new Interest { Name = interestName };
                    _context.Interests.Add(interest);
                    await _context.SaveChangesAsync(); // Save to get the ID
                }

                var userInterest = new UserInterest
                {
                    UserId = user.Id,
                    InterestId = interest.Id
                };

                _context.UserInterests.Add(userInterest);
            }
        }
    }
}
