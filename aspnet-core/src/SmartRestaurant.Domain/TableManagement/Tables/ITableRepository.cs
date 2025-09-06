using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.TableManagement.Tables
{
    /// <summary>
    /// Repository interface chuyên biệt cho bàn ăn trong nhà hàng
    /// Mở rộng IRepository cơ bản với các method truy vấn phức tạp
    /// Hỗ trợ quản lý vị trí, sắp xếp và nhóm theo khu vực
    /// </summary>
    public interface ITableRepository : IRepository<Table, Guid>
    {
        /// <summary>Lấy danh sách bàn theo khu vực với sắp xếp theo DisplayOrder</summary>
        Task<List<Table>> GetTablesBySectionAsync(
            Guid layoutSectionId, 
            bool includeInactive = false,
            CancellationToken cancellationToken = default);
        
        /// <summary>Lấy tất cả bàn có sắp xếp theo khu vực và thứ tự hiển thị</summary>
        Task<List<Table>> GetAllTablesOrderedAsync(
            bool includeInactive = false,
            CancellationToken cancellationToken = default);
        
        /// <summary>Lấy thứ tự hiển thị cao nhất trong khu vực</summary>
        Task<int> GetMaxDisplayOrderInSectionAsync(
            Guid layoutSectionId,
            CancellationToken cancellationToken = default);
        
        /// <summary>Cập nhật thứ tự hiển thị của nhiều bàn cùng lúc</summary>
        Task UpdateMultipleTablePositionsAsync(
            List<(Guid tableId, Guid? layoutSectionId, int displayOrder)> updates,
            CancellationToken cancellationToken = default);
            
        /// <summary>
        /// Lấy tất cả bàn active trong table section active, bao gồm các order hiện tại và order items
        /// </summary>
        /// <param name="tableNameFilter">Lọc theo tên bàn (tìm kiếm gần đúng)</param>
        /// <param name="statusFilter">Lọc theo trạng thái bàn</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Danh sách bàn active với order và order items</returns>
        Task<List<Table>> GetAllActiveTablesWithOrdersAsync(
            string? tableNameFilter = null,
            TableStatus? statusFilter = null,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Lấy thông tin bàn cụ thể với các đơn hàng đang hoạt động
        /// </summary>
        /// <param name="tableId">ID bàn cần lấy thông tin</param>
        /// <param name="cancellationToken">Cancellation token</param>
        /// <returns>Bàn với thông tin chi tiết</returns>
        Task<Table?> GetTableWithActiveOrdersAsync(
            Guid tableId,
            CancellationToken cancellationToken = default);
    }
}