using System;
using System.ComponentModel.DataAnnotations;

namespace SmartRestaurant.InventoryManagement.PurchaseInvoices.Dto
{
    public class CreateUpdatePurchaseInvoiceItemDto
    {
        [Required]
        public Guid IngredientId { get; set; }
        
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
        
        [MaxLength(500)]
        public string? Notes { get; set; }
    }
}