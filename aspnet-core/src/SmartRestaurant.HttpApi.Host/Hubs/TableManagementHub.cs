using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using SmartRestaurant.TableManagement.Tables;

namespace SmartRestaurant.HttpApi.Host.Hubs;

/// <summary>
/// SignalR Hub cho phát sóng trạng thái bàn thời gian thực
/// Sử dụng để thông báo thay đổi trạng thái bàn cho tất cả nhân viên
/// </summary>
[Authorize]
public class TableManagementHub : Hub
{
    private readonly ILogger<TableManagementHub> _logger;

    public TableManagementHub(ILogger<TableManagementHub> logger)
    {
        _logger = logger;
    }
    /// <summary>
    /// Join nhóm table management để nhận thông báo trạng thái bàn
    /// </summary>
    public async Task JoinTableManagementGroup()
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, "TableManagement");
    }

    /// <summary>
    /// Leave nhóm table management
    /// </summary>
    public async Task LeaveTableManagementGroup()
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, "TableManagement");
    }

    /// <summary>
    /// Join nhóm theo layout section để nhận thông báo chỉ các bàn trong khu vực
    /// </summary>
    /// <param name="layoutSectionId">ID khu vực</param>
    public async Task JoinLayoutSectionGroup(Guid layoutSectionId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"LayoutSection_{layoutSectionId}");
    }

    /// <summary>
    /// Leave nhóm layout section
    /// </summary>
    /// <param name="layoutSectionId">ID khu vực</param>
    public async Task LeaveLayoutSectionGroup(Guid layoutSectionId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"LayoutSection_{layoutSectionId}");
    }

    /// <summary>
    /// Cập nhật trạng thái bàn và phát sóng đến tất cả client
    /// </summary>
    /// <param name="tableId">ID bàn</param>
    /// <param name="newStatus">Trạng thái mới</param>
    /// <param name="layoutSectionId">ID khu vực (optional)</param>
    public async Task UpdateTableStatus(Guid tableId, TableStatus newStatus, Guid? layoutSectionId = null)
    {
        var updateInfo = new
        {
            TableId = tableId,
            Status = newStatus,
            UpdatedAt = DateTime.UtcNow,
            UpdatedBy = Context.User?.Identity?.Name
        };

        // Phát sóng đến tất cả client trong nhóm TableManagement
        await Clients.Group("TableManagement").SendAsync("TableStatusUpdated", updateInfo);

        // Nếu có layout section, phát sóng đến nhóm cụ thể
        if (layoutSectionId.HasValue)
        {
            await Clients.Group($"LayoutSection_{layoutSectionId.Value}")
                .SendAsync("TableStatusUpdated", updateInfo);
        }
    }

    /// <summary>
    /// Thông báo bàn được đặt trước
    /// </summary>
    /// <param name="tableId">ID bàn</param>
    /// <param name="reservationInfo">Thông tin đặt bàn</param>
    public async Task NotifyTableReservation(Guid tableId, object reservationInfo)
    {
        await Clients.Group("TableManagement").SendAsync("TableReserved", new
        {
            TableId = tableId,
            ReservationInfo = reservationInfo,
            NotifiedAt = DateTime.UtcNow,
            Message = "Có đặt bàn mới"
        });
    }

    /// <summary>
    /// Thông báo dọn bàn hoàn thành
    /// </summary>
    /// <param name="tableId">ID bàn</param>
    public async Task NotifyTableCleaned(Guid tableId)
    {
        await Clients.Group("TableManagement").SendAsync("TableCleaned", new
        {
            TableId = tableId,
            CleanedAt = DateTime.UtcNow,
            CleanedBy = Context.User?.Identity?.Name,
            Message = "Bàn đã được dọn dẹp và sẵn sàng phục vụ"
        });
    }

    /// <summary>
    /// Xử lý khi client kết nối
    /// </summary>
    public override async Task OnConnectedAsync()
    {
        _logger.LogInformation("Table management client connected: {ConnectionId}", Context.ConnectionId);
        
        // Tự động join nhóm TableManagement nếu user có quyền
        if (Context.User?.IsInRole("Waiter") == true || 
            Context.User?.IsInRole("Manager") == true ||
            Context.User?.IsInRole("Host") == true)
        {
            await JoinTableManagementGroup();
        }
        
        await base.OnConnectedAsync();
    }

    /// <summary>
    /// Xử lý khi client ngắt kết nối
    /// </summary>
    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        _logger.LogInformation("Table management client disconnected: {ConnectionId}", Context.ConnectionId);
        await base.OnDisconnectedAsync(exception);
    }
}