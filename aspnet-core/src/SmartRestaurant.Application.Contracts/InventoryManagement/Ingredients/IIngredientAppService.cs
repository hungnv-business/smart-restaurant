using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using SmartRestaurant.InventoryManagement.Ingredients.Dto;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;

namespace SmartRestaurant.InventoryManagement.Ingredients;

public interface IIngredientAppService :
    ICrudAppService<
        IngredientDto,
        Guid,
        PagedAndSortedResultRequestDto,
        CreateUpdateIngredientDto>
{
    Task<List<IngredientDto>> GetIngredientsByCategoryAsync(Guid categoryId);
}