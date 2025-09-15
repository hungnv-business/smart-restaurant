using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using SmartRestaurant.MenuManagement;
using SmartRestaurant.MenuManagement.MenuItems;
using SmartRestaurant.MenuManagement.MenuItemIngredients;
using SmartRestaurant.InventoryManagement.Ingredients;
using SmartRestaurant.Application.Contracts.Orders.Dto;
using Shouldly;
using Volo.Abp.Domain.Repositories;
using Xunit;
using NSubstitute;

namespace SmartRestaurant.Domain.Tests.MenuManagement
{
    /// <summary>
    /// Unit tests cho RecipeManager Domain Service
    /// Kiểm thử logic tính toán nguyên liệu và inventory management
    /// </summary>
    public sealed class RecipeManager_Tests : SmartRestaurantDomainTestBase
    {
        private readonly RecipeManager _recipeManager;
        private readonly IMenuItemRepository _menuItemRepository;
        private readonly IRepository<MenuItemIngredient, Guid> _menuItemIngredientRepository;
        private readonly IngredientManager _ingredientManager;

        public RecipeManager_Tests()
        {
            _menuItemRepository = Substitute.For<IMenuItemRepository>();
            _menuItemIngredientRepository = Substitute.For<IRepository<MenuItemIngredient, Guid>>();
            _ingredientManager = Substitute.For<IngredientManager>();

            _recipeManager = new RecipeManager(
                _menuItemRepository,
                _menuItemIngredientRepository,
                _ingredientManager);
        }

        #region Ingredient Availability Tests

        [Fact]
        public async Task CheckIngredientAvailabilityAsync_WithSufficientStock_ShouldReturnEmpty()
        {
            // Arrange
            var menuItemId = Guid.NewGuid();
            var ingredientId = Guid.NewGuid();

            var menuItem = CreateTestMenuItem(menuItemId);
            var ingredient = CreateTestIngredient(ingredientId, currentStock: 1000);
            var menuItemIngredient = CreateTestMenuItemIngredient(menuItemId, ingredientId, requiredQuantity: 200);

            _menuItemRepository.GetAsync(menuItemId, true, default).Returns(menuItem);
            _menuItemIngredientRepository.GetQueryableAsync().Returns(new List<MenuItemIngredient> { menuItemIngredient }.AsQueryable());
            _ingredientManager.GetByIdAsync(ingredientId).Returns(ingredient);

            // Act
            var result = await _recipeManager.CheckIngredientAvailabilityAsync(menuItemId);

            // Assert
            result.ShouldBeEmpty();
        }

        [Fact]
        public async Task CheckIngredientAvailabilityAsync_WithInsufficientStock_ShouldReturnMissingIngredients()
        {
            // Arrange
            var menuItemId = Guid.NewGuid();
            var ingredientId = Guid.NewGuid();

            var menuItem = CreateTestMenuItem(menuItemId);
            var ingredient = CreateTestIngredient(ingredientId, currentStock: 100);
            var menuItemIngredient = CreateTestMenuItemIngredient(menuItemId, ingredientId, requiredQuantity: 200);

            _menuItemRepository.GetAsync(menuItemId, true, default).Returns(menuItem);
            _menuItemIngredientRepository.GetQueryableAsync().Returns(new List<MenuItemIngredient> { menuItemIngredient }.AsQueryable());
            _ingredientManager.GetByIdAsync(ingredientId).Returns(ingredient);

            // Act
            var result = await _recipeManager.CheckIngredientAvailabilityAsync(menuItemId);

            // Assert
            result.ShouldNotBeEmpty();
            result.Count.ShouldBe(1);
            
            var missingIngredient = result.First();
            missingIngredient.IngredientName.ShouldBe(ingredient.Name);
            missingIngredient.MenuItemName.ShouldBe(menuItem.Name);
            missingIngredient.RequiredQuantity.ShouldBe(200);
            missingIngredient.CurrentStock.ShouldBe(100);
            missingIngredient.Unit.ShouldBe(ingredient.BaseUnit.Name);
        }

        [Fact]
        public async Task CheckIngredientAvailabilityAsync_WithNegativeStock_ShouldReturnMissingIngredients()
        {
            // Arrange
            var menuItemId = Guid.NewGuid();
            var ingredientId = Guid.NewGuid();

            var menuItem = CreateTestMenuItem(menuItemId);
            var ingredient = CreateTestIngredient(ingredientId, currentStock: -50);
            var menuItemIngredient = CreateTestMenuItemIngredient(menuItemId, ingredientId, requiredQuantity: 200);

            _menuItemRepository.GetAsync(menuItemId, true, default).Returns(menuItem);
            _menuItemIngredientRepository.GetQueryableAsync().Returns(new List<MenuItemIngredient> { menuItemIngredient }.AsQueryable());
            _ingredientManager.GetByIdAsync(ingredientId).Returns(ingredient);

            // Act
            var result = await _recipeManager.CheckIngredientAvailabilityAsync(menuItemId);

            // Assert
            result.ShouldNotBeEmpty();
            result.Count.ShouldBe(1);
            
            var missingIngredient = result.First();
            missingIngredient.CurrentStock.ShouldBe(-50);
            missingIngredient.RequiredQuantity.ShouldBe(200);
        }

        #endregion

        #region Required Ingredients Calculation Tests

        [Fact]
        public async Task CalculateRequiredIngredientsAsync_WithMultipleItems_ShouldReturnCorrectTotals()
        {
            // Arrange
            var menuItem1Id = Guid.NewGuid();
            var menuItem2Id = Guid.NewGuid();
            var ingredient1Id = Guid.NewGuid();
            var ingredient2Id = Guid.NewGuid();

            var orderItems = new List<CreateOrderItemDto>
            {
                new CreateOrderItemDto { MenuItemId = menuItem1Id, Quantity = 2 },
                new CreateOrderItemDto { MenuItemId = menuItem2Id, Quantity = 1 }
            };

            var menuItemIngredients = new List<MenuItemIngredient>
            {
                CreateTestMenuItemIngredient(menuItem1Id, ingredient1Id, 200), // Món 1 cần 200g nguyên liệu 1
                CreateTestMenuItemIngredient(menuItem1Id, ingredient2Id, 100), // Món 1 cần 100g nguyên liệu 2
                CreateTestMenuItemIngredient(menuItem2Id, ingredient1Id, 150)  // Món 2 cần 150g nguyên liệu 1
            };

            _menuItemIngredientRepository.GetQueryableAsync().Returns(menuItemIngredients.AsQueryable());

            // Act
            var result = await _recipeManager.CalculateRequiredIngredientsAsync(orderItems);

            // Assert
            result.ShouldNotBeEmpty();
            result.Count.ShouldBe(2);
            
            // Nguyên liệu 1: (2 * 200) + (1 * 150) = 550
            result[ingredient1Id].ShouldBe(550);
            
            // Nguyên liệu 2: (2 * 100) = 200
            result[ingredient2Id].ShouldBe(200);
        }

        [Fact]
        public async Task CalculateRequiredIngredientsAsync_WithEmptyOrderItems_ShouldReturnEmpty()
        {
            // Arrange
            var orderItems = new List<CreateOrderItemDto>();

            // Act
            var result = await _recipeManager.CalculateRequiredIngredientsAsync(orderItems);

            // Assert
            result.ShouldBeEmpty();
        }

        #endregion

        #region Missing Ingredients Check Tests

        [Fact]
        public async Task CheckMissingIngredientsAsync_WithSufficientStock_ShouldReturnEmpty()
        {
            // Arrange
            var menuItemId = Guid.NewGuid();
            var ingredientId = Guid.NewGuid();

            var orderItems = new List<CreateOrderItemDto>
            {
                new CreateOrderItemDto { MenuItemId = menuItemId, Quantity = 1 }
            };

            var menuItemIngredient = CreateTestMenuItemIngredient(menuItemId, ingredientId, 200);
            var ingredient = CreateTestIngredient(ingredientId, currentStock: 500);

            _menuItemIngredientRepository.GetQueryableAsync().Returns(new List<MenuItemIngredient> { menuItemIngredient }.AsQueryable());
            _ingredientManager.GetByIdAsync(ingredientId).Returns(ingredient);

            // Act
            var result = await _recipeManager.CheckMissingIngredientsAsync(orderItems);

            // Assert
            result.ShouldBeEmpty();
        }

        [Fact]
        public async Task CheckMissingIngredientsAsync_WithInsufficientStock_ShouldReturnMissingList()
        {
            // Arrange
            var menuItemId = Guid.NewGuid();
            var ingredientId = Guid.NewGuid();

            var orderItems = new List<CreateOrderItemDto>
            {
                new CreateOrderItemDto { MenuItemId = menuItemId, Quantity = 3 }
            };

            var menuItemIngredient = CreateTestMenuItemIngredient(menuItemId, ingredientId, 200);
            var ingredient = CreateTestIngredient(ingredientId, currentStock: 500);

            _menuItemIngredientRepository.GetQueryableAsync().Returns(new List<MenuItemIngredient> { menuItemIngredient }.AsQueryable());
            _ingredientManager.GetByIdAsync(ingredientId).Returns(ingredient);

            // Act - Cần 3 * 200 = 600, nhưng chỉ có 500
            var result = await _recipeManager.CheckMissingIngredientsAsync(orderItems);

            // Assert
            result.ShouldNotBeEmpty();
            result.Count.ShouldBe(1);
            
            var missingIngredient = result.First();
            missingIngredient.RequiredQuantity.ShouldBe(600);
            missingIngredient.CurrentStock.ShouldBe(500);
        }

        #endregion

        #region Automatic Deduction Tests

        [Fact]
        public async Task ProcessAutomaticDeductionAsync_WithValidItems_ShouldCallIngredientManager()
        {
            // Arrange
            var menuItemId = Guid.NewGuid();
            var ingredientId = Guid.NewGuid();

            var orderItems = new List<CreateOrderItemDto>
            {
                new CreateOrderItemDto { MenuItemId = menuItemId, Quantity = 2 }
            };

            var menuItemIngredient = CreateTestMenuItemIngredient(menuItemId, ingredientId, 200);
            _menuItemIngredientRepository.GetQueryableAsync().Returns(new List<MenuItemIngredient> { menuItemIngredient }.AsQueryable());

            // Act
            await _recipeManager.ProcessAutomaticDeductionAsync(orderItems);

            // Assert
            await _ingredientManager.Received(1).DeductStockAsync(ingredientId, 400); // 2 * 200
        }

        [Fact]
        public async Task ProcessAutomaticDeductionAsync_WithMultipleIngredients_ShouldDeductAll()
        {
            // Arrange
            var menuItemId = Guid.NewGuid();
            var ingredient1Id = Guid.NewGuid();
            var ingredient2Id = Guid.NewGuid();

            var orderItems = new List<CreateOrderItemDto>
            {
                new CreateOrderItemDto { MenuItemId = menuItemId, Quantity = 1 }
            };

            var menuItemIngredients = new List<MenuItemIngredient>
            {
                CreateTestMenuItemIngredient(menuItemId, ingredient1Id, 200),
                CreateTestMenuItemIngredient(menuItemId, ingredient2Id, 100)
            };

            _menuItemIngredientRepository.GetQueryableAsync().Returns(menuItemIngredients.AsQueryable());

            // Act
            await _recipeManager.ProcessAutomaticDeductionAsync(orderItems);

            // Assert
            await _ingredientManager.Received(1).DeductStockAsync(ingredient1Id, 200);
            await _ingredientManager.Received(1).DeductStockAsync(ingredient2Id, 100);
        }

        #endregion

        #region Helper Methods

        private MenuItem CreateTestMenuItem(Guid id)
        {
            return new MenuItem(
                id,
                "Phở Bò",
                "Phở bò tái nạm",
                50000m,
                Guid.NewGuid());
        }

        private Ingredient CreateTestIngredient(Guid id, int currentStock = 1000)
        {
            var baseUnit = new Unit(Guid.NewGuid(), "gram", "g", 1, 0);
            return new Ingredient(
                id,
                "Thịt bò",
                "Thịt bò tươi",
                baseUnit.Id,
                Guid.NewGuid(),
                currentStock);
        }

        private MenuItemIngredient CreateTestMenuItemIngredient(Guid menuItemId, Guid ingredientId, int requiredQuantity)
        {
            return new MenuItemIngredient(
                Guid.NewGuid(),
                menuItemId,
                ingredientId,
                requiredQuantity);
        }

        #endregion
    }
}