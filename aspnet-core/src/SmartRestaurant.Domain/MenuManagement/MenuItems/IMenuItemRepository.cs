using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.MenuManagement.MenuItems;

/// <summary>
/// Repository interface cho MenuItem với các method tùy chỉnh
/// </summary>
public interface IMenuItemRepository : IRepository<MenuItem, Guid>
{
    /// <summary>
    /// Lấy danh sách món ăn với filtering theo danh mục
    /// </summary>
    /// <param name="categoryId">ID danh mục (null để lấy tất cả)</param>
    /// <param name="onlyAvailable">Chỉ lấy món đang có sẵn</param>
    /// <param name="nameFilter">Tìm kiếm theo tên món</param>
    /// <param name="includeSalesData">Có bao gồm dữ liệu bán hàng không</param>
    /// <returns>Danh sách món ăn</returns>
    Task<List<MenuItem>> GetMenuItemsAsync(
        Guid? categoryId = null,
        bool onlyAvailable = true,
        string? nameFilter = null,
        bool includeSalesData = false);

    /// <summary>
    /// Lấy thống kê số lượng bán ra của các món ăn
    /// </summary>
    /// <param name="menuItemIds">Danh sách ID món ăn (null để lấy tất cả)</param>
    /// <returns>Dictionary với key là MenuItemId và value là số lượng bán</returns>
    Task<Dictionary<Guid, int>> GetMenuItemSalesDataAsync(List<Guid>? menuItemIds = null);

    /// <summary>
    /// Kiểm tra món ăn có tồn tại và available không
    /// </summary>
    /// <param name="menuItemId">ID món ăn</param>
    /// <returns>True nếu món ăn tồn tại và available</returns>
    Task<bool> IsMenuItemAvailableAsync(Guid menuItemId);
}