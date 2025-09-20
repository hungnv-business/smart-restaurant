using System;
using System.Collections.Generic;
using Volo.Abp.Application.Dtos;
using SmartRestaurant.Orders;

namespace SmartRestaurant.Application.Contracts.Orders.Dto;

/// <summary>
/// DTO cho takeaway orders - chỉ hiển thị thông tin cần thiết cho mobile app
/// </summary>
public class TakeawayOrderDto : EntityDto<Guid>
{
    /// <summary>
    /// Số đơn hàng hiển thị
    /// </summary>
    public string OrderNumber { get; set; } = string.Empty;

    /// <summary>
    /// Tên khách hàng
    /// </summary>
    public string CustomerName { get; set; } = string.Empty;

    /// <summary>
    /// Số điện thoại khách hàng
    /// </summary>
    public string CustomerPhone { get; set; } = string.Empty;

    /// <summary>
    /// Trạng thái đơn hàng takeaway
    /// </summary>
    public TakeawayStatus Status { get; set; }

    /// <summary>
    /// Tên trạng thái để hiển thị
    /// </summary>
    public string StatusDisplay { get; set; } = string.Empty;

    /// <summary>
    /// Tổng số tiền (VND)
    /// </summary>
    public int TotalAmount { get; set; }

    /// <summary>
    /// Ghi chú đơn hàng
    /// </summary>
    public string? Notes { get; set; }

    /// <summary>
    /// Thời gian tạo đơn
    /// </summary>
    public DateTime CreatedTime { get; set; }

    /// <summary>
    /// Thời gian thanh toán
    /// </summary>
    public DateTime? PaymentTime { get; set; }

    /// <summary>
    /// Danh sách món ăn (tên món)
    /// </summary>
    public List<string> ItemNames { get; set; } = new();

    /// <summary>
    /// Số lượng món trong đơn
    /// </summary>
    public int ItemCount { get; set; }

    /// <summary>
    /// Format tổng tiền hiển thị
    /// </summary>
    public string FormattedTotal => $"{TotalAmount:N0}₫";

    /// <summary>
    /// Thời gian tạo đơn format cho hiển thị
    /// </summary>
    public string FormattedOrderTime => CreatedTime.ToString("HH:mm");

    /// <summary>
    /// Thời gian thanh toán format cho hiển thị
    /// </summary>
    public string FormattedPaymentTime => PaymentTime?.ToString("HH:mm") ?? "";
}

/// <summary>
/// DTO cho filter takeaway orders
/// </summary>
public class GetTakeawayOrdersDto
{
    /// <summary>
    /// Filter theo trạng thái (nullable = tất cả)
    /// </summary>
    public TakeawayStatus? StatusFilter { get; set; }
}

/// <summary>
/// Enum trạng thái takeaway order (simplified from OrderStatus)
/// </summary>
public enum TakeawayStatus
{
    /// <summary>
    /// Đang chuẩn bị
    /// </summary>
    Preparing = 0,

    /// <summary>
    /// Sẵn sàng để lấy
    /// </summary>
    Ready = 1,

    /// <summary>
    /// Đã giao/lấy
    /// </summary>
    Delivered = 2
}

/// <summary>
/// Extension methods cho TakeawayStatus
/// </summary>
public static class TakeawayStatusExtensions
{
    public static string GetDisplayName(this TakeawayStatus status)
    {
        return status switch
        {
            TakeawayStatus.Preparing => "Đang chuẩn bị",
            TakeawayStatus.Ready => "Sẵn sàng",
            TakeawayStatus.Delivered => "Đã giao",
            _ => status.ToString()
        };
    }

    public static string GetColorHex(this TakeawayStatus status)
    {
        return status switch
        {
            TakeawayStatus.Preparing => "#FF9800", // Orange
            TakeawayStatus.Ready => "#4CAF50",     // Green
            TakeawayStatus.Delivered => "#9E9E9E", // Grey
            _ => "#6C757D"
        };
    }
}