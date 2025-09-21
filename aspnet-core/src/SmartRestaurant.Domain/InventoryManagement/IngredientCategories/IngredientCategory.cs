using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using SmartRestaurant.InventoryManagement.Ingredients;
using Volo.Abp.Domain.Entities.Auditing;

namespace SmartRestaurant.InventoryManagement.IngredientCategories;

/// <summary>
/// Danh mục nguyên liệu (ví dụ: "Rau củ", "Thịt cá", "Gia vị")
/// </summary>
public class IngredientCategory : FullAuditedEntity<Guid>
{
    /// <summary>
    /// Tên danh mục nguyên liệu (ví dụ: "Rau củ", "Thịt cá", "Gia vị")
    /// </summary>
    [Required]
    [MaxLength(128)]
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// Mô tả chi tiết về danh mục
    /// </summary>
    [MaxLength(512)]
    public string? Description { get; set; }

    /// <summary>
    /// Thứ tự hiển thị trong danh sách
    /// </summary>
    public int DisplayOrder { get; set; }

    /// <summary>
    /// Danh mục có đang sử dụng hay không
    /// </summary>
    public bool IsActive { get; set; } = true;

    // Navigation properties
    /// <summary>
    /// Danh sách nguyên liệu thuộc danh mục này
    /// </summary>
    public virtual ICollection<Ingredient> Ingredients { get; set; } = new List<Ingredient>();
}