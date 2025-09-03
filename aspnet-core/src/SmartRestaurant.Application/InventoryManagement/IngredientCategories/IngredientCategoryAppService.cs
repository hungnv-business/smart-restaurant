using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using SmartRestaurant.Common;
using SmartRestaurant.InventoryManagement.IngredientCategories;
using SmartRestaurant.InventoryManagement.IngredientCategories.Dto;
using SmartRestaurant.Permissions;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.InventoryManagement.IngredientCategories;

/// <summary>
/// Application Service cho IngredientCategory - Level 1 CRUD Pattern
/// Kế thừa CrudAppService của ABP để có sẵn các operations: GetList, Get, Create, Update, Delete
/// Chỉ cần override khi cần business logic đặc biệt
/// </summary>
[Authorize(SmartRestaurantPermissions.Inventory.Categories.Default)]
public class IngredientCategoryAppService :
    CrudAppService<
        IngredientCategory,                       // Domain Entity
        IngredientCategoryDto,                    // Output DTO  
        Guid,                                     // Primary Key Type
        PagedAndSortedResultRequestDto,           // GetList Input (có sẵn paging/sorting)
        CreateUpdateIngredientCategoryDto>,       // Create/Update Input DTO
    IIngredientCategoryAppService
{
    public IngredientCategoryAppService(IRepository<IngredientCategory, Guid> repository)
        : base(repository)
    {
        // Cấu hình permissions cho từng operation
        GetPolicyName = SmartRestaurantPermissions.Inventory.Categories.Default;
        GetListPolicyName = SmartRestaurantPermissions.Inventory.Categories.Default;
        CreatePolicyName = SmartRestaurantPermissions.Inventory.Categories.Create;
        UpdatePolicyName = SmartRestaurantPermissions.Inventory.Categories.Edit;
        DeletePolicyName = SmartRestaurantPermissions.Inventory.Categories.Delete;
    }

    /// <summary>
    /// Lấy thứ tự hiển thị tiếp theo có sẵn cho danh mục nguyên liệu mới
    /// </summary>
    /// <returns>Số thứ tự hiển thị tiếp theo</returns>
    [Authorize(SmartRestaurantPermissions.Inventory.Categories.Default)]
    public virtual async Task<int> GetNextDisplayOrderAsync()
    {
        var categories = await Repository.GetListAsync();
        var maxOrder = categories.Any() ? categories.Max(x => x.DisplayOrder) : 0;
        return maxOrder + 1;
    }

    /// <summary>
    /// Override CreateAsync để thêm business logic: validate name unique và auto-assign display order
    /// </summary>
    public override async Task<IngredientCategoryDto> CreateAsync(CreateUpdateIngredientCategoryDto input)
    {
        // Chuẩn hóa dữ liệu đầu vào để tránh khoảng trắng thừa
        input.Name = StringUtility.NormalizeString(input.Name);
        input.Description = StringUtility.NormalizeStringNullable(input.Description);

        // Business validation: kiểm tra trùng tên
        await ValidateNameNotExistsAsync(input.Name);

        // Auto-assign display order nếu chưa có
        if (input.DisplayOrder == 0)
        {
            input.DisplayOrder = await GetNextDisplayOrderAsync();
        }

        return await base.CreateAsync(input);
    }

    /// <summary>
    /// Override UpdateAsync để thêm business validation
    /// </summary>
    public override async Task<IngredientCategoryDto> UpdateAsync(Guid id, CreateUpdateIngredientCategoryDto input)
    {
        // Chuẩn hóa dữ liệu đầu vào
        input.Name = StringUtility.NormalizeString(input.Name);
        input.Description = StringUtility.NormalizeStringNullable(input.Description);

        // Business validation: kiểm tra trùng tên (loại trừ chính nó)
        await ValidateNameNotExistsAsync(input.Name, id);

        return await base.UpdateAsync(id, input);
    }

    /// <summary>
    /// Custom method: Xóa nhiều danh mục cùng lúc - không có sẵn trong CrudAppService
    /// </summary>
    [Authorize(SmartRestaurantPermissions.Inventory.Categories.Delete)]
    public virtual async Task DeleteManyAsync(List<Guid> ids)
    {
        if (ids == null || !ids.Any())
        {
            return;
        }

        var categoriesToDelete = await Repository.GetListAsync(x => ids.Contains(x.Id));
        
        if (categoriesToDelete.Any())
        {
            await Repository.DeleteManyAsync(categoriesToDelete);
        }
    }

    /// <summary>
    /// Private helper: Validate name uniqueness - business rule của IngredientCategory
    /// </summary>
    private async Task ValidateNameNotExistsAsync(string name, Guid? excludeId = null)
    {
        if (StringUtility.IsNullOrWhiteSpaceNormalized(name))
        {
            return;
        }

        // Kiểm tra trùng tên không phân biệt hoa thường và khoảng trắng
        var existingCategories = await Repository.GetListAsync();
        var duplicateCategory = existingCategories.FirstOrDefault(c => 
            (excludeId == null || c.Id != excludeId) && 
            StringUtility.AreNormalizedEqual(c.Name, name));

        if (duplicateCategory != null)
        {
            throw new IngredientCategoryNameAlreadyExistsException(name);
        }
    }
}