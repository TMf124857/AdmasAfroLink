using System.ComponentModel.DataAnnotations;

namespace AdmasAfroLink.API.Models
{
    public enum UserRoleType
    {
        Student = 1,
        Employer = 2,
        Admin = 3
    }

    public enum EmployerApprovalStatus
    {
        NotRequired = 1,
        Pending = 2,
        Approved = 3,
        Rejected = 4
    }

    public enum SwipeDirection
    {
        Left = 0,
        Right = 1
    }

    public enum MatchStatus
    {
        Active = 1,
        Closed = 2
    }

    public class InternshipSwipe
    {
        public int Id { get; set; }

        [Required]
        public int OpportunityId { get; set; }

        [Required]
        public string CandidateUserId { get; set; } = string.Empty;

        [Required]
        public string EmployerUserId { get; set; } = string.Empty;

        public SwipeDirection StudentDirection { get; set; } = SwipeDirection.Left;
        public SwipeDirection EmployerDirection { get; set; } = SwipeDirection.Left;

        public DateTime? StudentSwipedAt { get; set; }
        public DateTime? EmployerSwipedAt { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        public virtual Opportunity Opportunity { get; set; } = null!;
    }

    public class InternshipMatch
    {
        public int Id { get; set; }
        public int OpportunityId { get; set; }

        [Required]
        public string StudentUserId { get; set; } = string.Empty;

        [Required]
        public string EmployerUserId { get; set; } = string.Empty;

        public MatchStatus Status { get; set; } = MatchStatus.Active;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        public virtual Opportunity Opportunity { get; set; } = null!;
    }

    public class UserReport
    {
        public int Id { get; set; }

        [Required]
        public string ReporterUserId { get; set; } = string.Empty;

        [Required]
        public string ReportedUserId { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string Category { get; set; } = string.Empty;

        [Required]
        [MaxLength(1000)]
        public string Reason { get; set; } = string.Empty;

        public bool IsResolved { get; set; } = false;

        public string ResolvedByUserId { get; set; } = string.Empty;
        public DateTime? ResolvedAt { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

    public class UserBlock
    {
        public int Id { get; set; }

        [Required]
        public string UserId { get; set; } = string.Empty;

        [Required]
        public string BlockedUserId { get; set; } = string.Empty;

        [MaxLength(250)]
        public string Reason { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
