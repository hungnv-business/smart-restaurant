using AutoMapper;
using SmartRestaurant.MenuManagement.MenuCategories;
using SmartRestaurant.MenuManagement.MenuItems.Dto;
using SmartRestaurant.MenuManagement.MenuItemIngredients;

namespace SmartRestaurant.MenuManagement.MenuItems
{
    public class MenuItemAutoMapperProfile : Profile
    {
        public MenuItemAutoMapperProfile()
        {
            CreateMap<MenuItem, MenuItemDto>();
            CreateMap<CreateUpdateMenuItemDto, MenuItem>()
                .ForMember(dest => dest.Category, opt => opt.Ignore()) // Navigation property will be loaded automatically
                .ForMember(dest => dest.Ingredients, opt => opt.Ignore()); // Handled manually in AppService

            // Mapping cho nguyên liệu
            CreateMap<MenuItemIngredient, MenuItemIngredientDto>()
                .ForMember(dest => dest.CategoryId, opt => opt.MapFrom(src => src.Ingredient.CategoryId));
            CreateMap<MenuItemIngredientDto, MenuItemIngredient>();
        }
    }
}