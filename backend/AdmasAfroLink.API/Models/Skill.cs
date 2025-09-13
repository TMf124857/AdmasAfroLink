using System.ComponentModel.DataAnnotations;

namespace AdmasAfroLink.API.Models
{
    public class Skill
    {
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(200)]
        public string Description { get; set; } = string.Empty;

        [MaxLength(100)]
        public string Category { get; set; } = string.Empty;

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual ICollection<UserSkill> UserSkills { get; set; } = new List<UserSkill>();
    }

    public class UserSkill
    {
        public string UserId { get; set; } = string.Empty;
        public int SkillId { get; set; }

        [Range(1, 10)]
        public int ProficiencyLevel { get; set; } = 1; // 1-10 scale

        public bool IsEndorsed { get; set; } = false;
        public int EndorsementCount { get; set; } = 0;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual User User { get; set; } = null!;
        public virtual Skill Skill { get; set; } = null!;
    }

    public class Interest
    {
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(200)]
        public string Description { get; set; } = string.Empty;

        [MaxLength(100)]
        public string Category { get; set; } = string.Empty;

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual ICollection<UserInterest> UserInterests { get; set; } = new List<UserInterest>();
    }

    public class UserInterest
    {
        public string UserId { get; set; } = string.Empty;
        public int InterestId { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual User User { get; set; } = null!;
        public virtual Interest Interest { get; set; } = null!;
    }
}
