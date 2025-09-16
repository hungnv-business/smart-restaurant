namespace SmartRestaurant.Kitchen.Dtos
{
    /// <summary>
    /// DTO for Kitchen Dashboard statistics
    /// Provides overview metrics for cooking operations
    /// </summary>
    public class CookingStatsDto
    {
        /// <summary>Số lượng món nấu nhanh đang chờ (IsQuickCook=true, RequiresCooking=true)</summary>
        public int QuickCookItemsCount { get; set; }

        /// <summary>Số lượng bàn trống đang chờ món (có ít món đã phục vụ)</summary>
        public int EmptyTablesCount { get; set; }

        /// <summary>Tổng số món cần nấu (RequiresCooking=true, chưa served)</summary>
        public int TotalCookingItems { get; set; }

        /// <summary>Thời gian chờ trung bình tính bằng phút</summary>
        public double AverageWaitingTime { get; set; }

        /// <summary>Số món ở mức khẩn cấp cao (>20 phút)</summary>
        public int HighPriorityItemsCount { get; set; }

        /// <summary>Số món ở mức khẩn cấp nghiêm trọng (>30 phút)</summary>
        public int CriticalItemsCount { get; set; }

        /// <summary>Điểm ưu tiên cao nhất hiện tại</summary>
        public int HighestPriorityScore { get; set; }

        /// <summary>Bàn có thời gian chờ lâu nhất</summary>
        public string? LongestWaitingTable { get; set; }
    }
}