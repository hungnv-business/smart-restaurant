using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.InventoryManagement.Ingredients
{
    public interface IIngredientRepository : IRepository<Ingredient, Guid>
    {
        /// <summary>Lấy ingredient với đầy đủ navigation properties</summary>
        Task<Ingredient?> GetWithDetailsAsync(
            Guid id,
            CancellationToken cancellationToken = default);

        /// <summary>Lấy danh sách ingredients với navigation properties và phân trang</summary>
        Task<List<Ingredient>> GetListWithDetailsAsync(
            int skipCount,
            int maxResultCount,
            string sorting,
            string? filter = null,
            Guid? categoryId = null,
            bool includeInactive = false,
            CancellationToken cancellationToken = default);

        /// <summary>Đếm số lượng ingredients theo filter</summary>
        Task<int> GetCountAsync(
            string? filter = null,
            Guid? categoryId = null,
            bool includeInactive = false,
            CancellationToken cancellationToken = default);

        /// <summary>Lấy danh sách ingredients theo category</summary>
        Task<List<Ingredient>> GetByCategoryAsync(
            Guid categoryId,
            bool includeInactive = false,
            CancellationToken cancellationToken = default);

        /// <summary>Lấy ingredient với purchase units để conversion</summary>
        Task<Ingredient?> GetWithPurchaseUnitsAsync(
            Guid id,
            CancellationToken cancellationToken = default);

        /// <summary>Kiểm tra ingredient có đang được sử dụng không (PurchaseInvoiceItem, MenuItem)</summary>
        Task<bool> HasDependenciesAsync(
            Guid id,
            CancellationToken cancellationToken = default);
    }
}