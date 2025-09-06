using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using SmartRestaurant.TableManagement.LayoutSections;
using SmartRestaurant.Orders;
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
        
        /// <summary>ID đơn hàng hiện tại đang phục vụ tại bàn (nếu có)</summary>
        public Guid? CurrentOrderId { get; private set; }
        
        // Navigation properties
        /// <summary>Khu vực mà bàn này thuộc về</summary>
        public virtual LayoutSection LayoutSection { get; set; }
        
        /// <summary>Đơn hàng hiện tại đang phục vụ tại bàn</summary>
        public virtual Order? CurrentOrder { get; set; }
        
        /// <summary>Danh sách tất cả đơn hàng đã từng phục vụ tại bàn này</summary>
        public virtual ICollection<Order> Orders { get; set; }

        /// <summary>
        /// Constructor mặc định cho EF Core
        /// </summary>
        protected Table()
        {
            Orders = new HashSet<Order>();
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
            Orders = new HashSet<Order>();
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

        /// <summary>
        /// Gán đơn hàng cho bàn và chuyển trạng thái sang Occupied
        /// </summary>
        /// <param name="orderId">ID của đơn hàng được gán</param>
        /// <exception cref="OrderValidationException">Khi bàn không available hoặc đã có đơn hàng</exception>
        public void AssignOrder(Guid orderId)
        {
            if (Status != TableStatus.Available)
            {
                throw OrderValidationException.CannotReserveTable(TableNumber);
            }

            if (CurrentOrderId.HasValue)
            {
                throw OrderValidationException.TableAlreadyHasOrder(TableNumber, CurrentOrderId.Value);
            }

            CurrentOrderId = orderId;
            Status = TableStatus.Occupied;
        }

        /// <summary>
        /// Kết thúc phục vụ đơn hàng tại bàn, chuyển về trạng thái Available
        /// </summary>
        /// <exception cref="OrderValidationException">Khi bàn không có đơn hàng nào</exception>
        public void CompleteOrder()
        {
            if (!CurrentOrderId.HasValue)
            {
                throw OrderValidationException.TableHasNoOrder(TableNumber);
            }

            CurrentOrderId = null;
            Status = TableStatus.Available;
        }

        /// <summary>
        /// Đặt trước bàn với trạng thái Reserved
        /// </summary>
        /// <exception cref="OrderValidationException">Khi bàn không available</exception>
        public void Reserve()
        {
            if (Status != TableStatus.Available)
            {
                throw OrderValidationException.CannotReserveTable(TableNumber);
            }

            Status = TableStatus.Reserved;
        }

        /// <summary>
        /// Hủy đặt trước và chuyển bàn về Available
        /// </summary>
        /// <exception cref="OrderValidationException">Khi bàn không ở trạng thái Reserved</exception>
        public void CancelReservation()
        {
            if (Status != TableStatus.Reserved)
            {
                throw OrderValidationException.CannotCancelReservation(TableNumber);
            }

            Status = TableStatus.Available;
        }


        /// <summary>
        /// Kiểm tra bàn có đang trống không
        /// </summary>
        /// <returns>True nếu bàn Available và không có đơn hàng</returns>
        public bool IsAvailable()
        {
            return Status == TableStatus.Available && !CurrentOrderId.HasValue;
        }

        /// <summary>
        /// Kiểm tra bàn có đang phục vụ khách không
        /// </summary>
        /// <returns>True nếu bàn Occupied và có đơn hàng</returns>
        public bool IsOccupied()
        {
            return Status == TableStatus.Occupied && CurrentOrderId.HasValue;
        }

        /// <summary>
        /// Kiểm tra bàn có được đặt trước không
        /// </summary>
        /// <returns>True nếu bàn ở trạng thái Reserved</returns>
        public bool IsReserved()
        {
            return Status == TableStatus.Reserved;
        }

    }
}