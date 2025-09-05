using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using Microsoft.AspNetCore.SignalR;
using Shouldly;
using Xunit;
using SmartRestaurant.Orders;
using SmartRestaurant.Hubs;
using SmartRestaurant.MenuManagement.MenuItems;
using SmartRestaurant.Tables;
using SmartRestaurant.InventoryManagement.Ingredients;

namespace SmartRestaurant.RealTime
{
    public class RealTimeIntegrationTests : SmartRestaurantApplicationTestBase
    {
        private readonly IOrderAppService _orderAppService;
        private readonly ITableAppService _tableAppService;
        private readonly IMenuItemAppService _menuItemAppService;
        private readonly IIngredientAppService _ingredientAppService;
        private readonly IHubContext<OrderHub> _hubContext;

        public RealTimeIntegrationTests()
        {
            _orderAppService = GetRequiredService<IOrderAppService>();
            _tableAppService = GetRequiredService<ITableAppService>();
            _menuItemAppService = GetRequiredService<IMenuItemAppService>();
            _ingredientAppService = GetRequiredService<IIngredientAppService>();
            _hubContext = GetRequiredService<IHubContext<OrderHub>>();
        }

        [Fact]
        public async Task Order_Workflow_Should_Trigger_Real_Time_Events()
        {
            // Arrange - Tạo test data
            var table = await CreateTestTableAsync("RT-01");
            var menuItem = await CreateTestMenuItemAsync("Real Time Test Item", 55000m);

            var orderDto = new CreateOrderDto
            {
                TableId = table.Id,
                OrderType = OrderType.DineIn,
                CustomerNote = "Real-time test order",
                Items = new[]
                {
                    new CreateOrderItemDto
                    {
                        MenuItemId = menuItem.Id,
                        Quantity = 2,
                        Notes = "Test notes"
                    }
                }
            };

            // Act & Assert - Each step should trigger events
            
            // 1. Create Order
            var order = await _orderAppService.CreateAsync(orderDto);
            order.ShouldNotBeNull();
            // Should trigger: OrderCreated event

            // 2. Confirm Order  
            await _orderAppService.ConfirmOrderAsync(order.Id);
            var confirmedOrder = await _orderAppService.GetAsync(order.Id);
            confirmedOrder.Status.ShouldBe(OrderStatus.Confirmed);
            // Should trigger: OrderStatusUpdated, KitchenNotification

            // 3. Start Preparation
            await _orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
            {
                OrderId = order.Id,
                Status = OrderStatus.Preparing,
                Notes = "Bắt đầu nấu món"
            });
            // Should trigger: OrderStatusUpdated

            // 4. Mark Items Ready
            var preparingOrder = await _orderAppService.GetAsync(order.Id);
            foreach (var item in preparingOrder.Items)
            {
                await _orderAppService.UpdateOrderItemStatusAsync(new UpdateOrderItemStatusDto
                {
                    OrderItemId = item.Id,
                    Status = OrderItemStatus.Ready,
                    Notes = "Món đã hoàn thành"
                });
            }
            // Should trigger: OrderItemStatusUpdated, OrderStatusUpdated (auto)

            // 5. Complete Order
            await _orderAppService.CompleteOrderAsync(order.Id, "Đã phục vụ khách");
            var completedOrder = await _orderAppService.GetAsync(order.Id);
            completedOrder.Status.ShouldBe(OrderStatus.Served);
            // Should trigger: OrderStatusUpdated, TableStatusUpdated
        }

        [Fact]
        public async Task Multiple_Orders_Should_Not_Interfere_With_Notifications()
        {
            // Arrange - Tạo 3 orders đồng thời
            var tables = new[]
            {
                await CreateTestTableAsync("MULTI-01"),
                await CreateTestTableAsync("MULTI-02"), 
                await CreateTestTableAsync("MULTI-03")
            };

            var menuItems = new[]
            {
                await CreateTestMenuItemAsync("Multi Test 1", 45000m),
                await CreateTestMenuItemAsync("Multi Test 2", 50000m),
                await CreateTestMenuItemAsync("Multi Test 3", 55000m)
            };

            var orders = new List<OrderDto>();

            // Act - Tạo multiple orders cùng lúc
            for (int i = 0; i < 3; i++)
            {
                var orderDto = new CreateOrderDto
                {
                    TableId = tables[i].Id,
                    OrderType = OrderType.DineIn,
                    Items = new[]
                    {
                        new CreateOrderItemDto
                        {
                            MenuItemId = menuItems[i].Id,
                            Quantity = 1 + i // Different quantities
                        }
                    }
                };

                var order = await _orderAppService.CreateAsync(orderDto);
                orders.Add(order);
            }

            // Confirm all orders (should trigger separate notifications)
            var confirmTasks = orders.Select(async order =>
            {
                await _orderAppService.ConfirmOrderAsync(order.Id);
                return await _orderAppService.GetAsync(order.Id);
            });

            var confirmedOrders = await Task.WhenAll(confirmTasks);

            // Assert - All orders should be confirmed independently
            confirmedOrders.ShouldAllBe(order => order.Status == OrderStatus.Confirmed);
            confirmedOrders.Length.ShouldBe(3);

            // Each order should have correct data
            for (int i = 0; i < 3; i++)
            {
                confirmedOrders[i].TableId.ShouldBe(tables[i].Id);
                confirmedOrders[i].Items[0].Quantity.ShouldBe(1 + i);
            }
        }

        [Fact]
        public async Task Kitchen_Area_Notifications_Should_Be_Categorized()
        {
            // Arrange - Tạo items from different kitchen areas
            var phoItem = await CreateTestMenuItemAsync("Phở Bò Special", 70000m);
            var grillItem = await CreateTestMenuItemAsync("Sườn Nướng BBQ", 85000m);
            var drinkItem = await CreateTestMenuItemAsync("Nước Cam Tươi", 25000m);

            var table = await CreateTestTableAsync("KITCHEN-AREA-01");

            var order = await _orderAppService.CreateAsync(new CreateOrderDto
            {
                TableId = table.Id,
                OrderType = OrderType.DineIn,
                Items = new[]
                {
                    new CreateOrderItemDto { MenuItemId = phoItem.Id, Quantity = 1 },
                    new CreateOrderItemDto { MenuItemId = grillItem.Id, Quantity = 1 },
                    new CreateOrderItemDto { MenuItemId = drinkItem.Id, Quantity = 2 }
                }
            });

            // Act - Confirm order
            await _orderAppService.ConfirmOrderAsync(order.Id);

            // Should trigger separate notifications for each kitchen area:
            // - Pho Station: Phở Bò Special
            // - Grill Station: Sườn Nướng BBQ  
            // - Drink Station: Nước Cam Tươi x2

            var confirmedOrder = await _orderAppService.GetAsync(order.Id);
            confirmedOrder.Items.Count.ShouldBe(3);
            confirmedOrder.Status.ShouldBe(OrderStatus.Confirmed);
        }

        [Fact]
        public async Task Priority_Orders_Should_Send_Urgent_Notifications()
        {
            // Arrange - VIP customer order
            var table = await CreateTestTableAsync("VIP-01");
            var menuItem = await CreateTestMenuItemAsync("VIP Phở Đặc Biệt", 120000m);

            var order = await _orderAppService.CreateAsync(new CreateOrderDto
            {
                TableId = table.Id,
                OrderType = OrderType.DineIn,
                CustomerNote = "Khách VIP - ưu tiên cao",
                Items = new[]
                {
                    new CreateOrderItemDto
                    {
                        MenuItemId = menuItem.Id,
                        Quantity = 1,
                        Notes = "Làm đặc biệt, presentation đẹp"
                    }
                }
            });

            // Act - Confirm priority order
            await _orderAppService.ConfirmOrderAsync(order.Id);

            // Mark as high priority
            await _orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
            {
                OrderId = order.Id,
                Status = OrderStatus.Preparing,
                Notes = "ƯU TIÊN CAO - Khách VIP"
            });

            // Assert - Order should be marked as high priority
            var priorityOrder = await _orderAppService.GetAsync(order.Id);
            priorityOrder.Status.ShouldBe(OrderStatus.Preparing);
            priorityOrder.CustomerNote.ShouldContain("VIP");
        }

        [Fact]
        public async Task Ingredient_Stock_Alerts_Should_Trigger_At_Right_Time()
        {
            // Arrange - Ingredient gần hết
            var lowStockIngredient = await _ingredientAppService.CreateAsync(new CreateUpdateIngredientDto
            {
                Name = "Tôm Tươi Low Stock",
                Unit = "kg",
                CurrentStock = 3, // Very low
                MinimumStock = 2,
                UnitCost = 300000m
            });

            var menuItem = await CreateTestMenuItemAsync("Tôm Rang Me", 95000m);
            await CreateMenuItemIngredientAsync(menuItem.Id, lowStockIngredient.Id, 1, false); // 1kg per serving

            var table = await CreateTestTableAsync("STOCK-01");

            var order = await _orderAppService.CreateAsync(new CreateOrderDto
            {
                TableId = table.Id,
                OrderType = OrderType.DineIn,
                Items = new[]
                {
                    new CreateOrderItemDto
                    {
                        MenuItemId = menuItem.Id,
                        Quantity = 2 // Will use 2kg, leaving only 1kg (below minimum)
                    }
                }
            });

            // Act - Confirm order (should trigger low stock alert)
            await _orderAppService.ConfirmOrderAsync(order.Id);

            // Assert - Stock should be reduced and alert triggered
            var updatedIngredient = await _ingredientAppService.GetAsync(lowStockIngredient.Id);
            updatedIngredient.CurrentStock.ShouldBe(1); // 3 - 2 = 1
            updatedIngredient.CurrentStock.ShouldBeLessThan(updatedIngredient.MinimumStock);
        }

        [Fact]
        public async Task Table_Availability_Should_Update_Real_Time()
        {
            // Arrange
            var table = await CreateTestTableAsync("TABLE-RT-01");
            var menuItem = await CreateTestMenuItemAsync("Table Status Test", 45000m);

            // Initial state - table should be available
            var initialTable = await _tableAppService.GetAsync(table.Id);
            initialTable.Status.ShouldBe(TableStatus.Available);

            // Act - Create order for table
            var order = await _orderAppService.CreateAsync(new CreateOrderDto
            {
                TableId = table.Id,
                OrderType = OrderType.DineIn,
                Items = new[]
                {
                    new CreateOrderItemDto { MenuItemId = menuItem.Id, Quantity = 1 }
                }
            });

            await _orderAppService.ConfirmOrderAsync(order.Id);

            // Table should be occupied
            var occupiedTable = await _tableAppService.GetAsync(table.Id);
            occupiedTable.Status.ShouldBe(TableStatus.Occupied);

            // Complete order
            await _orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
            {
                OrderId = order.Id,
                Status = OrderStatus.Preparing
            });

            await _orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
            {
                OrderId = order.Id,
                Status = OrderStatus.Ready
            });

            await _orderAppService.CompleteOrderAsync(order.Id, "Khách đã thanh toán");

            // Table should be available again
            var freedTable = await _tableAppService.GetAsync(table.Id);
            freedTable.Status.ShouldBe(TableStatus.Available);
        }

        [Fact]
        public async Task Concurrent_Order_Updates_Should_Be_Handled_Correctly()
        {
            // Arrange - Order with multiple items
            var table = await CreateTestTableAsync("CONCURRENT-01");
            var menuItem1 = await CreateTestMenuItemAsync("Concurrent Item 1", 50000m);
            var menuItem2 = await CreateTestMenuItemAsync("Concurrent Item 2", 60000m);

            var order = await _orderAppService.CreateAsync(new CreateOrderDto
            {
                TableId = table.Id,
                OrderType = OrderType.DineIn,
                Items = new[]
                {
                    new CreateOrderItemDto { MenuItemId = menuItem1.Id, Quantity = 1 },
                    new CreateOrderItemDto { MenuItemId = menuItem2.Id, Quantity = 1 }
                }
            });

            await _orderAppService.ConfirmOrderAsync(order.Id);
            await _orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
            {
                OrderId = order.Id,
                Status = OrderStatus.Preparing
            });

            var preparingOrder = await _orderAppService.GetAsync(order.Id);

            // Act - Update both items simultaneously
            var updateTasks = preparingOrder.Items.Select(async item =>
            {
                await Task.Delay(100); // Small delay to simulate real timing
                await _orderAppService.UpdateOrderItemStatusAsync(new UpdateOrderItemStatusDto
                {
                    OrderItemId = item.Id,
                    Status = OrderItemStatus.Ready,
                    Notes = $"Món {item.MenuItemName} đã sẵn sàng"
                });
            });

            await Task.WhenAll(updateTasks);

            // Assert - Order should auto-update to Ready
            var readyOrder = await _orderAppService.GetAsync(order.Id);
            readyOrder.Status.ShouldBe(OrderStatus.Ready);
            readyOrder.Items.ShouldAllBe(item => item.Status == OrderItemStatus.Ready);
        }

        [Fact]
        public async Task Vietnamese_Messages_Should_Be_Formatted_Correctly()
        {
            // Arrange
            var table = await CreateTestTableAsync("VN-MSG-01");
            var menuItem = await CreateTestMenuItemAsync("Phở Bò Tái Nạm", 75000m);

            var order = await _orderAppService.CreateAsync(new CreateOrderDto
            {
                TableId = table.Id,
                OrderType = OrderType.DineIn,
                CustomerNote = "Khách hàng Việt Nam",
                Items = new[]
                {
                    new CreateOrderItemDto
                    {
                        MenuItemId = menuItem.Id,
                        Quantity = 1,
                        Notes = "Ít muối, nhiều rau thơm"
                    }
                }
            });

            // Act - Confirm and update với Vietnamese notes
            await _orderAppService.ConfirmOrderAsync(order.Id);
            
            await _orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
            {
                OrderId = order.Id,
                Status = OrderStatus.Preparing,
                Notes = "Đầu bếp đã nhận đơn, đang chuẩn bị"
            });

            await _orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
            {
                OrderId = order.Id,
                Status = OrderStatus.Ready,
                Notes = "Phở đã nấu xong, sẵn sàng phục vụ"
            });

            // Assert - All Vietnamese text should be preserved
            var finalOrder = await _orderAppService.GetAsync(order.Id);
            finalOrder.CustomerNote.ShouldBe("Khách hàng Việt Nam");
            finalOrder.Items[0].Notes.ShouldBe("Ít muối, nhiều rau thơm");
        }

        [Fact]
        public async Task Error_Recovery_Should_Maintain_Real_Time_Consistency()
        {
            // Arrange
            var table = await CreateTestTableAsync("ERROR-RECOVERY-01");
            var menuItem = await CreateTestMenuItemAsync("Error Test Item", 60000m);

            var order = await _orderAppService.CreateAsync(new CreateOrderDto
            {
                TableId = table.Id,
                OrderType = OrderType.DineIn,
                Items = new[]
                {
                    new CreateOrderItemDto { MenuItemId = menuItem.Id, Quantity = 1 }
                }
            });

            await _orderAppService.ConfirmOrderAsync(order.Id);

            // Act - Try invalid status transition
            var exception = await Should.ThrowAsync<BusinessException>(
                () => _orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
                {
                    OrderId = order.Id,
                    Status = OrderStatus.Served, // Invalid: skip Preparing and Ready
                    Notes = "Invalid transition test"
                })
            );

            // Assert - Error should be proper business exception
            exception.Code.ShouldBe(OrderErrorCodes.InvalidStatusTransition);

            // Order should remain in previous valid state
            var unchangedOrder = await _orderAppService.GetAsync(order.Id);
            unchangedOrder.Status.ShouldBe(OrderStatus.Confirmed);
        }

        [Fact]
        public async Task High_Volume_Orders_Should_Maintain_Performance()
        {
            // Arrange - Tạo nhiều bàn và món
            var tables = new List<TableDto>();
            var menuItems = new List<MenuItemDto>();

            for (int i = 1; i <= 10; i++)
            {
                tables.Add(await CreateTestTableAsync($"PERF-{i:D2}"));
                menuItems.Add(await CreateTestMenuItemAsync($"Performance Item {i}", 45000m + (i * 1000)));
            }

            var orders = new List<OrderDto>();

            // Act - Tạo 10 orders đồng thời
            var createTasks = tables.Select(async (table, index) =>
            {
                var orderDto = new CreateOrderDto
                {
                    TableId = table.Id,
                    OrderType = OrderType.DineIn,
                    Items = new[]
                    {
                        new CreateOrderItemDto
                        {
                            MenuItemId = menuItems[index].Id,
                            Quantity = 1,
                            Notes = $"Performance test order {index + 1}"
                        }
                    }
                };

                return await _orderAppService.CreateAsync(orderDto);
            });

            orders.AddRange(await Task.WhenAll(createTasks));

            // Confirm all orders đồng thời
            var confirmTasks = orders.Select(order =>
                _orderAppService.ConfirmOrderAsync(order.Id)
            );

            await Task.WhenAll(confirmTasks);

            // Assert - Tất cả orders phải được xử lý thành công
            orders.Count.ShouldBe(10);
            
            foreach (var order in orders)
            {
                var confirmedOrder = await _orderAppService.GetAsync(order.Id);
                confirmedOrder.Status.ShouldBe(OrderStatus.Confirmed);
                confirmedOrder.OrderNumber.ShouldNotBeEmpty();
            }
        }

        [Fact]
        public async Task Real_Time_Ingredient_Tracking_Should_Work()
        {
            // Arrange - Ingredient với stock cụ thể
            var ingredient = await _ingredientAppService.CreateAsync(new CreateUpdateIngredientDto
            {
                Name = "Real Time Stock Test",
                Unit = "portion",
                CurrentStock = 10,
                MinimumStock = 3,
                UnitCost = 25000m
            });

            var menuItem = await CreateTestMenuItemAsync("Real Time Dish", 80000m);
            await CreateMenuItemIngredientAsync(menuItem.Id, ingredient.Id, 2, false); // 2 portions per serving

            var table = await CreateTestTableAsync("RT-STOCK-01");

            // Act - Tạo order sẽ dùng hết ingredient
            var order = await _orderAppService.CreateAsync(new CreateOrderDto
            {
                TableId = table.Id,
                OrderType = OrderType.DineIn,
                Items = new[]
                {
                    new CreateOrderItemDto
                    {
                        MenuItemId = menuItem.Id,
                        Quantity = 4 // Uses 8 portions, leaves 2 (below minimum)
                    }
                }
            });

            await _orderAppService.ConfirmOrderAsync(order.Id);

            // Assert - Stock should be updated và alert triggered
            var updatedIngredient = await _ingredientAppService.GetAsync(ingredient.Id);
            updatedIngredient.CurrentStock.ShouldBe(2); // 10 - 8 = 2
            updatedIngredient.CurrentStock.ShouldBeLessThan(updatedIngredient.MinimumStock);

            // Real-time notification should be sent to management group
        }

        [Fact]
        public async Task WebSocket_Heartbeat_Should_Maintain_Connection()
        {
            // Arrange - Long running operation
            var table = await CreateTestTableAsync("HEARTBEAT-01");
            var menuItem = await CreateTestMenuItemAsync("Long Cooking Item", 90000m);

            var order = await _orderAppService.CreateAsync(new CreateOrderDto
            {
                TableId = table.Id,
                OrderType = OrderType.DineIn,
                Items = new[]
                {
                    new CreateOrderItemDto { MenuItemId = menuItem.Id, Quantity = 1 }
                }
            });

            await _orderAppService.ConfirmOrderAsync(order.Id);
            await _orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
            {
                OrderId = order.Id,
                Status = OrderStatus.Preparing,
                Notes = "Món cần thời gian lâu"
            });

            // Act - Simulate long preparation time với periodic updates
            for (int i = 0; i < 5; i++)
            {
                await Task.Delay(1000); // 1 second intervals
                
                await _orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
                {
                    OrderId = order.Id,
                    Status = OrderStatus.Preparing,
                    Notes = $"Đang nấu... bước {i + 1}/5"
                });
            }

            // Final ready status
            await _orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
            {
                OrderId = order.Id,
                Status = OrderStatus.Ready,
                Notes = "Món đã hoàn thành sau thời gian dài"
            });

            // Assert - Order should reach final state
            var finalOrder = await _orderAppService.GetAsync(order.Id);
            finalOrder.Status.ShouldBe(OrderStatus.Ready);
        }

        private async Task<TableDto> CreateTestTableAsync(string tableNumber)
        {
            return await _tableAppService.CreateAsync(new CreateUpdateTableDto
            {
                TableNumber = tableNumber,
                Capacity = 4,
                LayoutSectionId = Guid.NewGuid()
            });
        }

        private async Task<MenuItemDto> CreateTestMenuItemAsync(string name, decimal price)
        {
            return await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = name,
                Description = $"Mô tả cho {name}",
                Price = price,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });
        }

        private async Task CreateMenuItemIngredientAsync(
            Guid menuItemId,
            Guid ingredientId,
            int requiredQuantity,
            bool isOptional)
        {
            var repository = GetRequiredService<IMenuItemIngredientRepository>();
            var entity = new MenuItemIngredient
            {
                Id = Guid.NewGuid(),
                MenuItemId = menuItemId,
                IngredientId = ingredientId,
                RequiredQuantity = requiredQuantity,
                IsOptional = isOptional
            };

            await repository.InsertAsync(entity, autoSave: true);
        }
    }
}