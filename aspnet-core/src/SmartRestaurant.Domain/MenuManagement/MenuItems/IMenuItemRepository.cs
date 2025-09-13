using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.MenuManagement.MenuItems
{
    public interface IMenuItemRepository : IRepository<MenuItem, Guid>
    {
        /// <summary>Lấy menu item với đầy đủ navigation properties (Category, Ingredients)</summary>
        Task<MenuItem?> GetWithDetailsAsync(
            Guid id, 
            CancellationToken cancellationToken = default);

        /// <summary>Lấy danh sách menu items với navigation properties và phân trang</summary>
        Task<List<MenuItem>> GetListWithDetailsAsync(
            int skipCount,
            int maxResultCount,
            string sorting,
            string? filter = null,
            Guid? categoryId = null,
            bool onlyAvailable = false,
            CancellationToken cancellationToken = default);

        /// <summary>Đếm số lượng menu items theo filter</summary>
        Task<int> GetCountAsync(
            string? filter = null,
            Guid? categoryId = null,
            bool onlyAvailable = false,
            CancellationToken cancellationToken = default);

        /// <summary>Lấy danh sách menu items theo category</summary>
        Task<List<MenuItem>> GetByCategoryAsync(
            Guid categoryId,
            bool onlyAvailable = false,
            CancellationToken cancellationToken = default);

        /// <summary>Lấy menu item với ingredients để quản lý nguyên liệu</summary>
        Task<MenuItem?> GetWithIngredientsAsync(
            Guid id,
            CancellationToken cancellationToken = default);

        /// <summary>Lấy danh sách menu items phổ biến dựa trên sales data</summary>
        Task<List<MenuItem>> GetPopularMenuItemsAsync(
            int count = 10,
            CancellationToken cancellationToken = default);

        /// <summary>Kiểm tra menu item có đang được sử dụng không (OrderItem)</summary>
        Task<bool> HasDependenciesAsync(
            Guid id,
            CancellationToken cancellationToken = default);

        /// <summary>Kiểm tra menu item có tồn tại và available không</summary>
        Task<bool> IsMenuItemAvailableAsync(
            Guid menuItemId,
            CancellationToken cancellationToken = default);

        /// <summary>Kiểm tra tên menu item có trùng trong category không</summary>
        Task<bool> IsNameExistsInCategoryAsync(
            string name, 
            Guid categoryId, 
            Guid? excludeId = null,
            CancellationToken cancellationToken = default);

        // === Backward compatibility methods cho OrderAppService ===

        /// <summary>Lấy danh sách menu items với filtering - backward compatibility</summary>
        Task<List<MenuItem>> GetMenuItemsAsync(
            Guid? categoryId = null,
            bool onlyAvailable = true,
            string? nameFilter = null);

        /// <summary>Lấy thống kê sales data - backward compatibility</summary>
        Task<Dictionary<Guid, int>> GetMenuItemSalesDataAsync(List<Guid>? menuItemIds = null);
    }
}