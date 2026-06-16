using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using AdmasAfroLink.API.Data;
using AdmasAfroLink.API.Models;

namespace AdmasAfroLink.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class MatchmakingController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<MatchmakingController> _logger;

        public MatchmakingController(ApplicationDbContext context, ILogger<MatchmakingController> logger)
        {
            _context = context;
            _logger = logger;
        }

        [HttpGet("feed/opportunities")]
        public async Task<ActionResult<IEnumerable<object>>> GetOpportunityFeed([FromQuery] int page = 1, [FromQuery] int pageSize = 20)
        {
            var userId = GetCurrentUserId();
            if (userId is null) return Unauthorized();

            var currentUser = await _context.Users.FindAsync(userId);
            if (currentUser is null || currentUser.RoleType != UserRoleType.Student)
            {
                return Forbid();
            }

            var swipedOpportunityIds = await _context.InternshipSwipes
                .Where(s => s.CandidateUserId == userId && s.StudentSwipedAt != null)
                .Select(s => s.OpportunityId)
                .ToListAsync();

            var opportunities = await _context.Opportunities
                .Where(o => o.Type == OpportunityType.Internship &&
                            o.Status == OpportunityStatus.Published &&
                            !swipedOpportunityIds.Contains(o.Id))
                .OrderByDescending(o => o.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(o => new
                {
                    o.Id,
                    o.Title,
                    o.Description,
                    o.Location,
                    o.IsRemote,
                    o.ApplicationDeadline,
                    EmployerId = o.UserId
                })
                .ToListAsync();

            return Ok(opportunities);
        }

        [HttpPost("opportunities/{opportunityId:int}/swipe")]
        public async Task<ActionResult> SwipeOpportunity(int opportunityId, [FromBody] SwipeActionRequest request)
        {
            var userId = GetCurrentUserId();
            if (userId is null) return Unauthorized();

            var currentUser = await _context.Users.FindAsync(userId);
            if (currentUser is null || currentUser.RoleType != UserRoleType.Student)
            {
                return Forbid();
            }

            var opportunity = await _context.Opportunities
                .AsNoTracking()
                .FirstOrDefaultAsync(o => o.Id == opportunityId && o.Type == OpportunityType.Internship);
            if (opportunity is null) return NotFound("Internship opportunity not found.");

            if (await IsBlockedEitherWay(userId, opportunity.UserId))
            {
                return BadRequest("Cannot interact with this employer.");
            }

            var swipe = await _context.InternshipSwipes
                .FirstOrDefaultAsync(s => s.OpportunityId == opportunityId &&
                                          s.CandidateUserId == userId &&
                                          s.EmployerUserId == opportunity.UserId);

            if (swipe is null)
            {
                swipe = new InternshipSwipe
                {
                    OpportunityId = opportunityId,
                    CandidateUserId = userId,
                    EmployerUserId = opportunity.UserId,
                    StudentDirection = request.Direction,
                    StudentSwipedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                _context.InternshipSwipes.Add(swipe);
            }
            else
            {
                swipe.StudentDirection = request.Direction;
                swipe.StudentSwipedAt = DateTime.UtcNow;
                swipe.UpdatedAt = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();

            var matchCreated = await TryCreateMatchAsync(swipe);
            return Ok(new { Message = "Swipe saved.", MatchCreated = matchCreated });
        }

        [HttpGet("feed/candidates")]
        [Authorize(Roles = "Employer,Admin")]
        public async Task<ActionResult<IEnumerable<object>>> GetCandidateFeed([FromQuery] int opportunityId, [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
        {
            var userId = GetCurrentUserId();
            if (userId is null) return Unauthorized();

            var currentUser = await _context.Users.FindAsync(userId);
            if (currentUser is null || (currentUser.RoleType == UserRoleType.Employer && currentUser.EmployerApprovalStatus != EmployerApprovalStatus.Approved))
            {
                return Forbid();
            }

            var ownsOpportunity = await _context.Opportunities.AnyAsync(o => o.Id == opportunityId && o.UserId == userId && o.Type == OpportunityType.Internship);
            if (!ownsOpportunity) return NotFound("Internship opportunity not found.");

            var swipedCandidateIds = await _context.InternshipSwipes
                .Where(s => s.OpportunityId == opportunityId &&
                            s.EmployerUserId == userId &&
                            s.EmployerSwipedAt != null)
                .Select(s => s.CandidateUserId)
                .ToListAsync();

            var blockedIds = await _context.UserBlocks
                .Where(b => b.UserId == userId)
                .Select(b => b.BlockedUserId)
                .ToListAsync();

            var candidates = await _context.Users
                .Where(u => u.RoleType == UserRoleType.Student &&
                            u.IsActive &&
                            !swipedCandidateIds.Contains(u.Id) &&
                            !blockedIds.Contains(u.Id))
                .OrderByDescending(u => u.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(u => new
                {
                    u.Id,
                    u.FirstName,
                    u.LastName,
                    u.School,
                    u.Major,
                    u.GraduationYear,
                    u.Location,
                    u.ProfilePictureUrl
                })
                .ToListAsync();

            return Ok(candidates);
        }

        [HttpPost("candidates/swipe")]
        [Authorize(Roles = "Employer,Admin")]
        public async Task<ActionResult> SwipeCandidate([FromBody] CandidateSwipeRequest request)
        {
            var userId = GetCurrentUserId();
            if (userId is null) return Unauthorized();

            var currentUser = await _context.Users.FindAsync(userId);
            if (currentUser is null || (currentUser.RoleType == UserRoleType.Employer && currentUser.EmployerApprovalStatus != EmployerApprovalStatus.Approved))
            {
                return Forbid();
            }

            var opportunity = await _context.Opportunities
                .AsNoTracking()
                .FirstOrDefaultAsync(o => o.Id == request.OpportunityId &&
                                          o.UserId == userId &&
                                          o.Type == OpportunityType.Internship);
            if (opportunity is null) return NotFound("Internship opportunity not found.");

            if (await IsBlockedEitherWay(userId, request.CandidateUserId))
            {
                return BadRequest("Cannot interact with this candidate.");
            }

            var swipe = await _context.InternshipSwipes
                .FirstOrDefaultAsync(s => s.OpportunityId == request.OpportunityId &&
                                          s.CandidateUserId == request.CandidateUserId &&
                                          s.EmployerUserId == userId);

            if (swipe is null)
            {
                swipe = new InternshipSwipe
                {
                    OpportunityId = request.OpportunityId,
                    CandidateUserId = request.CandidateUserId,
                    EmployerUserId = userId,
                    EmployerDirection = request.Direction,
                    EmployerSwipedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                _context.InternshipSwipes.Add(swipe);
            }
            else
            {
                swipe.EmployerDirection = request.Direction;
                swipe.EmployerSwipedAt = DateTime.UtcNow;
                swipe.UpdatedAt = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();

            var matchCreated = await TryCreateMatchAsync(swipe);
            return Ok(new { Message = "Swipe saved.", MatchCreated = matchCreated });
        }

        [HttpGet("matches")]
        public async Task<ActionResult<IEnumerable<object>>> GetMyMatches()
        {
            var userId = GetCurrentUserId();
            if (userId is null) return Unauthorized();

            var matches = await _context.InternshipMatches
                .Where(m => m.Status == MatchStatus.Active &&
                            (m.StudentUserId == userId || m.EmployerUserId == userId))
                .Include(m => m.Opportunity)
                .OrderByDescending(m => m.CreatedAt)
                .Select(m => new
                {
                    m.Id,
                    m.OpportunityId,
                    OpportunityTitle = m.Opportunity.Title,
                    m.StudentUserId,
                    m.EmployerUserId,
                    m.CreatedAt
                })
                .ToListAsync();

            return Ok(matches);
        }

        [HttpGet("notifications")]
        public async Task<ActionResult<IEnumerable<Notification>>> GetNotifications([FromQuery] bool unreadOnly = false)
        {
            var userId = GetCurrentUserId();
            if (userId is null) return Unauthorized();

            var query = _context.Notifications.Where(n => n.UserId == userId);
            if (unreadOnly)
            {
                query = query.Where(n => !n.IsRead);
            }

            var items = await query
                .OrderByDescending(n => n.CreatedAt)
                .Take(100)
                .ToListAsync();

            return Ok(items);
        }

        [HttpPatch("notifications/{id:int}/read")]
        public async Task<ActionResult> MarkNotificationRead(int id)
        {
            var userId = GetCurrentUserId();
            if (userId is null) return Unauthorized();

            var notification = await _context.Notifications.FirstOrDefaultAsync(n => n.Id == id && n.UserId == userId);
            if (notification is null) return NotFound();

            notification.IsRead = true;
            notification.ReadAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
            return Ok(new { Message = "Notification marked as read." });
        }

        [HttpPost("reports")]
        public async Task<ActionResult> ReportUser([FromBody] ReportUserRequest request)
        {
            var userId = GetCurrentUserId();
            if (userId is null) return Unauthorized();
            if (request.ReportedUserId == userId) return BadRequest("You cannot report yourself.");

            var report = new UserReport
            {
                ReporterUserId = userId,
                ReportedUserId = request.ReportedUserId,
                Category = request.Category,
                Reason = request.Reason,
                CreatedAt = DateTime.UtcNow
            };

            _context.UserReports.Add(report);
            await _context.SaveChangesAsync();
            return Ok(new { Message = "Report submitted." });
        }

        [HttpPost("users/{targetUserId}/block")]
        public async Task<ActionResult> BlockUser(string targetUserId, [FromBody] BlockUserRequest request)
        {
            var userId = GetCurrentUserId();
            if (userId is null) return Unauthorized();
            if (targetUserId == userId) return BadRequest("You cannot block yourself.");

            var existing = await _context.UserBlocks.FirstOrDefaultAsync(b => b.UserId == userId && b.BlockedUserId == targetUserId);
            if (existing != null) return Ok(new { Message = "User already blocked." });

            _context.UserBlocks.Add(new UserBlock
            {
                UserId = userId,
                BlockedUserId = targetUserId,
                Reason = request.Reason,
                CreatedAt = DateTime.UtcNow
            });

            await _context.SaveChangesAsync();
            return Ok(new { Message = "User blocked." });
        }

        [HttpDelete("users/{targetUserId}/block")]
        public async Task<ActionResult> UnblockUser(string targetUserId)
        {
            var userId = GetCurrentUserId();
            if (userId is null) return Unauthorized();

            var existing = await _context.UserBlocks.FirstOrDefaultAsync(b => b.UserId == userId && b.BlockedUserId == targetUserId);
            if (existing is null) return NotFound("Block not found.");

            _context.UserBlocks.Remove(existing);
            await _context.SaveChangesAsync();
            return Ok(new { Message = "User unblocked." });
        }

        [HttpGet("moderation/employers/pending")]
        [Authorize(Roles = "Admin,Moderator")]
        public async Task<ActionResult<IEnumerable<object>>> GetPendingEmployers()
        {
            var pending = await _context.Users
                .Where(u => u.RoleType == UserRoleType.Employer && u.EmployerApprovalStatus == EmployerApprovalStatus.Pending)
                .OrderBy(u => u.CreatedAt)
                .Select(u => new
                {
                    u.Id,
                    u.Email,
                    u.FirstName,
                    u.LastName,
                    u.Company,
                    u.JobTitle,
                    u.CreatedAt
                })
                .ToListAsync();

            return Ok(pending);
        }

        [HttpPatch("moderation/employers/{userId}/approval")]
        [Authorize(Roles = "Admin,Moderator")]
        public async Task<ActionResult> UpdateEmployerApproval(string userId, [FromBody] EmployerApprovalRequest request)
        {
            var reviewerUserId = GetCurrentUserId();
            if (reviewerUserId is null) return Unauthorized();

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId && u.RoleType == UserRoleType.Employer);
            if (user is null) return NotFound("Employer not found.");

            user.EmployerApprovalStatus = request.Approve ? EmployerApprovalStatus.Approved : EmployerApprovalStatus.Rejected;
            user.EmployerApprovalNotes = request.Notes;
            user.UpdatedAt = DateTime.UtcNow;

            _context.Notifications.Add(new Notification
            {
                UserId = user.Id,
                Title = request.Approve ? "Employer account approved" : "Employer account rejected",
                Content = request.Approve ? "Your employer account is approved and ready." : $"Your employer account was rejected. {request.Notes}",
                Type = "moderation",
                CreatedAt = DateTime.UtcNow
            });

            await _context.SaveChangesAsync();
            return Ok(new { Message = "Approval status updated." });
        }

        [HttpGet("moderation/reports/open")]
        [Authorize(Roles = "Admin,Moderator")]
        public async Task<ActionResult<IEnumerable<UserReport>>> GetOpenReports()
        {
            var reports = await _context.UserReports
                .Where(r => !r.IsResolved)
                .OrderBy(r => r.CreatedAt)
                .Take(200)
                .ToListAsync();

            return Ok(reports);
        }

        [HttpPatch("moderation/reports/{reportId:int}/resolve")]
        [Authorize(Roles = "Admin,Moderator")]
        public async Task<ActionResult> ResolveReport(int reportId)
        {
            var adminId = GetCurrentUserId();
            if (adminId is null) return Unauthorized();

            var report = await _context.UserReports.FirstOrDefaultAsync(r => r.Id == reportId);
            if (report is null) return NotFound();

            report.IsResolved = true;
            report.ResolvedAt = DateTime.UtcNow;
            report.ResolvedByUserId = adminId;
            await _context.SaveChangesAsync();
            return Ok(new { Message = "Report resolved." });
        }

        private async Task<bool> TryCreateMatchAsync(InternshipSwipe swipe)
        {
            if (swipe.StudentDirection != SwipeDirection.Right || swipe.EmployerDirection != SwipeDirection.Right)
            {
                return false;
            }

            var alreadyExists = await _context.InternshipMatches.AnyAsync(m =>
                m.OpportunityId == swipe.OpportunityId &&
                m.StudentUserId == swipe.CandidateUserId &&
                m.EmployerUserId == swipe.EmployerUserId);

            if (alreadyExists) return false;

            _context.InternshipMatches.Add(new InternshipMatch
            {
                OpportunityId = swipe.OpportunityId,
                StudentUserId = swipe.CandidateUserId,
                EmployerUserId = swipe.EmployerUserId,
                Status = MatchStatus.Active,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            });

            _context.Notifications.AddRange(
                new Notification
                {
                    UserId = swipe.CandidateUserId,
                    Title = "New match",
                    Content = "You matched with an employer.",
                    Type = "match",
                    CreatedAt = DateTime.UtcNow
                },
                new Notification
                {
                    UserId = swipe.EmployerUserId,
                    Title = "New match",
                    Content = "You matched with an intern candidate.",
                    Type = "match",
                    CreatedAt = DateTime.UtcNow
                }
            );

            await _context.SaveChangesAsync();
            return true;
        }

        private async Task<bool> IsBlockedEitherWay(string userA, string userB)
        {
            return await _context.UserBlocks.AnyAsync(b =>
                (b.UserId == userA && b.BlockedUserId == userB) ||
                (b.UserId == userB && b.BlockedUserId == userA));
        }

        private string? GetCurrentUserId()
        {
            return User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        }
    }

    public class SwipeActionRequest
    {
        public SwipeDirection Direction { get; set; }
    }

    public class CandidateSwipeRequest
    {
        public int OpportunityId { get; set; }
        public string CandidateUserId { get; set; } = string.Empty;
        public SwipeDirection Direction { get; set; }
    }

    public class ReportUserRequest
    {
        public string ReportedUserId { get; set; } = string.Empty;
        public string Category { get; set; } = "other";
        public string Reason { get; set; } = string.Empty;
    }

    public class BlockUserRequest
    {
        public string Reason { get; set; } = string.Empty;
    }

    public class EmployerApprovalRequest
    {
        public bool Approve { get; set; }
        public string Notes { get; set; } = string.Empty;
    }
}
