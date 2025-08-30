using System;
using System.ComponentModel.DataAnnotations;

namespace SmartRestaurant.InventoryManagement.PurchaseInvoices.Dto
{
    public class CreateUpdatePurchaseInvoiceItemDto
    {
        public Guid? IngredientId { get; set; }
        
        [Required]
        [MaxLength(200)]
        public string IngredientName { get; set; } = string.Empty;
        
        [Required]
        public int Quantity { get; set; }
        
        public Guid? UnitId { get; set; }
        
        [Required]
        [MaxLength(50)]
        public string UnitName { get; set; } = string.Empty;
        
        public int? UnitPrice { get; set; }
        
        public int? TotalPrice { get; set; }
        
        [MaxLength(500)]
        public string? SupplierInfo { get; set; }
    }
}