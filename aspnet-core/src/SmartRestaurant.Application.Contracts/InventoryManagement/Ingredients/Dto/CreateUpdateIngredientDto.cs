using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SmartRestaurant.InventoryManagement.Ingredients.Dto;

public class CreateUpdateIngredientDto
{
    [Required]
    public Guid CategoryId { get; set; }

    [Required]
    [MaxLength(128)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(512)]
    public string? Description { get; set; }

    [Required]
    public Guid UnitId { get; set; }

    public int? CostPerUnit { get; set; }

    [MaxLength(512)]
    public string? SupplierInfo { get; set; }

    public bool IsActive { get; set; } = true;

    public List<CreateUpdatePurchaseUnitDto> PurchaseUnits { get; set; } = new();
}