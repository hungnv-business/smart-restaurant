using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using SmartRestaurant.MenuManagement.MenuItems.Dto;
using SmartRestaurant.Permissions;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Entities;
using SmartRestaurant.MenuManagement.MenuItemIngredients;

namespace SmartRestaurant.MenuManagement.MenuItems
{
    /// <summary>
    /// Application Service cho MenuItem - Manual Implementation
    /// Không kế thừa CrudAppService, implement tất cả methods thủ công
    /// </summary>
    [Authorize(SmartRestaurantPermissions.Menu.Items.Default)]
    public class MenuItemAppService : ApplicationService, IMenuItemAppService
    {
        private readonly IMenuItemRepository _menuItemRepository;
        private readonly MenuItemManager _menuItemManager;

        public MenuItemAppService(
            IMenuItemRepository menuItemRepository,
            MenuItemManager menuItemManager)
        {
            _menuItemRepository = menuItemRepository;
            _menuItemManager = menuItemManager;
        }

        /// <summary>
        /// Lấy danh sách món ăn với phân trang và filter
        /// </summary>
        public virtual async Task<PagedResultDto<MenuItemDto>> GetListAsync(GetMenuItemListRequestDto input)
        {
            var items = await _menuItemRepository.GetListWithDetailsAsync(
                input.SkipCount,
                input.MaxResultCount,
                input.Sorting ?? "Name",
                input.Filter,
                input.CategoryId,
                input.OnlyAvailable);

            var totalCount = await _menuItemRepository.GetCountAsync(
                input.Filter,
                input.CategoryId,
                input.OnlyAvailable);

            var itemDtos = ObjectMapper.Map<List<MenuItem>, List<MenuItemDto>>(items);

            return new PagedResultDto<MenuItemDto>(totalCount, itemDtos);
        }

        /// <summary>
        /// Lấy thông tin chi tiết một món ăn theo ID
        /// </summary>
        public virtual async Task<MenuItemDto> GetAsync(Guid id)
        {
            var menuItem = await _menuItemRepository.GetWithDetailsAsync(id);

            if (menuItem is null)
            {
                throw new EntityNotFoundException(typeof(MenuItem), id);
            }

            return ObjectMapper.Map<MenuItem, MenuItemDto>(menuItem);
        }

        /// <summary>
        /// Tạo mới một món ăn
        /// </summary>
        [Authorize(SmartRestaurantPermissions.Menu.Items.Create)]
        public virtual async Task CreateAsync(CreateUpdateMenuItemDto input)
        {
            var ingredients = this.ObjectMapper.Map<List<MenuItemIngredientDto>, List<MenuItemIngredient>>(input.Ingredients);

            // Sử dụng MenuItemManager để tạo MenuItem
            var menuItem = await _menuItemManager.CreateAsync(
                input.Name,
                input.Description,
                input.Price,
                input.IsAvailable,
                input.ImageUrl,
                input.CategoryId,
                ingredients);

            // Lưu vào database
            await _menuItemRepository.InsertAsync(menuItem, autoSave: true);
        }

        /// <summary>
        /// Cập nhật thông tin món ăn
        /// </summary>
        [Authorize(SmartRestaurantPermissions.Menu.Items.Edit)]
        public virtual async Task UpdateAsync(Guid id, CreateUpdateMenuItemDto input)
        {
            var ingredients = this.ObjectMapper.Map<List<MenuItemIngredientDto>, List<MenuItemIngredient>>(input.Ingredients);
            // Sử dụng MenuItemManager để cập nhật với pattern ExamsManager
            await _menuItemManager.UpdateAsync(
                id,
                input.Name,
                input.Description,
                input.Price,
                input.IsAvailable,
                input.ImageUrl,
                input.CategoryId,
                ingredients);
        }

        /// <summary>
        /// Xóa một món ăn
        /// </summary>
        [Authorize(SmartRestaurantPermissions.Menu.Items.Delete)]
        public virtual async Task DeleteAsync(Guid id)
        {
            // Sử dụng MenuItemManager để validation và xử lý business logic
            await _menuItemManager.DeleteAsync(id);
        }

        /// <summary>
        /// Cập nhật trạng thái có sẵn của món ăn
        /// </summary>
        [Authorize(SmartRestaurantPermissions.Menu.Items.UpdateAvailability)]
        public virtual async Task UpdateAvailabilityAsync(Guid id, bool isAvailable)
        {
            var menuItem = await _menuItemRepository.GetAsync(id);

            // Sử dụng MenuItemManager để cập nhật availability
            await _menuItemManager.UpdateAvailabilityAsync(menuItem, isAvailable);
        }
    }
}