using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using Volo.Abp.DependencyInjection;
using SmartRestaurant.Application.Contracts.Orders;
using SmartRestaurant.Application.Contracts.Orders.Dto;
using SmartRestaurant.HttpApi.Host.Hubs;
using SmartRestaurant.Orders;

namespace SmartRestaurant.HttpApi.Host.Services;

/// <summary>
/// Đơn giản hóa OrderNotificationService - chỉ gửi thông báo đến Kitchen khi có order mới từ mobile
/// </summary>
public class OrderNotificationService : IOrderNotificationService, ITransientDependency
{
    private readonly IHubContext<KitchenHub> _kitchenHubContext;

    public OrderNotificationService(IHubContext<KitchenHub> kitchenHubContext)
    {
        _kitchenHubContext = kitchenHubContext;
    }

    public async Task NotifyNewOrderAsync(OrderDto orderDto)
    {
        try
        {
            Console.WriteLine($"🔔 OrderNotificationService: Sending notification for order #{orderDto.OrderNumber}");

            // Chỉ gửi thông báo đến bếp khi có order mới từ mobile
            await _kitchenHubContext.Clients.Group("Kitchen").SendAsync("NewOrderReceived", new
            {
                Order = orderDto,
                NotifiedAt = DateTime.UtcNow,
                Message = $"Có đơn hàng mới từ {orderDto.TableName}"
            });

            Console.WriteLine($"✅ OrderNotificationService: Successfully sent notification for order #{orderDto.OrderNumber}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ OrderNotificationService: Error sending notification - {ex.Message}");
            Console.WriteLine($"❌ OrderNotificationService: Exception type: {ex.GetType().Name}");
            Console.WriteLine($"❌ OrderNotificationService: Stack trace: {ex.StackTrace}");
        }
    }

    // Đơn giản hóa - không cần các method khác, chỉ cần NotifyNewOrderAsync
    public async Task NotifyOrderStatusChangedAsync(Guid orderId, string orderNumber, OrderStatus newStatus, Guid? tableId = null)
    {
        // Không thực hiện gì - đã đơn giản hóa
        await Task.CompletedTask;
    }

    public async Task NotifyOrderReadyAsync(OrderDto orderDto)
    {
        // Không thực hiện gì - đã đơn giản hóa
        await Task.CompletedTask;
    }

    public async Task NotifyOrderServedAsync(OrderItemServedNotificationDto dto)
    {
        try
        {
            Console.WriteLine($"🔔 OrderNotificationService: Sending order served notification for {dto.TableName}");

            await _kitchenHubContext.Clients.Group("Kitchen").SendAsync("OrderItemServed", new
            {
                dto.OrderId,
                dto.OrderNumber,
                dto.MenuItemName,
                dto.Quantity,
                dto.TableName,
                dto.TableId,
                ServedAt = DateTime.UtcNow,
                Message = $"{dto.TableName} {dto.Quantity} {dto.MenuItemName} đã được phục vụ"
            });

            Console.WriteLine($"✅ OrderNotificationService: Successfully sent order served notification for {dto.TableName}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ OrderNotificationService: Error sending order served notification - {ex.Message}");
        }
    }

    public async Task NotifyKitchenNewOrderAsync(OrderDto orderDto)
    {
        // Gọi lại NotifyNewOrderAsync để tránh duplicate code
        await NotifyNewOrderAsync(orderDto);
    }

    public async Task NotifyOrderItemStatusUpdatedAsync(Guid orderItemId, int newStatus)
    {
        try
        {
            Console.WriteLine($"🔔 OrderNotificationService: Sending order item status update for {orderItemId} to status {newStatus}");

            await _kitchenHubContext.Clients.Group("Kitchen").SendAsync("OrderItemStatusUpdated", new
            {
                OrderItemId = orderItemId,
                NewStatus = newStatus,
                UpdatedAt = DateTime.UtcNow,
                Message = $"Trạng thái món ăn đã được cập nhật thành {(OrderItemStatus)newStatus}"
            });

            Console.WriteLine($"✅ OrderNotificationService: Successfully sent order item status update notification");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ OrderNotificationService: Error sending order item status update notification - {ex.Message}");
        }
    }

    public async Task NotifyOrderItemQuantityUpdatedAsync(OrderItemQuantityUpdateNotificationDto dto)
    {
        try
        {
            Console.WriteLine($"🔔 OrderNotificationService: Sending quantity update notification for table {dto.TableName}");

            await _kitchenHubContext.Clients.Group("Kitchen").SendAsync("OrderItemQuantityUpdated", new
            {
                dto.TableName,
                dto.OrderItemId,
                dto.MenuItemName,
                dto.NewQuantity,
                UpdatedAt = DateTime.UtcNow,
                Message = $"{dto.TableName} đã cập nhật {dto.MenuItemName} thành {dto.NewQuantity}"
            });

            Console.WriteLine($"✅ OrderNotificationService: Successfully sent quantity update notification for table {dto.TableName}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ OrderNotificationService: Error sending quantity update notification - {ex.Message}");
        }
    }

    public async Task NotifyOrderItemsAddedAsync(OrderItemsAddedNotificationDto dto)
    {
        try
        {
            Console.WriteLine($"🔔 OrderNotificationService: Sending add items notification for table {dto.TableName}");

            await _kitchenHubContext.Clients.Group("Kitchen").SendAsync("OrderItemsAdded", new
            {
                dto.TableName,
                dto.AddedItemsDetail,
                AddedAt = DateTime.UtcNow,
                Message = $"{dto.TableName} đã thêm {dto.AddedItemsDetail}"
            });

            Console.WriteLine($"✅ OrderNotificationService: Successfully sent add items notification for table {dto.TableName}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ OrderNotificationService: Error sending add items notification - {ex.Message}");
        }
    }

    public async Task NotifyOrderItemRemovedAsync(OrderItemRemovedNotificationDto dto)
    {
        try
        {
            Console.WriteLine($"🔔 OrderNotificationService: Sending remove item notification for table {dto.TableName}");

            await _kitchenHubContext.Clients.Group("Kitchen").SendAsync("OrderItemRemoved", new
            {
                dto.TableName,
                dto.OrderItemId,
                dto.MenuItemName,
                dto.Quantity,
                RemovedAt = DateTime.UtcNow,
                Message = $"{dto.TableName} đã xóa {dto.Quantity} {dto.MenuItemName}"
            });

            Console.WriteLine($"✅ OrderNotificationService: Successfully sent remove item notification for table {dto.TableName}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ OrderNotificationService: Error sending remove item notification - {ex.Message}");
        }
    }
}