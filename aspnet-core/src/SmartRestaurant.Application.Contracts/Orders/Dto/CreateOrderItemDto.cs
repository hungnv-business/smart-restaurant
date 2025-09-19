using System;
using System.ComponentModel.DataAnnotations;

namespace SmartRestaurant.Application.Contracts.Orders.Dto;

/// <summary>
/// DTO cho việc tạo OrderItem trong đơn hàng
/// </summary>
public class CreateOrderItemDto
{
    /// <summary>
    /// ID của món ăn từ menu
    /// </summary>
    [Required]
    public Guid MenuItemId { get; set; }

    /// <summary>
    /// Tên món ăn (sẽ được lấy từ MenuItem, có thể override)
    /// </summary>
    [Required]
    [StringLength(200, ErrorMessage = "Tên món ăn không được vượt quá 200 ký tự")]
    public string MenuItemName { get; set; } = string.Empty;

    /// <summary>
    /// Số lượng món được đặt
    /// </summary>
    [Required]
    [Range(1, int.MaxValue, ErrorMessage = "Số lượng phải lớn hơn 0")]
    public int Quantity { get; set; } = 1;

    /// <summary>
    /// Giá đơn vị (sẽ được lấy từ MenuItem, có thể override cho discount)
    /// </summary>
    [Required]
    [Range(0, int.MaxValue, ErrorMessage = "Giá không được âm")]
    public int UnitPrice { get; set; }

    /// <summary>
    /// Ghi chú riêng cho món này (ví dụ: "Không cay", "Thêm hành")
    /// </summary>
    [StringLength(300, ErrorMessage = "Ghi chú không được vượt quá 300 ký tự")]
    public string? Notes { get; set; }
}