using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using SmartRestaurant.Entities.Inventory;
using SmartRestaurant.EntityFrameworkCore;
using Volo.Abp.Domain.Repositories.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;
using System.Linq.Dynamic.Core;
using Volo.Abp.Linq;

namespace SmartRestaurant.InventoryManagement.PurchaseInvoices
{
    public class EfCorePurchaseInvoiceRepository : EfCoreRepository<SmartRestaurantDbContext, PurchaseInvoice, Guid>, IPurchaseInvoiceRepository
    {
        public EfCorePurchaseInvoiceRepository(IDbContextProvider<SmartRestaurantDbContext> dbContextProvider)
            : base(dbContextProvider)
        {
        }

        public async Task<List<PurchaseInvoice>> GetListAsync(
            int skipCount,
            int maxResultCount,
            string sorting,
            string? filter = null,
            int? fromDateId = null,
            int? toDateId = null)
        {
            var dbSet = await GetDbSetAsync();
            var query = dbSet
                .Include(x => x.Items)
                .Include(x => x.InvoiceDate)
                .AsQueryable();

            // Apply filters using WhereIf
            query = query
                .WhereIf(!string.IsNullOrWhiteSpace(filter), x =>
                    x.InvoiceNumber.ToLower().Contains(filter!.Trim().ToLower()))
                .WhereIf(fromDateId.HasValue, x => x.InvoiceDateId >= fromDateId!.Value)
                .WhereIf(toDateId.HasValue, x => x.InvoiceDateId <= toDateId!.Value);

            // Apply sorting
            if (!string.IsNullOrEmpty(sorting))
            {
                query = query.OrderBy(sorting);
            }
            else
            {
                query = query.OrderByDescending(x => x.InvoiceDate.Date);
            }

            // Apply paging
            return await query.Skip(skipCount).Take(maxResultCount).ToListAsync();
        }

        public async Task<int> GetCountAsync(
            string ?filter = null,
            int? fromDateId = null,
            int? toDateId = null)
        {
            var dbSet = await GetDbSetAsync();
            var query = dbSet.AsQueryable();

            // Apply same filters using WhereIf
            query = query
                .WhereIf(!string.IsNullOrWhiteSpace(filter), x =>
                    x.InvoiceNumber.ToLower().Contains(filter!.Trim().ToLower()))
                .WhereIf(fromDateId.HasValue, x => x.InvoiceDateId >= fromDateId!.Value)
                .WhereIf(toDateId.HasValue, x => x.InvoiceDateId <= toDateId!.Value);

            return await query.CountAsync();
        }

        public async Task<PurchaseInvoice?> GetWithDetailsAsync(Guid id)
        {
            var dbSet = await GetDbSetAsync();
            return await dbSet
                .Include(x => x.Items)
                    .ThenInclude(item => item.Ingredient)
                .Include(x => x.InvoiceDate)
                .FirstOrDefaultAsync(x => x.Id == id);
        }
    }
}