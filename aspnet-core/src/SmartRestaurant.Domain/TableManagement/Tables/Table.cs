using System;
using System.ComponentModel.DataAnnotations;
using SmartRestaurant.TableManagement.LayoutSections;
using Volo.Abp.Domain.Entities.Auditing;

namespace SmartRestaurant.TableManagement.Tables
{
    /// <summary>
    /// Entity quản lý bàn ăn trong nhà hàng
    /// Mỗi bàn thuộc về một khu vực bố cục và có trạng thái riêng
    /// </summary>
    public class Table : FullAuditedEntity<Guid>
    {
        /// <summary>Số bàn hiển thị (ví dụ: "B01", "B02", "VIP1")</summary>
        [Required]
        [MaxLength(64)]
        public string TableNumber { get; set; }
        
        /// <summary>Số thứ tự bàn trong khu vực</summary>
        public int DisplayOrder { get; set; }
        
        /// <summary>Trạng thái bàn</summary>
        public TableStatus Status { get; set; }
        
        /// <summary>Bàn có đang hoạt động hay không</summary>
        public bool IsActive { get; set; }
        
        /// <summary>ID khu vực mà bàn này thuộc về</summary>
        public Guid? LayoutSectionId { get; set; }
        
        // Navigation properties
        /// <summary>Khu vực mà bàn này thuộc về</summary>
        public virtual LayoutSection LayoutSection { get; set; }

        /// <summary>
        /// Constructor mặc định cho EF Core
        /// </summary>
        protected Table()
        {
        }

        /// <summary>
        /// Constructor với tham số để tạo bàn mới
        /// </summary>
        /// <param name="id">ID của bàn</param>
        /// <param name="tableNumber">Số hiệu bàn</param>
        /// <param name="displayOrder">Thứ tự hiển thị trong khu vực</param>
        /// <param name="status">Trạng thái bàn</param>
        /// <param name="isActive">Trạng thái hoạt động</param>
        /// <param name="layoutSectionId">ID khu vực chứa bàn</param>
        public Table(
            Guid id,
            string tableNumber,
            int displayOrder = 0,
            TableStatus status = TableStatus.Available,
            bool isActive = true,
            Guid? layoutSectionId = null
        ) : base(id)
        {
            TableNumber = tableNumber;
            DisplayOrder = displayOrder;
            Status = status;
            IsActive = isActive;
            LayoutSectionId = layoutSectionId;
        }

        /// <summary>
        /// Gán bàn vào khu vực bố cục
        /// </summary>
        /// <param name="layoutSectionId">ID khu vực bố cục</param>
        public void AssignToSection(Guid layoutSectionId)
        {
            LayoutSectionId = layoutSectionId;
        }

        /// <summary>
        /// Cập nhật thứ tự hiển thị của bàn trong khu vực
        /// </summary>
        /// <param name="displayOrder">Thứ tự hiển thị mới</param>
        public void UpdateDisplayOrder(int displayOrder)
        {
            DisplayOrder = displayOrder;
        }

        /// <summary>
        /// Cập nhật trạng thái của bàn (Trống, Đang sử dụng, Đã đặt)
        /// </summary>
        /// <param name="status">Trạng thái mới</param>
        public void UpdateStatus(TableStatus status)
        {
            Status = status;
        }
    }
}