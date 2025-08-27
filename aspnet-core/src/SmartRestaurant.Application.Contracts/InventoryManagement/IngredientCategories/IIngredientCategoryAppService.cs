using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using SmartRestaurant.InventoryManagement.IngredientCategories.Dto;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;

namespace SmartRestaurant.InventoryManagement.IngredientCategories;

public interface IIngredientCategoryAppService :
    ICrudAppService<
        IngredientCategoryDto,
        Guid,
        PagedAndSortedResultRequestDto,
        CreateUpdateIngredientCategoryDto>
{
    Task<int> GetNextDisplayOrderAsync();
    Task DeleteManyAsync(List<Guid> ids);
}