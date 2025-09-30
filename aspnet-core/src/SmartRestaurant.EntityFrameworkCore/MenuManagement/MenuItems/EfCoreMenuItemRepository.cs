using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
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

        if (menuItemIds != null && menuItemIds.Count != 0)
        {
            query = query.Where(x => menuItemIds.Contains(x.MenuItemId));
        }

        var results = await query.ToListAsync();
        return results.ToDictionary(x => x.MenuItemId, x => x.TotalSold);
    }

    /// <summary>
    /// Kiểm tra món ăn có tồn tại và available không
    /// </summary>
    public async Task<bool> IsMenuItemAvailableAsync(
        Guid menuItemId,
        CancellationToken cancellationToken = default)
    {
        var dbSet = await GetDbSetAsync();
        return await dbSet.AnyAsync(m => m.Id == menuItemId && m.IsAvailable == true, cancellationToken);
    }

    /// <summary>
    /// Lấy món ăn kèm theo danh sách nguyên liệu của món đó
    /// </summary>
    public async Task<MenuItem?> GetWithIngredientsAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var dbSet = await GetDbSetAsync();

        return await dbSet
            .Include(m => m.Ingredients) // Eager loading MenuItemIngredients
                .ThenInclude(mi => mi.Ingredient) // Eager loading Ingredient entity
                    .ThenInclude(i => i.Unit) // Eager loading Unit for ingredient
            .FirstOrDefaultAsync(m => m.Id == id, cancellationToken);
    }

    /// <summary>
    /// Lấy menu item với đầy đủ navigation properties (Category, Ingredients)
    /// </summary>
    public async Task<MenuItem?> GetWithDetailsAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var dbSet = await GetDbSetAsync();

        return await dbSet
            .Include(m => m.Category)
            .Include(m => m.Ingredients)
                .ThenInclude(mi => mi.Ingredient)
                    .ThenInclude(i => i.Category)
            .FirstOrDefaultAsync(m => m.Id == id, cancellationToken);
    }

    /// <summary>
    /// Lấy danh sách menu items với navigation properties và phân trang
    /// </summary>
    public async Task<List<MenuItem>> GetListWithDetailsAsync(
        int skipCount,
        int maxResultCount,
        string sorting,
        string? filter = null,
        Guid? categoryId = null,
        bool onlyAvailable = false,
        CancellationToken cancellationToken = default)
    {
        var dbSet = await GetDbSetAsync();

        var query = dbSet
            .Include(m => m.Category)
            .Include(m => m.Ingredients)
            .WhereIf(!string.IsNullOrWhiteSpace(filter), m =>
                m.Name.Contains(filter!) ||
                (m.Description != null && m.Description.Contains(filter!)))
            .WhereIf(categoryId.HasValue, m => m.CategoryId == categoryId!.Value)
            .WhereIf(onlyAvailable, m => m.IsAvailable);

        // Sorting
        query = sorting.ToLowerInvariant() switch
        {
            "name desc" => query.OrderByDescending(m => m.Name),
            "price" => query.OrderBy(m => m.Price),
            "price desc" => query.OrderByDescending(m => m.Price),
            _ => query.OrderBy(m => m.Name)
        };

        return await query
            .Skip(skipCount)
            .Take(maxResultCount)
            .ToListAsync(cancellationToken);
    }

    /// <summary>
    /// Đếm số lượng menu items theo filter
    /// </summary>
    public async Task<int> GetCountAsync(
        string? filter = null,
        Guid? categoryId = null,
        bool onlyAvailable = false,
        CancellationToken cancellationToken = default)
    {
        var dbSet = await GetDbSetAsync();

        return await dbSet
            .WhereIf(!string.IsNullOrWhiteSpace(filter), m =>
                m.Name.Contains(filter!) ||
                (m.Description != null && m.Description.Contains(filter!)))
            .WhereIf(categoryId.HasValue, m => m.CategoryId == categoryId!.Value)
            .WhereIf(onlyAvailable, m => m.IsAvailable)
            .CountAsync(cancellationToken);
    }

    /// <summary>
    /// Lấy danh sách menu items theo category
    /// </summary>
    public async Task<List<MenuItem>> GetByCategoryAsync(
        Guid categoryId,
        bool onlyAvailable = false,
        CancellationToken cancellationToken = default)
    {
        var dbSet = await GetDbSetAsync();

        return await dbSet
            .Include(m => m.Category)
            .Where(m => m.CategoryId == categoryId)
            .WhereIf(onlyAvailable, m => m.IsAvailable)
            .OrderBy(m => m.Name)
            .ToListAsync(cancellationToken);
    }

    /// <summary>
    /// Lấy danh sách menu items phổ biến dựa trên sales data
    /// </summary>
    public async Task<List<MenuItem>> GetPopularMenuItemsAsync(
        int count = 10,
        CancellationToken cancellationToken = default)
    {
        var dbSet = await GetDbSetAsync();
        var dbContext = await GetDbContextAsync();

        var popularMenuItemIds = await (
            from orderItem in dbContext.Set<SmartRestaurant.Orders.OrderItem>()
            join order in dbContext.Set<SmartRestaurant.Orders.Order>()
                on orderItem.OrderId equals order.Id
            where order.Status == SmartRestaurant.Orders.OrderStatus.Paid
            group orderItem by orderItem.MenuItemId into g
            orderby g.Sum(x => x.Quantity) descending
            select g.Key
        ).Take(count).ToListAsync(cancellationToken);

        return await dbSet
            .Include(m => m.Category)
            .Where(m => popularMenuItemIds.Contains(m.Id))
            .ToListAsync(cancellationToken);
    }

    /// <summary>
    /// Kiểm tra menu item có đang được sử dụng không (OrderItem)
    /// </summary>
    public async Task<bool> HasDependenciesAsync(
        Guid id,
        CancellationToken cancellationToken = default)
    {
        var dbContext = await GetDbContextAsync();

        return await dbContext.Set<SmartRestaurant.Orders.OrderItem>()
            .AnyAsync(oi => oi.MenuItemId == id, cancellationToken);
    }

    /// <summary>
    /// Kiểm tra tên menu item có trùng trong category không
    /// </summary>
    public async Task<bool> IsNameExistsInCategoryAsync(
        string name,
        Guid categoryId,
        Guid? excludeId = null,
        CancellationToken cancellationToken = default)
    {
        var dbSet = await GetDbSetAsync();

        return await dbSet
            .Where(m => m.CategoryId == categoryId && m.Name == name)
            .WhereIf(excludeId.HasValue, m => m.Id != excludeId!.Value)
            .AnyAsync(cancellationToken);
    }
}