using System;
using Volo.Abp.Application.Dtos;

namespace SmartRestaurant.InventoryManagement.Ingredients.Dto;

public class IngredientDto : FullAuditedEntityDto<Guid>
{
    public Guid CategoryId { get; set; }
    public string CategoryName { get; set; } = string.Empty; // Để hiển thị tên danh mục
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public Guid UnitId { get; set; }
    public string UnitName { get; set; } = string.Empty; // Để hiển thị tên đơn vị
    public decimal? CostPerUnit { get; set; }
    public string? SupplierInfo { get; set; }
    public bool IsActive { get; set; }
}