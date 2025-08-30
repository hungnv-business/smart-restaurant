using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SmartRestaurant.InventoryManagement.PurchaseInvoices.Dto
{
    public class CreateUpdatePurchaseInvoiceDto
    {
        [Required]
        [MaxLength(50)]
        public string InvoiceNumber { get; set; } = string.Empty;
        
        
        [Required]
        public int InvoiceDateId { get; set; }
        
        [MaxLength(500)]
        public string? Notes { get; set; }
        
        [Required]
        public List<CreateUpdatePurchaseInvoiceItemDto> Items { get; set; } = new();
    }
}