using System;
using SmartRestaurant.Orders;
using Volo.Abp.Application.Dtos;

namespace SmartRestaurant.Kitchen.Dtos
{
    /// <summary>
    /// DTO for Kitchen Order Item display
    /// Represents individual dishes that need cooking in the Kitchen Dashboard
    /// Used for both flat list and grouped display modes
    /// 
    /// Features:
    /// - Priority calculation (QuickCook + EmptyTable/Takeaway + FIFO time)
    /// - Real-time waiting time tracking
    /// - Urgency level indicators (Critical/High/Medium/Normal)
    /// - Support for both dine-in and takeaway orders
    /// </summary>
    public class KitchenOrderItemDto : EntityDto<Guid>
    {
        /// <summary>
        /// ID của đơn hàng chứa món này
        /// </summary>
        public Guid OrderId { get; set; }

        /// <summary>
        /// Tên hiển thị của bàn/order: "B05", "Mang về #001"
        /// </summary>
        public string TableNumber { get; set; } = string.Empty;

        /// <summary>
        /// Tên món ăn từ menu
        /// </summary>
        public string MenuItemName { get; set; } = string.Empty;

        /// <summary>
        /// Số lượng món cần nấu
        /// </summary>
        public int Quantity { get; set; }

        /// <summary>
        /// Thời gian gọi món
        /// </summary>
        public DateTime OrderTime { get; set; }

        /// <summary>
        /// True nếu món này có thể nấu nhanh (ưu tiên +100 points)
        /// </summary>
        public bool IsQuickCook { get; set; }

        /// <summary>
        /// True nếu món này cần nấu (chỉ hiển thị món RequiresCooking = true)
        /// </summary>
        public bool RequiresCooking { get; set; }

        /// <summary>
        /// True nếu bàn này có ưu tiên "bàn trống" (≤1 món đã phục vụ)
        /// </summary>
        public bool IsEmptyTablePriority { get; set; }

        /// <summary>
        /// Số món đã được phục vụ cho bàn này (dùng tính empty table priority)
        /// </summary>
        public int ServedDishesCount { get; set; }

        /// <summary>
        /// Điểm priority tổng: QuickCook (100) + EmptyTable (50/25) + Takeaway (30) + FIFO time
        /// </summary>
        public int PriorityScore { get; set; }

        /// <summary>
        /// Trạng thái hiện tại: Pending, Preparing, Ready, Served, Canceled
        /// </summary>
        public OrderItemStatus Status { get; set; }

        /// <summary>
        /// Loại đơn hàng: DineIn, Takeaway, Delivery
        /// </summary>
        public OrderType OrderType { get; set; }
    }
}