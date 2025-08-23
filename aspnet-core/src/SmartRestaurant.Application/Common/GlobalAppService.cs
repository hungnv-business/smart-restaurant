using System.Collections.Generic;
using System.Threading.Tasks;
using SmartRestaurant.Common.Dto;
using Volo.Abp.Application.Services;

namespace SmartRestaurant.Common
{
    /// <summary>
    /// Service tập trung cung cấp các API lookup cho dropdown
    /// </summary>
    public class GlobalAppService : ApplicationService, IGlobalAppService
    {
        public GlobalAppService()
        {
            
        }

        public Task<List<IntLookupItemDto>> GetTableStatusesAsync()
        {
            var tableStatuses = new List<IntLookupItemDto>
            {
                new() { Id = (int)TableStatus.Available, DisplayName = "Có sẵn" },
                new() { Id = (int)TableStatus.Occupied, DisplayName = "Đang sử dụng" },
                new() { Id = (int)TableStatus.Reserved, DisplayName = "Đã đặt trước" },
                new() { Id = (int)TableStatus.Cleaning, DisplayName = "Đang dọn dẹp" }
            };

            return Task.FromResult(tableStatuses);
        }
    }
}