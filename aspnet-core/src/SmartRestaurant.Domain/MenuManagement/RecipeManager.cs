using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Domain.Services;
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
    private readonly IRepository<Ingredient, Guid> _ingredientRepository;
    private readonly IRepository<MenuItem, Guid> _menuItemRepository;

    public RecipeManager(
        IRepository<MenuItemIngredient, Guid> menuItemIngredientRepository,
        IRepository<Ingredient, Guid> ingredientRepository,
        IRepository<MenuItem, Guid> menuItemRepository)
    {
        _menuItemIngredientRepository = menuItemIngredientRepository;
        _ingredientRepository = ingredientRepository;
        _menuItemRepository = menuItemRepository;
    }

    /// <summary>
    /// Kiểm tra tình trạng nguyên liệu có sẵn cho một món ăn
    /// </summary>
    /// <param name="menuItemId">ID món ăn</param>
    /// <returns>Danh sách nguyên liệu thiếu (nếu có)</returns>
    public async Task<List<MissingIngredientInfo>> CheckIngredientAvailabilityAsync(Guid menuItemId)
    {
        var missingIngredients = new List<MissingIngredientInfo>();

        // Lấy tất cả nguyên liệu của món ăn
        var menuItemIngredients = await _menuItemIngredientRepository
            .GetQueryableAsync();

        var ingredientsForItem = menuItemIngredients
            .Where(x => x.MenuItemId == menuItemId)
            .ToList();

        foreach (var menuItemIngredient in ingredientsForItem)
        {
            var ingredient = await _ingredientRepository.GetAsync(menuItemIngredient.IngredientId);
            
            // Kiểm tra xem có đủ nguyên liệu không
            if (ingredient.CurrentStock < menuItemIngredient.RequiredQuantity)
            {
                var menuItem = await _menuItemRepository.GetAsync(menuItemId);
                
                missingIngredients.Add(new MissingIngredientInfo
                {
                    MenuItemId = menuItemId,
                    MenuItemName = menuItem.Name,
                    IngredientId = menuItemIngredient.IngredientId,
                    IngredientName = ingredient.Name,
                    RequiredQuantity = menuItemIngredient.RequiredQuantity,
                    CurrentStock = ingredient.CurrentStock,
                    Unit = ingredient.Unit?.Name ?? "đơn vị",
                    IsOptional = menuItemIngredient.IsOptional,
                    ShortageAmount = menuItemIngredient.RequiredQuantity - ingredient.CurrentStock
                });
            }
        }

        return missingIngredients;
    }

    /// <summary>
    /// Tính toán tổng nguyên liệu cần thiết cho danh sách order items
    /// </summary>
    /// <param name="orderItems">Danh sách order items</param>
    /// <returns>Dictionary với IngredientId và tổng quantity cần thiết</returns>
    public async Task<Dictionary<Guid, int>> CalculateRequiredIngredientsAsync(List<OrderItemDto> orderItems)
    {
        var requiredIngredients = new Dictionary<Guid, int>();

        foreach (var orderItem in orderItems)
        {
            var menuItemIngredients = await _menuItemIngredientRepository
                .GetQueryableAsync();

            var ingredientsForItem = menuItemIngredients
                .Where(x => x.MenuItemId == orderItem.MenuItemId)
                .ToList();

            foreach (var menuItemIngredient in ingredientsForItem)
            {
                // Tính quantity cần thiết = RequiredQuantity * OrderItem.Quantity
                var totalRequired = menuItemIngredient.RequiredQuantity * orderItem.Quantity;

                if (requiredIngredients.ContainsKey(menuItemIngredient.IngredientId))
                {
                    requiredIngredients[menuItemIngredient.IngredientId] += totalRequired;
                }
                else
                {
                    requiredIngredients[menuItemIngredient.IngredientId] = totalRequired;
                }
            }
        }

        return requiredIngredients;
    }

    /// <summary>
    /// Xử lý tự động trừ kho khi đơn hàng được confirmed (hỗ trợ negative stock)
    /// </summary>
    /// <param name="orderId">ID đơn hàng</param>
    public async Task ProcessAutomaticDeductionAsync(Guid orderId)
    {
        // Lấy thông tin order items từ orderId
        // Tính toán required ingredients
        // Update ingredient stock (allow negative)
        
        Logger.LogInformation("Processing automatic inventory deduction for order {OrderId}", orderId);
        
        // TODO: Implement actual deduction logic after Order entity is available
        // This is a placeholder for the business logic
        
        // Example implementation:
        // 1. Get order items
        // 2. Calculate required ingredients using CalculateRequiredIngredientsAsync
        // 3. Update ingredient stocks (allow negative values)
        // 4. Log the deduction
        
        await Task.CompletedTask; // Placeholder
    }

    /// <summary>
    /// Lấy danh sách nguyên liệu thiếu cho một đơn hàng cụ thể
    /// </summary>
    /// <param name="orderId">ID đơn hàng</param>
    /// <returns>Danh sách nguyên liệu thiếu</returns>
    public async Task<List<MissingIngredientInfo>> GetMissingIngredientsAsync(Guid orderId)
    {
        var allMissingIngredients = new List<MissingIngredientInfo>();

        // TODO: Implement after Order entity integration
        // 1. Get order items from orderId
        // 2. For each order item, check ingredient availability
        // 3. Aggregate missing ingredients
        
        Logger.LogInformation("Getting missing ingredients for order {OrderId}", orderId);
        
        await Task.CompletedTask; // Placeholder
        return allMissingIngredients;
    }

    /// <summary>
    /// Kiểm tra logic kinh doanh cho nguyên liệu tùy chọn vs bắt buộc
    /// </summary>
    /// <param name="menuItemId">ID món ăn</param>
    /// <param name="includeOptional">Có bao gồm nguyên liệu tùy chọn không</param>
    /// <returns>Danh sách nguyên liệu cần thiết</returns>
    public async Task<List<RequiredIngredientInfo>> GetRequiredIngredientsAsync(Guid menuItemId, bool includeOptional = true)
    {
        var requiredIngredients = new List<RequiredIngredientInfo>();

        var menuItemIngredients = await _menuItemIngredientRepository
            .GetQueryableAsync();

        var ingredientsQuery = menuItemIngredients
            .Where(x => x.MenuItemId == menuItemId);

        // Lọc theo optional flag
        if (!includeOptional)
        {
            ingredientsQuery = ingredientsQuery.Where(x => !x.IsOptional);
        }

        var ingredients = ingredientsQuery.ToList();

        foreach (var menuItemIngredient in ingredients)
        {
            var ingredient = await _ingredientRepository.GetAsync(menuItemIngredient.IngredientId);

            requiredIngredients.Add(new RequiredIngredientInfo
            {
                IngredientId = menuItemIngredient.IngredientId,
                IngredientName = ingredient.Name,
                RequiredQuantity = menuItemIngredient.RequiredQuantity,
                Unit = ingredient.Unit?.Name ?? "đơn vị",
                IsOptional = menuItemIngredient.IsOptional,
                PreparationNotes = menuItemIngredient.PreparationNotes,
                DisplayOrder = menuItemIngredient.DisplayOrder
            });
        }

        return requiredIngredients.OrderBy(x => x.DisplayOrder).ThenBy(x => x.IngredientName).ToList();
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
    public bool IsOptional { get; set; }
    public int ShortageAmount { get; set; }

    /// <summary>
    /// Thông điệp hiển thị cho user (tiếng Việt)
    /// </summary>
    public string DisplayMessage => 
        $"{MenuItemName}: thiếu {IngredientName} (cần {RequiredQuantity}{Unit}, còn {CurrentStock}{Unit})";
}

/// <summary>
/// Thông tin về nguyên liệu cần thiết
/// </summary>
public class RequiredIngredientInfo
{
    public Guid IngredientId { get; set; }
    public string IngredientName { get; set; } = string.Empty;
    public int RequiredQuantity { get; set; }
    public string Unit { get; set; } = string.Empty;
    public bool IsOptional { get; set; }
    public string? PreparationNotes { get; set; }
    public int DisplayOrder { get; set; }
}

/// <summary>
/// DTO cho OrderItem (placeholder - sẽ được thay bằng actual DTO)
/// </summary>
public class OrderItemDto
{
    public Guid MenuItemId { get; set; }
    public int Quantity { get; set; }
}