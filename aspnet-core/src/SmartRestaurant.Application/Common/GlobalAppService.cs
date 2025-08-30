using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using SmartRestaurant.Common.Dto;
using SmartRestaurant.Common.Units.Dto;
using SmartRestaurant.Entities.Common;
using SmartRestaurant.Entities.InventoryManagement;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.Common
{
    /// <summary>
    /// Service tập trung cung cấp các API lookup cho dropdown
    /// </summary>
    public class GlobalAppService : ApplicationService, IGlobalAppService
    {
        private readonly IRepository<Unit> _unitRepository;
        private readonly IRepository<IngredientCategory> _ingredientCategoryRepository;
        private readonly IRepository<Ingredient, Guid> _ingredientRepository;

        public GlobalAppService(
            IRepository<Unit> unitRepository,
            IRepository<IngredientCategory> ingredientCategoryRepository,
            IRepository<Ingredient, Guid> ingredientRepository)
        {
            _unitRepository = unitRepository;
            _ingredientCategoryRepository = ingredientCategoryRepository;
            _ingredientRepository = ingredientRepository;
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

        /// <summary>
        /// Lấy tất cả units active để sử dụng trong dropdowns
        /// Master data cố định, không cần authorization
        /// </summary>
        /// <returns>Danh sách units active được sắp xếp theo DisplayOrder</returns>
        public async Task<List<UnitDto>> GetUnitsAsync()
        {
            var units = await _unitRepository.GetListAsync(u => u.IsActive);
            var orderedUnits = units.OrderBy(u => u.DisplayOrder).ToList();
            
            return ObjectMapper.Map<List<Unit>, List<UnitDto>>(orderedUnits);
        }

        /// <summary>
        /// Lấy tất cả ingredient categories active để sử dụng trong dropdowns
        /// Master data cho filter, không cần authorization
        /// </summary>
        /// <returns>Danh sách ingredient categories active được sắp xếp theo DisplayOrder</returns>
        public async Task<List<GuidLookupItemDto>> GetCategoriesAsync()
        {
            var categories = await _ingredientCategoryRepository.GetListAsync(c => c.IsActive);
            var orderedCategories = categories.OrderBy(c => c.DisplayOrder).ToList();
            
            return orderedCategories.Select(c => new GuidLookupItemDto
            {
                Id = c.Id,
                DisplayName = c.Name
            }).ToList();
        }

        /// <summary>
        /// Lấy danh sách nguyên liệu theo danh mục cho dropdown
        /// </summary>
        public async Task<List<GuidLookupItemDto>> GetIngredientsByCategoryAsync(Guid categoryId)
        {
            var ingredients = await _ingredientRepository.GetListAsync(i => 
                i.CategoryId == categoryId && i.IsActive);
            var orderedIngredients = ingredients.OrderBy(i => i.Name).ToList();
            
            return orderedIngredients.Select(i => new GuidLookupItemDto
            {
                Id = i.Id,
                DisplayName = i.Name
            }).ToList();
        }
    }
}