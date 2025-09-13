using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using AdmasAfroLink.API.Models;

namespace AdmasAfroLink.API.Data
{
    public class ApplicationDbContext : IdentityDbContext<User>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }

        // DbSets
        public DbSet<Skill> Skills { get; set; }
        public DbSet<UserSkill> UserSkills { get; set; }
        public DbSet<Interest> Interests { get; set; }
        public DbSet<UserInterest> UserInterests { get; set; }
        public DbSet<Opportunity> Opportunities { get; set; }
        public DbSet<Tag> Tags { get; set; }
        public DbSet<OpportunityTag> OpportunityTags { get; set; }
        public DbSet<OpportunitySkill> OpportunitySkills { get; set; }
        public DbSet<OpportunityApplication> OpportunityApplications { get; set; }
        public DbSet<Message> Messages { get; set; }
        public DbSet<UserConnection> UserConnections { get; set; }
        public DbSet<Notification> Notifications { get; set; }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            // Configure User entity
            builder.Entity<User>(entity =>
            {
                entity.Property(e => e.FirstName).IsRequired().HasMaxLength(100);
                entity.Property(e => e.LastName).IsRequired().HasMaxLength(100);
                entity.Property(e => e.Bio).HasMaxLength(500);
                entity.Property(e => e.Location).HasMaxLength(200);
                entity.Property(e => e.Country).HasMaxLength(200);
                entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.Property(e => e.UpdatedAt).HasDefaultValueSql("GETUTCDATE()");

                entity.HasIndex(e => e.Email).IsUnique();
                entity.HasIndex(e => e.Country);
                entity.HasIndex(e => e.IsActive);
                entity.HasIndex(e => e.CreatedAt);
            });

            // Configure UserSkill composite key and relationships
            builder.Entity<UserSkill>(entity =>
            {
                entity.HasKey(us => new { us.UserId, us.SkillId });

                entity.HasOne(us => us.User)
                    .WithMany(u => u.Skills)
                    .HasForeignKey(us => us.UserId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(us => us.Skill)
                    .WithMany(s => s.UserSkills)
                    .HasForeignKey(us => us.SkillId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
            });

            // Configure UserInterest composite key and relationships
            builder.Entity<UserInterest>(entity =>
            {
                entity.HasKey(ui => new { ui.UserId, ui.InterestId });

                entity.HasOne(ui => ui.User)
                    .WithMany(u => u.Interests)
                    .HasForeignKey(ui => ui.UserId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(ui => ui.Interest)
                    .WithMany(i => i.UserInterests)
                    .HasForeignKey(ui => ui.InterestId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
            });

            // Configure Opportunity entity
            builder.Entity<Opportunity>(entity =>
            {
                entity.Property(e => e.Title).IsRequired().HasMaxLength(200);
                entity.Property(e => e.Description).IsRequired();
                entity.Property(e => e.Location).HasMaxLength(200);
                entity.Property(e => e.Currency).HasMaxLength(10).HasDefaultValue("USD");
                entity.Property(e => e.BudgetMin).HasPrecision(18, 2);
                entity.Property(e => e.BudgetMax).HasPrecision(18, 2);
                entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.Property(e => e.UpdatedAt).HasDefaultValueSql("GETUTCDATE()");

                entity.HasOne(o => o.User)
                    .WithMany(u => u.Opportunities)
                    .HasForeignKey(o => o.UserId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasIndex(e => e.Type);
                entity.HasIndex(e => e.Status);
                entity.HasIndex(e => e.Location);
                entity.HasIndex(e => e.IsRemote);
                entity.HasIndex(e => e.CreatedAt);
                entity.HasIndex(e => e.IsFeatured);
            });

            // Configure OpportunityTag composite key and relationships
            builder.Entity<OpportunityTag>(entity =>
            {
                entity.HasKey(ot => new { ot.OpportunityId, ot.TagId });

                entity.HasOne(ot => ot.Opportunity)
                    .WithMany(o => o.Tags)
                    .HasForeignKey(ot => ot.OpportunityId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(ot => ot.Tag)
                    .WithMany(t => t.OpportunityTags)
                    .HasForeignKey(ot => ot.TagId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
            });

            // Configure OpportunitySkill composite key and relationships
            builder.Entity<OpportunitySkill>(entity =>
            {
                entity.HasKey(os => new { os.OpportunityId, os.SkillId });

                entity.HasOne(os => os.Opportunity)
                    .WithMany(o => o.RequiredSkills)
                    .HasForeignKey(os => os.OpportunityId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(os => os.Skill)
                    .WithMany()
                    .HasForeignKey(os => os.SkillId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
            });

            // Configure OpportunityApplication entity
            builder.Entity<OpportunityApplication>(entity =>
            {
                entity.Property(e => e.CoverLetter).IsRequired();
                entity.Property(e => e.ProposedRate).HasPrecision(18, 2);
                entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.Property(e => e.UpdatedAt).HasDefaultValueSql("GETUTCDATE()");

                entity.HasOne(oa => oa.Opportunity)
                    .WithMany(o => o.Applications)
                    .HasForeignKey(oa => oa.OpportunityId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(oa => oa.User)
                    .WithMany()
                    .HasForeignKey(oa => oa.UserId)
                    .OnDelete(DeleteBehavior.NoAction);

                entity.HasIndex(e => e.Status);
                entity.HasIndex(e => e.CreatedAt);
            });

            // Configure Message entity
            builder.Entity<Message>(entity =>
            {
                entity.Property(e => e.Content).IsRequired();
                entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

                entity.HasOne(m => m.Sender)
                    .WithMany(u => u.SentMessages)
                    .HasForeignKey(m => m.SenderId)
                    .OnDelete(DeleteBehavior.NoAction);

                entity.HasOne(m => m.Receiver)
                    .WithMany(u => u.ReceivedMessages)
                    .HasForeignKey(m => m.ReceiverId)
                    .OnDelete(DeleteBehavior.NoAction);

                entity.HasIndex(e => e.SenderId);
                entity.HasIndex(e => e.ReceiverId);
                entity.HasIndex(e => e.Status);
                entity.HasIndex(e => e.CreatedAt);
            });

            // Configure UserConnection entity
            builder.Entity<UserConnection>(entity =>
            {
                entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
                entity.Property(e => e.UpdatedAt).HasDefaultValueSql("GETUTCDATE()");

                entity.HasOne(uc => uc.Requester)
                    .WithMany(u => u.Connections)
                    .HasForeignKey(uc => uc.RequesterId)
                    .OnDelete(DeleteBehavior.NoAction);

                entity.HasOne(uc => uc.Receiver)
                    .WithMany(u => u.ConnectedUsers)
                    .HasForeignKey(uc => uc.ReceiverId)
                    .OnDelete(DeleteBehavior.NoAction);

                entity.HasIndex(e => e.Status);
                entity.HasIndex(e => e.CreatedAt);
            });

            // Configure Notification entity
            builder.Entity<Notification>(entity =>
            {
                entity.Property(e => e.Title).IsRequired().HasMaxLength(200);
                entity.Property(e => e.Content).IsRequired();
                entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

                entity.HasOne(n => n.User)
                    .WithMany()
                    .HasForeignKey(n => n.UserId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasIndex(e => e.UserId);
                entity.HasIndex(e => e.IsRead);
                entity.HasIndex(e => e.Type);
                entity.HasIndex(e => e.CreatedAt);
            });

            // Configure Skill entity
            builder.Entity<Skill>(entity =>
            {
                entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
                entity.Property(e => e.Category).HasMaxLength(100);
                entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

                entity.HasIndex(e => e.Name).IsUnique();
                entity.HasIndex(e => e.Category);
                entity.HasIndex(e => e.IsActive);
            });

            // Configure Interest entity
            builder.Entity<Interest>(entity =>
            {
                entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
                entity.Property(e => e.Category).HasMaxLength(100);
                entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

                entity.HasIndex(e => e.Name).IsUnique();
                entity.HasIndex(e => e.Category);
                entity.HasIndex(e => e.IsActive);
            });

            // Configure Tag entity
            builder.Entity<Tag>(entity =>
            {
                entity.Property(e => e.Name).IsRequired().HasMaxLength(50);
                entity.Property(e => e.Category).HasMaxLength(100);
                entity.Property(e => e.ColorCode).HasMaxLength(20).HasDefaultValue("#007bff");
                entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");

                entity.HasIndex(e => e.Name).IsUnique();
                entity.HasIndex(e => e.Category);
                entity.HasIndex(e => e.IsActive);
            });

            // Seed initial data
            SeedData(builder);
        }

        private static void SeedData(ModelBuilder builder)
        {
            // Seed Skills
            builder.Entity<Skill>().HasData(
                new Skill { Id = 1, Name = "Web Development", Category = "Technology", Description = "Full-stack web development" },
                new Skill { Id = 2, Name = "Mobile Development", Category = "Technology", Description = "iOS and Android app development" },
                new Skill { Id = 3, Name = "Graphic Design", Category = "Design", Description = "Visual design and branding" },
                new Skill { Id = 4, Name = "Digital Marketing", Category = "Marketing", Description = "Online marketing and social media" },
                new Skill { Id = 5, Name = "Project Management", Category = "Management", Description = "Leading and managing projects" },
                new Skill { Id = 6, Name = "Data Analysis", Category = "Technology", Description = "Data processing and analytics" },
                new Skill { Id = 7, Name = "Content Writing", Category = "Writing", Description = "Creating engaging content" },
                new Skill { Id = 8, Name = "Photography", Category = "Creative", Description = "Professional photography" },
                new Skill { Id = 9, Name = "Video Production", Category = "Creative", Description = "Video creation and editing" },
                new Skill { Id = 10, Name = "Business Development", Category = "Business", Description = "Growing business opportunities" }
            );

            // Seed Interests
            builder.Entity<Interest>().HasData(
                new Interest { Id = 1, Name = "Technology", Category = "Industry", Description = "Tech innovations and trends" },
                new Interest { Id = 2, Name = "Entrepreneurship", Category = "Business", Description = "Starting and running businesses" },
                new Interest { Id = 3, Name = "Arts & Culture", Category = "Creative", Description = "African arts and cultural heritage" },
                new Interest { Id = 4, Name = "Education", Category = "Social Impact", Description = "Educational development in Africa" },
                new Interest { Id = 5, Name = "Healthcare", Category = "Social Impact", Description = "Health and wellness initiatives" },
                new Interest { Id = 6, Name = "Finance", Category = "Business", Description = "Financial services and fintech" },
                new Interest { Id = 7, Name = "Agriculture", Category = "Industry", Description = "Agricultural innovation and sustainability" },
                new Interest { Id = 8, Name = "Fashion", Category = "Creative", Description = "African fashion and textile industry" },
                new Interest { Id = 9, Name = "Music", Category = "Creative", Description = "African music and entertainment" },
                new Interest { Id = 10, Name = "Sports", Category = "Recreation", Description = "Sports and fitness" }
            );

            // Seed Tags
            builder.Entity<Tag>().HasData(
                new Tag { Id = 1, Name = "Tech", Category = "Industry", ColorCode = "#007bff" },
                new Tag { Id = 2, Name = "Fashion", Category = "Industry", ColorCode = "#e83e8c" },
                new Tag { Id = 3, Name = "Music", Category = "Industry", ColorCode = "#fd7e14" },
                new Tag { Id = 4, Name = "Real Estate", Category = "Industry", ColorCode = "#28a745" },
                new Tag { Id = 5, Name = "Remote", Category = "Work Type", ColorCode = "#6f42c1" },
                new Tag { Id = 6, Name = "Freelance", Category = "Work Type", ColorCode = "#20c997" },
                new Tag { Id = 7, Name = "Full-time", Category = "Work Type", ColorCode = "#ffc107" },
                new Tag { Id = 8, Name = "Part-time", Category = "Work Type", ColorCode = "#6c757d" },
                new Tag { Id = 9, Name = "Urgent", Category = "Priority", ColorCode = "#dc3545" },
                new Tag { Id = 10, Name = "Featured", Category = "Priority", ColorCode = "#17a2b8" }
            );
        }
    }
}
