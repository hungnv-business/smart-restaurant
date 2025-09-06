using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using SmartRestaurant.Application.Contracts.Orders.Dto;
using SmartRestaurant.Application.Contracts.Common;
using SmartRestaurant.Orders;

namespace SmartRestaurant.HttpApi.Host.Hubs;

/// <summary>
/// SignalR Hub cho thông báo nhân viên về trạng thái đơn hàng
/// Sử dụng để cập nhật thời gian thực trạng thái đơn hàng cho nhân viên phục vụ
/// </summary>
[Authorize]
public class OrderStatusHub : Hub
{
    private readonly ILogger<OrderStatusHub> _logger;

    public OrderStatusHub(ILogger<OrderStatusHub> logger)
    {
        _logger = logger;
    }
    /// <summary>
    /// Join nhóm waitstaff để nhận thông báo trạng thái đơn hàng
    /// </summary>
    public async Task JoinWaitstaffGroup()
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, "Waitstaff");
    }

    /// <summary>
    /// Leave nhóm waitstaff
    /// </summary>
    public async Task LeaveWaitstaffGroup()
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, "Waitstaff");
    }

    /// <summary>
    /// Join nhóm theo bàn để nhận thông báo chỉ đơn hàng của bàn đó
    /// </summary>
    /// <param name="tableId">ID bàn</param>
    public async Task JoinTableGroup(Guid tableId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"Table_{tableId}");
    }

    /// <summary>
    /// Leave nhóm bàn
    /// </summary>
    /// <param name="tableId">ID bàn</param>
    public async Task LeaveTableGroup(Guid tableId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"Table_{tableId}");
    }

    /// <summary>
    /// Thông báo đơn hàng mới được tạo
    /// </summary>
    /// <param name="orderDto">Thông tin đơn hàng</param>
    public async Task NotifyNewOrder(OrderDto orderDto)
    {
        await Clients.Group("Waitstaff").SendAsync("NewOrderCreated", new
        {
            Order = orderDto,
            CreatedAt = DateTime.UtcNow,
            Message = $"Đơn hàng mới #{orderDto.OrderNumber} đã được tạo"
        });

        // Nếu có bàn, thông báo đến nhóm bàn cụ thể
        if (orderDto.TableId.HasValue)
        {
            await Clients.Group($"Table_{orderDto.TableId.Value}")
                .SendAsync("NewOrderCreated", new
                {
                    Order = orderDto,
                    CreatedAt = DateTime.UtcNow,
                    Message = $"Đơn hàng mới #{orderDto.OrderNumber} cho bàn {orderDto.TableName}"
                });
        }
    }

    /// <summary>
    /// Thông báo trạng thái đơn hàng thay đổi
    /// </summary>
    /// <param name="orderId">ID đơn hàng</param>
    /// <param name="orderNumber">Số đơn hàng</param>
    /// <param name="newStatus">Trạng thái mới</param>
    /// <param name="tableId">ID bàn (optional)</param>
    public async Task NotifyOrderStatusChanged(Guid orderId, string orderNumber, OrderStatus newStatus, Guid? tableId = null)
    {
        var statusMessage = GetStatusMessage(newStatus);
        var updateInfo = new
        {
            OrderId = orderId,
            OrderNumber = orderNumber,
            Status = newStatus,
            StatusDisplay = statusMessage,
            UpdatedAt = DateTime.UtcNow,
            UpdatedBy = Context.User?.Identity?.Name,
            Message = $"Đơn hàng #{orderNumber} {statusMessage}"
        };

        // Thông báo đến tất cả nhân viên
        await Clients.Group("Waitstaff").SendAsync("OrderStatusChanged", updateInfo);

        // Nếu có bàn, thông báo đến nhóm bàn cụ thể
        if (tableId.HasValue)
        {
            await Clients.Group($"Table_{tableId.Value}").SendAsync("OrderStatusChanged", updateInfo);
        }
    }

    /// <summary>
    /// Thông báo đơn hàng sẵn sàng phục vụ
    /// </summary>
    /// <param name="orderDto">Thông tin đơn hàng</param>
    public async Task NotifyOrderReady(OrderDto orderDto)
    {
        var notificationInfo = new
        {
            Order = orderDto,
            ReadyAt = DateTime.UtcNow,
            Message = $"Đơn hàng #{orderDto.OrderNumber} sẵn sàng phục vụ!",
            Priority = "High" // Đánh dấu ưu tiên cao
        };

        await Clients.Group("Waitstaff").SendAsync("OrderReady", notificationInfo);

        // Thông báo riêng cho bàn nếu có
        if (orderDto.TableId.HasValue)
        {
            await Clients.Group($"Table_{orderDto.TableId.Value}")
                .SendAsync("OrderReady", notificationInfo);
        }
    }

    /// <summary>
    /// Thông báo đơn hàng đã được phục vụ
    /// </summary>
    /// <param name="orderId">ID đơn hàng</param>
    /// <param name="orderNumber">Số đơn hàng</param>
    /// <param name="tableId">ID bàn (optional)</param>
    public async Task NotifyOrderServed(Guid orderId, string orderNumber, Guid? tableId = null)
    {
        var servedInfo = new
        {
            OrderId = orderId,
            OrderNumber = orderNumber,
            ServedAt = DateTime.UtcNow,
            ServedBy = Context.User?.Identity?.Name,
            Message = $"Đơn hàng #{orderNumber} đã được phục vụ"
        };

        await Clients.Group("Waitstaff").SendAsync("OrderServed", servedInfo);

        if (tableId.HasValue)
        {
            await Clients.Group($"Table_{tableId.Value}").SendAsync("OrderServed", servedInfo);
        }
    }

    /// <summary>
    /// Lấy thông điệp trạng thái tiếng Việt
    /// </summary>
    private string GetStatusMessage(OrderStatus status)
    {
        return GlobalEnums.GetOrderStatusDisplayName(status);
    }

    /// <summary>
    /// Xử lý khi client kết nối
    /// </summary>
    public override async Task OnConnectedAsync()
    {
        _logger.LogInformation("Order status client connected: {ConnectionId}", Context.ConnectionId);
        
        // Tự động join nhóm Waitstaff nếu user có quyền
        if (Context.User?.IsInRole("Waiter") == true || 
            Context.User?.IsInRole("Manager") == true ||
            Context.User?.IsInRole("Host") == true)
        {
            await JoinWaitstaffGroup();
        }
        
        await base.OnConnectedAsync();
    }

    /// <summary>
    /// Xử lý khi client ngắt kết nối
    /// </summary>
    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        _logger.LogInformation("Order status client disconnected: {ConnectionId}", Context.ConnectionId);
        await base.OnDisconnectedAsync(exception);
    }
}