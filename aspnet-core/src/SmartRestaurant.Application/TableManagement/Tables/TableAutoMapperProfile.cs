using AutoMapper;
using SmartRestaurant.TableManagement.Tables;
using SmartRestaurant.TableManagement.Tables.Dto;

namespace SmartRestaurant.TableManagement.Tables
{
    public class TableAutoMapperProfile : Profile
    {
        public TableAutoMapperProfile()
        {
            // Entity to DTO mappings
            CreateMap<Table, TableDto>()
                .ForMember(dest => dest.LayoutSectionName, opt => opt.MapFrom(src => src.LayoutSection != null ? src.LayoutSection.SectionName : null));
            
            // DTO to Entity mappings
            CreateMap<CreateTableDto, Table>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.LayoutSection, opt => opt.Ignore())
                .ForMember(dest => dest.CreationTime, opt => opt.Ignore())
                .ForMember(dest => dest.CreatorId, opt => opt.Ignore())
                .ForMember(dest => dest.LastModificationTime, opt => opt.Ignore())
                .ForMember(dest => dest.LastModifierId, opt => opt.Ignore())
                .ForMember(dest => dest.DeletionTime, opt => opt.Ignore())
                .ForMember(dest => dest.DeleterId, opt => opt.Ignore())
                .ForMember(dest => dest.IsDeleted, opt => opt.Ignore());
            
            CreateMap<UpdateTableDto, Table>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.LayoutSection, opt => opt.Ignore())
                .ForMember(dest => dest.CreationTime, opt => opt.Ignore())
                .ForMember(dest => dest.CreatorId, opt => opt.Ignore())
                .ForMember(dest => dest.LastModificationTime, opt => opt.Ignore())
                .ForMember(dest => dest.LastModifierId, opt => opt.Ignore())
                .ForMember(dest => dest.DeletionTime, opt => opt.Ignore())
                .ForMember(dest => dest.DeleterId, opt => opt.Ignore())
                .ForMember(dest => dest.IsDeleted, opt => opt.Ignore());
        }
    }
}