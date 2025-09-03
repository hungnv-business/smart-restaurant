using System;
using Volo.Abp.Application.Dtos;

namespace SmartRestaurant.InventoryManagement.Ingredients.Dto;

public class IngredientPurchaseUnitDto : FullAuditedEntityDto<Guid>
{
    public Guid IngredientId { get; set; }
    public Guid UnitId { get; set; }
    public string UnitName { get; set; } = string.Empty;
    public int ConversionRatio { get; set; }
    public bool IsBaseUnit { get; set; }
    public decimal? PurchasePrice { get; set; }
    public bool IsActive { get; set; }
}