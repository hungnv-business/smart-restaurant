using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using SmartRestaurant.Common;
using SmartRestaurant.MenuManagement.MenuCategories;
using SmartRestaurant.MenuManagement.MenuItems;
using SmartRestaurant.MenuManagement.MenuItems.Dto;
using SmartRestaurant.Permissions;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.MenuManagement.MenuItems
{
    /// <summary>
    /// Application Service cho MenuItem - Level 1 CRUD Pattern
    /// Kế thừa CrudAppService của ABP để có sẵn các operations: GetList, Get, Create, Update, Delete
    /// Chỉ cần override khi cần business logic đặc biệt
    /// </summary>
    [Authorize(SmartRestaurantPermissions.Menu.Items.Default)]
    public class MenuItemAppService : 
        CrudAppService<
            MenuItem,                         // Domain Entity
            MenuItemDto,                      // Output DTO  
            Guid,                            // Primary Key Type
            PagedAndSortedResultRequestDto,   // GetList Input (có sẵn paging/sorting)
            CreateUpdateMenuItemDto>,         // Create/Update Input DTO
        IMenuItemAppService
    {
        private readonly IRepository<MenuCategory, Guid> _categoryRepository;

        public MenuItemAppService(
            IRepository<MenuItem, Guid> repository,
            IRepository<MenuCategory, Guid> categoryRepository)
            : base(repository)
        {
            _categoryRepository = categoryRepository;
            
            // Cấu hình permissions cho từng operation
            GetPolicyName = SmartRestaurantPermissions.Menu.Items.Default;
            GetListPolicyName = SmartRestaurantPermissions.Menu.Items.Default;
            CreatePolicyName = SmartRestaurantPermissions.Menu.Items.Create;
            UpdatePolicyName = SmartRestaurantPermissions.Menu.Items.Edit;
            DeletePolicyName = SmartRestaurantPermissions.Menu.Items.Delete;
        }

        protected override async Task<IQueryable<MenuItem>> CreateFilteredQueryAsync(PagedAndSortedResultRequestDto input)
        {
            // ABP tự động include navigation properties khi cần thiết thông qua AutoMapper
            return await base.CreateFilteredQueryAsync(input);
        }

        /// <summary>
        /// Override CreateAsync để thêm business logic: validate category exists và name unique
        /// </summary>
        public override async Task<MenuItemDto> CreateAsync(CreateUpdateMenuItemDto input)
        {
            // Chuẩn hóa dữ liệu đầu vào để tránh khoảng trắng thừa
            input.Name = StringUtility.NormalizeString(input.Name);
            input.Description = StringUtility.NormalizeStringNullable(input.Description);
            
            // Business validation: validate category exists
            await ValidateCategoryExistsAsync(input.CategoryId);
            
            // Business validation: validate name uniqueness trong cùng category
            await ValidateNameNotExistsAsync(input.Name, input.CategoryId);

            return await base.CreateAsync(input);
        }

        /// <summary>
        /// Override UpdateAsync để thêm business validation
        /// </summary>
        public override async Task<MenuItemDto> UpdateAsync(Guid id, CreateUpdateMenuItemDto input)
        {
            // Chuẩn hóa dữ liệu đầu vào
            input.Name = StringUtility.NormalizeString(input.Name);
            input.Description = StringUtility.NormalizeStringNullable(input.Description);
            
            // Business validation: validate category exists
            await ValidateCategoryExistsAsync(input.CategoryId);
            
            // Business validation: validate name uniqueness (exclude current item)
            await ValidateNameNotExistsAsync(input.Name, input.CategoryId, id);

            return await base.UpdateAsync(id, input);
        }

        /// <summary>
        /// Cập nhật trạng thái có sẵn của món ăn (còn hàng/hết hàng)
        /// </summary>
        [Authorize(SmartRestaurantPermissions.Menu.Items.UpdateAvailability)]
        public async Task<MenuItemDto> UpdateAvailabilityAsync(Guid id, bool isAvailable)
        {
            var menuItem = await Repository.GetAsync(id);
            menuItem.IsAvailable = isAvailable;
            
            await Repository.UpdateAsync(menuItem);
            
            return ObjectMapper.Map<MenuItem, MenuItemDto>(menuItem);
        }

        private async Task ValidateCategoryExistsAsync(Guid categoryId)
        {
            var categoryExists = await _categoryRepository.AnyAsync(x => x.Id == categoryId);
                
            if (!categoryExists)
            {
                throw new MenuItemCategoryNotFoundException(categoryId);
            }
        }

        /// <summary>
        /// Private helper: Validate name uniqueness trong category - business rule của MenuItem
        /// </summary>
        private async Task ValidateNameNotExistsAsync(string name, Guid categoryId, Guid? excludeId = null)
        {
            if (StringUtility.IsNullOrWhiteSpaceNormalized(name))
            {
                return;
            }

            // Kiểm tra trùng tên trong cùng category không phân biệt hoa thường và khoảng trắng
            var existingMenuItems = await Repository.GetListAsync(x => x.CategoryId == categoryId);
            var duplicateMenuItem = existingMenuItems.FirstOrDefault(m => 
                (excludeId == null || m.Id != excludeId) && 
                StringUtility.AreNormalizedEqual(m.Name, name));

            if (duplicateMenuItem != null)
            {
                throw new MenuItemNameAlreadyExistsInCategoryException(name, categoryId);
            }
        }
    }
}