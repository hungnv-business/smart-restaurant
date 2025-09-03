using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using SmartRestaurant.EntityFrameworkCore;
using SmartRestaurant.TableManagement.Tables;
using Volo.Abp.Domain.Repositories.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;

namespace SmartRestaurant.EntityFrameworkCore.TableManagement.Tables
{
    public class EfCoreTableRepository : EfCoreRepository<SmartRestaurantDbContext, Table, Guid>, ITableRepository
    {
        public EfCoreTableRepository(IDbContextProvider<SmartRestaurantDbContext> dbContextProvider)
            : base(dbContextProvider)
        {
        }

        public async Task<List<Table>> GetTablesBySectionAsync(
            Guid layoutSectionId, 
            bool includeInactive = false,
            CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            return await dbSet
                .Include(t => t.LayoutSection)
                .Where(t => t.LayoutSectionId == layoutSectionId)
                .WhereIf(!includeInactive, t => t.IsActive)
                .OrderBy(t => t.DisplayOrder)
                .ThenBy(t => t.TableNumber)
                .ToListAsync(GetCancellationToken(cancellationToken));
        }

        public async Task<List<Table>> GetAllTablesOrderedAsync(
            bool includeInactive = false,
            CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            return await dbSet
                .Include(t => t.LayoutSection)
                .WhereIf(!includeInactive, t => t.IsActive)
                .OrderBy(t => t.LayoutSection.DisplayOrder)
                .ThenBy(t => t.DisplayOrder)
                .ThenBy(t => t.TableNumber)
                .ToListAsync(GetCancellationToken(cancellationToken));
        }

        public async Task<int> GetMaxDisplayOrderInSectionAsync(
            Guid layoutSectionId,
            CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            var maxOrder = await dbSet
                .Where(t => t.LayoutSectionId == layoutSectionId)
                .MaxAsync(t => (int?)t.DisplayOrder, GetCancellationToken(cancellationToken));
            return maxOrder ?? -1;
        }

        public async Task UpdateMultipleTablePositionsAsync(
            List<(Guid tableId, Guid? layoutSectionId, int displayOrder)> updates,
            CancellationToken cancellationToken = default)
        {
            var dbContext = await GetDbContextAsync();
            var tableIds = updates.Select(u => u.tableId).ToList();
            
            var tables = await dbContext.Tables
                .Where(t => tableIds.Contains(t.Id))
                .ToListAsync(GetCancellationToken(cancellationToken));

            foreach (var update in updates)
            {
                var table = tables.FirstOrDefault(t => t.Id == update.tableId);
                if (table != null)
                {
                    table.LayoutSectionId = update.layoutSectionId;
                    table.DisplayOrder = update.displayOrder;
                }
            }

            await dbContext.SaveChangesAsync(GetCancellationToken(cancellationToken));
        }
    }
}