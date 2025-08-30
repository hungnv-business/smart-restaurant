using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using SmartRestaurant.Common.Dto;
using SmartRestaurant.Common.Units.Dto;
using SmartRestaurant.InventoryManagement.Ingredients.Dto;
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

        /// <summary>Lấy danh sách tất cả đơn vị active cho dropdown</summary>
        Task<List<UnitDto>> GetUnitsAsync();
        
        /// <summary>Lấy danh sách tất cả danh mục nguyên liệu active cho dropdown</summary>
        Task<List<GuidLookupItemDto>> GetCategoriesAsync();
        
        /// <summary>Lấy danh sách nguyên liệu theo danh mục cho dropdown</summary>
        Task<List<GuidLookupItemDto>> GetIngredientsByCategoryAsync(Guid categoryId);
    }
}