using System;
using System.ComponentModel.DataAnnotations;
using SmartRestaurant.Orders;

namespace SmartRestaurant.Kitchen.Dtos
{
    /// <summary>
    /// Input DTO for updating order item status from kitchen dashboard
    /// </summary>
    public class UpdateOrderItemStatusInput
    {
        /// <summary>ID của OrderItem cần cập nhật</summary>
        [Required]
        public Guid OrderItemId { get; set; }

        /// <summary>Trạng thái mới</summary>
        [Required]
        public OrderItemStatus Status { get; set; }

        /// <summary>Ghi chú từ bếp (tùy chọn)</summary>
        [MaxLength(500)]
        public string? Notes { get; set; }
    }
}