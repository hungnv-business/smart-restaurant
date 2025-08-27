using AutoMapper;
using SmartRestaurant.Entities.InventoryManagement;
using SmartRestaurant.InventoryManagement.IngredientCategories.Dto;

namespace SmartRestaurant.InventoryManagement.IngredientCategories;

public class IngredientCategoryAutoMapperProfile : Profile
{
    public IngredientCategoryAutoMapperProfile()
    {
        CreateMap<IngredientCategory, IngredientCategoryDto>();
        CreateMap<CreateUpdateIngredientCategoryDto, IngredientCategory>();
    }
}