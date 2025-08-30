using System;
using System.Collections.Generic;
using Volo.Abp.Application.Dtos;

namespace SmartRestaurant.InventoryManagement.PurchaseInvoices.Dto
{
    public class PurchaseInvoiceDto : FullAuditedEntityDto<Guid>
    {
        public string InvoiceNumber { get; set; } = string.Empty;
        public string InvoiceDate { get; set; } = string.Empty;
        public int InvoiceDateId { get; set; }
        public int TotalAmount { get; set; }
        public string? Notes { get; set; }
        public bool CanDelete { get; set; }
        public bool CanEdit { get; set; }
        public List<PurchaseInvoiceItemDto> Items { get; set; } = new();
    }
}