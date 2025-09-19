using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Logging;
using SmartRestaurant.Kitchen.Dtos;
using SmartRestaurant.Permissions;
using SmartRestaurant.Application.Contracts.Orders;
using SmartRestaurant.Application.Contracts.Orders.Dto;
using SmartRestaurant.Orders;
using Volo.Abp.Application.Services;

namespace SmartRestaurant.Kitchen
{
    /// <summary>
    /// Application Service for Kitchen Dashboard operations
    /// Handles cooking order management and priority calculation
    /// </summary>
    [Authorize(SmartRestaurantPermissions.Kitchen.Default)]
    public class KitchenDashboardAppService : ApplicationService, IKitchenDashboardAppService
    {
        private readonly KitchenPriorityManager _kitchenPriorityManager;
        private readonly IOrderNotificationService _notificationService;
        private readonly IOrderRepository _orderRepository;

        public KitchenDashboardAppService(
            KitchenPriorityManager kitchenPriorityManager,
            IOrderNotificationService notificationService,
            IOrderRepository orderRepository)
        {
            _kitchenPriorityManager = kitchenPriorityManager;
            _notificationService = notificationService;
            _orderRepository = orderRepository;
        }

        /// <summary>
        /// Lấy danh sách món cần nấu được group theo bàn
        /// Hiển thị theo format organized cho Kitchen Dashboard
        /// </summary>
        /// <returns>Danh sách bàn với các món cần nấu</returns>
        public virtual async Task<List<KitchenTableGroupDto>> GetCookingOrdersGroupedAsync()
        {
            Logger.LogInformation("Getting cooking orders grouped by table for kitchen dashboard");

            var groupedItems = await _kitchenPriorityManager.GetKitchenDashboardGroupedAsync();

            Logger.LogInformation("Found {ItemCount} items grouped into {TableCount} tables", 
                groupedItems.Sum(g => g.TotalItems), groupedItems.Count);
            
            return groupedItems;
        }


        /// <summary>
        /// Cập nhật trạng thái món ăn từ kitchen dashboard
        /// Chỉ cho phép cập nhật các trạng thái liên quan đến bếp
        /// </summary>
        /// <param name="input">Thông tin cập nhật trạng thái</param>
        [Authorize(SmartRestaurantPermissions.Kitchen.UpdateStatus)]
        public virtual async Task UpdateOrderItemStatusAsync(UpdateOrderItemStatusInput input)
        {
            Logger.LogInformation("Kitchen Dashboard updating OrderItem {OrderItemId} status to {Status}", 
                input.OrderItemId, input.Status);

            // Sử dụng KitchenPriorityManager để cập nhật trạng thái (kitchen-specific logic)
            await _kitchenPriorityManager.UpdateOrderItemStatusAsync(input.OrderItemId, input.Status);

            // Gửi notification đến mobile khi trạng thái thay đổi
            await SendStatusUpdateNotification(input.OrderItemId, input.Status);

            Logger.LogInformation("Successfully updated OrderItem {OrderItemId} status to {Status}", 
                input.OrderItemId, input.Status);
        }

        /// <summary>
        /// Gửi notification khi kitchen cập nhật trạng thái món ăn
        /// </summary>
        private async Task SendStatusUpdateNotification(Guid orderItemId, OrderItemStatus newStatus)
        {
            try
            {
                // Lấy thông tin order item từ tất cả orders
                var orders = await _orderRepository.GetListAsync();
                OrderItem? orderItem = null;
                Order? parentOrder = null;

                foreach (var order in orders)
                {
                    var item = order.OrderItems.FirstOrDefault(oi => oi.Id == orderItemId);
                    if (item != null)
                    {
                        orderItem = item;
                        parentOrder = order;
                        break;
                    }
                }

                if (orderItem == null || parentOrder == null)
                {
                    Logger.LogWarning("OrderItem {OrderItemId} not found for notification", orderItemId);
                    return;
                }

                // Gửi notification tùy theo trạng thái
                switch (newStatus)
                {
                    case OrderItemStatus.Preparing:
                    case OrderItemStatus.Ready:
                        // Gửi notification cho status updates khác
                        await _notificationService.NotifyOrderItemStatusUpdatedAsync(orderItemId, (int)newStatus);
                        Logger.LogInformation("🔔 Sent OrderItemStatusUpdated notification for {MenuItemName} status: {Status}", 
                            orderItem.MenuItemName, newStatus);
                        Console.WriteLine($"🔔 KitchenDashboard: Sent status update for {orderItem.MenuItemName} to {newStatus}");
                        break;
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex, "Error sending notification for OrderItem {OrderItemId} status update", orderItemId);
                Console.WriteLine($"❌ KitchenDashboard: Error sending notification - {ex.Message}");
                // Don't throw - notification failure shouldn't block status update
            }
        }

        /// <summary>
        /// Lấy thống kê tổng quan cho kitchen dashboard
        /// </summary>
        /// <returns>Thống kê cooking operations</returns>
        public virtual async Task<CookingStatsDto> GetCookingStatsAsync()
        {
            Logger.LogInformation("Getting cooking statistics for dashboard");

            var cookingItems = await _kitchenPriorityManager.GetPriorizedOrderItemsAsync();
            
            // Group by table để tính EmptyTablesCount và LongestWaitingTable
            var tableGroups = cookingItems
                .GroupBy(item => item.TableNumber)
                .ToList();

            var stats = new CookingStatsDto
            {
                TotalCookingItems = cookingItems.Count,
                QuickCookItemsCount = cookingItems.Count(item => item.IsQuickCook),
                EmptyTablesCount = tableGroups.Count(group => group.Count() <= 1),
                AverageWaitingTime = cookingItems.Count > 0
                    ? cookingItems.Average(item => (DateTime.UtcNow - item.OrderTime).TotalMinutes)
                    : 0,
                HighPriorityItemsCount = cookingItems.Count(item => (DateTime.UtcNow - item.OrderTime).TotalMinutes > 20),
                CriticalItemsCount = cookingItems.Count(item => (DateTime.UtcNow - item.OrderTime).TotalMinutes > 30),
                HighestPriorityScore = cookingItems.Count > 0 ? cookingItems.Max(item => item.PriorityScore) : 0,
                LongestWaitingTable = cookingItems.Count > 0
                    ? tableGroups.OrderByDescending(group => group.Min(item => item.OrderTime))
                        .First().Key
                    : null
            };

            Logger.LogInformation("Cooking stats: Total={Total}, QuickCook={QuickCook}, EmptyTables={EmptyTables}", 
                stats.TotalCookingItems, stats.QuickCookItemsCount, stats.EmptyTablesCount);

            return stats;
        }
    }
}