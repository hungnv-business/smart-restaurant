using System.Collections.Generic;
using SmartRestaurant.Orders;

namespace SmartRestaurant.Kitchen.Dtos
{
    /// <summary>
    /// DTO for Kitchen Table Group - groups cooking items by table/order
    /// Organizes Kitchen Dashboard display for better visual management
    /// 
    /// Purpose:
    /// - Groups all dishes for the same table/takeaway order together
    /// - Shows table-level priority (highest priority dish determines table priority)
    /// - Provides summary information (total items, earliest order time)
    /// - Enables kitchen staff to prioritize by table instead of individual dishes
    /// 
    /// Display Structure:
    /// Table B05 (2 items, waiting 15 min) [HIGH PRIORITY]
    ///   - Phở Bò (Quick Cook) - 30 min wait [CRITICAL]
    ///   - Cơm Tấm - 15 min wait [HIGH]
    /// 
    /// Takeaway #001 (1 item, waiting 10 min) [NORMAL]
    ///   - Bánh Mì - 10 min wait [MEDIUM]
    /// </summary>
    public class KitchenTableGroupDto
    {
        /// <summary>
        /// Tên hiển thị của bàn hoặc order
        /// Examples: "B05", "Mang về #001", "Giao hàng #002"
        /// </summary>
        public string TableNumber { get; set; } = string.Empty;

        /// <summary>
        /// True nếu đây là đơn mang về/giao hàng (không có bàn thật)
        /// </summary>
        public bool IsTakeaway { get; set; }

        /// <summary>
        /// Loại đơn hàng: DineIn (ăn tại chỗ), Takeaway (mang về), Delivery (giao hàng)
        /// </summary>
        public OrderType OrderType { get; set; }

        /// <summary>
        /// Tổng số món cần nấu trong nhóm này
        /// </summary>
        public int TotalItems { get; set; }

        /// <summary>
        /// Điểm priority cao nhất trong nhóm (dùng để sắp xếp thứ tự bàn)
        /// Score càng cao = ưu tiên càng cao
        /// </summary>
        public int HighestPriority { get; set; }

        /// <summary>
        /// Danh sách tất cả món cần nấu trong nhóm này
        /// Đã được sắp xếp theo priority giảm dần (món ưu tiên cao nhất lên đầu)
        /// </summary>
        public List<KitchenOrderItemDto> OrderItems { get; set; } = [];
    }
}