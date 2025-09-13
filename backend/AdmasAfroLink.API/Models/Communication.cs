using System.ComponentModel.DataAnnotations;

namespace AdmasAfroLink.API.Models
{
    public enum MessageStatus
    {
        Sent = 1,
        Delivered = 2,
        Read = 3
    }

    public class Message
    {
        public int Id { get; set; }

        [Required]
        public string SenderId { get; set; } = string.Empty;

        [Required]
        public string ReceiverId { get; set; } = string.Empty;

        [Required]
        public string Content { get; set; } = string.Empty;

        public MessageStatus Status { get; set; } = MessageStatus.Sent;

        public bool IsDeleted { get; set; } = false;
        public bool IsDeletedBySender { get; set; } = false;
        public bool IsDeletedByReceiver { get; set; } = false;

        public DateTime? ReadAt { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual User Sender { get; set; } = null!;
        public virtual User Receiver { get; set; } = null!;
    }

    public enum ConnectionStatus
    {
        Pending = 1,
        Accepted = 2,
        Declined = 3,
        Blocked = 4
    }

    public class UserConnection
    {
        public int Id { get; set; }

        [Required]
        public string RequesterId { get; set; } = string.Empty;

        [Required]
        public string ReceiverId { get; set; } = string.Empty;

        public ConnectionStatus Status { get; set; } = ConnectionStatus.Pending;

        [MaxLength(500)]
        public string Message { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual User Requester { get; set; } = null!;
        public virtual User Receiver { get; set; } = null!;
    }

    public class Notification
    {
        public int Id { get; set; }

        [Required]
        public string UserId { get; set; } = string.Empty;

        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;

        [Required]
        public string Content { get; set; } = string.Empty;

        [MaxLength(50)]
        public string Type { get; set; } = string.Empty; // message, connection, opportunity, etc.

        [MaxLength(255)]
        public string ActionUrl { get; set; } = string.Empty;

        public bool IsRead { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? ReadAt { get; set; }

        // Navigation properties
        public virtual User User { get; set; } = null!;
    }
}
