using System;
using System.ComponentModel.DataAnnotations;
using SmartRestaurant.Exceptions;
using SmartRestaurant.Entities.InventoryManagement;
using Volo.Abp.Domain.Entities.Auditing;

namespace SmartRestaurant.Entities.Inventory
{
    /// <summary>
    /// Chi tiết hóa đơn mua hàng - Detail entity cho Master-Detail pattern
    /// </summary>
    public class PurchaseInvoiceItem : FullAuditedEntity<Guid>
    {
        /// <summary>
        /// ID hóa đơn mua hàng (Foreign Key)
        /// </summary>
        [Required]
        public Guid PurchaseInvoiceId { get; set; }

        /// <summary>
        /// ID nguyên liệu (Bắt buộc chọn từ Ingredient)
        /// </summary>
        [Required]
        public Guid IngredientId { get; set; }


        /// <summary>
        /// Số lượng
        /// </summary>
        [Required]
        public int Quantity { get; set; }

        /// <summary>
        /// ID đơn vị (Nullable - chọn từ Unit)
        /// </summary>
        public Guid? UnitId { get; set; }

        /// <summary>
        /// Tên đơn vị (auto-fill từ Unit.Name)
        /// </summary>
        [Required]
        [MaxLength(50)]
        public string UnitName { get; set; } = string.Empty;

        /// <summary>
        /// Giá đơn vị (Nullable - có thể bỏ trống)
        /// </summary>
        public int? UnitPrice { get; set; }

        /// <summary>
        /// Tổng tiền - tự động tính từ Quantity * UnitPrice
        /// </summary>
        [Required]
        public int TotalPrice { get; private set; }

        /// <summary>
        /// Thông tin nhà cung cấp (auto-fill từ Ingredient hoặc nhập tự do)
        /// </summary>
        [MaxLength(500)]
        public string? SupplierInfo { get; set; }

        /// <summary>
        /// Ghi chú cho từng item
        /// </summary>
        [MaxLength(500)]
        public string? Notes { get; set; }

        /// <summary>
        /// Navigation property về PurchaseInvoice
        /// </summary>
        public virtual PurchaseInvoice PurchaseInvoice { get; set; } = null!;

        /// <summary>
        /// Navigation property về Ingredient
        /// </summary>
        public virtual Ingredient Ingredient { get; set; }

        protected PurchaseInvoiceItem()
        {
        }

        public PurchaseInvoiceItem(
            Guid id,
            Guid purchaseInvoiceId,
            Guid ingredientId,
            int quantity,
            string unitName,
            int totalPrice,
            Guid? unitId = null,
            int? unitPrice = null,
            string? supplierInfo = null,
            string? notes = null) : base(id)
        {
            if (quantity <= 0)
            {
                throw new InvalidQuantityException(quantity);
            }

            if (totalPrice < 0)
            {
                throw new InvalidTotalPriceException(totalPrice);
            }

            PurchaseInvoiceId = purchaseInvoiceId;
            IngredientId = ingredientId;
            Quantity = quantity;
            UnitId = unitId;
            UnitName = unitName;
            UnitPrice = unitPrice;
            TotalPrice = totalPrice;
            SupplierInfo = supplierInfo;
            Notes = notes;
        }
    }
}