namespace AdmasAfroLink.API.DTOs.UserProfile
{
    public class UserProfileResponse
    {
        public string Id { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string? Bio { get; set; }
        public string? Company { get; set; }
        public string? JobTitle { get; set; }
        public string? Location { get; set; }
        public string? Country { get; set; }
        public string? PhoneNumber { get; set; }
        public string? Website { get; set; }
        public string? LinkedInProfile { get; set; }
        public string? GitHubProfile { get; set; }
        public string? ProfilePictureUrl { get; set; }
        public bool IsProfilePublic { get; set; }
        public bool IsAvailableForOpportunities { get; set; }
        public bool EmailConfirmed { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? LastLoginAt { get; set; }
        public List<SkillDto> Skills { get; set; } = new();
        public List<InterestDto> Interests { get; set; } = new();
    }

    public class SkillDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
    }

    public class InterestDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
    }

    public class UserSearchResponse
    {
        public string Id { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string? Company { get; set; }
        public string? JobTitle { get; set; }
        public string? Location { get; set; }
        public string? Country { get; set; }
        public string? ProfilePictureUrl { get; set; }
        public bool IsAvailableForOpportunities { get; set; }
        public List<SkillDto> Skills { get; set; } = new();
        public List<InterestDto> Interests { get; set; } = new();
    }

    public class PublicUserProfileResponse
    {
        public string Id { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string? Bio { get; set; }
        public string? Company { get; set; }
        public string? JobTitle { get; set; }
        public string? Location { get; set; }
        public string? Country { get; set; }
        public string? Website { get; set; }
        public string? LinkedInProfile { get; set; }
        public string? GitHubProfile { get; set; }
        public string? ProfilePictureUrl { get; set; }
        public bool IsAvailableForOpportunities { get; set; }
        public DateTime CreatedAt { get; set; }
        public List<SkillDto> Skills { get; set; } = new();
        public List<InterestDto> Interests { get; set; } = new();
    }
}
