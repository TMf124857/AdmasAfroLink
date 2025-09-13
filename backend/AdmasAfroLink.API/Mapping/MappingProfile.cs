using AutoMapper;
using AdmasAfroLink.API.Models;
using AdmasAfroLink.API.DTOs;

namespace AdmasAfroLink.API.Mapping
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            // User mappings
            CreateMap<User, UserProfileDto>()
                .ForMember(dest => dest.Skills, opt => opt.MapFrom(src => src.Skills))
                .ForMember(dest => dest.Interests, opt => opt.MapFrom(src => src.Interests))
                .ForMember(dest => dest.ConnectionCount, opt => opt.Ignore())
                .ForMember(dest => dest.OpportunityCount, opt => opt.Ignore());

            CreateMap<User, UserDirectoryDto>()
                .ForMember(dest => dest.Skills, opt => opt.MapFrom(src => src.Skills))
                .ForMember(dest => dest.Interests, opt => opt.MapFrom(src => src.Interests))
                .ForMember(dest => dest.ConnectionCount, opt => opt.Ignore())
                .ForMember(dest => dest.IsConnected, opt => opt.Ignore())
                .ForMember(dest => dest.ConnectionStatus, opt => opt.Ignore());

            CreateMap<UpdateUserProfileDto, User>()
                .ForMember(dest => dest.UpdatedAt, opt => opt.MapFrom(src => DateTime.UtcNow));

            // Skill mappings
            CreateMap<Skill, SkillDto>()
                .ForMember(dest => dest.UsageCount, opt => opt.Ignore())
                .ForMember(dest => dest.IsRequired, opt => opt.Ignore())
                .ForMember(dest => dest.RequiredLevel, opt => opt.Ignore());

            CreateMap<UserSkill, UserSkillDto>()
                .ForMember(dest => dest.SkillName, opt => opt.MapFrom(src => src.Skill.Name))
                .ForMember(dest => dest.SkillCategory, opt => opt.MapFrom(src => src.Skill.Category));

            // Interest mappings
            CreateMap<Interest, InterestDto>();

            CreateMap<UserInterest, UserInterestDto>()
                .ForMember(dest => dest.InterestName, opt => opt.MapFrom(src => src.Interest.Name))
                .ForMember(dest => dest.InterestCategory, opt => opt.MapFrom(src => src.Interest.Category));

            // Opportunity mappings
            CreateMap<Opportunity, OpportunityDto>()
                .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => $"{src.User.FirstName} {src.User.LastName}"))
                .ForMember(dest => dest.UserProfilePicture, opt => opt.MapFrom(src => src.User.ProfilePictureUrl))
                .ForMember(dest => dest.Tags, opt => opt.MapFrom(src => src.Tags.Select(ot => ot.Tag)))
                .ForMember(dest => dest.RequiredSkills, opt => opt.MapFrom(src => src.RequiredSkills.Select(os => new SkillDto
                {
                    Id = os.Skill.Id,
                    Name = os.Skill.Name,
                    Description = os.Skill.Description,
                    Category = os.Skill.Category,
                    IsActive = os.Skill.IsActive,
                    IsRequired = os.IsRequired,
                    RequiredLevel = os.RequiredLevel
                })))
                .ForMember(dest => dest.HasApplied, opt => opt.Ignore())
                .ForMember(dest => dest.UserApplicationStatus, opt => opt.Ignore());

            CreateMap<CreateOpportunityDto, Opportunity>()
                .ForMember(dest => dest.CreatedAt, opt => opt.MapFrom(src => DateTime.UtcNow))
                .ForMember(dest => dest.UpdatedAt, opt => opt.MapFrom(src => DateTime.UtcNow))
                .ForMember(dest => dest.Status, opt => opt.MapFrom(src => OpportunityStatus.Published));

            CreateMap<UpdateOpportunityDto, Opportunity>()
                .ForMember(dest => dest.UpdatedAt, opt => opt.MapFrom(src => DateTime.UtcNow));

            // Tag mappings
            CreateMap<Tag, TagDto>()
                .ForMember(dest => dest.UsageCount, opt => opt.Ignore());

            // Application mappings
            CreateMap<OpportunityApplication, OpportunityApplicationDto>()
                .ForMember(dest => dest.OpportunityTitle, opt => opt.MapFrom(src => src.Opportunity.Title))
                .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => $"{src.User.FirstName} {src.User.LastName}"))
                .ForMember(dest => dest.UserEmail, opt => opt.MapFrom(src => src.User.Email))
                .ForMember(dest => dest.UserProfilePicture, opt => opt.MapFrom(src => src.User.ProfilePictureUrl));

            CreateMap<CreateApplicationDto, OpportunityApplication>()
                .ForMember(dest => dest.CreatedAt, opt => opt.MapFrom(src => DateTime.UtcNow))
                .ForMember(dest => dest.UpdatedAt, opt => opt.MapFrom(src => DateTime.UtcNow))
                .ForMember(dest => dest.Status, opt => opt.MapFrom(src => ApplicationStatus.Submitted));

            // Message mappings
            CreateMap<Message, MessageDto>()
                .ForMember(dest => dest.SenderName, opt => opt.MapFrom(src => $"{src.Sender.FirstName} {src.Sender.LastName}"))
                .ForMember(dest => dest.SenderProfilePicture, opt => opt.MapFrom(src => src.Sender.ProfilePictureUrl))
                .ForMember(dest => dest.ReceiverName, opt => opt.MapFrom(src => $"{src.Receiver.FirstName} {src.Receiver.LastName}"))
                .ForMember(dest => dest.ReceiverProfilePicture, opt => opt.MapFrom(src => src.Receiver.ProfilePictureUrl))
                .ForMember(dest => dest.IsFromCurrentUser, opt => opt.Ignore());

            CreateMap<SendMessageDto, Message>()
                .ForMember(dest => dest.CreatedAt, opt => opt.MapFrom(src => DateTime.UtcNow))
                .ForMember(dest => dest.Status, opt => opt.MapFrom(src => MessageStatus.Sent));

            // Connection mappings
            CreateMap<UserConnection, UserConnectionDto>()
                .ForMember(dest => dest.RequesterName, opt => opt.MapFrom(src => $"{src.Requester.FirstName} {src.Requester.LastName}"))
                .ForMember(dest => dest.RequesterProfilePicture, opt => opt.MapFrom(src => src.Requester.ProfilePictureUrl))
                .ForMember(dest => dest.ReceiverName, opt => opt.MapFrom(src => $"{src.Receiver.FirstName} {src.Receiver.LastName}"))
                .ForMember(dest => dest.ReceiverProfilePicture, opt => opt.MapFrom(src => src.Receiver.ProfilePictureUrl))
                .ForMember(dest => dest.IsRequester, opt => opt.Ignore());

            CreateMap<SendConnectionRequestDto, UserConnection>()
                .ForMember(dest => dest.CreatedAt, opt => opt.MapFrom(src => DateTime.UtcNow))
                .ForMember(dest => dest.UpdatedAt, opt => opt.MapFrom(src => DateTime.UtcNow))
                .ForMember(dest => dest.Status, opt => opt.MapFrom(src => ConnectionStatus.Pending));

            // Notification mappings
            CreateMap<Notification, NotificationDto>()
                .ForMember(dest => dest.TimeAgo, opt => opt.Ignore());

            CreateMap<CreateNotificationDto, Notification>()
                .ForMember(dest => dest.CreatedAt, opt => opt.MapFrom(src => DateTime.UtcNow))
                .ForMember(dest => dest.IsRead, opt => opt.MapFrom(src => false));
        }
    }
}
