using System;

namespace SmartRestaurant.Application.Contracts.Orders.Dto
{
    /// <summary>
    /// DTO thông tin nguyên liệu thiếu khi verify ingredients
    /// </summary>
    public class MissingIngredientDto
    {
        public Guid MenuItemId { get; set; }
        public string MenuItemName { get; set; } = string.Empty;
        public Guid IngredientId { get; set; }
        public string IngredientName { get; set; } = string.Empty;
        public int RequiredQuantity { get; set; }
        public int CurrentStock { get; set; }
        public string Unit { get; set; } = string.Empty;
        public int ShortageAmount { get; set; }

        /// <summary>
        /// Thông điệp hiển thị dễ đọc
        /// </summary>
        public string DisplayMessage { get; set; } = string.Empty;
    }
}