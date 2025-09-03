using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.TableManagement.Tables
{
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
    }
}