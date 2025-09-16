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

        // /// <summary>
        // /// Lấy danh sách đơn hàng theo bàn
        // /// </summary>
        // public async Task<List<Order>> GetOrdersByTableIdAsync(
        //     Guid tableId, 
        //     bool includeOrderItems = false,
        //     CancellationToken cancellationToken = default)
        // {
        //     var dbSet = await GetDbSetAsync();
        //     var query = dbSet.Where(o => o.TableId == tableId);

        //     if (includeOrderItems)
        //     {
        //         query = query.Include(o => o.OrderItems);
        //     }

        //     return await query
        //         .OrderBy(o => o.CreationTime)
        //         .ToListAsync(GetCancellationToken(cancellationToken));
        // }

        // /// <summary>
        // /// Lấy danh sách đơn hàng theo trạng thái
        // /// </summary>
        // public async Task<List<Order>> GetOrdersByStatusAsync(
        //     OrderStatus status, 
        //     bool includeOrderItems = false,
        //     CancellationToken cancellationToken = default)
        // {
        //     var dbSet = await GetDbSetAsync();
        //     var query = dbSet.Where(o => o.Status == status);

        //     if (includeOrderItems)
        //     {
        //         query = query.Include(o => o.OrderItems);
        //     }

        //     return await query
        //         .OrderBy(o => o.CreationTime)
        //         .ToListAsync(GetCancellationToken(cancellationToken));
        // }

        // /// <summary>
        // /// Lấy danh sách đơn hàng cho bếp (trạng thái Confirmed và Preparing)
        // /// </summary>
        // public async Task<List<Order>> GetKitchenOrdersAsync(
        //     bool includeOrderItems = true,
        //     CancellationToken cancellationToken = default)
        // {
        //     var dbSet = await GetDbSetAsync();
        //     var query = dbSet.Where(o => 
        //         o.Status == OrderStatus.Serving);

        //     if (includeOrderItems)
        //     {
        //         query = query.Include(o => o.OrderItems);
        //     }

        //     return await query
        //         .OrderBy(o => o.CreationTime)
        //         .ToListAsync(GetCancellationToken(cancellationToken));
        // }

        // /// <summary>
        // /// Lấy đơn hàng theo số đơn hàng
        // /// </summary>
        // public async Task<Order?> GetByOrderNumberAsync(
        //     string orderNumber, 
        //     bool includeOrderItems = false,
        //     CancellationToken cancellationToken = default)
        // {
        //     var dbSet = await GetDbSetAsync();
        //     var query = dbSet.Where(o => o.OrderNumber == orderNumber);

        //     if (includeOrderItems)
        //     {
        //         query = query.Include(o => o.OrderItems);
        //     }

        //     return await query.FirstOrDefaultAsync(GetCancellationToken(cancellationToken));
        // }

        /// <summary>
        /// Lấy đơn hàng đầy đủ thông tin bao gồm OrderItems và MenuItem
        /// </summary>
        public async Task<Order?> GetWithDetailsAsync(
            Guid orderId,
            CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            return await dbSet
                .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.MenuItem)
                .Where(o => o.Id == orderId)
                .FirstOrDefaultAsync(GetCancellationToken(cancellationToken));
        }

        // /// <summary>
        // /// Kiểm tra xem số đơn hàng đã tồn tại chưa
        // /// </summary>
        // public async Task<bool> IsOrderNumberExistsAsync(
        //     string orderNumber, 
        //     Guid? excludeOrderId = null,
        //     CancellationToken cancellationToken = default)
        // {
        //     var dbSet = await GetDbSetAsync();
        //     var query = dbSet.Where(o => o.OrderNumber == orderNumber);

        //     if (excludeOrderId.HasValue)
        //     {
        //         query = query.Where(o => o.Id != excludeOrderId.Value);
        //     }

        //     return await query.AnyAsync(GetCancellationToken(cancellationToken));
        // }

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

        // /// <summary>
        // /// Lấy danh sách đơn hàng đang hoạt động (chưa thanh toán)
        // /// </summary>
        // public async Task<List<Order>> GetActiveOrdersAsync(
        //     bool includeOrderItems = false,
        //     CancellationToken cancellationToken = default)
        // {
        //     var dbSet = await GetDbSetAsync();
        //     var query = dbSet.Where(o => o.Status != OrderStatus.Paid);

        //     if (includeOrderItems)
        //     {
        //         query = query.Include(o => o.OrderItems);
        //     }

        //     return await query
        //         .OrderBy(o => o.CreationTime)
        //         .ToListAsync(GetCancellationToken(cancellationToken));
        // }

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
                .Include(o => o.OrderItems)
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

    }
}