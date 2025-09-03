using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using SmartRestaurant.InventoryManagement.Ingredients;
using Volo.Abp.Domain.Repositories.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;
using System.Linq.Dynamic.Core;

namespace SmartRestaurant.EntityFrameworkCore.InventoryManagement.Ingredients
{
    public class EfCoreIngredientRepository : EfCoreRepository<SmartRestaurantDbContext, Ingredient, Guid>, IIngredientRepository
    {
        public EfCoreIngredientRepository(IDbContextProvider<SmartRestaurantDbContext> dbContextProvider)
            : base(dbContextProvider)
        {
        }

        public async Task<Ingredient?> GetWithDetailsAsync(Guid id, CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            return await dbSet
                .Include(x => x.Category)
                .Include(x => x.Unit)
                .Include(x => x.PurchaseUnits.OrderByDescending(e => e.IsBaseUnit).ThenBy(e => e.DisplayOrder))
                .ThenInclude(x => x.Unit)
                .FirstOrDefaultAsync(x => x.Id == id, GetCancellationToken(cancellationToken));
        }

        public async Task<List<Ingredient>> GetListWithDetailsAsync(
            int skipCount,
            int maxResultCount,
            string sorting,
            string? filter = null,
            Guid? categoryId = null,
            bool includeInactive = false,
            CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            var query = dbSet
                .Include(x => x.Category)
                .Include(x => x.Unit)
                .Include(x => x.PurchaseUnits.OrderByDescending(e => e.IsBaseUnit).ThenBy(e => e.DisplayOrder))
                .ThenInclude(x => x.Unit)
                .AsQueryable();

            if (filter != null)
            {
                filter = filter.Trim().ToLower();
            }

            // Apply filters
            query = query
                .WhereIf(!string.IsNullOrWhiteSpace(filter), x => x.Name.Contains(filter!))
                .WhereIf(categoryId.HasValue, x => x.CategoryId == categoryId!.Value)
                .WhereIf(!includeInactive, x => x.IsActive);

            // Apply sorting
            if (!string.IsNullOrEmpty(sorting))
            {
                query = query.OrderBy(sorting);
            }
            else
            {
                query = query.OrderBy(x => x.Name);
            }

            // Apply paging
            return await query
                .Skip(skipCount)
                .Take(maxResultCount)
                .ToListAsync(GetCancellationToken(cancellationToken));
        }

        public async Task<int> GetCountAsync(
            string? filter = null,
            Guid? categoryId = null,
            bool includeInactive = false,
            CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            var query = dbSet.AsQueryable();

            if (filter != null)
            {
                filter = filter.Trim().ToLower();
            }

            // Apply same filters
            query = query
            .WhereIf(!string.IsNullOrWhiteSpace(filter), x => x.Name.Contains(filter!))
            .WhereIf(categoryId.HasValue, x => x.CategoryId == categoryId!.Value)
            .WhereIf(!includeInactive, x => x.IsActive);

            return await query.CountAsync(GetCancellationToken(cancellationToken));
        }

        public async Task<List<Ingredient>> GetByCategoryAsync(
            Guid categoryId,
            bool includeInactive = false,
            CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            return await dbSet
                .Include(x => x.Category)
                .Include(x => x.Unit)
                .Include(x => x.PurchaseUnits)
                .Where(x => x.CategoryId == categoryId)
                .WhereIf(!includeInactive, x => x.IsActive)
                .OrderBy(x => x.Name)
                .ToListAsync(GetCancellationToken(cancellationToken));
        }

        public async Task<Ingredient?> GetWithPurchaseUnitsAsync(Guid id, CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            return await dbSet
                .Include(x => x.PurchaseUnits)
                .FirstOrDefaultAsync(x => x.Id == id, GetCancellationToken(cancellationToken));
        }

        public async Task<bool> HasDependenciesAsync(Guid id, CancellationToken cancellationToken = default)
        {
            var dbContext = await GetDbContextAsync();

            // Kiểm tra PurchaseInvoiceItem
            var hasPurchaseInvoiceItems = await dbContext.PurchaseInvoiceItems
                .AnyAsync(x => x.IngredientId == id, GetCancellationToken(cancellationToken));

            if (hasPurchaseInvoiceItems)
                return true;

            // Kiểm tra MenuItem
            var hasMenuItems = await dbContext.MenuItems
                .AnyAsync(x => x.PrimaryIngredientId == id, GetCancellationToken(cancellationToken));

            return hasMenuItems;
        }
    }
}