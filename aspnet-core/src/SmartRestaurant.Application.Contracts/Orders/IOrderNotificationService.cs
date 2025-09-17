using System;
using System.Threading.Tasks;
using SmartRestaurant.Application.Contracts.Orders.Dto;
using SmartRestaurant.Orders;

namespace SmartRestaurant.Application.Contracts.Orders;

/// <summary>
/// Interface cho service thông báo trạng thái đơn hàng thời gian thực
/// Được implement bởi SignalR service trong HttpApi.Host layer
/// </summary>
public interface IOrderNotificationService
{
    /// <summary>
    /// Thông báo đơn hàng mới được tạo
    /// </summary>
    /// <param name="orderDto">Thông tin đơn hàng</param>
    Task NotifyNewOrderAsync(OrderDto orderDto);

    /// <summary>
    /// Thông báo trạng thái đơn hàng thay đổi
    /// </summary>
    /// <param name="orderId">ID đơn hàng</param>
    /// <param name="orderNumber">Số đơn hàng</param>
    /// <param name="newStatus">Trạng thái mới</param>
    /// <param name="tableId">ID bàn (optional)</param>
    Task NotifyOrderStatusChangedAsync(Guid orderId, string orderNumber, OrderStatus newStatus, Guid? tableId = null);

    /// <summary>
    /// Thông báo đơn hàng sẵn sàng phục vụ
    /// </summary>
    /// <param name="orderDto">Thông tin đơn hàng</param>
    Task NotifyOrderReadyAsync(OrderDto orderDto);

    /// <summary>
    /// Thông báo món ăn đã được phục vụ
    /// </summary>
    /// <param name="dto">Thông tin chi tiết về món ăn đã được phục vụ</param>
    Task NotifyOrderServedAsync(OrderItemServedNotificationDto dto);

    /// <summary>
    /// Thông báo đơn hàng mới đến bếp
    /// </summary>
    /// <param name="orderDto">Thông tin đơn hàng</param>
    Task NotifyKitchenNewOrderAsync(OrderDto orderDto);

    /// <summary>
    /// Thông báo cập nhật trạng thái món ăn
    /// </summary>
    /// <param name="orderItemId">ID món ăn trong đơn hàng</param>
    /// <param name="newStatus">Trạng thái mới</param>
    Task NotifyOrderItemStatusUpdatedAsync(Guid orderItemId, int newStatus);

    /// <summary>
    /// Thông báo cập nhật số lượng món ăn từ mobile
    /// </summary>
    /// <param name="dto">Thông tin chi tiết về món ăn được cập nhật</param>
    Task NotifyOrderItemQuantityUpdatedAsync(OrderItemQuantityUpdateNotificationDto dto);

    /// <summary>
    /// Thông báo thêm món vào order hiện có từ mobile
    /// </summary>
    /// <param name="dto">Thông tin chi tiết về các món đã thêm</param>
    Task NotifyOrderItemsAddedAsync(OrderItemsAddedNotificationDto dto);

    /// <summary>
    /// Thông báo xóa món khỏi order từ mobile
    /// </summary>
    /// <param name="dto">Thông tin chi tiết về món đã xóa</param>
    Task NotifyOrderItemRemovedAsync(OrderItemRemovedNotificationDto dto);
}