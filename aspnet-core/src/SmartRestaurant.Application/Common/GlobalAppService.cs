using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using SmartRestaurant.Common.Dto;
using SmartRestaurant.Application.Contracts.Common;
using SmartRestaurant.InventoryManagement.IngredientCategories;
using SmartRestaurant.InventoryManagement.Ingredients;
using SmartRestaurant.MenuManagement.MenuCategories;
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
        private readonly IRepository<MenuCategory, Guid> _menuCategoryRepository;

        /// <summary>
        /// Constructor - khởi tạo service với các repository cần thiết
        /// </summary>
        /// <param name="unitRepository">Repository cho đơn vị đo lường</param>
        /// <param name="ingredientCategoryRepository">Repository cho danh mục nguyên liệu</param>
        /// <param name="ingredientRepository">Repository cho nguyên liệu</param>
        /// <param name="menuCategoryRepository">Repository cho danh mục món ăn</param>
        public GlobalAppService(
            IRepository<Unit> unitRepository,
            IRepository<IngredientCategory> ingredientCategoryRepository,
            IRepository<Ingredient, Guid> ingredientRepository,
            IRepository<MenuCategory, Guid> menuCategoryRepository)
        {
            _unitRepository = unitRepository;
            _ingredientCategoryRepository = ingredientCategoryRepository;
            _ingredientRepository = ingredientRepository;
            _menuCategoryRepository = menuCategoryRepository;
        }

        public Task<List<IntLookupItemDto>> GetTableStatusLookupAsync()
        {
            var tableStatuses = GlobalEnums.TableStatuses
                .Select(kvp => new IntLookupItemDto
                {
                    Id = (int)kvp.Key,
                    DisplayName = kvp.Value
                })
                .ToList();

            return Task.FromResult(tableStatuses);
        }

        /// <summary>
        /// Lấy tất cả units active để sử dụng trong dropdowns
        /// Master data cố định, không cần authorization
        /// </summary>
        /// <returns>Danh sách units active được sắp xếp theo DisplayOrder</returns>
        public async Task<List<GuidLookupItemDto>> GetUnitsLookupAsync()
        {
            var units = await _unitRepository.GetListAsync(u => u.IsActive);
            var orderedUnits = units.OrderBy(u => u.DisplayOrder).ToList();

            return orderedUnits.Select(c => new GuidLookupItemDto
            {
                Id = c.Id,
                DisplayName = c.Name
            }).ToList();
        }

        /// <summary>
        /// Lấy tất cả ingredient categories active để sử dụng trong dropdowns
        /// Master data cho filter, không cần authorization
        /// </summary>
        /// <returns>Danh sách ingredient categories active được sắp xếp theo DisplayOrder</returns>
        public async Task<List<GuidLookupItemDto>> GetIngredientCategoriesLookupAsync()
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
        /// Lấy tất cả menu categories active để sử dụng trong dropdowns
        /// Master data cho filter, không cần authorization
        /// </summary>
        /// <returns>Danh sách menu categories active được sắp xếp theo DisplayOrder</returns>
        public async Task<List<GuidLookupItemDto>> GetMenuCategoriesLookupAsync()
        {
            var categories = await _menuCategoryRepository.GetListAsync(c => c.IsEnabled);
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
        public async Task<List<GuidLookupItemDto>> GetIngredientsByCategoryLookupAsync(Guid categoryId)
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