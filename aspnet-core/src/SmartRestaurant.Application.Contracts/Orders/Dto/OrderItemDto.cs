using System;
using Volo.Abp.Application.Dtos;
using SmartRestaurant.Orders;

namespace SmartRestaurant.Application.Contracts.Orders.Dto;

/// <summary>
/// DTO cho OrderItem entity - dùng để trả về dữ liệu món trong đơn hàng
/// </summary>
public class OrderItemDto : FullAuditedEntityDto<Guid>
{
    /// <summary>
    /// ID của đơn hàng chứa món này
    /// </summary>
    public Guid OrderId { get; set; }

    /// <summary>
    /// ID của món ăn từ menu
    /// </summary>
    public Guid MenuItemId { get; set; }

    /// <summary>
    /// Tên món ăn (snapshot tại thời điểm đặt)
    /// </summary>
    public string MenuItemName { get; set; } = string.Empty;

    /// <summary>
    /// Số lượng món được đặt
    /// </summary>
    public int Quantity { get; set; }

    /// <summary>
    /// Giá đơn vị tại thời điểm đặt hàng (VND)
    /// </summary>
    public decimal UnitPrice { get; set; }

    /// <summary>
    /// Tổng tiền của món này
    /// </summary>
    public decimal TotalPrice => UnitPrice * Quantity;

    /// <summary>
    /// Ghi chú riêng cho món này
    /// </summary>
    public string? Notes { get; set; }

    /// <summary>
    /// Trạng thái chuẩn bị của món này
    /// </summary>
    public OrderItemStatus Status { get; set; }

    /// <summary>
    /// Tên trạng thái để hiển thị UI
    /// </summary>
    public string StatusDisplay { get; set; } = string.Empty;

    /// <summary>
    /// Thời gian bắt đầu chuẩn bị món này
    /// </summary>
    public DateTime? PreparationStartTime { get; set; }

    /// <summary>
    /// Thời gian hoàn thành chuẩn bị món này
    /// </summary>
    public DateTime? PreparationCompleteTime { get; set; }

    /// <summary>
    /// Thời gian chuẩn bị (phút) - nếu đã hoàn thành
    /// </summary>
    public int? PreparationDurationMinutes
    {
        get
        {
            if (PreparationStartTime.HasValue && PreparationCompleteTime.HasValue)
                return (int)(PreparationCompleteTime.Value - PreparationStartTime.Value).TotalMinutes;
            return null;
        }
    }
}