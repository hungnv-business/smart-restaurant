using System.Collections.Generic;

namespace SmartRestaurant.Application.Contracts.Orders.Dto
{
    /// <summary>
    /// DTO kết quả kiểm tra tình trạng nguyên liệu
    /// </summary>
    public class IngredientAvailabilityResultDto
    {
        /// <summary>
        /// Tất cả nguyên liệu đều có sẵn
        /// </summary>
        public bool IsAvailable { get; set; }

        /// <summary>
        /// Danh sách nguyên liệu thiếu
        /// </summary>
        public List<MissingIngredientDto> MissingIngredients { get; set; } = new();

        /// <summary>
        /// Tổng số món được kiểm tra
        /// </summary>
        public int TotalItemsCount { get; set; }

        /// <summary>
        /// Số món không thể làm được do thiếu nguyên liệu
        /// </summary>
        public int UnavailableItemsCount { get; set; }

        /// <summary>
        /// Thông điệp tóm tắt
        /// </summary>
        public string SummaryMessage { get; set; } = string.Empty;

        /// <summary>
        /// Danh sách tên món không thể làm được
        /// </summary>
        public List<string> UnavailableMenuItems { get; set; } = new();
    }
}