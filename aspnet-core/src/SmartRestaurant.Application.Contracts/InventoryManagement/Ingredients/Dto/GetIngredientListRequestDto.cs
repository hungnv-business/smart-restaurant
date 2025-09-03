using System;
using Volo.Abp.Application.Dtos;

namespace SmartRestaurant.InventoryManagement.Ingredients.Dto;

public class GetIngredientListRequestDto : PagedAndSortedResultRequestDto
{
    /// <summary>
    /// Tìm kiếm theo tên hoặc mô tả nguyên liệu
    /// </summary>
    public string? Filter { get; set; }
    
    /// <summary>
    /// Lọc theo ID danh mục nguyên liệu (null = tất cả danh mục)
    /// </summary>
    public Guid? CategoryId { get; set; }
    
    /// <summary>
    /// Bao gồm nguyên liệu không hoạt động (mặc định: false)
    /// </summary>
    public bool IncludeInactive { get; set; } = false;
}