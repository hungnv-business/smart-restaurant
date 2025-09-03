using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using SmartRestaurant.Common;
using Volo.Abp.Domain.Entities.Auditing;

namespace SmartRestaurant.InventoryManagement.PurchaseInvoices
{
    /// <summary>
    /// Hóa đơn mua hàng - Header entity cho Master-Detail pattern
    /// </summary>
    public class PurchaseInvoice : FullAuditedAggregateRoot<Guid>
    {
        /// <summary>
        /// Thời gian tối đa có thể xóa hóa đơn (tính bằng giờ)
        /// </summary>
        public const int DELETION_TIME_LIMIT_HOURS = 6;
        /// <summary>
        /// Số hóa đơn (ví dụ: "HD001", "INV-2024-001")
        /// </summary>
        [Required]
        [MaxLength(50)]
        public string InvoiceNumber { get; set; } = string.Empty;
        
        
        /// <summary>
        /// Ngày lập hóa đơn - Foreign Key tới DimDate
        /// </summary>
        [Required]
        public int InvoiceDateId { get; set; }
        
        /// <summary>
        /// Navigation property tới DimDate
        /// </summary>
        public virtual DimDate InvoiceDate { get; set; } = null!;
        
        /// <summary>
        /// Tổng tiền tự động tính từ các Items
        /// </summary>
        [Required]
        public int TotalAmount { get; private set; }
        
        /// <summary>
        /// Ghi chú chung cho hóa đơn
        /// </summary>
        [MaxLength(500)]
        public string? Notes { get; set; }

        /// <summary>
        /// Danh sách các mặt hàng trong hóa đơn (Master-Detail)
        /// </summary>
        public virtual ICollection<PurchaseInvoiceItem> Items { get; set; } = new List<PurchaseInvoiceItem>();

        /// <summary>
        /// Constructor mặc định cho EF Core
        /// </summary>
        protected PurchaseInvoice()
        {
        }

        /// <summary>
        /// Constructor tạo hóa đơn mua hàng mới
        /// </summary>
        /// <param name="id">ID duy nhất của hóa đơn</param>
        /// <param name="invoiceNumber">Số hóa đơn</param>
        /// <param name="invoiceDateId">ID ngày lập hóa đơn trong bảng DimDate</param>
        /// <param name="notes">Ghi chú cho hóa đơn (tùy chọn)</param>
        public PurchaseInvoice(
            Guid id,
            string invoiceNumber,
            int invoiceDateId,
            string? notes = null) : base(id)
        {
            InvoiceNumber = invoiceNumber;
            InvoiceDateId = invoiceDateId;
            Notes = notes;
            TotalAmount = 0;
        }

        /// <summary>
        /// Tính tổng tiền từ tất cả Items
        /// </summary>
        public void CalculateTotalAmount()
        {
            TotalAmount = Items.Sum(item => item.TotalPrice);
        }

        /// <summary>
        /// Kiểm tra có thể xóa hóa đơn không (trong vòng DELETION_TIME_LIMIT_HOURS giờ)
        /// </summary>
        public bool CanDelete()
        {
            return CreationTime.AddHours(DELETION_TIME_LIMIT_HOURS) > DateTime.Now;
        }

        /// <summary>
        /// Kiểm tra có thể sửa hóa đơn không (trong vòng DELETION_TIME_LIMIT_HOURS giờ)
        /// </summary>
        public bool CanEdit()
        {
            return CreationTime.AddHours(DELETION_TIME_LIMIT_HOURS) > DateTime.Now;
        }

        /// <summary>
        /// Validate trước khi xóa hóa đơn
        /// </summary>
        public void ValidateDelete()
        {
            if (!CanDelete())
            {
                throw new CannotDeleteAfterTimeException(CreationTime, DELETION_TIME_LIMIT_HOURS);
            }
        }

        /// <summary>
        /// Thêm item mới vào hóa đơn với validation
        /// </summary>
        public void AddItem(
            Guid itemId,
            Guid ingredientId,
            int quantity,
            Guid purchaseUnitId,
            int baseUnitQuantity,
            int totalPrice,
            int displayOrder,
            int? unitPrice = null,
            string? supplierInfo = null,
            string? notes = null)
        {
            ValidateItemData(quantity, baseUnitQuantity, totalPrice);

            var item = new PurchaseInvoiceItem(
                itemId,
                Id,
                ingredientId,
                quantity,
                purchaseUnitId,
                baseUnitQuantity,
                totalPrice,
                displayOrder,
                unitPrice,
                supplierInfo,
                notes);

            Items.Add(item);
        }

        /// <summary>
        /// Thêm nhiều items cùng lúc
        /// </summary>
        public void AddItems(IEnumerable<PurchaseInvoiceItem> items)
        {
            foreach (var item in items)
            {
                AddItem(
                    item.Id,
                    item.IngredientId,
                    item.Quantity,
                    item.PurchaseUnitId,
                    item.BaseUnitQuantity,
                    item.TotalPrice,
                    item.DisplayOrder,
                    item.UnitPrice,
                    item.SupplierInfo,
                    item.Notes);
            }
        }

        /// <summary>
        /// Cập nhật item hiện có
        /// </summary>
        public void UpdateItem(
            Guid itemId,
            int quantity,
            Guid purchaseUnitId,
            int baseUnitQuantity,
            int totalPrice,
            int displayOrder,
            int? unitPrice = null,
            string? supplierInfo = null,
            string? notes = null)
        {
            var existingItem = GetItem(itemId);
            if (existingItem == null)
            {
                throw new InvoiceItemNotFoundException(itemId);
            }

            ValidateItemData(quantity, baseUnitQuantity, totalPrice);

            // Sử dụng domain method của PurchaseInvoiceItem để update
            existingItem.UpdateDetails(
                quantity,
                purchaseUnitId,
                baseUnitQuantity,
                totalPrice,
                displayOrder,
                unitPrice,
                supplierInfo,
                notes);
        }

        /// <summary>
        /// Cập nhật items collection một cách thông minh (so sánh để add/update/remove)
        /// </summary>
        public void UpdateItems(IEnumerable<PurchaseInvoiceItem> newItems)
        {
            var newItemsList = newItems.ToList();
            var currentItemIds = Items.Select(i => i.Id).ToHashSet();
            var newItemIds = newItemsList.Select(i => i.Id).ToHashSet();

            // 1. Xóa các items không còn trong danh sách mới
            var itemsToRemove = Items.Where(i => !newItemIds.Contains(i.Id)).ToList();
            foreach (var item in itemsToRemove)
            {
                Items.Remove(item);
            }

            // 2. Thêm mới các items chưa có
            var itemsToAdd = newItemsList.Where(i => !currentItemIds.Contains(i.Id)).ToList();
            foreach (var item in itemsToAdd)
            {
                AddItem(
                    item.Id,
                    item.IngredientId,
                    item.Quantity,
                    item.PurchaseUnitId,
                    item.BaseUnitQuantity,
                    item.TotalPrice,
                    item.DisplayOrder,
                    item.UnitPrice,
                    item.SupplierInfo,
                    item.Notes);
            }

            // 3. Cập nhật các items đã tồn tại
            var itemsToUpdate = newItemsList.Where(i => currentItemIds.Contains(i.Id)).ToList();
            foreach (var newItem in itemsToUpdate)
            {
                UpdateItem(
                    newItem.Id,
                    newItem.Quantity,
                    newItem.PurchaseUnitId,
                    newItem.BaseUnitQuantity,
                    newItem.TotalPrice,
                    newItem.DisplayOrder,
                    newItem.UnitPrice,
                    newItem.SupplierInfo,
                    newItem.Notes);
            }
        }

        /// <summary>
        /// Xóa item theo ID
        /// </summary>
        public void RemoveItem(Guid itemId)
        {
            var itemToRemove = Items.FirstOrDefault(i => i.Id == itemId);
            if (itemToRemove != null)
            {
                Items.Remove(itemToRemove);
            }
        }

        /// <summary>
        /// Lấy item theo ID
        /// </summary>
        public PurchaseInvoiceItem? GetItem(Guid itemId)
        {
            return Items.FirstOrDefault(i => i.Id == itemId);
        }

        /// <summary>
        /// Kiểm tra có items không
        /// </summary>
        public bool HasItems()
        {
            return Items.Count > 0;
        }

        /// <summary>
        /// Lấy số lượng items
        /// </summary>
        public int GetItemCount()
        {
            return Items.Count;
        }

        /// <summary>
        /// Lấy tất cả items
        /// </summary>
        public IReadOnlyList<PurchaseInvoiceItem> GetItems()
        {
            return Items.ToList().AsReadOnly();
        }

        /// <summary>
        /// Xóa tất cả items
        /// </summary>
        public void ClearItems()
        {
            Items.Clear();
        }

        /// <summary>
        /// Kiểm tra item có tồn tại không
        /// </summary>
        public bool HasItem(Guid itemId)
        {
            return Items.Any(i => i.Id == itemId);
        }

        /// <summary>
        /// Kiểm tra ingredient đã có trong invoice chưa
        /// </summary>
        public bool HasIngredient(Guid ingredientId)
        {
            return Items.Any(i => i.IngredientId == ingredientId);
        }

        /// <summary>
        /// Lấy item theo ingredient ID
        /// </summary>
        public PurchaseInvoiceItem? GetItemByIngredient(Guid ingredientId)
        {
            return Items.FirstOrDefault(i => i.IngredientId == ingredientId);
        }

        /// <summary>
        /// Validate dữ liệu item trước khi thêm/sửa
        /// </summary>
        private static void ValidateItemData(int quantity, int baseUnitQuantity, int totalPrice)
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
        }

        /// <summary>
        /// Validate có thể chỉnh sửa invoice không
        /// </summary>
        public void ValidateCanEdit()
        {
            if (!CanEdit())
            {
                throw new CannotDeleteAfterTimeException(CreationTime, DELETION_TIME_LIMIT_HOURS);
            }
        }


        /// <summary>
        /// Lấy danh sách items đã bị xóa so với danh sách mới (cho stock tracking)
        /// </summary>
        public IReadOnlyList<PurchaseInvoiceItem> GetRemovedItems(IEnumerable<Guid> newItemIds)
        {
            var newIds = newItemIds.ToHashSet();
            return Items.Where(i => !newIds.Contains(i.Id)).ToList().AsReadOnly();
        }

        /// <summary>
        /// Lấy danh sách items mới được thêm (cho stock tracking)
        /// </summary>
        public IReadOnlyList<PurchaseInvoiceItem> GetAddedItems(IEnumerable<Guid> currentItemIds)
        {
            var currentIds = currentItemIds.ToHashSet();
            return Items.Where(i => !currentIds.Contains(i.Id)).ToList().AsReadOnly();
        }
    }
}