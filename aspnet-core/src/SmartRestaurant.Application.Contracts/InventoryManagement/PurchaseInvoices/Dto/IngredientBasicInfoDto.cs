using System;

namespace SmartRestaurant.InventoryManagement.PurchaseInvoices.Dto
{
    public class IngredientBasicInfoDto
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public decimal? CostPerUnit { get; set; }
        public string? SupplierInfo { get; set; }
    }
}