using System;
using System.ComponentModel.DataAnnotations;

namespace SmartRestaurant.InventoryManagement.Ingredients.Dto;

public class CreateUpdatePurchaseUnitDto
{
    [Required]
    public Guid Id { get; set; }
    
    [Required]
    public Guid UnitId { get; set; }
    
    [Required]
    [Range(1, 1000000)]
    public int ConversionRatio { get; set; }
    
    [Required]
    public bool IsBaseUnit { get; set; }
    
    public int? PurchasePrice { get; set; }
    
    public bool IsActive { get; set; } = true;
}