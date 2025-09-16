using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using JetBrains.Annotations;
using Microsoft.Extensions.Logging;
using SmartRestaurant.Common;
using Volo.Abp;
using SmartRestaurant.MenuManagement.MenuCategories;
using SmartRestaurant.MenuManagement.MenuItemIngredients;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Domain.Services;

namespace SmartRestaurant.MenuManagement.MenuItems;

/// <summary>
/// Domain Service quản lý business logic cho MenuItem
/// Xử lý validation, ingredients management và các logic phức tạp
/// Theo pattern của PurchaseInvoiceManager
/// </summary>
public class MenuItemManager : DomainService
{
    private readonly IMenuItemRepository _menuItemRepository;
    private readonly IRepository<MenuCategory, Guid> _categoryRepository;

    public MenuItemManager(
        IMenuItemRepository menuItemRepository,
        IRepository<MenuCategory, Guid> categoryRepository)
    {
        _menuItemRepository = menuItemRepository;
        _categoryRepository = categoryRepository;
    }

    /// <summary>
    /// Tạo MenuItem mới với validation và ingredients
    /// </summary>
    public async Task<MenuItem> CreateAsync(
        [NotNull] string name,
        string? description,
        decimal price,
        bool isAvailable,
        string? imageUrl,
        [NotNull] Guid categoryId,
        bool isQuickCook,
        bool requiresCooking,
        IEnumerable<MenuItemIngredient> ingredients)
    {
        Check.NotNull(name, nameof(name));
        Check.NotNull(categoryId, nameof(categoryId));

        // Chuẩn hóa dữ liệu
        name = StringUtility.NormalizeString(name);
        description = StringUtility.NormalizeStringNullable(description);

        // Business validation
        await ValidateCategoryExistsAsync(categoryId);
        await ValidateNameNotExistsAsync(name, categoryId);

        // Tạo MenuItem
        var menuItem = new MenuItem(
            GuidGenerator.Create(),
            name,
            description,
            price,
            isAvailable,
            imageUrl,
            categoryId,
            isQuickCook,
            requiresCooking);

        menuItem.AddMenuItemIngredients(GuidGenerator, ingredients);
        return menuItem;
    }

    /// <summary>
    /// Cập nhật MenuItem với validation
    /// </summary>
    public async Task<MenuItem> UpdateAsync(
        [NotNull] Guid id,
        [NotNull] string name,
        string? description,
        decimal price,
        bool isAvailable,
        string? imageUrl,
        [NotNull] Guid categoryId,
        bool isQuickCook,
        bool requiresCooking,
        IEnumerable<MenuItemIngredient> ingredients)
    {
        Check.NotNull(id, nameof(id));
        Check.NotNull(name, nameof(name));
        Check.NotNull(categoryId, nameof(categoryId));

        // Chuẩn hóa dữ liệu
        name = StringUtility.NormalizeString(name);
        description = StringUtility.NormalizeStringNullable(description);

        // Business validation
        await ValidateCategoryExistsAsync(categoryId);
        await ValidateNameNotExistsAsync(name, categoryId, id);

        // Lấy entity từ repository
        var menuItem = await _menuItemRepository.GetAsync(id);

        // Sử dụng UpdateEntity từ domain entity
        menuItem.UpdateEntity(
            GuidGenerator,
            name,
            description,
            price,
            isAvailable,
            imageUrl,
            categoryId,
            isQuickCook,
            requiresCooking,
            ingredients);

        Logger.LogInformation("Updated MenuItem: {Id} - {Name}", menuItem.Id, name);

        return menuItem;
    }

    /// <summary>
    /// Xóa MenuItem với validation
    /// </summary>
    public async Task DeleteAsync([NotNull] Guid id)
    {
        Check.NotNull(id, nameof(id));

        // Lấy entity từ repository
        var menuItem = await _menuItemRepository.GetAsync(id);

        // Kiểm tra dependencies
        var hasDependencies = await _menuItemRepository.HasDependenciesAsync(id);
        if (hasDependencies)
        {
            throw new MenuItemHasDependenciesException(id);
        }

        // Xóa ingredients trước khi xóa MenuItem
        menuItem.ClearIngredients();

        await _menuItemRepository.DeleteAsync(id, autoSave: true);
    }

    /// <summary>
    /// Kiểm tra availability của MenuItem
    /// </summary>
    public async Task<bool> IsAvailableAsync(Guid menuItemId)
    {
        return await _menuItemRepository.IsMenuItemAvailableAsync(menuItemId);
    }

    /// <summary>
    /// Cập nhật availability của MenuItem
    /// </summary>
    public Task UpdateAvailabilityAsync(MenuItem menuItem, bool isAvailable)
    {
        if (menuItem.IsAvailable != isAvailable)
        {
            menuItem.IsAvailable = isAvailable;
            Logger.LogInformation("Updated availability for MenuItem {Id} - {Name} to {IsAvailable}",
                menuItem.Id, menuItem.Name, isAvailable);
        }
        return Task.CompletedTask;
    }

    #region Private Methods

    private async Task ValidateCategoryExistsAsync(Guid categoryId)
    {
        var categoryExists = await _categoryRepository.AnyAsync(x => x.Id == categoryId);
        if (!categoryExists)
        {
            throw new MenuItemCategoryNotFoundException(categoryId);
        }
    }

    private async Task ValidateNameNotExistsAsync(string name, Guid categoryId, Guid? excludeId = null)
    {
        if (StringUtility.IsNullOrWhiteSpaceNormalized(name))
        {
            return;
        }

        var nameExists = await _menuItemRepository.IsNameExistsInCategoryAsync(name, categoryId, excludeId);
        if (nameExists)
        {
            throw new MenuItemNameAlreadyExistsInCategoryException(name, categoryId);
        }
    }

    #endregion
}