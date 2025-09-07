using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using SmartRestaurant.MenuManagement.MenuItems;
using Volo.Abp.Domain.Repositories.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;

namespace SmartRestaurant.EntityFrameworkCore.MenuManagement.MenuItems;

/// <summary>
/// Entity Framework Core implementation của IMenuItemRepository
/// </summary>
public class EfCoreMenuItemRepository : EfCoreRepository<SmartRestaurantDbContext, MenuItem, Guid>, IMenuItemRepository
{
    public EfCoreMenuItemRepository(IDbContextProvider<SmartRestaurantDbContext> dbContextProvider)
        : base(dbContextProvider)
    {
    }

    /// <summary>
    /// Lấy danh sách món ăn với filtering theo danh mục
    /// </summary>
    public async Task<List<MenuItem>> GetMenuItemsAsync(
        Guid? categoryId = null,
        bool onlyAvailable = true,
        string? nameFilter = null)
    {
        var dbSet = await GetDbSetAsync();
        
        return await dbSet
            .Include(m => m.Category)
            .WhereIf(onlyAvailable, m => m.IsAvailable == true)
            .WhereIf(categoryId.HasValue, m => m.CategoryId == categoryId!.Value)
            .WhereIf(!string.IsNullOrWhiteSpace(nameFilter), m => 
                m.Name.ToLower().Contains(nameFilter!.Trim().ToLower()) ||
                (m.Description != null && m.Description.ToLower().Contains(nameFilter.Trim().ToLower())))
            .OrderBy(m => m.Name)
            .ToListAsync();
    }

    /// <summary>
    /// Lấy thống kê số lượng bán ra của các món ăn
    /// </summary>
    public async Task<Dictionary<Guid, int>> GetMenuItemSalesDataAsync(List<Guid>? menuItemIds = null)
    {
        var dbContext = await GetDbContextAsync();
        
        var query = from orderItem in dbContext.Set<SmartRestaurant.Orders.OrderItem>()
                    join order in dbContext.Set<SmartRestaurant.Orders.Order>() 
                        on orderItem.OrderId equals order.Id
                    where order.Status == SmartRestaurant.Orders.OrderStatus.Paid
                    group orderItem by orderItem.MenuItemId into g
                    select new { MenuItemId = g.Key, TotalSold = g.Sum(x => x.Quantity) };

        if (menuItemIds != null && menuItemIds.Any())
        {
            query = query.Where(x => menuItemIds.Contains(x.MenuItemId));
        }

        var results = await query.ToListAsync();
        return results.ToDictionary(x => x.MenuItemId, x => x.TotalSold);
    }

    /// <summary>
    /// Kiểm tra món ăn có tồn tại và available không
    /// </summary>
    public async Task<bool> IsMenuItemAvailableAsync(Guid menuItemId)
    {
        var dbSet = await GetDbSetAsync();
        return await dbSet.AnyAsync(m => m.Id == menuItemId && m.IsAvailable == true);
    }
}