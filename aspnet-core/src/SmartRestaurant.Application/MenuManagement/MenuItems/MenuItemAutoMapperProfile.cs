using AutoMapper;
using SmartRestaurant.MenuManagement.MenuCategories;
using SmartRestaurant.MenuManagement.MenuItems.Dto;

namespace SmartRestaurant.MenuManagement.MenuItems
{
    public class MenuItemAutoMapperProfile : Profile
    {
        public MenuItemAutoMapperProfile()
        {
            CreateMap<MenuItem, MenuItemDto>();
            CreateMap<CreateUpdateMenuItemDto, MenuItem>()
                .ForMember(dest => dest.Category, opt => opt.Ignore()); // Navigation property will be loaded automatically
        }
    }
}