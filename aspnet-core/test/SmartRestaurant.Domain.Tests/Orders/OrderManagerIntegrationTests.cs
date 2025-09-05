using System;
using System.Threading.Tasks;
using System.Linq;
using Shouldly;
using Volo.Abp.Domain.Entities;
using Xunit;
using SmartRestaurant.Orders;
using SmartRestaurant.MenuManagement.MenuItems;
using SmartRestaurant.MenuManagement.MenuItemIngredients;
using SmartRestaurant.InventoryManagement.Ingredients;

namespace SmartRestaurant.Orders
{
    public class OrderManagerIntegrationTests : SmartRestaurantDomainTestBase
    {
        private readonly OrderManager _orderManager;
        private readonly IOrderRepository _orderRepository;
        private readonly IMenuItemRepository _menuItemRepository;
        private readonly IMenuItemIngredientRepository _menuItemIngredientRepository;
        private readonly IIngredientRepository _ingredientRepository;

        public OrderManagerIntegrationTests()
        {
            _orderManager = GetRequiredService<OrderManager>();
            _orderRepository = GetRequiredService<IOrderRepository>();
            _menuItemRepository = GetRequiredService<IMenuItemRepository>();
            _menuItemIngredientRepository = GetRequiredService<IMenuItemIngredientRepository>();
            _ingredientRepository = GetRequiredService<IIngredientRepository>();
        }

        [Fact]
        public async Task CreateOrderAsync_Should_Generate_Unique_Order_Number()
        {
            // Arrange - Tạo 3 orders cùng lúc
            var menuItem = await CreateTestMenuItemAsync();
            var orders = new Order[3];

            // Act - Tạo orders đồng thời
            for (int i = 0; i < 3; i++)
            {
                orders[i] = await _orderManager.CreateOrderAsync(
                    OrderType.DineIn,
                    tableId: Guid.NewGuid(),
                    customerNote: $"Test order {i + 1}"
                );
            }

            // Assert - Tất cả order numbers phải unique
            var orderNumbers = orders.Select(o => o.OrderNumber).ToArray();
            orderNumbers.Distinct().Count().ShouldBe(3);
            orderNumbers.ShouldAllBe(on => !string.IsNullOrEmpty(on));
        }

        [Fact]
        public async Task AddItemToOrderAsync_Should_Calculate_Total_Correctly()
        {
            // Arrange - Tạo order và menu items
            var order = await CreateTestOrderAsync();
            var menuItem1 = await CreateTestMenuItemAsync("Phở Bò", 65000m);
            var menuItem2 = await CreateTestMenuItemAsync("Cơm Tấm", 55000m);

            // Act - Thêm items với quantities khác nhau
            await _orderManager.AddItemToOrderAsync(order, menuItem1.Id, 2, "Ít muối");
            await _orderManager.AddItemToOrderAsync(order, menuItem2.Id, 1, "Không cay");

            // Assert - Kiểm tra total amount
            order.Items.Count.ShouldBe(2);
            order.TotalAmount.ShouldBe(185000m); // (65000 * 2) + (55000 * 1)
            
            // Kiểm tra chi tiết items
            var phoItem = order.Items.FirstOrDefault(i => i.MenuItemId == menuItem1.Id);
            phoItem.ShouldNotBeNull();
            phoItem.Quantity.ShouldBe(2);
            phoItem.UnitPrice.ShouldBe(65000m);
            phoItem.Notes.ShouldBe("Ít muối");
        }

        [Fact]
        public async Task ConfirmOrderAsync_Should_Check_Ingredient_Availability()
        {
            // Arrange - Tạo menu item với ingredient thiếu
            var ingredient = await CreateTestIngredientAsync("Thịt bò", currentStock: 100);
            var menuItem = await CreateTestMenuItemWithIngredientAsync("Phở Bò", ingredient.Id, requiredQuantity: 150);
            var order = await CreateTestOrderAsync();
            
            await _orderManager.AddItemToOrderAsync(order, menuItem.Id, 1);

            // Act & Assert - Confirm order phải báo lỗi thiếu ingredient
            var exception = await Should.ThrowAsync<BusinessException>(
                () => _orderManager.ConfirmOrderAsync(order.Id)
            );

            exception.Code.ShouldBe(OrderErrorCodes.InsufficientIngredients);
            exception.Data["MissingIngredients"].ShouldNotBeNull();
        }

        [Fact]
        public async Task ConfirmOrderAsync_Should_Reduce_Ingredient_Stock()
        {
            // Arrange - Tạo menu item với ingredient đủ
            var ingredient = await CreateTestIngredientAsync("Thịt bò", currentStock: 500);
            var menuItem = await CreateTestMenuItemWithIngredientAsync("Phở Bò", ingredient.Id, requiredQuantity: 150);
            var order = await CreateTestOrderAsync();
            
            await _orderManager.AddItemToOrderAsync(order, menuItem.Id, 2); // 2 suất = 300g thịt

            // Act - Confirm order
            await _orderManager.ConfirmOrderAsync(order.Id);

            // Assert - Stock phải giảm
            var updatedIngredient = await _ingredientRepository.GetAsync(ingredient.Id);
            updatedIngredient.CurrentStock.ShouldBe(200); // 500 - (150 * 2)
        }

        [Fact]
        public async Task UpdateOrderItemStatusAsync_Should_Trigger_Order_Status_Update()
        {
            // Arrange - Tạo order với nhiều items và confirm
            var order = await CreateTestOrderWithMultipleItemsAsync();
            await _orderManager.ConfirmOrderAsync(order.Id);
            await _orderManager.UpdateOrderStatusAsync(order.Id, OrderStatus.Preparing);

            // Act - Đặt tất cả items thành Ready
            foreach (var item in order.Items)
            {
                await _orderManager.UpdateOrderItemStatusAsync(item.Id, OrderItemStatus.Ready);
            }

            // Assert - Order status phải auto-update thành Ready
            var updatedOrder = await _orderRepository.GetAsync(order.Id);
            updatedOrder.Status.ShouldBe(OrderStatus.Ready);
        }

        [Fact]
        public async Task CancelOrderAsync_Should_Restore_Ingredient_Stock()
        {
            // Arrange - Tạo và confirm order (đã giảm stock)
            var ingredient = await CreateTestIngredientAsync("Thịt gà", currentStock: 300);
            var menuItem = await CreateTestMenuItemWithIngredientAsync("Phở Gà", ingredient.Id, requiredQuantity: 100);
            var order = await CreateTestOrderAsync();
            
            await _orderManager.AddItemToOrderAsync(order, menuItem.Id, 2);
            await _orderManager.ConfirmOrderAsync(order.Id); // Stock giảm xuống 100

            // Act - Cancel order
            await _orderManager.CancelOrderAsync(order.Id, "Khách hàng hủy");

            // Assert - Stock phải được khôi phục
            var restoredIngredient = await _ingredientRepository.GetAsync(ingredient.Id);
            restoredIngredient.CurrentStock.ShouldBe(300); // Khôi phục về ban đầu
            
            var cancelledOrder = await _orderRepository.GetAsync(order.Id);
            cancelledOrder.Status.ShouldBe(OrderStatus.Cancelled);
        }

        private async Task<Order> CreateTestOrderAsync()
        {
            return await _orderManager.CreateOrderAsync(
                OrderType.DineIn,
                tableId: Guid.NewGuid(),
                customerNote: "Test order"
            );
        }

        private async Task<Order> CreateTestOrderWithMultipleItemsAsync()
        {
            var order = await CreateTestOrderAsync();
            var menuItem1 = await CreateTestMenuItemAsync("Test Item 1", 50000m);
            var menuItem2 = await CreateTestMenuItemAsync("Test Item 2", 60000m);

            await _orderManager.AddItemToOrderAsync(order, menuItem1.Id, 1);
            await _orderManager.AddItemToOrderAsync(order, menuItem2.Id, 1);

            return order;
        }

        private async Task<MenuItem> CreateTestMenuItemAsync(string name = "Test Menu Item", decimal price = 50000m)
        {
            var menuItem = new MenuItem
            {
                Id = Guid.NewGuid(),
                Name = name,
                Description = $"Mô tả cho {name}",
                Price = price,
                IsAvailable = true,
                CategoryId = Guid.NewGuid()
            };

            return await _menuItemRepository.InsertAsync(menuItem, autoSave: true);
        }

        private async Task<MenuItem> CreateTestMenuItemWithIngredientAsync(
            string menuItemName, 
            Guid ingredientId, 
            int requiredQuantity)
        {
            var menuItem = await CreateTestMenuItemAsync(menuItemName);
            
            var menuItemIngredient = new MenuItemIngredient
            {
                Id = Guid.NewGuid(),
                MenuItemId = menuItem.Id,
                IngredientId = ingredientId,
                RequiredQuantity = requiredQuantity,
                IsOptional = false
            };

            await _menuItemIngredientRepository.InsertAsync(menuItemIngredient, autoSave: true);
            
            return menuItem;
        }

        private async Task<Ingredient> CreateTestIngredientAsync(string name, int currentStock)
        {
            var ingredient = new Ingredient
            {
                Id = Guid.NewGuid(),
                Name = name,
                Unit = "g",
                CurrentStock = currentStock,
                MinimumStock = 50,
                UnitCost = 1000m
            };

            return await _ingredientRepository.InsertAsync(ingredient, autoSave: true);
        }
    }
}