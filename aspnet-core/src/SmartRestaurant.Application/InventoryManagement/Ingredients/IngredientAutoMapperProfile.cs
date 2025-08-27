using AutoMapper;
using SmartRestaurant.Entities.InventoryManagement;
using SmartRestaurant.InventoryManagement.Ingredients.Dto;

namespace SmartRestaurant.InventoryManagement.Ingredients;

public class IngredientAutoMapperProfile : Profile
{
    public IngredientAutoMapperProfile()
    {
        CreateMap<Ingredient, IngredientDto>()
            .ForMember(dest => dest.UnitName, opt => opt.MapFrom(src => src.Unit != null ? src.Unit.Name : string.Empty))
            .ForMember(dest => dest.CategoryName, opt => opt.MapFrom(src => src.Category != null ? src.Category.Name : string.Empty));
            
        CreateMap<CreateUpdateIngredientDto, Ingredient>();
    }
}