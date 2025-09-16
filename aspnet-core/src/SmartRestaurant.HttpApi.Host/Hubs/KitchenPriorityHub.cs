using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using SmartRestaurant.Permissions;

namespace SmartRestaurant.Hubs
{
    /// <summary>
    /// SignalR Hub for Kitchen Priority Management
    /// Handles real-time communication for kitchen dashboard updates
    /// </summary>
    [Authorize(SmartRestaurantPermissions.Kitchen.Default)]
    public class KitchenPriorityHub : Hub
    {
        private readonly ILogger<KitchenPriorityHub> _logger;

        public KitchenPriorityHub(ILogger<KitchenPriorityHub> logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// Kết nối client vào nhóm kitchen station cụ thể
        /// </summary>
        /// <param name="station">Kitchen station (General, Hotpot, Grilled, etc.)</param>
        public async Task JoinKitchenStation(string station)
        {
            var groupName = $"KitchenStation_{station}";
            await Groups.AddToGroupAsync(Context.ConnectionId, groupName);
            
            _logger.LogInformation("Connection {ConnectionId} joined kitchen station group: {Station}", 
                Context.ConnectionId, station);
        }

        /// <summary>
        /// Rời khỏi nhóm kitchen station
        /// </summary>
        /// <param name="station">Kitchen station cần rời khỏi</param>
        public async Task LeaveKitchenStation(string station)
        {
            var groupName = $"KitchenStation_{station}";
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, groupName);
            
            _logger.LogInformation("Connection {ConnectionId} left kitchen station group: {Station}", 
                Context.ConnectionId, station);
        }

        /// <summary>
        /// Thông báo cho tất cả kitchen stations về order status changed
        /// </summary>
        /// <param name="orderItemId">ID của OrderItem được cập nhật</param>
        /// <param name="newStatus">Trạng thái mới</param>
        /// <param name="tableNumber">Số bàn</param>
        public async Task NotifyOrderStatusChanged(string orderItemId, string newStatus, string tableNumber)
        {
            _logger.LogInformation("Broadcasting order status change: OrderItem {OrderItemId} -> {Status} (Table {Table})", 
                orderItemId, newStatus, tableNumber);

            await Clients.Group("AllKitchens").SendAsync("OrderStatusChanged", new
            {
                OrderItemId = orderItemId,
                Status = newStatus,
                TableNumber = tableNumber,
                Timestamp = System.DateTime.UtcNow
            });
        }

        /// <summary>
        /// Thông báo về order mới cần nấu
        /// </summary>
        /// <param name="orderItemId">ID của OrderItem mới</param>
        /// <param name="menuItemName">Tên món ăn</param>
        /// <param name="tableNumber">Số bàn</param>
        /// <param name="isQuickCook">Có phải món nấu nhanh không</param>
        /// <param name="priorityScore">Điểm ưu tiên</param>
        public async Task NotifyNewOrderReceived(string orderItemId, string menuItemName, string tableNumber, 
            bool isQuickCook, int priorityScore)
        {
            _logger.LogInformation("Broadcasting new cooking order: {MenuItem} for Table {Table} (Priority: {Priority})", 
                menuItemName, tableNumber, priorityScore);

            await Clients.Group("AllKitchens").SendAsync("NewOrderReceived", new
            {
                OrderItemId = orderItemId,
                MenuItemName = menuItemName,
                TableNumber = tableNumber,
                IsQuickCook = isQuickCook,
                PriorityScore = priorityScore,
                Timestamp = System.DateTime.UtcNow
            });
        }

        /// <summary>
        /// Thông báo cập nhật priority score cho tất cả items
        /// </summary>
        public async Task NotifyPriorityRecalculated()
        {
            _logger.LogInformation("Broadcasting priority recalculation notification");

            await Clients.Group("AllKitchens").SendAsync("PriorityRecalculated", new
            {
                Message = "Priority scores have been recalculated",
                Timestamp = System.DateTime.UtcNow
            });
        }

        /// <summary>
        /// Khi client kết nối
        /// </summary>
        public override async Task OnConnectedAsync()
        {
            // Tự động join vào nhóm chung cho tất cả kitchen
            await Groups.AddToGroupAsync(Context.ConnectionId, "AllKitchens");
            
            _logger.LogInformation("Kitchen client connected: {ConnectionId}", Context.ConnectionId);
            
            await base.OnConnectedAsync();
        }

        /// <summary>
        /// Khi client ngắt kết nối
        /// </summary>
        /// <param name="exception">Exception nếu có</param>
        public override async Task OnDisconnectedAsync(System.Exception? exception)
        {
            _logger.LogInformation("Kitchen client disconnected: {ConnectionId}. Exception: {Exception}", 
                Context.ConnectionId, exception?.Message);
            
            await base.OnDisconnectedAsync(exception);
        }
    }
}