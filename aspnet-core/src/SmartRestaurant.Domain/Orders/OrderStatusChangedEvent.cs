using System;
using Volo.Abp.Domain.Entities.Events.Distributed;

namespace SmartRestaurant.Orders;

/// <summary>
/// Domain event được kích hoạt khi trạng thái đơn hàng thay đổi
/// Sự kiện này được sử dụng để thông báo đến các hệ thống khác (bếp, mobile app)
/// </summary>
[Serializable]
public class OrderStatusChangedEvent : EtoBase
{
    /// <summary>
    /// ID của đơn hàng
    /// </summary>
    public Guid OrderId { get; set; }

    /// <summary>
    /// Trạng thái cũ
    /// </summary>
    public OrderStatus OldStatus { get; set; }

    /// <summary>
    /// Trạng thái mới
    /// </summary>
    public OrderStatus NewStatus { get; set; }

    /// <summary>
    /// Thời gian thay đổi trạng thái
    /// </summary>
    public DateTime ChangeTime { get; set; }

    /// <summary>
    /// Constructor mặc định cho serialization
    /// </summary>
    public OrderStatusChangedEvent()
    {
        ChangeTime = DateTime.UtcNow;
    }

    /// <summary>
    /// Constructor với tham số
    /// </summary>
    /// <param name="orderId">ID đơn hàng</param>
    /// <param name="oldStatus">Trạng thái cũ</param>
    /// <param name="newStatus">Trạng thái mới</param>
    public OrderStatusChangedEvent(Guid orderId, OrderStatus oldStatus, OrderStatus newStatus)
    {
        OrderId = orderId;
        OldStatus = oldStatus;
        NewStatus = newStatus;
        ChangeTime = DateTime.UtcNow;
    }
}