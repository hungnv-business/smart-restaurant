using System;
using Volo.Abp.Application.Dtos;

namespace SmartRestaurant.InventoryManagement.PurchaseInvoices.Dto
{
    public class PurchaseInvoiceItemDto : FullAuditedEntityDto<Guid>
    {
        public Guid PurchaseInvoiceId { get; set; }
        public Guid IngredientId { get; set; }
        public int Quantity { get; set; }
        public Guid UnitId { get; set; }
        public int? UnitPrice { get; set; }
        public int TotalPrice { get; set; }
        public string? SupplierInfo { get; set; }
        public string? Notes { get; set; }
        public Guid? CategoryId { get; set; }
    }
}