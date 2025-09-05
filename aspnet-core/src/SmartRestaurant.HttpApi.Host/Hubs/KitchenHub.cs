using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using SmartRestaurant.Application.Contracts.Orders.Dto;

namespace SmartRestaurant.HttpApi.Host.Hubs;

/// <summary>
/// SignalR Hub cho cập nhật đơn hàng bếp thời gian thực
/// Sử dụng để thông báo cho nhân viên bếp về đơn hàng mới và cập nhật trạng thái
/// </summary>
[Authorize]
public class KitchenHub : Hub
{
    private readonly ILogger<KitchenHub> _logger;

    public KitchenHub(ILogger<KitchenHub> logger)
    {
        _logger = logger;
    }

    /// <summary>
    /// Join nhóm kitchen để nhận thông báo đơn hàng
    /// </summary>
    public async Task JoinKitchenGroup()
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, "Kitchen");
    }

    /// <summary>
    /// Leave nhóm kitchen
    /// </summary>
    public async Task LeaveKitchenGroup()
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, "Kitchen");
    }

    /// <summary>
    /// Cập nhật trạng thái món ăn trong đơn hàng
    /// </summary>
    /// <param name="orderItemId">ID món ăn trong đơn hàng</param>
    /// <param name="newStatus">Trạng thái mới</param>
    public async Task UpdateOrderItemStatus(Guid orderItemId, int newStatus)
    {
        // Phát sóng cập nhật trạng thái đến tất cả client trong nhóm Kitchen
        await Clients.Group("Kitchen").SendAsync("OrderItemStatusUpdated", new
        {
            OrderItemId = orderItemId,
            Status = newStatus,
            UpdatedAt = DateTime.UtcNow,
            UpdatedBy = Context.User?.Identity?.Name
        });
    }

    /// <summary>
    /// Thông báo đơn hàng mới đến bếp
    /// </summary>
    /// <param name="orderDto">Thông tin đơn hàng mới</param>
    public async Task NotifyNewOrder(OrderDto orderDto)
    {
        await Clients.Group("Kitchen").SendAsync("NewOrderReceived", new
        {
            Order = orderDto,
            NotifiedAt = DateTime.UtcNow,
            Message = $"Đơn hàng mới #{orderDto.OrderNumber} cần chuẩn bị"
        });
    }

    /// <summary>
    /// Xử lý khi client kết nối
    /// </summary>
    public override async Task OnConnectedAsync()
    {
        // Log connection để debug
        _logger.LogInformation("Kitchen client connected: {ConnectionId}", Context.ConnectionId);
        
        // Tự động join nhóm Kitchen nếu user có quyền
        if (Context.User?.IsInRole("Kitchen") == true || 
            Context.User?.IsInRole("KitchenManager") == true)
        {
            await JoinKitchenGroup();
        }
        
        await base.OnConnectedAsync();
    }

    /// <summary>
    /// Xử lý khi client ngắt kết nối
    /// </summary>
    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        _logger.LogInformation("Kitchen client disconnected: {ConnectionId}", Context.ConnectionId);
        await base.OnDisconnectedAsync(exception);
    }
}