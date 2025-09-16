using System;
using SmartRestaurant.Orders;

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
    public class KitchenOrderItemDto
    {
        /// <summary>
        /// ID của đơn hàng chứa món này
        /// </summary>
        public Guid OrderId { get; set; }
        
        /// <summary>
        /// ID unique của món ăn này trong order
        /// </summary>
        public Guid OrderItemId { get; set; }
        
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
        
        /// <summary>
        /// Số phút đã chờ từ lúc gọi món đến bây giờ (real-time)
        /// </summary>
        public int WaitingMinutes { get; set; }
        
        /// <summary>
        /// Urgency level dựa trên thời gian chờ
        /// </summary>
        public string UrgencyLevel => WaitingMinutes switch
        {
            > 30 => "Critical",
            > 15 => "High", 
            > 5 => "Medium",
            _ => "Normal"
        };
        
        /// <summary>
        /// Màu hiển thị urgency
        /// </summary>
        public string UrgencyColor => UrgencyLevel switch
        {
            "Critical" => "red",
            "High" => "orange",
            "Medium" => "yellow", 
            _ => "green"
        };
    }
}