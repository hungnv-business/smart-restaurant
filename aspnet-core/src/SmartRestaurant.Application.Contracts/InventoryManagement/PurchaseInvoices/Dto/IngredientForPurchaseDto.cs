using System;
using System.Collections.Generic;
using SmartRestaurant.InventoryManagement.Ingredients.Dto;

namespace SmartRestaurant.InventoryManagement.PurchaseInvoices.Dto;

public class IngredientForPurchaseDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal? CostPerUnit { get; set; }
    public string? SupplierInfo { get; set; }
    public List<IngredientPurchaseUnitDto> PurchaseUnits { get; set; } = new();
}