using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Domain.Services;
using Volo.Abp.Guids;
using SmartRestaurant.MenuManagement.MenuItems;
using SmartRestaurant.MenuManagement.MenuItemIngredients;
using SmartRestaurant.InventoryManagement.Ingredients;
using SmartRestaurant.Orders;

namespace SmartRestaurant.MenuManagement;

/// <summary>
/// Domain Service quản lý logic kinh doanh liên quan đến recipe và tồn kho nguyên liệu
/// Xử lý việc kiểm tra ingredient availability, tính toán required ingredients và xử lý deduction
/// </summary>
public class RecipeManager : DomainService
{
    private readonly IRepository<MenuItemIngredient, Guid> _menuItemIngredientRepository;
    private readonly IIngredientRepository _ingredientRepository;
    private readonly IMenuItemRepository _menuItemRepository;
    private readonly IOrderRepository _orderRepository;
    private readonly IngredientManager _ingredientManager;
    private readonly IGuidGenerator _guidGenerator;

    public RecipeManager(
        IRepository<MenuItemIngredient, Guid> menuItemIngredientRepository,
        IIngredientRepository ingredientRepository,
        IMenuItemRepository menuItemRepository,
        IOrderRepository orderRepository,
        IngredientManager ingredientManager,
        IGuidGenerator guidGenerator)
    {
        _menuItemIngredientRepository = menuItemIngredientRepository;
        _ingredientRepository = ingredientRepository;
        _menuItemRepository = menuItemRepository;
        _orderRepository = orderRepository;
        _ingredientManager = ingredientManager;
        _guidGenerator = guidGenerator;
    }

    /// <summary>
    /// Kiểm tra tình trạng nguyên liệu có sẵn cho một món ăn
    /// </summary>
    /// <param name="menuItemId">ID món ăn</param>
    /// <returns>Danh sách nguyên liệu thiếu (nếu có)</returns>
    public async Task<List<MissingIngredientInfo>> CheckIngredientAvailabilityAsync(Guid menuItemId)
    {
        var missingIngredients = new List<MissingIngredientInfo>();

        // Sử dụng repository method mới để lấy MenuItem với ingredients trong 1 query
        var menuItemWithIngredients = await _menuItemRepository.GetWithIngredientsAsync(menuItemId);

        if (menuItemWithIngredients?.Ingredients == null)
        {
            return missingIngredients; // Món không tồn tại hoặc không có nguyên liệu
        }

        foreach (var menuItemIngredient in menuItemWithIngredients.Ingredients)
        {
            // Sử dụng Ingredient đã được eager load - không cần query database
            var ingredient = menuItemIngredient.Ingredient;

            // Kiểm tra xem có đủ nguyên liệu không
            if (ingredient.CurrentStock < menuItemIngredient.RequiredQuantity)
            {
                missingIngredients.Add(new MissingIngredientInfo
                {
                    MenuItemId = menuItemId,
                    MenuItemName = menuItemWithIngredients.Name,
                    IngredientId = menuItemIngredient.IngredientId,
                    IngredientName = ingredient.Name,
                    RequiredQuantity = menuItemIngredient.RequiredQuantity,
                    CurrentStock = ingredient.CurrentStock,
                    Unit = ingredient.Unit?.Name ?? "đơn vị",
                    ShortageAmount = menuItemIngredient.RequiredQuantity - ingredient.CurrentStock
                });
            }
        }

        return missingIngredients;
    }

    /// <summary>
    /// Kiểm tra tình trạng nguyên liệu có sẵn cho một món ăn với số lượng cụ thể
    /// </summary>
    /// <param name="menuItemId">ID món ăn</param>
    /// <param name="quantity">Số lượng món</param>
    /// <returns>Danh sách nguyên liệu thiếu (nếu có)</returns>
    public async Task<List<MissingIngredientInfo>> CheckIngredientAvailabilityAsync(Guid menuItemId, int quantity)
    {
        var missingIngredients = new List<MissingIngredientInfo>();

        // Sử dụng repository method để lấy MenuItem với ingredients trong 1 query
        var menuItemWithIngredients = await _menuItemRepository.GetWithIngredientsAsync(menuItemId);

        if (menuItemWithIngredients?.Ingredients == null)
        {
            return missingIngredients; // Món không tồn tại hoặc không có nguyên liệu
        }

        foreach (var menuItemIngredient in menuItemWithIngredients.Ingredients)
        {
            var ingredient = menuItemIngredient.Ingredient;
            var totalRequiredQuantity = menuItemIngredient.RequiredQuantity * quantity;

            // Kiểm tra xem có đủ nguyên liệu không (tính theo số lượng món)
            if (ingredient.CurrentStock < totalRequiredQuantity)
            {
                missingIngredients.Add(new MissingIngredientInfo
                {
                    MenuItemId = menuItemId,
                    MenuItemName = menuItemWithIngredients.Name,
                    IngredientId = menuItemIngredient.IngredientId,
                    IngredientName = ingredient.Name,
                    RequiredQuantity = totalRequiredQuantity, // Đã nhân với số lượng
                    CurrentStock = ingredient.CurrentStock,
                    Unit = ingredient.Unit?.Name ?? "đơn vị",
                    ShortageAmount = totalRequiredQuantity - ingredient.CurrentStock
                });
            }
        }

        return missingIngredients;
    }

    /// <summary>
    /// Tính toán số lượng tối đa có thể làm được của một món ăn dựa vào tồn kho nguyên liệu
    /// </summary>
    /// <param name="menuItemId">ID món ăn</param>
    /// <returns>Số lượng tối đa có thể làm được (0 nếu hết nguyên liệu nào đó)</returns>
    public async Task<int> CalculateMaximumPossibleQuantityAsync(Guid menuItemId)
    {
        // Lấy MenuItem với danh sách nguyên liệu
        var menuItemWithIngredients = await _menuItemRepository.GetWithIngredientsAsync(menuItemId);

        if (menuItemWithIngredients?.Ingredients == null || !menuItemWithIngredients.Ingredients.Any())
        {
            return 0; // Món không có nguyên liệu hoặc không tồn tại
        }

        int minimumQuantity = int.MaxValue;

        foreach (var menuItemIngredient in menuItemWithIngredients.Ingredients)
        {
            var ingredient = menuItemIngredient.Ingredient;

            // Chỉ tính cho nguyên liệu có bật stock tracking
            if (!ingredient.IsStockTrackingEnabled)
            {
                continue; // Skip nguyên liệu không track stock
            }

            // Nếu nguyên liệu nào đó hết hàng hoặc RequiredQuantity = 0
            if (ingredient.CurrentStock <= 0 || menuItemIngredient.RequiredQuantity <= 0)
            {
                return 0; // Không thể làm được món nào
            }

            // Tính số lượng món có thể làm được từ nguyên liệu này
            var possibleQuantity = ingredient.CurrentStock / menuItemIngredient.RequiredQuantity;

            // Lấy minimum (bottleneck ingredient)
            minimumQuantity = Math.Min(minimumQuantity, possibleQuantity);
        }

        // Nếu tất cả nguyên liệu không track stock
        if (minimumQuantity == int.MaxValue)
        {
            return int.MaxValue; // Không có giới hạn
        }

        return minimumQuantity;
    }

    /// <summary>
    /// Tính toán số lượng tối đa cho nhiều món ăn cùng lúc (batch processing)
    /// </summary>
    /// <param name="menuItemIds">Danh sách ID món ăn</param>
    /// <returns>Dictionary với MenuItemId và số lượng tối đa</returns>
    public async Task<Dictionary<Guid, int>> CalculateMaximumPossibleQuantitiesAsync(List<Guid> menuItemIds)
    {
        var results = new Dictionary<Guid, int>();

        foreach (var menuItemId in menuItemIds)
        {
            var maxQuantity = await CalculateMaximumPossibleQuantityAsync(menuItemId);
            results[menuItemId] = maxQuantity;
        }

        return results;
    }

    /// <summary>
    /// Tính toán tổng nguyên liệu cho danh sách order items
    /// </summary>
    /// <param name="orderItems">Danh sách order items</param>
    /// <returns>Dictionary với IngredientId và tổng quantity</returns>
    public async Task<Dictionary<Guid, int>> CalculateIngredientsAsync(List<MenuItemQuantityDto> orderItems)
    {
        var totalIngredients = new Dictionary<Guid, int>();

        foreach (var orderItem in orderItems)
        {
            // Sử dụng repository method mới để lấy MenuItem với ingredients trong 1 query
            var menuItemWithIngredients = await _menuItemRepository.GetWithIngredientsAsync(orderItem.MenuItemId);

            if (menuItemWithIngredients?.Ingredients != null)
            {
                foreach (var ingredient in menuItemWithIngredients.Ingredients)
                {
                    // Tính quantity = RequiredQuantity * OrderItem.Quantity
                    var totalQuantity = ingredient.RequiredQuantity * orderItem.Quantity;

                    if (totalIngredients.ContainsKey(ingredient.IngredientId))
                    {
                        totalIngredients[ingredient.IngredientId] += totalQuantity;
                    }
                    else
                    {
                        totalIngredients[ingredient.IngredientId] = totalQuantity;
                    }
                }
            }
        }

        return totalIngredients;
    }

    /// <summary>
    /// Xử lý tự động trừ kho cho danh sách OrderItems cụ thể (hỗ trợ negative stock)
    /// </summary>
    /// <param name="orderItems">Danh sách OrderItems cần trừ kho</param>
    public async Task ProcessAutomaticDeductionForItemsAsync(List<OrderItem> orderItems)
    {
        Logger.LogInformation("Processing automatic inventory deduction for {ItemCount} order items", orderItems.Count);

        try
        {
            if (orderItems.Count == 0)
            {
                Logger.LogInformation("No order items provided, skipping inventory deduction");
                return;
            }

            // Convert OrderItems sang MenuItemQuantityDto format
            var orderItemDtos = orderItems.Select(oi => new MenuItemQuantityDto
            {
                MenuItemId = oi.MenuItemId,
                Quantity = oi.Quantity
            }).ToList();

            // Sử dụng method có sẵn để tính toán ingredients
            var totalIngredients = await CalculateIngredientsAsync(orderItemDtos);

            if (totalIngredients.Count == 0)
            {
                Logger.LogInformation("Order items have no ingredients, skipping inventory deduction");
                return;
            }

            // Tạo stock changes (negative values để trừ kho)
            var stockChanges = totalIngredients.Select(kvp =>
                StockChangeItem.ForSubtraction(kvp.Key, kvp.Value)).ToList();

            // Process stock changes thông qua IngredientManager
            await _ingredientManager.ProcessStockChangesAsync(stockChanges);

            // Log thông tin thành công
            Logger.LogInformation("Successfully processed automatic inventory deduction for {ItemCount} order items, {IngredientCount} ingredients affected",
                orderItems.Count, stockChanges.Count);
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, "Failed to process automatic inventory deduction for order items");
            throw;
        }
    }


    /// <summary>
    /// Lấy danh sách nguyên liệu cho một món ăn
    /// </summary>
    /// <param name="menuItemId">ID món ăn</param>
    /// <returns>Danh sách nguyên liệu của món ăn</returns>
    public async Task<List<IngredientInfo>> GetIngredientsAsync(Guid menuItemId)
    {
        var ingredients = new List<IngredientInfo>();

        // Sử dụng repository method mới để lấy MenuItem với ingredients trong 1 query
        var menuItemWithIngredients = await _menuItemRepository.GetWithIngredientsAsync(menuItemId);

        if (menuItemWithIngredients?.Ingredients == null)
        {
            return ingredients; // Món không tồn tại hoặc không có nguyên liệu
        }

        foreach (var menuItemIngredient in menuItemWithIngredients.Ingredients)
        {
            // Sử dụng Ingredient đã được eager load - không cần query database
            var ingredient = menuItemIngredient.Ingredient;

            ingredients.Add(new IngredientInfo
            {
                IngredientId = menuItemIngredient.IngredientId,
                IngredientName = ingredient.Name,
                Quantity = menuItemIngredient.RequiredQuantity,
                Unit = ingredient.Unit?.Name ?? "đơn vị",
                DisplayOrder = menuItemIngredient.DisplayOrder
            });
        }

        return ingredients.OrderBy(x => x.DisplayOrder).ThenBy(x => x.IngredientName).ToList();
    }

    /// <summary>
    /// Cập nhật ingredients trong MenuItem với domain pattern
    /// </summary>
    public Task UpdateMenuItemIngredientsAsync<TIngredientDto>(
        MenuItem menuItem,
        IEnumerable<TIngredientDto> ingredientDtos) where TIngredientDto : class
    {
        var ingredientDtosList = ingredientDtos.ToList();

        // Xóa tất cả ingredients hiện tại
        menuItem.ClearIngredients();

        // Tạo ingredients mới và thêm vào
        var ingredients = ingredientDtosList.Select(dto =>
        {
            var dynamicDto = (dynamic)dto;
            return new MenuItemIngredient(
                _guidGenerator.Create(),
                menuItem.Id,
                dynamicDto.IngredientId,
                dynamicDto.RequiredQuantity,
                dynamicDto.DisplayOrder);
        });

        menuItem.AddMenuItemIngredients(_guidGenerator, ingredients);

        return Task.CompletedTask;
    }

    /// <summary>
    /// Thêm ingredients cho MenuItem mới khi tạo (sử dụng domain methods)
    /// </summary>
    public Task<MenuItem> CreateAsync<TIngredientDto>(
        MenuItem menuItem,
        IEnumerable<TIngredientDto> ingredientDtos) where TIngredientDto : class
    {
        var ingredientDtosList = ingredientDtos.ToList();

        var ingredients = ingredientDtosList.Select(dto =>
        {
            var dynamicDto = (dynamic)dto;
            return new MenuItemIngredient(
                _guidGenerator.Create(),
                menuItem.Id,
                dynamicDto.IngredientId,
                dynamicDto.RequiredQuantity,
                dynamicDto.DisplayOrder);
        });

        menuItem.AddMenuItemIngredients(_guidGenerator, ingredients);

        return Task.FromResult(menuItem);
    }
}

/// <summary>
/// Thông tin về nguyên liệu thiếu
/// </summary>
public class MissingIngredientInfo
{
    public Guid MenuItemId { get; set; }
    public string MenuItemName { get; set; } = string.Empty;
    public Guid IngredientId { get; set; }
    public string IngredientName { get; set; } = string.Empty;
    public int RequiredQuantity { get; set; }
    public int CurrentStock { get; set; }
    public string Unit { get; set; } = string.Empty;
    public int ShortageAmount { get; set; }

    /// <summary>
    /// Thông điệp hiển thị cho user (tiếng Việt)
    /// </summary>
    public string DisplayMessage =>
        $"{MenuItemName}: thiếu {IngredientName} (cần {RequiredQuantity}{Unit}, còn {CurrentStock}{Unit})";
}

/// <summary>
/// Thông tin về nguyên liệu của món ăn
/// </summary>
public class IngredientInfo
{
    public Guid IngredientId { get; set; }
    public string IngredientName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public string Unit { get; set; } = string.Empty;
    public int DisplayOrder { get; set; }
}

/// <summary>
/// DTO đại diện cho món ăn và số lượng (dùng trong tính toán nguyên liệu)
/// </summary>
public class MenuItemQuantityDto
{
    public Guid MenuItemId { get; set; }
    public int Quantity { get; set; }
}

