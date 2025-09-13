using AutoMapper;
using AdmasAfroLink.API.Models;
using AdmasAfroLink.API.DTOs.UserProfile;

namespace AdmasAfroLink.API.MappingProfiles
{
    public class UserProfileMappingProfile : Profile
    {
        public UserProfileMappingProfile()
        {
            // User to UserProfileResponse
            CreateMap<User, UserProfileResponse>()
                .ForMember(dest => dest.Skills, opt => opt.MapFrom(src => src.Skills.Select(us => us.Skill)))
                .ForMember(dest => dest.Interests, opt => opt.MapFrom(src => src.Interests.Select(ui => ui.Interest)));

            // User to PublicUserProfileResponse (limited information)
            CreateMap<User, PublicUserProfileResponse>()
                .ForMember(dest => dest.Skills, opt => opt.MapFrom(src => src.Skills.Select(us => us.Skill)))
                .ForMember(dest => dest.Interests, opt => opt.MapFrom(src => src.Interests.Select(ui => ui.Interest)));

            // User to UserSearchResponse
            CreateMap<User, UserSearchResponse>()
                .ForMember(dest => dest.Skills, opt => opt.MapFrom(src => src.Skills.Select(us => us.Skill)))
                .ForMember(dest => dest.Interests, opt => opt.MapFrom(src => src.Interests.Select(ui => ui.Interest)));

            // Skill to SkillDto
            CreateMap<Skill, SkillDto>();

            // Interest to InterestDto
            CreateMap<Interest, InterestDto>();

            // UpdateProfileRequest to User (for updating existing user)
            CreateMap<UpdateProfileRequest, User>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.Email, opt => opt.Ignore())
                .ForMember(dest => dest.UserName, opt => opt.Ignore())
                .ForMember(dest => dest.CreatedAt, opt => opt.Ignore())
                .ForMember(dest => dest.UpdatedAt, opt => opt.Ignore())
                .ForMember(dest => dest.Skills, opt => opt.Ignore())
                .ForMember(dest => dest.Interests, opt => opt.Ignore());
        }
    }
}
