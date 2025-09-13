using System;
using System.ComponentModel.DataAnnotations;

namespace SmartRestaurant.Application.Contracts.Orders.Dto;

/// <summary>
/// DTO để cập nhật số lượng món ăn trong đơn hàng
/// </summary>
public class UpdateOrderItemQuantityDto
{
    /// <summary>
    /// Số lượng mới (phải lớn hơn 0)
    /// </summary>
    [Required]
    [Range(1, int.MaxValue, ErrorMessage = "Số lượng phải lớn hơn 0")]
    public int NewQuantity { get; set; }

    /// <summary>
    /// Ghi chú bổ sung khi thay đổi số lượng (tùy chọn)
    /// </summary>
    [StringLength(200)]
    public string? Notes { get; set; }
}