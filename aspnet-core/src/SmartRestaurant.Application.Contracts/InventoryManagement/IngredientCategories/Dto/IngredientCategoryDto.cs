using System;
using Volo.Abp.Application.Dtos;

namespace SmartRestaurant.InventoryManagement.IngredientCategories.Dto;

public class IngredientCategoryDto : FullAuditedEntityDto<Guid>
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int DisplayOrder { get; set; }
    public bool IsActive { get; set; }
}