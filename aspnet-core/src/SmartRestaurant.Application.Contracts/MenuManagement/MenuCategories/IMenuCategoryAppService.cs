using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using SmartRestaurant.MenuManagement.MenuCategories.Dto;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;

namespace SmartRestaurant.MenuManagement.MenuCategories;

/// <summary>
/// Application Service Interface cho MenuCategory - Level 1 CRUD Pattern
/// Kế thừa ICrudAppService để có sẵn: GetListAsync, GetAsync, CreateAsync, UpdateAsync, DeleteAsync
/// Chỉ định nghĩa thêm các method custom không có sẵn trong ICrudAppService
/// </summary>
public interface IMenuCategoryAppService : ICrudAppService<
    MenuCategoryDto,                      // Entity DTO cho output
    Guid,                                 // Primary key type
    PagedAndSortedResultRequestDto,       // GetList input với paging/sorting
    CreateUpdateMenuCategoryDto>          // Create/Update input DTO
{
    /// <summary>
    /// Custom method: Lấy display order tiếp theo cho danh mục mới
    /// </summary>
    Task<int> GetNextDisplayOrderAsync();

    /// <summary>
    /// Custom method: Bulk delete - không có sẵn trong ICrudAppService
    /// </summary>
    Task DeleteManyAsync(List<Guid> ids);
}