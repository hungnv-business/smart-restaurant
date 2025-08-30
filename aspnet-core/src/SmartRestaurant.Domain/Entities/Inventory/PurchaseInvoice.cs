using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using SmartRestaurant.Exceptions;
using SmartRestaurant.Entities.Common;
using Volo.Abp.Domain.Entities.Auditing;

namespace SmartRestaurant.Entities.Inventory
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

        protected PurchaseInvoice()
        {
        }

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
    }
}