using System.Linq;
using AutoMapper;
using SmartRestaurant.InventoryManagement.Ingredients;
using SmartRestaurant.InventoryManagement.Ingredients.Dto;

namespace SmartRestaurant.InventoryManagement.Ingredients;

public class IngredientAutoMapperProfile : Profile
{
    public IngredientAutoMapperProfile()
    {
        CreateMap<Ingredient, IngredientDto>()
            .ForMember(dest => dest.UnitName, opt => opt.MapFrom(src => src.Unit != null ? src.Unit.Name : string.Empty))
            .ForMember(dest => dest.CategoryName, opt => opt.MapFrom(src => src.Category != null ? src.Category.Name : string.Empty))
            .ForMember(dest => dest.PurchaseUnits, opt => opt.MapFrom(src => src.PurchaseUnits.Where(pu => pu.IsActive)));
            
        CreateMap<CreateUpdateIngredientDto, Ingredient>();
        
        CreateMap<IngredientPurchaseUnit, IngredientPurchaseUnitDto>()
            .ForMember(dest => dest.UnitName, opt => opt.MapFrom(src => src.Unit != null ? src.Unit.Name : string.Empty));
            
        CreateMap<CreateUpdatePurchaseUnitDto, IngredientPurchaseUnit>();
    }
}