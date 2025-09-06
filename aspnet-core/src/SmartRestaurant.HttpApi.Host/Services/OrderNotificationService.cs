using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using Volo.Abp.DependencyInjection;
using SmartRestaurant.Application.Contracts.Orders;
using SmartRestaurant.Application.Contracts.Orders.Dto;
using SmartRestaurant.Application.Contracts.Common;
using SmartRestaurant.HttpApi.Host.Hubs;
using SmartRestaurant.Orders;

namespace SmartRestaurant.HttpApi.Host.Services;

/// <summary>
/// Implementation của IOrderNotificationService sử dụng SignalR
/// Gửi thông báo thời gian thực về trạng thái đơn hàng
/// </summary>
public class OrderNotificationService : IOrderNotificationService, ITransientDependency
{
    private readonly IHubContext<KitchenHub> _kitchenHubContext;
    private readonly IHubContext<OrderStatusHub> _orderStatusHubContext;
    private readonly IHubContext<TableManagementHub> _tableManagementHubContext;

    public OrderNotificationService(
        IHubContext<KitchenHub> kitchenHubContext,
        IHubContext<OrderStatusHub> orderStatusHubContext,
        IHubContext<TableManagementHub> tableManagementHubContext)
    {
        _kitchenHubContext = kitchenHubContext;
        _orderStatusHubContext = orderStatusHubContext;
        _tableManagementHubContext = tableManagementHubContext;
    }

    public async Task NotifyNewOrderAsync(OrderDto orderDto)
    {
        // Thông báo đến nhân viên phục vụ
        await _orderStatusHubContext.Clients.Group("Waitstaff").SendAsync("NewOrderCreated", new
        {
            Order = orderDto,
            CreatedAt = DateTime.UtcNow,
            Message = $"Đơn hàng mới #{orderDto.OrderNumber} đã được tạo"
        });

        // Nếu có bàn, thông báo đến nhóm bàn cụ thể
        if (orderDto.TableId.HasValue)
        {
            await _orderStatusHubContext.Clients.Group($"Table_{orderDto.TableId.Value}")
                .SendAsync("NewOrderCreated", new
                {
                    Order = orderDto,
                    CreatedAt = DateTime.UtcNow,
                    Message = $"Đơn hàng mới #{orderDto.OrderNumber} cho bàn {orderDto.TableName}"
                });
        }
    }

    public async Task NotifyOrderStatusChangedAsync(Guid orderId, string orderNumber, OrderStatus newStatus, Guid? tableId = null)
    {
        var statusMessage = GetStatusMessage(newStatus);
        var updateInfo = new
        {
            OrderId = orderId,
            OrderNumber = orderNumber,
            Status = newStatus,
            StatusDisplay = statusMessage,
            UpdatedAt = DateTime.UtcNow,
            Message = $"Đơn hàng #{orderNumber} {statusMessage}"
        };

        // Thông báo đến tất cả nhân viên
        await _orderStatusHubContext.Clients.Group("Waitstaff").SendAsync("OrderStatusChanged", updateInfo);

        // Nếu có bàn, thông báo đến nhóm bàn cụ thể
        if (tableId.HasValue)
        {
            await _orderStatusHubContext.Clients.Group($"Table_{tableId.Value}").SendAsync("OrderStatusChanged", updateInfo);
        }
    }

    public async Task NotifyOrderReadyAsync(OrderDto orderDto)
    {
        var notificationInfo = new
        {
            Order = orderDto,
            ReadyAt = DateTime.UtcNow,
            Message = $"Đơn hàng #{orderDto.OrderNumber} sẵn sàng phục vụ!",
            Priority = "High" // Đánh dấu ưu tiên cao
        };

        await _orderStatusHubContext.Clients.Group("Waitstaff").SendAsync("OrderReady", notificationInfo);

        // Thông báo riêng cho bàn nếu có
        if (orderDto.TableId.HasValue)
        {
            await _orderStatusHubContext.Clients.Group($"Table_{orderDto.TableId.Value}")
                .SendAsync("OrderReady", notificationInfo);
        }
    }

    public async Task NotifyOrderServedAsync(Guid orderId, string orderNumber, Guid? tableId = null)
    {
        var servedInfo = new
        {
            OrderId = orderId,
            OrderNumber = orderNumber,
            ServedAt = DateTime.UtcNow,
            Message = $"Đơn hàng #{orderNumber} đã được phục vụ"
        };

        await _orderStatusHubContext.Clients.Group("Waitstaff").SendAsync("OrderServed", servedInfo);

        if (tableId.HasValue)
        {
            await _orderStatusHubContext.Clients.Group($"Table_{tableId.Value}").SendAsync("OrderServed", servedInfo);
        }
    }

    public async Task NotifyKitchenNewOrderAsync(OrderDto orderDto)
    {
        await _kitchenHubContext.Clients.Group("Kitchen").SendAsync("NewOrderReceived", new
        {
            Order = orderDto,
            NotifiedAt = DateTime.UtcNow,
            Message = $"Đơn hàng mới #{orderDto.OrderNumber} cần chuẩn bị"
        });
    }

    public async Task NotifyOrderItemStatusUpdatedAsync(Guid orderItemId, int newStatus)
    {
        // Phát sóng cập nhật trạng thái đến tất cả client trong nhóm Kitchen
        await _kitchenHubContext.Clients.Group("Kitchen").SendAsync("OrderItemStatusUpdated", new
        {
            OrderItemId = orderItemId,
            Status = newStatus,
            UpdatedAt = DateTime.UtcNow
        });
    }

    /// <summary>
    /// Lấy thông điệp trạng thái tiếng Việt
    /// </summary>
    private static string GetStatusMessage(OrderStatus status)
    {
        return GlobalEnums.GetOrderStatusDisplayName(status);
    }
}