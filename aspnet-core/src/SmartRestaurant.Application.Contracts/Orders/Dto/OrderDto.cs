using System;
using System.Collections.Generic;
using Volo.Abp.Application.Dtos;
using SmartRestaurant.Orders;

namespace SmartRestaurant.Application.Contracts.Orders.Dto;

/// <summary>
/// DTO cho Order entity - dùng để trả về dữ liệu đơn hàng
/// </summary>
public class OrderDto : FullAuditedEntityDto<Guid>
{
    /// <summary>
    /// Số đơn hàng hiển thị (ví dụ: ORD-20250904-001)
    /// </summary>
    public string OrderNumber { get; set; } = string.Empty;

    /// <summary>
    /// ID của bàn được phục vụ (nullable cho takeaway)
    /// </summary>
    public Guid? TableId { get; set; }

    /// <summary>
    /// Tên bàn (để hiển thị, không cần join)
    /// </summary>
    public string? TableName { get; set; }

    /// <summary>
    /// Loại đơn hàng (Ăn tại chỗ/Mang về/Giao hàng)
    /// </summary>
    public OrderType OrderType { get; set; }

    /// <summary>
    /// Trạng thái hiện tại của đơn hàng
    /// </summary>
    public OrderStatus Status { get; set; }

    /// <summary>
    /// Tên trạng thái để hiển thị UI
    /// </summary>
    public string StatusDisplay { get; set; } = string.Empty;

    /// <summary>
    /// Tổng số tiền của đơn hàng (VND)
    /// </summary>
    public decimal TotalAmount { get; set; }

    /// <summary>
    /// Ghi chú chung của khách hàng hoặc nhân viên
    /// </summary>
    public string? Notes { get; set; }

    /// <summary>
    /// Thời gian các trạng thái
    /// </summary>
    public DateTime? ConfirmedTime { get; set; }
    public DateTime? PreparingTime { get; set; }
    public DateTime? ReadyTime { get; set; }
    public DateTime? ServedTime { get; set; }
    public DateTime? PaidTime { get; set; }

    /// <summary>
    /// Danh sách các món trong đơn hàng
    /// </summary>
    public List<OrderItemDto> OrderItems { get; set; } = new();

    /// <summary>
    /// Số lượng món trong đơn hàng
    /// </summary>
    public int ItemCount => OrderItems.Count;

    /// <summary>
    /// Thời gian từ lúc tạo đến hiện tại (phút)
    /// </summary>
    public int ElapsedMinutes => (int)(DateTime.UtcNow - CreationTime).TotalMinutes;
}