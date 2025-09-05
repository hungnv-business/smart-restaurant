using System.ComponentModel.DataAnnotations;
using SmartRestaurant.Orders;

namespace SmartRestaurant.Application.Contracts.Orders.Dto;

/// <summary>
/// DTO cho việc cập nhật trạng thái đơn hàng
/// </summary>
public class UpdateOrderStatusDto
{
    /// <summary>
    /// Trạng thái mới của đơn hàng
    /// </summary>
    [Required]
    public OrderStatus NewStatus { get; set; }

    /// <summary>
    /// Ghi chú về việc thay đổi trạng thái (tùy chọn)
    /// </summary>
    [StringLength(200, ErrorMessage = "Ghi chú không được vượt quá 200 ký tự")]
    public string? Notes { get; set; }
}