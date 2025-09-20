using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using SmartRestaurant.EntityFrameworkCore;
using SmartRestaurant.Orders;
using Volo.Abp.Domain.Repositories.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;

namespace SmartRestaurant.EntityFrameworkCore.Orders
{
    /// <summary>
    /// Entity Framework Core implementation của IOrderRepository
    /// </summary>
    public class EfCoreOrderRepository : EfCoreRepository<SmartRestaurantDbContext, Order, Guid>, IOrderRepository
    {
        public EfCoreOrderRepository(IDbContextProvider<SmartRestaurantDbContext> dbContextProvider)
            : base(dbContextProvider)
        {
        }


        /// <summary>
        /// Lấy đơn hàng đầy đủ thông tin bao gồm OrderItems và MenuItem
        /// </summary>
        public async Task<Order?> GetWithDetailsAsync(
            Guid orderId,
            CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            return await dbSet
                .Include(o => o.Table)
                .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.MenuItem)
                .Where(o => o.Id == orderId)
                .FirstOrDefaultAsync(GetCancellationToken(cancellationToken));
        }


        /// <summary>
        /// Đếm số đơn hàng theo ngày
        /// </summary>
        public async Task<int> CountOrdersByDateAsync(
            DateTime date,
            CancellationToken cancellationToken = default)
        {
            var startOfDay = date.Date;
            var endOfDay = startOfDay.AddDays(1);

            var dbSet = await GetDbSetAsync();
            return await dbSet
                .Where(o => o.CreationTime >= startOfDay && o.CreationTime < endOfDay)
                .CountAsync(GetCancellationToken(cancellationToken));
        }


        /// <summary>
        /// Lấy danh sách đơn hàng đang hoạt động của một bàn cụ thể
        /// </summary>
        public async Task<List<Order>> GetActiveOrdersByTableIdAsync(
            Guid tableId,
            bool includeOrderItems = false,
            CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            var query = dbSet.Where(o => o.TableId == tableId && o.Status != OrderStatus.Paid);

            if (includeOrderItems)
            {
                query = query.Include(o => o.OrderItems);
            }

            return await query
                .OrderBy(o => o.CreationTime)
                .ToListAsync(GetCancellationToken(cancellationToken));
        }


        /// <summary>
        /// Lấy đơn hàng với đầy đủ thông tin để thanh toán
        /// </summary>
        public async Task<Order?> GetOrderForPaymentAsync(
            Guid orderId,
            CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            return await dbSet
                .Include(o => o.OrderItems)
                .Include(o => o.Table)
                .FirstOrDefaultAsync(o => o.Id == orderId, GetCancellationToken(cancellationToken));
        }

        /// <summary>
        /// Lấy đơn hàng chứa OrderItem cụ thể
        /// </summary>
        public async Task<Order?> GetByOrderItemIdAsync(
            Guid orderItemId,
            CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            return await dbSet
                .Include(o => o.Table)
                .Include(o => o.OrderItems)
                    .ThenInclude(o => o.MenuItem)
                .FirstOrDefaultAsync(o => o.OrderItems.Any(oi => oi.Id == orderItemId), 
                    GetCancellationToken(cancellationToken));
        }

        /// <summary>
        /// Lấy tất cả đơn hàng đang hoạt động (Serving) với đầy đủ thông tin
        /// Bao gồm: OrderItems, MenuItem, và Table để phục vụ Kitchen Priority Dashboard
        /// </summary>
        public async Task<List<Order>> GetActiveOrdersWithDetailsAsync(
            CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            return await dbSet
                .Where(o => o.Status == OrderStatus.Serving)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.MenuItem) // Include MenuItem cho mỗi OrderItem
                .Include(o => o.Table) // Include Table information
                .OrderBy(o => o.CreationTime)
                .ToListAsync(GetCancellationToken(cancellationToken));
        }

        /// <summary>
        /// Lấy danh sách đơn hàng takeaway trong ngày hôm nay
        /// </summary>
        public async Task<List<Order>> GetTakeawayOrdersTodayAsync(
            OrderStatus? status = null,
            CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            var today = DateTime.Today;
            var tomorrow = today.AddDays(1);

            return await dbSet
                .Where(o => o.OrderType == OrderType.Takeaway)
                .Where(o => o.CreationTime >= today && o.CreationTime < tomorrow)
                .WhereIf(status.HasValue, o => o.Status == status!.Value)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.MenuItem)
                .OrderBy(o => o.CreationTime)
                .ToListAsync(GetCancellationToken(cancellationToken));
        }

        /// <summary>
        /// Lấy danh sách đơn hàng với filtering chung (unified method)
        /// </summary>
        public async Task<List<Order>> GetOrdersAsync(
            OrderType? orderTypeFilter = null,
            OrderStatus? statusFilter = null,
            DateTime? date = null,
            string? searchText = null,
            CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            var targetDate = date ?? DateTime.Today;
            var nextDay = targetDate.AddDays(1);

            var searchLower = searchText?.ToLower();

            return await dbSet
                .WhereIf(orderTypeFilter.HasValue, o => o.OrderType == orderTypeFilter!.Value)
                .WhereIf(statusFilter.HasValue, o => o.Status == statusFilter!.Value)
                .Where(o => o.CreationTime >= targetDate && o.CreationTime < nextDay)
                .WhereIf(!string.IsNullOrWhiteSpace(searchText), o => 
                    (o.CustomerName != null && o.CustomerName.ToLower().Contains(searchLower!)) ||
                    (o.CustomerPhone != null && o.CustomerPhone.Contains(searchLower!)) ||
                    (o.Table != null && o.Table.TableNumber.ToLower().Contains(searchLower!)) ||
                    o.OrderNumber.ToLower().Contains(searchLower!)
                )
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.MenuItem)
                .Include(o => o.Table)
                .Include(o => o.Payment)
                .OrderByDescending(o => o.CreationTime)
                .ToListAsync(GetCancellationToken(cancellationToken));
        }

    }
}