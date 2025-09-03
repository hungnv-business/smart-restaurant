using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.TableManagement.LayoutSections
{
    /// <summary>
    /// Repository interface chuyên biệt cho khu vực bố cục bàn ăn
    /// Mở rộng IRepository cơ bản với các method truy vấn phức tạp
    /// </summary>
    public interface ILayoutSectionRepository : IRepository<LayoutSection, Guid>
    {
        /// <summary>Lấy tất cả khu vực có sắp xếp theo DisplayOrder</summary>
        Task<List<LayoutSection>> GetAllOrderedAsync(
            bool includeInactive = false,
            CancellationToken cancellationToken = default);
        
        /// <summary>Lấy khu vực cùng với danh sách bàn</summary>
        Task<LayoutSection> GetWithTablesAsync(
            Guid id,
            CancellationToken cancellationToken = default);
        
        /// <summary>Lấy thứ tự hiển thị cao nhất</summary>
        Task<int> GetMaxDisplayOrderAsync(CancellationToken cancellationToken = default);
    }
}