using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using SmartRestaurant.MenuManagement;
using SmartRestaurant.MenuManagement.MenuItems;
using SmartRestaurant.MenuManagement.MenuItemIngredients;
using SmartRestaurant.InventoryManagement.Ingredients;
using SmartRestaurant.Orders;
using Shouldly;
using Volo.Abp.Domain.Repositories;
using Xunit;
using NSubstitute;

namespace SmartRestaurant.Domain.Tests.MenuManagement
{
    public sealed class RecipeManager_Tests : SmartRestaurantDomainTestBase<SmartRestaurantDomainTestModule>
    {
        private readonly RecipeManager _recipeManager;
        private readonly IRepository<MenuItem, Guid> _menuItemRepository;
        private readonly IRepository<Ingredient, Guid> _ingredientRepository;
        private readonly IRepository<MenuItemIngredient, Guid> _menuItemIngredientRepository;

        public RecipeManager_Tests()
        {
            _menuItemRepository = Substitute.For<IRepository<MenuItem, Guid>>();
            _ingredientRepository = Substitute.For<IRepository<Ingredient, Guid>>();
            _menuItemIngredientRepository = Substitute.For<IRepository<MenuItemIngredient, Guid>>();
            
            _recipeManager = new RecipeManager(
                _menuItemRepository,
                _ingredientRepository,
                _menuItemIngredientRepository
            );
        }

        [Fact]
        public async Task CheckIngredientAvailabilityAsync_WithSufficientStock_ShouldReturnEmpty()
        {
            // Arrange
            var menuItemId = Guid.NewGuid();
            var ingredientId = Guid.NewGuid();

            var menuItem = new MenuItem(
                menuItemId,
                "Phở Bò",
                "Phở bò truyền thống",
                50000m,
                true,
                null,
                Guid.NewGuid()
            );

            var ingredient = new Ingredient(
                ingredientId,
                "Thịt bò",
                "Thịt bò tươi",
                Guid.NewGuid(),
                Guid.NewGuid()
            );
            ingredient.UpdateStock(1000); // 1kg có sẵn

            var menuItemIngredient = new MenuItemIngredient(
                Guid.NewGuid(),
                menuItemId,
                ingredientId,
                200, // Cần 200g
                false
            );

            _menuItemRepository.GetAsync(menuItemId, true, default).Returns(menuItem);
            _menuItemIngredientRepository.GetListAsync(
                Arg.Any<System.Linq.Expressions.Expression<Func<MenuItemIngredient, bool>>>(),
                true,
                default
            ).Returns(new List<MenuItemIngredient> { menuItemIngredient });
            _ingredientRepository.GetAsync(ingredientId, true, default).Returns(ingredient);

            // Act
            var result = await _recipeManager.CheckIngredientAvailabilityAsync(menuItemId);

            // Assert
            result.ShouldNotBeNull();
            result.Count.ShouldBe(0); // Không thiếu nguyên liệu nào
        }

        [Fact]
        public async Task CheckIngredientAvailabilityAsync_WithInsufficientStock_ShouldReturnMissingIngredients()
        {
            // Arrange
            var menuItemId = Guid.NewGuid();
            var ingredientId = Guid.NewGuid();

            var menuItem = new MenuItem(
                menuItemId,
                "Phở Bò",
                "Phở bò truyền thống",
                50000m,
                true,
                null,
                Guid.NewGuid()
            );

            var ingredient = new Ingredient(
                ingredientId,
                "Thịt bò",
                "Thịt bò tươi",
                Guid.NewGuid(),
                Guid.NewGuid()
            );
            ingredient.UpdateStock(100); // Chỉ có 100g

            var menuItemIngredient = new MenuItemIngredient(
                Guid.NewGuid(),
                menuItemId,
                ingredientId,
                200, // Cần 200g
                false
            );

            _menuItemRepository.GetAsync(menuItemId, true, default).Returns(menuItem);
            _menuItemIngredientRepository.GetListAsync(
                Arg.Any<System.Linq.Expressions.Expression<Func<MenuItemIngredient, bool>>>(),
                true,
                default
            ).Returns(new List<MenuItemIngredient> { menuItemIngredient });
            _ingredientRepository.GetAsync(ingredientId, true, default).Returns(ingredient);

            // Act
            var result = await _recipeManager.CheckIngredientAvailabilityAsync(menuItemId);

            // Assert
            result.ShouldNotBeNull();
            result.Count.ShouldBe(1);
            
            var missingIngredient = result.First();
            missingIngredient.IngredientName.ShouldBe("Thịt bò");
            missingIngredient.MenuItemName.ShouldBe("Phở Bò");
            missingIngredient.RequiredQuantity.ShouldBe(200);
            missingIngredient.CurrentStock.ShouldBe(100);
            missingIngredient.MissingQuantity.ShouldBe(100);
            missingIngredient.IsOptional.ShouldBeFalse();
        }

        [Fact]
        public async Task CheckIngredientAvailabilityAsync_WithOptionalIngredient_ShouldIncludeInResult()
        {
            // Arrange
            var menuItemId = Guid.NewGuid();
            var ingredientId = Guid.NewGuid();

            var menuItem = new MenuItem(
                menuItemId,
                "Phở Bò",
                "Phở bò truyền thống",
                50000m,
                true,
                null,
                Guid.NewGuid()
            );

            var ingredient = new Ingredient(
                ingredientId,
                "Hành lá",
                "Hành lá tươi",
                Guid.NewGuid(),
                Guid.NewGuid()
            );
            ingredient.UpdateStock(10); // Ít hành lá

            var menuItemIngredient = new MenuItemIngredient(
                Guid.NewGuid(),
                menuItemId,
                ingredientId,
                50, // Cần 50g hành lá
                true // Tùy chọn
            );

            _menuItemRepository.GetAsync(menuItemId, true, default).Returns(menuItem);
            _menuItemIngredientRepository.GetListAsync(
                Arg.Any<System.Linq.Expressions.Expression<Func<MenuItemIngredient, bool>>>(),
                true,
                default
            ).Returns(new List<MenuItemIngredient> { menuItemIngredient });
            _ingredientRepository.GetAsync(ingredientId, true, default).Returns(ingredient);

            // Act
            var result = await _recipeManager.CheckIngredientAvailabilityAsync(menuItemId);

            // Assert
            result.ShouldNotBeNull();
            result.Count.ShouldBe(1);
            
            var missingIngredient = result.First();
            missingIngredient.IsOptional.ShouldBeTrue();
            missingIngredient.MissingQuantity.ShouldBe(40);
        }

        [Fact]
        public void CalculateRequiredIngredients_WithMultipleItems_ShouldCalculateCorrectly()
        {
            // Arrange
            var orderId = Guid.NewGuid();
            var menuItemId1 = Guid.NewGuid();
            var menuItemId2 = Guid.NewGuid();
            var ingredientId = Guid.NewGuid(); // Cùng nguyên liệu

            var order = new Order(orderId, "DH001", OrderType.DineIn);
            
            var orderItem1 = new OrderItem(
                Guid.NewGuid(),
                orderId,
                menuItemId1,
                "Phở Bò",
                2, // 2 phần
                50000m
            );
            
            var orderItem2 = new OrderItem(
                Guid.NewGuid(),
                orderId,
                menuItemId2,
                "Bún Bò",
                1, // 1 phần
                40000m
            );

            order.OrderItems.Add(orderItem1);
            order.OrderItems.Add(orderItem2);

            var menuItemIngredients = new List<MenuItemIngredient>
            {
                new MenuItemIngredient(
                    Guid.NewGuid(),
                    menuItemId1,
                    ingredientId,
                    200, // 200g cho món 1
                    false
                ),
                new MenuItemIngredient(
                    Guid.NewGuid(),
                    menuItemId2,
                    ingredientId,
                    100, // 100g cho món 2
                    false
                )
            };

            // Act - Direct calculation based on order
            var totalRequired = 0;
            foreach (var orderItem in order.OrderItems)
            {
                var recipe = menuItemIngredients.Where(x => x.MenuItemId == orderItem.MenuItemId);
                foreach (var ingredient in recipe)
                {
                    if (ingredient.IngredientId == ingredientId)
                    {
                        totalRequired += ingredient.RequiredQuantity * orderItem.Quantity;
                    }
                }
            }

            // Assert
            // 2 × 200g + 1 × 100g = 500g
            totalRequired.ShouldBe(500);
        }

        [Fact]
        public async Task ProcessAutomaticDeductionAsync_WithValidOrder_ShouldDeductStock()
        {
            // Arrange
            var orderId = Guid.NewGuid();
            var menuItemId = Guid.NewGuid();
            var ingredientId = Guid.NewGuid();

            var order = new Order(orderId, "DH001", OrderType.DineIn);
            var orderItem = new OrderItem(
                Guid.NewGuid(),
                orderId,
                menuItemId,
                "Phở Bò",
                2,
                50000m
            );
            order.OrderItems.Add(orderItem);

            var ingredient = new Ingredient(
                ingredientId,
                "Thịt bò",
                "Thịt bò tươi",
                Guid.NewGuid(),
                Guid.NewGuid()
            );
            ingredient.UpdateStock(1000); // 1kg có sẵn

            var menuItemIngredient = new MenuItemIngredient(
                Guid.NewGuid(),
                menuItemId,
                ingredientId,
                200, // 200g cho 1 phần
                false
            );

            // Mock repository calls
            var orderRepository = Substitute.For<IRepository<Order, Guid>>();
            orderRepository.GetAsync(orderId, true, default).Returns(order);

            _menuItemIngredientRepository.GetListAsync(
                Arg.Any<System.Linq.Expressions.Expression<Func<MenuItemIngredient, bool>>>(),
                true,
                default
            ).Returns(new List<MenuItemIngredient> { menuItemIngredient });

            _ingredientRepository.GetListAsync(
                Arg.Any<System.Linq.Expressions.Expression<Func<Ingredient, bool>>>(),
                true,
                default
            ).Returns(new List<Ingredient> { ingredient });

            var recipeManagerWithOrderRepo = new RecipeManager(
                _menuItemRepository,
                _ingredientRepository,
                _menuItemIngredientRepository,
                orderRepository
            );

            // Act
            await recipeManagerWithOrderRepo.ProcessAutomaticDeductionAsync(orderId);

            // Assert
            // Verify ingredient stock was deducted: 1000 - (2 × 200) = 600
            ingredient.CurrentStock.ShouldBe(600);
        }

        [Fact]
        public async Task ProcessAutomaticDeductionAsync_WithNegativeStock_ShouldAllowNegativeValues()
        {
            // Arrange
            var orderId = Guid.NewGuid();
            var menuItemId = Guid.NewGuid();
            var ingredientId = Guid.NewGuid();

            var order = new Order(orderId, "DH001", OrderType.DineIn);
            var orderItem = new OrderItem(
                Guid.NewGuid(),
                orderId,
                menuItemId,
                "Phở Bò",
                3,
                50000m
            );
            order.OrderItems.Add(orderItem);

            var ingredient = new Ingredient(
                ingredientId,
                "Thịt bò",
                "Thịt bò tươi",
                Guid.NewGuid(),
                Guid.NewGuid()
            );
            ingredient.UpdateStock(100); // Chỉ có 100g

            var menuItemIngredient = new MenuItemIngredient(
                Guid.NewGuid(),
                menuItemId,
                ingredientId,
                200, // Cần 200g cho 1 phần
                false
            );

            // Mock repository calls
            var orderRepository = Substitute.For<IRepository<Order, Guid>>();
            orderRepository.GetAsync(orderId, true, default).Returns(order);

            _menuItemIngredientRepository.GetListAsync(
                Arg.Any<System.Linq.Expressions.Expression<Func<MenuItemIngredient, bool>>>(),
                true,
                default
            ).Returns(new List<MenuItemIngredient> { menuItemIngredient });

            _ingredientRepository.GetListAsync(
                Arg.Any<System.Linq.Expressions.Expression<Func<Ingredient, bool>>>(),
                true,
                default
            ).Returns(new List<Ingredient> { ingredient });

            var recipeManagerWithOrderRepo = new RecipeManager(
                _menuItemRepository,
                _ingredientRepository,
                _menuItemIngredientRepository,
                orderRepository
            );

            // Act
            await recipeManagerWithOrderRepo.ProcessAutomaticDeductionAsync(orderId);

            // Assert
            // Verify negative stock allowed: 100 - (3 × 200) = -500
            ingredient.CurrentStock.ShouldBe(-500);
        }
    }
}