using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using SmartRestaurant.Application.Contracts.Orders.Dto;

namespace SmartRestaurant.HttpApi.Host.Hubs;

/// <summary>
/// SignalR Hub đơn giản cho thông báo đơn hàng mới từ mobile đến bếp
/// </summary>
// [Authorize] // Tạm thời bỏ authorize để test
public class KitchenHub : Hub
{
    private readonly ILogger<KitchenHub> _logger;

    public KitchenHub(ILogger<KitchenHub> logger)
    {
        _logger = logger;
    }

    /// <summary>
    /// Join nhóm kitchen để nhận thông báo đơn hàng mới
    /// </summary>
    public async Task JoinKitchenGroup()
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, "Kitchen");
        _logger.LogInformation("Client {ConnectionId} joined Kitchen group", Context.ConnectionId);
        Console.WriteLine($"👥 KitchenHub: Client {Context.ConnectionId} joined Kitchen group");
        
        // Gửi confirmation message cho client
        await Clients.Caller.SendAsync("JoinedKitchenGroup", new
        {
            ConnectionId = Context.ConnectionId,
            JoinedAt = DateTime.UtcNow,
            Message = "Successfully joined Kitchen group"
        });
    }


    /// <summary>
    /// Xử lý khi client kết nối - tự động join Kitchen group
    /// </summary>
    public override async Task OnConnectedAsync()
    {
        _logger.LogInformation("Kitchen client connected: {ConnectionId}", Context.ConnectionId);
        Console.WriteLine($"🔗 KitchenHub: Client {Context.ConnectionId} connected");
        
        // Tự động join Kitchen group cho tất cả user đã đăng nhập
        await JoinKitchenGroup();
        
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