using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using SmartRestaurant.Entities.InventoryManagement;
using SmartRestaurant.InventoryManagement.Ingredients.Dto;
using SmartRestaurant.Permissions;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.InventoryManagement.Ingredients;

[Authorize(SmartRestaurantPermissions.Inventory.Ingredients.Default)]
public class IngredientAppService :
    CrudAppService<
        Ingredient,
        IngredientDto,
        Guid,
        PagedAndSortedResultRequestDto,
        CreateUpdateIngredientDto>,
    IIngredientAppService
{
    public IngredientAppService(IRepository<Ingredient, Guid> repository)
        : base(repository)
    {
        GetPolicyName = SmartRestaurantPermissions.Inventory.Ingredients.Default;
        GetListPolicyName = SmartRestaurantPermissions.Inventory.Ingredients.Default;
        CreatePolicyName = SmartRestaurantPermissions.Inventory.Ingredients.Create;
        UpdatePolicyName = SmartRestaurantPermissions.Inventory.Ingredients.Edit;
        DeletePolicyName = SmartRestaurantPermissions.Inventory.Ingredients.Delete;
    }

    /// <summary>
    /// Override GetListAsync để include navigation properties (Category và Unit)
    /// </summary>
    public override async Task<PagedResultDto<IngredientDto>> GetListAsync(PagedAndSortedResultRequestDto input)
    {
        var queryable = await Repository.WithDetailsAsync(x => x.Category, x => x.Unit);
        
        // Get total count first
        var totalCount = queryable.Count();
        
        // Apply sorting
        if (!string.IsNullOrEmpty(input.Sorting))
        {
            queryable = queryable.OrderBy(input.Sorting);
        }
        else
        {
            queryable = queryable.OrderBy(x => x.Name);
        }
        
        // Apply paging CORRECTLY - skip and take
        var ingredients = queryable
            .Skip(input.SkipCount)
            .Take(input.MaxResultCount)
            .ToList();
            
        var dtos = ObjectMapper.Map<List<Ingredient>, List<IngredientDto>>(ingredients);
        
        return new PagedResultDto<IngredientDto>(totalCount, dtos);
    }

    /// <summary>
    /// Override GetAsync để include navigation properties
    /// </summary>
    public override async Task<IngredientDto> GetAsync(Guid id)
    {
        var ingredient = await Repository.GetAsync(id, includeDetails: false);
        await Repository.EnsurePropertyLoadedAsync(ingredient, x => x.Category);
        await Repository.EnsurePropertyLoadedAsync(ingredient, x => x.Unit);
        
        return ObjectMapper.Map<Ingredient, IngredientDto>(ingredient);
    }

    public virtual async Task<List<IngredientDto>> GetIngredientsByCategoryAsync(Guid categoryId)
    {
        var queryable = await Repository.WithDetailsAsync(x => x.Category, x => x.Unit);
        var ingredients = queryable.Where(x => x.CategoryId == categoryId && x.IsActive).ToList();
        
        return ObjectMapper.Map<List<Ingredient>, List<IngredientDto>>(ingredients);
    }

}