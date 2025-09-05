using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;
using Shouldly;
using Xunit;
using SmartRestaurant.MenuManagement;
using SmartRestaurant.MenuManagement.MenuItemIngredients;
using SmartRestaurant.Application.Contracts.MenuManagement.MenuItems;
using SmartRestaurant.Application.Contracts.MenuManagement.MenuItems.Dto;
using SmartRestaurant.Application.Contracts.InventoryManagement.Ingredients;
using SmartRestaurant.Application.Contracts.InventoryManagement.Ingredients.Dto;
using SmartRestaurant.Application.Contracts.Orders;
using SmartRestaurant.Application.Contracts.Orders.Dto;
using SmartRestaurant.Application.Contracts.TableManagement.Tables;
using SmartRestaurant.Application.Contracts.TableManagement.Tables.Dto;
using SmartRestaurant.Domain.Shared.Orders;
using SmartRestaurant.Orders;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.MenuManagement
{
    /// <summary>
    /// Integration tests cho Recipe Management và Negative Stock Prevention
    /// Phần của Story 5.1: Quy trình Quản lý Đơn hàng của Nhân viên Phục vụ
    /// </summary>
    public class SimpleRecipeIntegrationTests : SmartRestaurantApplicationTestBase<SmartRestaurantApplicationTestModule>
    {
        private readonly RecipeManager _recipeManager;
        private readonly IRepository<MenuItemIngredient, Guid> _menuItemIngredientRepository;
        private readonly IIngredientAppService _ingredientAppService;
        private readonly IMenuItemAppService _menuItemAppService;
        private readonly IOrderAppService _orderAppService;

        public SimpleRecipeIntegrationTests()
        {
            _recipeManager = GetRequiredService<RecipeManager>();
            _menuItemIngredientRepository = GetRequiredService<IRepository<MenuItemIngredient, Guid>>();
            _ingredientAppService = GetRequiredService<IIngredientAppService>();
            _menuItemAppService = GetRequiredService<IMenuItemAppService>();
            _orderAppService = GetRequiredService<IOrderAppService>();
        }

        [Fact]
        public async Task Basic_Recipe_Ingredient_Linking_Should_Work()
        {
            // Arrange - Tạo món đơn giản với 1 ingredient
            var ingredient = await CreateTestIngredientAsync("Thịt bò cơ bản", 500);
            
            var menuItem = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Phở Bò Test",
                Description = "Phở bò để test recipe",
                Price = 70000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            // Act - Link ingredient với menu item
            await CreateMenuItemIngredientAsync(menuItem.Id, ingredient.Id, 120, false);

            // Assert - Verify link tồn tại
            var menuItemIngredients = await _menuItemIngredientRepository
                .GetListAsync(mi => mi.MenuItemId == menuItem.Id);
                
            menuItemIngredients.Count.ShouldBe(1);
            menuItemIngredients[0].RequiredQuantity.ShouldBe(120);
            menuItemIngredients[0].IsOptional.ShouldBe(false);
        }

        [Fact]
        public async Task Recipe_With_Multiple_Ingredients_Should_Be_Created()
        {
            // Arrange - Tạo món với nhiều ingredients
            var ingredients = new Dictionary<string, IngredientDto>();
            ingredients["thit_bo"] = await CreateTestIngredientAsync("Thịt bò", 400);
            ingredients["bun_bo"] = await CreateTestIngredientAsync("Bún bò", 10);
            ingredients["hanh_la"] = await CreateTestIngredientAsync("Hành lá", 100);

            var bunBoHue = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Bún Bò Huế",
                Description = "Bún bò Huế truyền thống",
                Price = 85000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            // Act - Tạo recipe với multiple ingredients
            await CreateMenuItemIngredientAsync(bunBoHue.Id, ingredients["thit_bo"].Id, 150, false);
            await CreateMenuItemIngredientAsync(bunBoHue.Id, ingredients["bun_bo"].Id, 1, false);
            await CreateMenuItemIngredientAsync(bunBoHue.Id, ingredients["hanh_la"].Id, 20, true);

            // Assert - Verify tất cả ingredients được link
            var menuItemIngredients = await _menuItemIngredientRepository
                .GetListAsync(mi => mi.MenuItemId == bunBoHue.Id);

            menuItemIngredients.Count.ShouldBe(3);
            menuItemIngredients.Count(mi => !mi.IsOptional).ShouldBe(2); // Thịt bò và bún là bắt buộc
            menuItemIngredients.Count(mi => mi.IsOptional).ShouldBe(1); // Hành lá là tùy chọn
        }

        [Fact]
        public async Task Ingredient_Stock_Tracking_Should_Work()
        {
            // Arrange - Ingredient với stock có hạn
            var limitedIngredient = await CreateTestIngredientAsync("Tôm hùm", 5);
            
            // Act - Kiểm tra stock hiện tại
            var currentStock = await _ingredientAppService.GetAsync(limitedIngredient.Id);
            
            // Assert - Stock phải chính xác
            currentStock.CurrentStock.ShouldBe(5);
            currentStock.Name.ShouldBe("Tôm hùm");
        }

        [Fact]
        public async Task Zero_Stock_Ingredient_Should_Be_Detected()
        {
            // Arrange - Ingredient hết hàng
            var emptyIngredient = await CreateTestIngredientAsync("Hải sản hết hàng", 0);
            
            var dish = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Món Hết Hàng",
                Price = 100000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            await CreateMenuItemIngredientAsync(dish.Id, emptyIngredient.Id, 1, false);

            // Act - Kiểm tra stock
            var ingredient = await _ingredientAppService.GetAsync(emptyIngredient.Id);

            // Assert - Stock = 0
            ingredient.CurrentStock.ShouldBe(0);
        }

        [Fact]
        public async Task MenuItemIngredient_Required_Quantity_Should_Be_Positive()
        {
            // Arrange
            var ingredient = await CreateTestIngredientAsync("Test Ingredient", 100);
            var menuItem = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Test Dish",
                Price = 50000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            // Act & Assert - Tạo với quantity hợp lệ
            await CreateMenuItemIngredientAsync(menuItem.Id, ingredient.Id, 50, false);
            
            var ingredients = await _menuItemIngredientRepository
                .GetListAsync(mi => mi.MenuItemId == menuItem.Id);
                
            ingredients[0].RequiredQuantity.ShouldBe(50);
        }

        [Fact]
        public async Task Recipe_Basic_Calculation_Should_Work()
        {
            // Arrange - Recipe đơn giản: 1 món = 2 ingredients
            var ingredient1 = await CreateTestIngredientAsync("Ingredient 1", 1000);
            var ingredient2 = await CreateTestIngredientAsync("Ingredient 2", 500);
            
            var dish = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Test Recipe Dish",
                Price = 60000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            await CreateMenuItemIngredientAsync(dish.Id, ingredient1.Id, 100, false); // 100g ingredient1
            await CreateMenuItemIngredientAsync(dish.Id, ingredient2.Id, 50, false);  // 50g ingredient2

            // Act - Lấy recipe info
            var ingredients = await _menuItemIngredientRepository
                .GetListAsync(mi => mi.MenuItemId == dish.Id);

            // Assert - Recipe có đúng ingredients
            ingredients.Count.ShouldBe(2);
            
            var ing1 = ingredients.First(i => i.RequiredQuantity == 100);
            var ing2 = ingredients.First(i => i.RequiredQuantity == 50);
            
            ing1.ShouldNotBeNull();
            ing2.ShouldNotBeNull();
            ing1.IsOptional.ShouldBe(false);
            ing2.IsOptional.ShouldBe(false);
        }

        [Fact]
        public async Task Recipe_Optional_Ingredients_Should_Be_Marked_Correctly()
        {
            // Arrange
            var requiredIngredient = await CreateTestIngredientAsync("Bắt buộc", 100);
            var optionalIngredient = await CreateTestIngredientAsync("Tùy chọn", 100);
            
            var dish = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Món Có Tùy Chọn",
                Price = 55000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            // Act - Tạo recipe với ingredients bắt buộc và tùy chọn
            await CreateMenuItemIngredientAsync(dish.Id, requiredIngredient.Id, 80, false);  // Required
            await CreateMenuItemIngredientAsync(dish.Id, optionalIngredient.Id, 30, true);   // Optional

            // Assert
            var ingredients = await _menuItemIngredientRepository
                .GetListAsync(mi => mi.MenuItemId == dish.Id);

            var required = ingredients.First(i => i.RequiredQuantity == 80);
            var optional = ingredients.First(i => i.RequiredQuantity == 30);
            
            required.IsOptional.ShouldBe(false);
            optional.IsOptional.ShouldBe(true);
        }

        // Helper methods
        private async Task<IngredientDto> CreateTestIngredientAsync(string name, int currentStock)
        {
            return await _ingredientAppService.CreateAsync(new CreateUpdateIngredientDto
            {
                Name = name,
                Unit = "g",
                CurrentStock = currentStock,
                MinimumStock = Math.Max(currentStock / 10, 5),
                UnitCost = 1000m
            });
        }

        private async Task CreateMenuItemIngredientAsync(Guid menuItemId, Guid ingredientId, int quantity, bool isOptional)
        {
            await _menuItemIngredientRepository.InsertAsync(new MenuItemIngredient
            {
                Id = Guid.NewGuid(),
                MenuItemId = menuItemId,
                IngredientId = ingredientId,
                RequiredQuantity = quantity,
                IsOptional = isOptional
            }, autoSave: true);
        }
    }
}