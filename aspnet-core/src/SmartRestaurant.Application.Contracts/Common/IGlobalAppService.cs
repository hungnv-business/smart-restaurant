using System.Collections.Generic;
using System.Threading.Tasks;
using SmartRestaurant.Common.Dto;
using Volo.Abp.Application.Services;

namespace SmartRestaurant.Common
{
    /// <summary>
    /// Service tập trung để cung cấp các API lookup cho dropdown
    /// </summary>
    public interface IGlobalAppService : IApplicationService
    {
        /// <summary>Lấy danh sách tất cả trạng thái của bàn</summary>
        Task<List<IntLookupItemDto>> GetTableStatusesAsync();
    }
}