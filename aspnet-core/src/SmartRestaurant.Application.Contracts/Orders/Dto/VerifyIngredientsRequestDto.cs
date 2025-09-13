using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SmartRestaurant.Application.Contracts.Orders.Dto
{
    /// <summary>
    /// DTO request để verify tình trạng nguyên liệu
    /// </summary>
    public class VerifyIngredientsRequestDto
    {
        /// <summary>
        /// Danh sách món cần kiểm tra nguyên liệu
        /// </summary>
        [Required]
        public List<CreateOrderItemDto> Items { get; set; } = new();
    }
}