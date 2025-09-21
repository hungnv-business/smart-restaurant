using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using SmartRestaurant.Common;
using SmartRestaurant.InventoryManagement.Ingredients;
using SmartRestaurant.InventoryManagement.Ingredients.Dto;
using SmartRestaurant.Permissions;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Entities;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.InventoryManagement.Ingredients;

/// <summary>
/// Application Service quản lý nguyên liệu trong hệ thống nhà hàng
/// Xử lý CRUD operations cho nguyên liệu và các đơn vị mua hàng
/// Bao gồm validation, authorization và business logic
/// </summary>

[Authorize(SmartRestaurantPermissions.Inventory.Ingredients.Default)]
public class IngredientAppService : ApplicationService, IIngredientAppService
{
    private readonly IIngredientRepository _ingredientRepository;
    private readonly IRepository<Unit> _unitRepository;

    /// <summary>
    /// Khởi tạo IngredientAppService với các dependency cần thiết
    /// </summary>
    /// <param name="ingredientRepository">Repository quản lý nguyên liệu</param>
    /// <param name="unitRepository">Repository quản lý đơn vị đo lường</param>
    public IngredientAppService(IIngredientRepository ingredientRepository, IRepository<Unit> unitRepository)
    {
        _ingredientRepository = ingredientRepository;
        _unitRepository = unitRepository;
    }

    /// <summary>
    /// Lấy danh sách nguyên liệu có phân trang và bộ lọc
    /// Bao gồm thông tin danh mục, đơn vị và các đơn vị mua hàng
    /// </summary>
    /// <param name="input">Tham số tìm kiếm và phân trang</param>
    /// <returns>Danh sách nguyên liệu đã được phân trang</returns>
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
        }

        return new PagedResultDto<IngredientDto>(totalCount, dtos);
    }

    /// <summary>
    /// Lấy thông tin chi tiết của một nguyên liệu theo ID
    /// Bao gồm thông tin danh mục, đơn vị và các đơn vị mua hàng
    /// </summary>
    /// <param name="id">ID của nguyên liệu cần lấy</param>
    /// <returns>Thông tin chi tiết nguyên liệu</returns>
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




    /// <summary>
    /// Tạo nguyên liệu mới trong hệ thống
    /// Bao gồm cả các đơn vị mua hàng và tỉ lệ quy đổi
    /// </summary>
    /// <param name="input">Thông tin nguyên liệu cần tạo</param>
    /// <returns>Thông tin nguyên liệu đã được tạo</returns>
    [Authorize(SmartRestaurantPermissions.Inventory.Ingredients.Create)]
    public virtual async Task<IngredientDto> CreateAsync(CreateUpdateIngredientDto input)
    {
        var ingredient = ObjectMapper.Map<CreateUpdateIngredientDto, Ingredient>(input);

        var createdIngredient = await _ingredientRepository.InsertAsync(ingredient);
        return ObjectMapper.Map<Ingredient, IngredientDto>(createdIngredient);
    }

    /// <summary>
    /// Cập nhật thông tin nguyên liệu hiện có
    /// Bao gồm cả việc cập nhật các đơn vị mua hàng và tỉ lệ quy đổi
    /// </summary>
    /// <param name="id">ID của nguyên liệu cần cập nhật</param>
    /// <param name="input">Thông tin nguyên liệu mới</param>
    /// <returns>Thông tin nguyên liệu đã được cập nhật</returns>
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
            // Load units để lấy tên đơn vị (bao gồm cả units từ input và units hiện tại)
            var inputUnitIds = input.PurchaseUnits.Select(dto => dto.UnitId).ToList();
            var currentUnitIds = ingredient.PurchaseUnits.Select(pu => pu.UnitId).ToList();
            var allUnitIds = inputUnitIds.Concat(currentUnitIds).Distinct().ToList();
            var units = await _unitRepository.GetListAsync(u => allUnitIds.Contains(u.Id));
            var unitLookup = units.ToDictionary(u => u.Id, u => u.Name);

            // Xóa các units không còn trong input
            var unitsToRemove = ingredient.PurchaseUnits
                .Where(pu => !inputUnitIds.Contains(pu.UnitId))
                .ToList();

            foreach (var unitToRemove in unitsToRemove)
            {
                var unitNameToRemove = unitLookup.GetValueOrDefault(unitToRemove.UnitId, "Unknown");
                ingredient.RemovePurchaseUnit(unitToRemove.UnitId, unitNameToRemove);
            }

            // Thêm/cập nhật units từ input với DisplayOrder theo index
            var unitsToAdd = input.PurchaseUnits.Select(dto => (
                id: dto.Id,
                unitId: dto.UnitId,
                unitName: unitLookup.GetValueOrDefault(dto.UnitId, "Unknown"),
                conversionRatio: dto.ConversionRatio,
                isBaseUnit: dto.IsBaseUnit,
                purchasePrice: dto.PurchasePrice,
                isActive: dto.IsActive
            ));

            ingredient.AddPurchaseUnits(unitsToAdd);
        }
        else
        {
            // Nếu input không có PurchaseUnits thì clear hết
            ingredient.ClearPurchaseUnits();
        }

        await _ingredientRepository.UpdateAsync(ingredient);

        return ObjectMapper.Map<Ingredient, IngredientDto>(ingredient);
    }

    /// <summary>
    /// Xóa nguyên liệu khỏi hệ thống
    /// Kiểm tra dependencies trước khi xóa để tránh lỗi tham chiếu
    /// </summary>
    /// <param name="id">ID của nguyên liệu cần xóa</param>
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

    // === Multi-Unit Management Methods ===

    /// <summary>
    /// Lấy danh sách đơn vị mua hàng của nguyên liệu
    /// </summary>
    /// <param name="ingredientId">ID của nguyên liệu</param>
    /// <returns>Danh sách đơn vị mua hàng với tỷ lệ quy đổi</returns>
    [Authorize(SmartRestaurantPermissions.Inventory.Ingredients.Default)]
    public virtual async Task<List<IngredientPurchaseUnitDto>> GetPurchaseUnitsAsync(Guid ingredientId)
    {
        var ingredient = await _ingredientRepository.GetWithDetailsAsync(ingredientId);
        if (ingredient == null)
        {
            throw new EntityNotFoundException(typeof(Ingredient), ingredientId);
        }

        var purchaseUnits = ingredient.PurchaseUnits
            .Where(pu => pu.IsActive)
            .OrderBy(pu => pu.DisplayOrder)
            .ToList();

        return ObjectMapper.Map<List<IngredientPurchaseUnit>, List<IngredientPurchaseUnitDto>>(purchaseUnits);
    }

    /// <summary>
    /// Chuyển đổi số lượng từ đơn vị này sang đơn vị khác cho nguyên liệu
    /// </summary>
    /// <param name="ingredientId">ID của nguyên liệu</param>
    /// <param name="fromUnitId">ID đơn vị nguồn</param>
    /// <param name="toUnitId">ID đơn vị đích</param>
    /// <param name="quantity">Số lượng cần chuyển đổi</param>
    /// <returns>Số lượng sau chuyển đổi</returns>
    [Authorize(SmartRestaurantPermissions.Inventory.Ingredients.Default)]
    public virtual async Task<int> ConvertQuantityAsync(Guid ingredientId, Guid fromUnitId, Guid toUnitId, int quantity)
    {
        var ingredient = await _ingredientRepository.GetWithDetailsAsync(ingredientId);
        if (ingredient == null)
        {
            throw new EntityNotFoundException(typeof(Ingredient), ingredientId);
        }

        // Chuyển đổi từ fromUnit sang base unit
        var baseQuantity = ingredient.ConvertToBaseUnit(quantity, fromUnitId);

        // Chuyển đổi từ base unit sang toUnit
        var convertedQuantity = ingredient.ConvertFromBaseUnit(baseQuantity, toUnitId);

        return convertedQuantity;
    }

}