using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using SmartRestaurant.InventoryManagement.Ingredients;
using SmartRestaurant.InventoryManagement.Ingredients.Dto;
using SmartRestaurant.Permissions;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Entities;

namespace SmartRestaurant.InventoryManagement.Ingredients;

[Authorize(SmartRestaurantPermissions.Inventory.Ingredients.Default)]
public class IngredientAppService : ApplicationService, IIngredientAppService
{
    private readonly IIngredientRepository _ingredientRepository;

    public IngredientAppService(IIngredientRepository ingredientRepository)
    {
        _ingredientRepository = ingredientRepository;
    }

    [Authorize(SmartRestaurantPermissions.Inventory.Ingredients.Default)]
    public virtual async Task<PagedResultDto<IngredientDto>> GetListAsync(GetIngredientListRequestDto input)
    {
        var totalCount = await _ingredientRepository.GetCountAsync(
            filter: input.Filter,
            categoryId: input.CategoryId,
            includeInactive: input.IncludeInactive);
            
        var ingredients = await _ingredientRepository.GetListWithDetailsAsync(
            skipCount: input.SkipCount,
            maxResultCount: input.MaxResultCount,
            sorting: input.Sorting ?? "name",
            filter: input.Filter,
            categoryId: input.CategoryId,
            includeInactive: input.IncludeInactive);
            
        var dtos = ObjectMapper.Map<List<Ingredient>, List<IngredientDto>>(ingredients);
        
        // Set CanDelete và sắp xếp PurchaseUnits cho từng ingredient
        foreach (var dto in dtos)
        {
            dto.CanDelete = !await _ingredientRepository.HasDependenciesAsync(dto.Id);
            
            // Sắp xếp purchase units: base unit lên đầu, sau đó theo conversion ratio
            if (dto.PurchaseUnits?.Any() == true)
            {
                dto.PurchaseUnits = dto.PurchaseUnits
                    .OrderByDescending(pu => pu.IsBaseUnit)
                    .ThenBy(pu => pu.ConversionRatio)
                    .ToList();
            }
        }
        
        return new PagedResultDto<IngredientDto>(totalCount, dtos);
    }

    [Authorize(SmartRestaurantPermissions.Inventory.Ingredients.Default)]
    public virtual async Task<IngredientDto> GetAsync(Guid id)
    {
        var ingredient = await _ingredientRepository.GetWithDetailsAsync(id);
        if (ingredient == null)
        {
            throw new EntityNotFoundException(typeof(Ingredient), id);
        }
        
        var dto = ObjectMapper.Map<Ingredient, IngredientDto>(ingredient);
        dto.CanDelete = !await _ingredientRepository.HasDependenciesAsync(id);
        
        return dto;
    }




    [Authorize(SmartRestaurantPermissions.Inventory.Ingredients.Create)]
    public virtual async Task<IngredientDto> CreateAsync(CreateUpdateIngredientDto input)
    {
        var ingredient = ObjectMapper.Map<CreateUpdateIngredientDto, Ingredient>(input);
        
        if (input.PurchaseUnits?.Count > 0)
        {
            var units = input.PurchaseUnits.Select(dto => (
                unitId: dto.UnitId,
                conversionRatio: dto.ConversionRatio,
                isBaseUnit: dto.IsBaseUnit,
                purchasePrice: dto.PurchasePrice,
                isActive: dto.IsActive
            ));
            ingredient.AddPurchaseUnits(units);
        }
        
        var createdIngredient = await _ingredientRepository.InsertAsync(ingredient);
        return ObjectMapper.Map<Ingredient, IngredientDto>(createdIngredient);
    }

    [Authorize(SmartRestaurantPermissions.Inventory.Ingredients.Edit)]
    public virtual async Task<IngredientDto> UpdateAsync(Guid id, CreateUpdateIngredientDto input)
    {
        var ingredient = await _ingredientRepository.GetWithDetailsAsync(id);
        if (ingredient == null)
        {
            throw new EntityNotFoundException(typeof(Ingredient), id);
        }
        
        // Map basic properties (exclude PurchaseUnits)
        ingredient.CategoryId = input.CategoryId;
        ingredient.Name = input.Name;
        ingredient.Description = input.Description;
        ingredient.UnitId = input.UnitId;
        ingredient.CostPerUnit = input.CostPerUnit;
        ingredient.SupplierInfo = input.SupplierInfo;
        ingredient.IsActive = input.IsActive;
        
        // Update purchase units using domain methods
        if (input.PurchaseUnits?.Count > 0)
        {
            // Xóa các units không còn trong input
            var inputUnitIds = input.PurchaseUnits.Select(dto => dto.UnitId).ToList();
            var unitsToRemove = ingredient.PurchaseUnits
                .Where(pu => !inputUnitIds.Contains(pu.UnitId))
                .ToList();
            
            foreach (var unitToRemove in unitsToRemove)
            {
                ingredient.RemovePurchaseUnit(unitToRemove.UnitId);
            }
            
            // Thêm/cập nhật units từ input
            foreach (var unitDto in input.PurchaseUnits)
            {
                ingredient.AddPurchaseUnit(
                    unitId: unitDto.UnitId,
                    conversionRatio: unitDto.ConversionRatio,
                    isBaseUnit: unitDto.IsBaseUnit,
                    purchasePrice: unitDto.PurchasePrice,
                    isActive: unitDto.IsActive
                );
            }
        }
        else
        {
            // Nếu input không có PurchaseUnits thì clear hết
            ingredient.ClearPurchaseUnits();
        }
        
        await _ingredientRepository.UpdateAsync(ingredient);
        
        return ObjectMapper.Map<Ingredient, IngredientDto>(ingredient);
    }

    [Authorize(SmartRestaurantPermissions.Inventory.Ingredients.Delete)]
    public virtual async Task DeleteAsync(Guid id)
    {
        var ingredient = await _ingredientRepository.GetAsync(id);
        if (ingredient == null)
        {
            throw new EntityNotFoundException(typeof(Ingredient), id);
        }

        var hasDependencies = await _ingredientRepository.HasDependenciesAsync(id);
        if (hasDependencies)
        {
            throw new IngredientIsBeingUsedException(ingredient.Name);
        }

        await _ingredientRepository.DeleteAsync(id);
    }

}