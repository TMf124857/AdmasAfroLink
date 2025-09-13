using AdmasAfroLink.API.DTOs.UserProfile;
using AdmasAfroLink.API.Models;

namespace AdmasAfroLink.API.Services.Interfaces
{
    public interface IUserProfileService
    {
        Task<UserProfileResponse?> GetUserProfileAsync(string userId);
        Task<PublicUserProfileResponse?> GetPublicUserProfileAsync(string userId);
        Task<UserProfileResponse?> UpdateUserProfileAsync(string userId, UpdateProfileRequest request);
        Task<IEnumerable<UserSearchResponse>> SearchUsersAsync(string? query = null, string? location = null, 
            List<string>? skills = null, int page = 1, int pageSize = 20);
        Task<bool> UpdateSkillsAsync(string userId, List<string> skillNames);
        Task<bool> UpdateInterestsAsync(string userId, List<string> interestNames);
        Task<string?> UploadProfilePictureAsync(string userId, IFormFile file);
        Task<bool> DeleteProfilePictureAsync(string userId);
    }
}
