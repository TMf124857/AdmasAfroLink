using Microsoft.AspNetCore.SignalR;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace AdmasAfroLink.API.Hubs
{
    [Authorize]
    public class ChatHub : Hub
    {
        private static readonly Dictionary<string, string> UserConnections = new();

        public override async Task OnConnectedAsync()
        {
            var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userId))
            {
                UserConnections[userId] = Context.ConnectionId;
                
                // Notify other users that this user is online
                await Clients.Others.SendAsync("UserOnline", userId);
            }
            
            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userId) && UserConnections.ContainsKey(userId))
            {
                UserConnections.Remove(userId);
                
                // Notify other users that this user is offline
                await Clients.Others.SendAsync("UserOffline", userId);
            }
            
            await base.OnDisconnectedAsync(exception);
        }

        public async Task SendMessage(string receiverId, string message)
        {
            var senderId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(senderId))
                return;

            // Send to receiver if they're online
            if (UserConnections.TryGetValue(receiverId, out var connectionId))
            {
                await Clients.Client(connectionId).SendAsync("ReceiveMessage", senderId, message, DateTime.UtcNow);
            }

            // Send confirmation back to sender
            await Clients.Caller.SendAsync("MessageSent", receiverId, message, DateTime.UtcNow);
        }

        public async Task MarkMessageAsRead(string senderId, int messageId)
        {
            var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userId))
                return;

            // Notify sender that message was read
            if (UserConnections.TryGetValue(senderId, out var connectionId))
            {
                await Clients.Client(connectionId).SendAsync("MessageRead", messageId, userId, DateTime.UtcNow);
            }
        }

        public async Task JoinConversation(string otherUserId)
        {
            var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userId))
                return;

            var groupName = GetConversationGroupName(userId, otherUserId);
            await Groups.AddToGroupAsync(Context.ConnectionId, groupName);
        }

        public async Task LeaveConversation(string otherUserId)
        {
            var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userId))
                return;

            var groupName = GetConversationGroupName(userId, otherUserId);
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, groupName);
        }

        public async Task SendTypingIndicator(string receiverId, bool isTyping)
        {
            var senderId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(senderId))
                return;

            if (UserConnections.TryGetValue(receiverId, out var connectionId))
            {
                await Clients.Client(connectionId).SendAsync("TypingIndicator", senderId, isTyping);
            }
        }

        public async Task SendNotification(string userId, string title, string message, string type, string? actionUrl = null)
        {
            if (UserConnections.TryGetValue(userId, out var connectionId))
            {
                await Clients.Client(connectionId).SendAsync("ReceiveNotification", new
                {
                    Title = title,
                    Message = message,
                    Type = type,
                    ActionUrl = actionUrl,
                    CreatedAt = DateTime.UtcNow
                });
            }
        }

        public static bool IsUserOnline(string userId)
        {
            return UserConnections.ContainsKey(userId);
        }

        public static async Task SendNotificationToUser(IHubContext<ChatHub> hubContext, string userId, string title, string message, string type, string? actionUrl = null)
        {
            if (UserConnections.TryGetValue(userId, out var connectionId))
            {
                await hubContext.Clients.Client(connectionId).SendAsync("ReceiveNotification", new
                {
                    Title = title,
                    Message = message,
                    Type = type,
                    ActionUrl = actionUrl,
                    CreatedAt = DateTime.UtcNow
                });
            }
        }

        private static string GetConversationGroupName(string userId1, string userId2)
        {
            // Create a consistent group name regardless of order
            var users = new[] { userId1, userId2 }.OrderBy(x => x).ToArray();
            return $"conversation_{users[0]}_{users[1]}";
        }
    }
}
