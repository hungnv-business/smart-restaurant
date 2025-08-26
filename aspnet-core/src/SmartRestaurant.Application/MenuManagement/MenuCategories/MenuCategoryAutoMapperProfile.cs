using AutoMapper;
using SmartRestaurant.Entities.MenuManagement;
using SmartRestaurant.MenuManagement.MenuCategories.Dto;

namespace SmartRestaurant.MenuManagement.MenuCategories;

public class MenuCategoryAutoMapperProfile : Profile
{
    public MenuCategoryAutoMapperProfile()
    {
        // MenuCategory mappings
        CreateMap<MenuCategory, MenuCategoryDto>();
        CreateMap<CreateUpdateMenuCategoryDto, MenuCategory>();
    }
}