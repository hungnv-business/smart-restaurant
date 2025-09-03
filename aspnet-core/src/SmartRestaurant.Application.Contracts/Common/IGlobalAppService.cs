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
        Task<List<IntLookupItemDto>> GetTableStatusLookupAsync();

        /// <summary>Lấy danh sách tất cả đơn vị active cho dropdown</summary>
        Task<List<GuidLookupItemDto>> GetUnitsLookupAsync();
        
        /// <summary>Lấy danh sách tất cả danh mục nguyên liệu active cho dropdown</summary>
        Task<List<GuidLookupItemDto>> GetCategoriesLookupAsync();
        
        /// <summary>Lấy danh sách nguyên liệu theo danh mục cho dropdown</summary>
        Task<List<GuidLookupItemDto>> GetIngredientsByCategoryLookupAsync(Guid categoryId);
    }
}