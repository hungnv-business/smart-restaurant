using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using SmartRestaurant.EntityFrameworkCore;
using SmartRestaurant.Entities.Tables;
using SmartRestaurant.Repositories;
using Volo.Abp.Domain.Repositories.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;

namespace SmartRestaurant.EntityFrameworkCore.Repositories
{
    public class EfCoreLayoutSectionRepository : EfCoreRepository<SmartRestaurantDbContext, LayoutSection, Guid>, ILayoutSectionRepository
    {
        public EfCoreLayoutSectionRepository(IDbContextProvider<SmartRestaurantDbContext> dbContextProvider)
            : base(dbContextProvider)
        {
        }

        public async Task<List<LayoutSection>> GetAllOrderedAsync(
            bool includeInactive = false,
            CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            return await dbSet
                .WhereIf(!includeInactive, s => s.IsActive)
                .OrderBy(s => s.DisplayOrder)
                .ThenBy(s => s.SectionName)
                .ToListAsync(GetCancellationToken(cancellationToken));
        }

        public async Task<LayoutSection> GetWithTablesAsync(
            Guid id,
            CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            return await dbSet
                .Include(s => s.Tables.Where(t => t.IsActive))
                .FirstOrDefaultAsync(s => s.Id == id, GetCancellationToken(cancellationToken));
        }

        public async Task<int> GetMaxDisplayOrderAsync(CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            var maxOrder = await dbSet
                .MaxAsync(s => (int?)s.DisplayOrder, GetCancellationToken(cancellationToken));
            return maxOrder ?? -1;
        }
    }
}