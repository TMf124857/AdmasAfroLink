using System.ComponentModel.DataAnnotations;
using AdmasAfroLink.API.Models;

namespace AdmasAfroLink.API.DTOs
{
    public class MessageDto
    {
        public int Id { get; set; }
        public string SenderId { get; set; } = string.Empty;
        public string SenderName { get; set; } = string.Empty;
        public string SenderProfilePicture { get; set; } = string.Empty;
        public string ReceiverId { get; set; } = string.Empty;
        public string ReceiverName { get; set; } = string.Empty;
        public string ReceiverProfilePicture { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public MessageStatus Status { get; set; }
        public string StatusName => Status.ToString();
        public bool IsDeleted { get; set; }
        public DateTime? ReadAt { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsFromCurrentUser { get; set; } = false;
    }

    public class SendMessageDto
    {
        [Required]
        public string ReceiverId { get; set; } = string.Empty;

        [Required]
        [MaxLength(1000)]
        public string Content { get; set; } = string.Empty;
    }

    public class ConversationDto
    {
        public string UserId { get; set; } = string.Empty;
        public string UserName { get; set; } = string.Empty;
        public string UserProfilePicture { get; set; } = string.Empty;
        public bool IsOnline { get; set; } = false;
        public MessageDto? LastMessage { get; set; }
        public int UnreadCount { get; set; }
        public DateTime LastActivity { get; set; }
    }

    public class UserConnectionDto
    {
        public int Id { get; set; }
        public string RequesterId { get; set; } = string.Empty;
        public string RequesterName { get; set; } = string.Empty;
        public string RequesterProfilePicture { get; set; } = string.Empty;
        public string ReceiverId { get; set; } = string.Empty;
        public string ReceiverName { get; set; } = string.Empty;
        public string ReceiverProfilePicture { get; set; } = string.Empty;
        public ConnectionStatus Status { get; set; }
        public string StatusName => Status.ToString();
        public string Message { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public bool IsRequester { get; set; } = false;
    }

    public class SendConnectionRequestDto
    {
        [Required]
        public string ReceiverId { get; set; } = string.Empty;

        [MaxLength(500)]
        public string Message { get; set; } = string.Empty;
    }

    public class UpdateConnectionStatusDto
    {
        [Required]
        public ConnectionStatus Status { get; set; }
    }

    public class NotificationDto
    {
        public int Id { get; set; }
        public string UserId { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty;
        public string ActionUrl { get; set; } = string.Empty;
        public bool IsRead { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? ReadAt { get; set; }
        public string TimeAgo { get; set; } = string.Empty;
    }

    public class CreateNotificationDto
    {
        [Required]
        public string UserId { get; set; } = string.Empty;

        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;

        [Required]
        public string Content { get; set; } = string.Empty;

        [MaxLength(50)]
        public string Type { get; set; } = string.Empty;

        [MaxLength(255)]
        public string ActionUrl { get; set; } = string.Empty;
    }

    public class MarkNotificationReadDto
    {
        public List<int> NotificationIds { get; set; } = new List<int>();
    }

    public class UserSearchDto
    {
        public string? SearchTerm { get; set; }
        public string? Country { get; set; }
        public string? Location { get; set; }
        public List<int> SkillIds { get; set; } = new List<int>();
        public List<int> InterestIds { get; set; } = new List<int>();
        public bool? IsVerified { get; set; }
        public string OrderBy { get; set; } = "CreatedAt"; // CreatedAt, FullName, Country
        public string OrderDirection { get; set; } = "DESC"; // ASC, DESC
        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 10;
    }

    public class UserDirectoryDto
    {
        public string Id { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string FullName => $"{FirstName} {LastName}";
        public string Bio { get; set; } = string.Empty;
        public string Location { get; set; } = string.Empty;
        public string Country { get; set; } = string.Empty;
        public string ProfilePictureUrl { get; set; } = string.Empty;
        public bool IsVerified { get; set; }
        public DateTime CreatedAt { get; set; }
        public List<UserSkillDto> Skills { get; set; } = new List<UserSkillDto>();
        public List<UserInterestDto> Interests { get; set; } = new List<UserInterestDto>();
        public int ConnectionCount { get; set; }
        public bool IsConnected { get; set; } = false;
        public ConnectionStatus? ConnectionStatus { get; set; }
    }

    public class ConnectionStatsDto
    {
        public int TotalConnections { get; set; }
        public int PendingRequests { get; set; }
        public int SentRequests { get; set; }
        public int MutualConnections { get; set; }
    }

    public class MessageStatsDto
    {
        public int TotalConversations { get; set; }
        public int UnreadMessages { get; set; }
        public int TotalMessages { get; set; }
    }
}
