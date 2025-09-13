using AutoMapper;
using AdmasAfroLink.API.Models;
using AdmasAfroLink.API.DTOs.Opportunity;

namespace AdmasAfroLink.API.MappingProfiles
{
    public class OpportunityMappingProfile : Profile
    {
        public OpportunityMappingProfile()
        {
            // CreateOpportunityRequest to Opportunity
            CreateMap<CreateOpportunityRequest, Opportunity>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.Status, opt => opt.MapFrom(src => OpportunityStatus.Draft))
                .ForMember(dest => dest.UserId, opt => opt.Ignore())
                .ForMember(dest => dest.ViewCount, opt => opt.Ignore())
                .ForMember(dest => dest.ApplicationCount, opt => opt.Ignore())
                .ForMember(dest => dest.CreatedAt, opt => opt.Ignore())
                .ForMember(dest => dest.UpdatedAt, opt => opt.Ignore())
                .ForMember(dest => dest.User, opt => opt.Ignore())
                .ForMember(dest => dest.Tags, opt => opt.Ignore())
                .ForMember(dest => dest.RequiredSkills, opt => opt.Ignore())
                .ForMember(dest => dest.Applications, opt => opt.Ignore());

            // UpdateOpportunityRequest to Opportunity
            CreateMap<UpdateOpportunityRequest, Opportunity>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.UserId, opt => opt.Ignore())
                .ForMember(dest => dest.ViewCount, opt => opt.Ignore())
                .ForMember(dest => dest.ApplicationCount, opt => opt.Ignore())
                .ForMember(dest => dest.CreatedAt, opt => opt.Ignore())
                .ForMember(dest => dest.UpdatedAt, opt => opt.Ignore())
                .ForMember(dest => dest.User, opt => opt.Ignore())
                .ForMember(dest => dest.Tags, opt => opt.Ignore())
                .ForMember(dest => dest.RequiredSkills, opt => opt.Ignore())
                .ForMember(dest => dest.Applications, opt => opt.Ignore());

            // Opportunity to OpportunityResponse
            CreateMap<Opportunity, OpportunityResponse>()
                .ForMember(dest => dest.Tags, opt => opt.MapFrom(src => src.Tags.Select(ot => ot.Tag)))
                .ForMember(dest => dest.RequiredSkills, opt => opt.MapFrom(src => src.RequiredSkills.Select(os => os.Skill)));

            // Opportunity to OpportunitySearchResponse
            CreateMap<Opportunity, OpportunitySearchResponse>()
                .ForMember(dest => dest.Description, opt => opt.MapFrom(src => src.Description.Length > 300 ? src.Description.Substring(0, 300) + "..." : src.Description))
                .ForMember(dest => dest.Tags, opt => opt.MapFrom(src => src.Tags.Select(ot => ot.Tag)))
                .ForMember(dest => dest.RequiredSkills, opt => opt.MapFrom(src => src.RequiredSkills.Select(os => os.Skill)));

            // User to OpportunityUserResponse
            CreateMap<User, OpportunityUserResponse>();

            // Tag to TagDto
            CreateMap<Tag, TagDto>();

            // Skill to SkillDto
            CreateMap<Skill, SkillDto>();
        }
    }
}
