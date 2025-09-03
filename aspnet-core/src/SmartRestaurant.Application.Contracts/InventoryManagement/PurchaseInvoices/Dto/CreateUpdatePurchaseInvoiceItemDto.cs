using System;
using System.ComponentModel.DataAnnotations;
using Volo.Abp.Application.Dtos;

namespace SmartRestaurant.InventoryManagement.PurchaseInvoices.Dto
{
    public class CreateUpdatePurchaseInvoiceItemDto : EntityDto<Guid?>
    {
        [Required]
        public Guid IngredientId { get; set; }

        [Required]
        public int Quantity { get; set; }

        [Required]
        public Guid PurchaseUnitId { get; set; }

        public int? UnitPrice { get; set; }

        public int? TotalPrice { get; set; }

        [MaxLength(500)]
        public string? SupplierInfo { get; set; }

        [MaxLength(500)]
        public string? Notes { get; set; }

        public int DisplayOrder { get; set; }
    }
}