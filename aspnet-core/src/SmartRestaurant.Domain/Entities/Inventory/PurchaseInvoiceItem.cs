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
        /// ID đơn vị mua hàng (từ IngredientPurchaseUnit)
        /// </summary>
        [Required]
        public Guid PurchaseUnitId { get; set; }

        /// <summary>
        /// Số lượng chuyển đổi về đơn vị cơ sở (để tracking stock)
        /// </summary>
        [Required]
        public int BaseUnitQuantity { get; set; }

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
        /// Thứ tự hiển thị item trong hóa đơn
        /// </summary>
        [Required]
        public int DisplayOrder { get; set; }

        /// <summary>
        /// Navigation property về PurchaseInvoice
        /// </summary>
        public virtual PurchaseInvoice PurchaseInvoice { get; set; } = null!;

        /// <summary>
        /// Navigation property về Ingredient
        /// </summary>
        public virtual Ingredient Ingredient { get; set; }

        /// <summary>
        /// Navigation property về IngredientPurchaseUnit
        /// </summary>
        public virtual IngredientPurchaseUnit PurchaseUnit { get; set; } = null!;

        protected PurchaseInvoiceItem()
        {
        }

        public PurchaseInvoiceItem(
            Guid id,
            Guid purchaseInvoiceId,
            Guid ingredientId,
            int quantity,
            Guid purchaseUnitId,
            int baseUnitQuantity,
            int totalPrice,
            int displayOrder,
            int? unitPrice = null,
            string? supplierInfo = null,
            string? notes = null) : base(id)
        {
            if (quantity <= 0)
            {
                throw new InvalidQuantityException(quantity);
            }

            if (baseUnitQuantity <= 0)
            {
                throw new InvalidQuantityException(baseUnitQuantity);
            }

            if (totalPrice < 0)
            {
                throw new InvalidTotalPriceException(totalPrice);
            }

            PurchaseInvoiceId = purchaseInvoiceId;
            IngredientId = ingredientId;
            Quantity = quantity;
            PurchaseUnitId = purchaseUnitId;
            BaseUnitQuantity = baseUnitQuantity;
            UnitPrice = unitPrice;
            TotalPrice = totalPrice;
            DisplayOrder = displayOrder;
            SupplierInfo = supplierInfo;
            Notes = notes;
        }

        /// <summary>
        /// Cập nhật thông tin chi tiết của item
        /// </summary>
        public void UpdateDetails(
            int quantity,
            Guid purchaseUnitId,
            int baseUnitQuantity,
            int totalPrice,
            int displayOrder,
            int? unitPrice = null,
            string? supplierInfo = null,
            string? notes = null)
        {
            if (quantity <= 0)
            {
                throw new InvalidQuantityException(quantity);
            }

            if (baseUnitQuantity <= 0)
            {
                throw new InvalidQuantityException(baseUnitQuantity);
            }

            if (totalPrice < 0)
            {
                throw new InvalidTotalPriceException(totalPrice);
            }

            Quantity = quantity;
            PurchaseUnitId = purchaseUnitId;
            BaseUnitQuantity = baseUnitQuantity;
            TotalPrice = totalPrice;
            DisplayOrder = displayOrder;
            UnitPrice = unitPrice;
            SupplierInfo = supplierInfo;
            Notes = notes;
        }
    }
}