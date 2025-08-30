using System;

namespace SmartRestaurant.InventoryManagement.PurchaseInvoices.Dto
{
    public class IngredientLookupDto
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public Guid UnitId { get; set; }
        public string UnitName { get; set; } = string.Empty;
        public int CostPerUnit { get; set; }
        public string? SupplierInfo { get; set; }
    }
}