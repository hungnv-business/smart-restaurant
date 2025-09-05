using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using Shouldly;
using Xunit;
using SmartRestaurant.MenuManagement.MenuItems;
using SmartRestaurant.MenuManagement.MenuItemIngredients;
using SmartRestaurant.InventoryManagement.Ingredients;
using SmartRestaurant.MenuManagement.Recipes;

namespace SmartRestaurant.MenuManagement
{
    public class RecipeManagerIntegrationTests : SmartRestaurantApplicationTestBase
    {
        private readonly RecipeManager _recipeManager;
        private readonly IIngredientAppService _ingredientAppService;
        private readonly IMenuItemAppService _menuItemAppService;

        public RecipeManagerIntegrationTests()
        {
            _recipeManager = GetRequiredService<RecipeManager>();
            _ingredientAppService = GetRequiredService<IIngredientAppService>();
            _menuItemAppService = GetRequiredService<IMenuItemAppService>();
        }

        [Fact]
        public async Task CheckIngredientAvailabilityAsync_Should_Return_Missing_Ingredients()
        {
            // Arrange - Tạo ingredients với stock khác nhau
            var thitBo = await _ingredientAppService.CreateAsync(new CreateUpdateIngredientDto
            {
                Name = "Thịt bò",
                Unit = "g",
                CurrentStock = 100,
                MinimumStock = 50,
                UnitCost = 150m
            });

            var banhPho = await _ingredientAppService.CreateAsync(new CreateUpdateIngredientDto
            {
                Name = "Bánh phở",
                Unit = "suất",
                CurrentStock = 5,
                MinimumStock = 10,
                UnitCost = 5000m
            });

            var hanhLa = await _ingredientAppService.CreateAsync(new CreateUpdateIngredientDto
            {
                Name = "Hành lá",
                Unit = "g", 
                CurrentStock = 200,
                MinimumStock = 100,
                UnitCost = 10m
            });

            // Tạo menu item Phở Bò với recipes
            var phoBoMenuItem = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Phở Bò",
                Description = "Phở bò truyền thống",
                Price = 65000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            // Tạo recipes - thịt bò cần 150g (thiếu 50g), bánh phở cần 1 suất (đủ), hành lá cần 10g (đủ)
            await CreateMenuItemIngredientAsync(phoBoMenuItem.Id, thitBo.Id, 150, false);
            await CreateMenuItemIngredientAsync(phoBoMenuItem.Id, banhPho.Id, 1, false);
            await CreateMenuItemIngredientAsync(phoBoMenuItem.Id, hanhLa.Id, 10, true); // Optional

            var orderItems = new List<(Guid menuItemId, int quantity)>
            {
                (phoBoMenuItem.Id, 1) // 1 suất Phở Bò
            };

            // Act - Kiểm tra ingredient availability
            var missingIngredients = await _recipeManager.CheckIngredientAvailabilityAsync(orderItems);

            // Assert - Phải có 1 missing ingredient (thịt bò)
            missingIngredients.Count.ShouldBe(1);
            var missingThitBo = missingIngredients[0];
            missingThitBo.IngredientName.ShouldBe("Thịt bò");
            missingThitBo.RequiredQuantity.ShouldBe(150);
            missingThitBo.CurrentStock.ShouldBe(100);
            missingThitBo.MissingQuantity.ShouldBe(50);
            missingThitBo.IsOptional.ShouldBe(false);
        }

        [Fact]
        public async Task ReserveIngredientsAsync_Should_Reduce_Stock()
        {
            // Arrange - Tạo ingredient với stock đủ
            var ingredient = await _ingredientAppService.CreateAsync(new CreateUpdateIngredientDto
            {
                Name = "Thịt gà",
                Unit = "g",
                CurrentStock = 500,
                MinimumStock = 100,
                UnitCost = 120m
            });

            var menuItem = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Phở Gà",
                Price = 60000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            await CreateMenuItemIngredientAsync(menuItem.Id, ingredient.Id, 120, false);

            var orderItems = new List<(Guid menuItemId, int quantity)>
            {
                (menuItem.Id, 2) // 2 suất = 240g thịt gà
            };

            // Act - Reserve ingredients
            await _recipeManager.ReserveIngredientsAsync(orderItems);

            // Assert - Stock phải giảm
            var updatedIngredient = await _ingredientAppService.GetAsync(ingredient.Id);
            updatedIngredient.CurrentStock.ShouldBe(260); // 500 - 240
        }

        [Fact]
        public async Task ReleaseIngredientsAsync_Should_Restore_Stock()
        {
            // Arrange - Tạo và reserve ingredients trước
            var ingredient = await _ingredientAppService.CreateAsync(new CreateUpdateIngredientDto
            {
                Name = "Cà chua",
                Unit = "g",
                CurrentStock = 300,
                MinimumStock = 50,
                UnitCost = 20m
            });

            var menuItem = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Salad",
                Price = 35000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            await CreateMenuItemIngredientAsync(menuItem.Id, ingredient.Id, 80, false);

            var orderItems = new List<(Guid menuItemId, int quantity)>
            {
                (menuItem.Id, 2) // 2 suất = 160g cà chua
            };

            await _recipeManager.ReserveIngredientsAsync(orderItems); // Stock = 140

            // Act - Release ingredients (vd: cancel order)
            await _recipeManager.ReleaseIngredientsAsync(orderItems);

            // Assert - Stock phải được khôi phục
            var restoredIngredient = await _ingredientAppService.GetAsync(ingredient.Id);
            restoredIngredient.CurrentStock.ShouldBe(300); // Khôi phục về ban đầu
        }

        [Fact]
        public async Task GetMenuItemRecipeAsync_Should_Return_Complete_Recipe()
        {
            // Arrange - Tạo menu item với nhiều ingredients
            var menuItem = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Bún Bò Huế",
                Description = "Bún bò Huế cay nồng",
                Price = 70000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            var thitBo = await _ingredientAppService.CreateAsync(new CreateUpdateIngredientDto
            {
                Name = "Thịt bò",
                Unit = "g",
                CurrentStock = 1000,
                MinimumStock = 200,
                UnitCost = 150m
            });

            var bunBo = await _ingredientAppService.CreateAsync(new CreateUpdateIngredientDto
            {
                Name = "Bún bò",
                Unit = "suất",
                CurrentStock = 50,
                MinimumStock = 20,
                UnitCost = 8000m
            });

            var otTuong = await _ingredientAppService.CreateAsync(new CreateUpdateIngredientDto
            {
                Name = "Ớt tương",
                Unit = "g",
                CurrentStock = 500,
                MinimumStock = 100,
                UnitCost = 30m
            });

            // Tạo recipe
            await CreateMenuItemIngredientAsync(menuItem.Id, thitBo.Id, 120, false);
            await CreateMenuItemIngredientAsync(menuItem.Id, bunBo.Id, 1, false);
            await CreateMenuItemIngredientAsync(menuItem.Id, otTuong.Id, 20, true); // Optional

            // Act - Lấy recipe
            var recipe = await _recipeManager.GetMenuItemRecipeAsync(menuItem.Id);

            // Assert - Recipe phải complete
            recipe.ShouldNotBeNull();
            recipe.MenuItemId.ShouldBe(menuItem.Id);
            recipe.MenuItemName.ShouldBe("Bún Bò Huế");
            recipe.Ingredients.Count.ShouldBe(3);
            
            // Kiểm tra ingredients chi tiết
            var thitBoIngredient = recipe.Ingredients.Find(i => i.IngredientName == "Thịt bò");
            thitBoIngredient.ShouldNotBeNull();
            thitBoIngredient.RequiredQuantity.ShouldBe(120);
            thitBoIngredient.IsOptional.ShouldBe(false);

            var otTuongIngredient = recipe.Ingredients.Find(i => i.IngredientName == "Ớt tương");
            otTuongIngredient.ShouldNotBeNull();
            otTuongIngredient.IsOptional.ShouldBe(true);
        }

        [Fact]
        public async Task CanFulfillOrderAsync_Should_Check_All_Items_Availability()
        {
            // Arrange - Tạo 2 menu items: 1 có đủ ingredient, 1 thiếu
            var availableIngredient = await _ingredientAppService.CreateAsync(new CreateUpdateIngredientDto
            {
                Name = "Rau muống",
                Unit = "g",
                CurrentStock = 500,
                MinimumStock = 100,
                UnitCost = 15m
            });

            var unavailableIngredient = await _ingredientAppService.CreateAsync(new CreateUpdateIngredientDto
            {
                Name = "Tôm tươi",
                Unit = "g", 
                CurrentStock = 50,
                MinimumStock = 100,
                UnitCost = 200m
            });

            var availableMenuItem = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Rau muống xào tỏi",
                Price = 30000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            var unavailableMenuItem = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Tôm rang me",
                Price = 120000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            await CreateMenuItemIngredientAsync(availableMenuItem.Id, availableIngredient.Id, 100, false);
            await CreateMenuItemIngredientAsync(unavailableMenuItem.Id, unavailableIngredient.Id, 200, false); // Cần 200g, chỉ có 50g

            var orderItems = new List<(Guid menuItemId, int quantity)>
            {
                (availableMenuItem.Id, 1),
                (unavailableMenuItem.Id, 1)
            };

            // Act - Kiểm tra có thể fulfill không
            var (canFulfill, missingIngredients) = await _recipeManager.CanFulfillOrderAsync(orderItems);

            // Assert - Không thể fulfill vì thiếu tôm
            canFulfill.ShouldBe(false);
            missingIngredients.Count.ShouldBe(1);
            missingIngredients[0].IngredientName.ShouldBe("Tôm tươi");
            missingIngredients[0].MissingQuantity.ShouldBe(150); // 200 - 50
        }

        private async Task<MenuItemIngredient> CreateMenuItemIngredientAsync(
            Guid menuItemId,
            Guid ingredientId,
            int requiredQuantity,
            bool isOptional)
        {
            var menuItemIngredient = new MenuItemIngredient
            {
                Id = Guid.NewGuid(),
                MenuItemId = menuItemId,
                IngredientId = ingredientId,
                RequiredQuantity = requiredQuantity,
                IsOptional = isOptional
            };

            return await _menuItemIngredientRepository.InsertAsync(menuItemIngredient, autoSave: true);
        }
    }
}