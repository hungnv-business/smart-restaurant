using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.InventoryManagement.PurchaseInvoices
{
    public interface IPurchaseInvoiceRepository : IRepository<PurchaseInvoice, Guid>
    {
        Task<List<PurchaseInvoice>> GetListAsync(
            int skipCount,
            int maxResultCount,
            string sorting,
            string? filter = null,
            int? fromDateId = null,
            int? toDateId = null
        );

        Task<int> GetCountAsync(
            string? filter = null,
            int? fromDateId = null,
            int? toDateId = null
        );

        Task<PurchaseInvoice?> GetWithDetailsAsync(Guid id);
    }
}