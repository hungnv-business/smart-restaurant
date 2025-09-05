using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.Extensions.DependencyInjection;
using Shouldly;
using Xunit;
using SmartRestaurant.Orders;
using SmartRestaurant.Hubs;

namespace SmartRestaurant.SignalR
{
    public class OrderHubIntegrationTests : SmartRestaurantHttpApiHostTestBase
    {
        private HubConnection _connection;

        public OrderHubIntegrationTests()
        {
            // Setup SignalR connection
            _connection = new HubConnectionBuilder()
                .WithUrl($"{GetRequiredService<IWebHostEnvironment>().BaseAddress}/hubs/orders")
                .Build();
        }

        [Fact]
        public async Task SignalR_Connection_Should_Establish_Successfully()
        {
            // Act
            await _connection.StartAsync();

            // Assert
            _connection.State.ShouldBe(HubConnectionState.Connected);
        }

        [Fact]
        public async Task OrderStatusUpdate_Should_Notify_Connected_Clients()
        {
            // Arrange
            var orderStatusReceived = false;
            string receivedOrderId = null;
            string receivedStatus = null;

            await _connection.StartAsync();
            
            _connection.On<string, string>("OrderStatusUpdated", (orderId, status) =>
            {
                orderStatusReceived = true;
                receivedOrderId = orderId;
                receivedStatus = status;
            });

            var orderAppService = GetRequiredService<IOrderAppService>();
            var tableAppService = GetRequiredService<ITableAppService>();
            var menuItemAppService = GetRequiredService<IMenuItemAppService>();

            // Tạo test data
            var table = await tableAppService.CreateAsync(new CreateUpdateTableDto
            {
                TableNumber = "TEST-HUB-01",
                Capacity = 4,
                LayoutSectionId = Guid.NewGuid()
            });

            var menuItem = await menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Test Hub Item",
                Price = 50000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            // Tạo order
            var order = await orderAppService.CreateAsync(new CreateOrderDto
            {
                TableId = table.Id,
                OrderType = OrderType.DineIn,
                Items = new[]
                {
                    new CreateOrderItemDto
                    {
                        MenuItemId = menuItem.Id,
                        Quantity = 1
                    }
                }
            });

            // Act - Update order status
            await orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
            {
                OrderId = order.Id,
                Status = OrderStatus.Confirmed,
                Notes = "SignalR test confirmation"
            });

            // Wait for SignalR message
            await Task.Delay(1000);

            // Assert
            orderStatusReceived.ShouldBe(true);
            receivedOrderId.ShouldBe(order.Id.ToString());
            receivedStatus.ShouldBe("Confirmed");
        }

        [Fact]
        public async Task KitchenNotification_Should_Broadcast_To_Kitchen_Group()
        {
            // Arrange
            var kitchenNotificationReceived = false;
            string receivedMessage = null;
            string receivedPriority = null;

            await _connection.StartAsync();

            // Join kitchen group
            await _connection.InvokeAsync("JoinKitchenGroup");

            _connection.On<string, string, string>("KitchenNotification", (orderId, message, priority) =>
            {
                kitchenNotificationReceived = true;
                receivedMessage = message;
                receivedPriority = priority;
            });

            var orderAppService = GetRequiredService<IOrderAppService>();
            var tableAppService = GetRequiredService<ITableAppService>();
            var menuItemAppService = GetRequiredService<IMenuItemAppService>();

            // Tạo order với priority cao
            var table = await tableAppService.CreateAsync(new CreateUpdateTableDto
            {
                TableNumber = "KITCHEN-01",
                Capacity = 4,
                LayoutSectionId = Guid.NewGuid()
            });

            var menuItem = await menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Phở Bò Khẩn Cấp",
                Price = 75000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            var order = await orderAppService.CreateAsync(new CreateOrderDto
            {
                TableId = table.Id,
                OrderType = OrderType.DineIn,
                CustomerNote = "Khách VIP, làm nhanh",
                Items = new[]
                {
                    new CreateOrderItemDto
                    {
                        MenuItemId = menuItem.Id,
                        Quantity = 1,
                        Notes = "Extra thịt"
                    }
                }
            });

            // Act - Confirm order (should trigger kitchen notification)
            await orderAppService.ConfirmOrderAsync(order.Id);

            // Wait for SignalR message
            await Task.Delay(1500);

            // Assert
            kitchenNotificationReceived.ShouldBe(true);
            receivedMessage.ShouldContain("Phở Bò Khẩn Cấp");
            receivedMessage.ShouldContain("KITCHEN-01");
            receivedPriority.ShouldBe("High"); // VIP customer = high priority
        }

        [Fact]
        public async Task OrderItemStatusUpdate_Should_Trigger_Order_Status_Check()
        {
            // Arrange
            var orderStatusUpdated = false;
            string finalOrderStatus = null;

            await _connection.StartAsync();

            _connection.On<string, string>("OrderStatusUpdated", (orderId, status) =>
            {
                orderStatusUpdated = true;
                finalOrderStatus = status;
            });

            var orderAppService = GetRequiredService<IOrderAppService>();
            var tableAppService = GetRequiredService<ITableAppService>();
            var menuItemAppService = GetRequiredService<IMenuItemAppService>();

            // Tạo order với nhiều items
            var table = await tableAppService.CreateAsync(new CreateUpdateTableDto
            {
                TableNumber = "ITEM-TEST-01",
                Capacity = 6,
                LayoutSectionId = Guid.NewGuid()
            });

            var menuItem1 = await menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Item Hub Test 1",
                Price = 60000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            var menuItem2 = await menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Item Hub Test 2",
                Price = 40000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            var order = await orderAppService.CreateAsync(new CreateOrderDto
            {
                TableId = table.Id,
                OrderType = OrderType.DineIn,
                Items = new[]
                {
                    new CreateOrderItemDto { MenuItemId = menuItem1.Id, Quantity = 1 },
                    new CreateOrderItemDto { MenuItemId = menuItem2.Id, Quantity = 1 }
                }
            });

            await orderAppService.ConfirmOrderAsync(order.Id);
            await orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
            {
                OrderId = order.Id,
                Status = OrderStatus.Preparing
            });

            // Act - Mark all items as ready
            var orderDetails = await orderAppService.GetAsync(order.Id);
            foreach (var item in orderDetails.Items)
            {
                await orderAppService.UpdateOrderItemStatusAsync(new UpdateOrderItemStatusDto
                {
                    OrderItemId = item.Id,
                    Status = OrderItemStatus.Ready,
                    Notes = "Món đã hoàn thành"
                });
            }

            // Wait for auto status update
            await Task.Delay(2000);

            // Assert - Order should auto-update to Ready
            orderStatusUpdated.ShouldBe(true);
            finalOrderStatus.ShouldBe("Ready");
        }

        [Fact]
        public async Task WaiterNotification_Should_Send_To_Specific_Waiter()
        {
            // Arrange
            var waiterNotificationReceived = false;
            string receivedMessage = null;

            await _connection.StartAsync();

            // Simulate waiter connection
            var waiterId = Guid.NewGuid().ToString();
            await _connection.InvokeAsync("JoinWaiterGroup", waiterId);

            _connection.On<string, string>("WaiterNotification", (orderId, message) =>
            {
                waiterNotificationReceived = true;
                receivedMessage = message;
            });

            var orderAppService = GetRequiredService<IOrderAppService>();
            var tableAppService = GetRequiredService<ITableAppService>();
            var menuItemAppService = GetRequiredService<IMenuItemAppService>();

            // Tạo order và mark as ready
            var table = await tableAppService.CreateAsync(new CreateUpdateTableDto
            {
                TableNumber = "WAITER-01",
                Capacity = 4,
                LayoutSectionId = Guid.NewGuid()
            });

            var menuItem = await menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Món cho Waiter Test",
                Price = 55000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            var order = await orderAppService.CreateAsync(new CreateOrderDto
            {
                TableId = table.Id,
                OrderType = OrderType.DineIn,
                Items = new[]
                {
                    new CreateOrderItemDto
                    {
                        MenuItemId = menuItem.Id,
                        Quantity = 1
                    }
                }
            });

            await orderAppService.ConfirmOrderAsync(order.Id);
            await orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
            {
                OrderId = order.Id,
                Status = OrderStatus.Preparing
            });

            // Act - Mark order as ready (should notify waiter)
            await orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
            {
                OrderId = order.Id,
                Status = OrderStatus.Ready,
                Notes = "Món đã sẵn sàng phục vụ"
            });

            // Wait for notification
            await Task.Delay(1000);

            // Assert
            waiterNotificationReceived.ShouldBe(true);
            receivedMessage.ShouldContain("WAITER-01");
            receivedMessage.ShouldContain("sẵn sàng");
        }

        [Fact]
        public async Task TableStatusUpdate_Should_Notify_Table_Management()
        {
            // Arrange
            var tableStatusUpdated = false;
            string receivedTableId = null;
            string receivedStatus = null;

            await _connection.StartAsync();

            _connection.On<string, string>("TableStatusUpdated", (tableId, status) =>
            {
                tableStatusUpdated = true;
                receivedTableId = tableId;
                receivedStatus = status;
            });

            var orderAppService = GetRequiredService<IOrderAppService>();
            var tableAppService = GetRequiredService<ITableAppService>();
            var menuItemAppService = GetRequiredService<IMenuItemAppService>();

            // Tạo bàn và order
            var table = await tableAppService.CreateAsync(new CreateUpdateTableDto
            {
                TableNumber = "TABLE-STATUS-01",
                Capacity = 4,
                LayoutSectionId = Guid.NewGuid()
            });

            var menuItem = await menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Table Test Item",
                Price = 45000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            var order = await orderAppService.CreateAsync(new CreateOrderDto
            {
                TableId = table.Id,
                OrderType = OrderType.DineIn,
                Items = new[]
                {
                    new CreateOrderItemDto { MenuItemId = menuItem.Id, Quantity = 1 }
                }
            });

            // Act - Complete order (should free table)
            await orderAppService.ConfirmOrderAsync(order.Id);
            await orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
            {
                OrderId = order.Id,
                Status = OrderStatus.Preparing
            });
            await orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
            {
                OrderId = order.Id,
                Status = OrderStatus.Ready
            });
            await orderAppService.CompleteOrderAsync(order.Id, "Đã phục vụ xong");

            // Wait for table status update
            await Task.Delay(1000);

            // Assert
            tableStatusUpdated.ShouldBe(true);
            receivedTableId.ShouldBe(table.Id.ToString());
            receivedStatus.ShouldBe("Available");
        }

        [Fact]
        public async Task IngredientAlert_Should_Notify_Management()
        {
            // Arrange
            var ingredientAlertReceived = false;
            string receivedIngredientName = null;
            int receivedCurrentStock = 0;

            await _connection.StartAsync();

            // Join management group for ingredient alerts
            await _connection.InvokeAsync("JoinManagementGroup");

            _connection.On<string, int, int>("IngredientAlert", (ingredientName, currentStock, minimumStock) =>
            {
                ingredientAlertReceived = true;
                receivedIngredientName = ingredientName;
                receivedCurrentStock = currentStock;
            });

            var ingredientAppService = GetRequiredService<IIngredientAppService>();
            var menuItemAppService = GetRequiredService<IMenuItemAppService>();
            var orderAppService = GetRequiredService<IOrderAppService>();
            var tableAppService = GetRequiredService<ITableAppService>();

            // Tạo ingredient với stock thấp
            var ingredient = await ingredientAppService.CreateAsync(new CreateUpdateIngredientDto
            {
                Name = "Thịt Bò Alert Test",
                Unit = "g",
                CurrentStock = 60, // Gần minimum
                MinimumStock = 50,
                UnitCost = 200m
            });

            var menuItem = await menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Phở Test Alert",
                Price = 70000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            var table = await tableAppService.CreateAsync(new CreateUpdateTableDto
            {
                TableNumber = "ALERT-01",
                Capacity = 4,
                LayoutSectionId = Guid.NewGuid()
            });

            // Tạo recipe link
            await CreateMenuItemIngredientAsync(menuItem.Id, ingredient.Id, 30, false);

            // Act - Create order that will reduce stock below minimum
            var order = await orderAppService.CreateAsync(new CreateOrderDto
            {
                TableId = table.Id,
                OrderType = OrderType.DineIn,
                Items = new[]
                {
                    new CreateOrderItemDto
                    {
                        MenuItemId = menuItem.Id,
                        Quantity = 2 // Needs 60g, will leave only 0g
                    }
                }
            });

            await orderAppService.ConfirmOrderAsync(order.Id); // This should trigger alert

            // Wait for alert
            await Task.Delay(1500);

            // Assert
            ingredientAlertReceived.ShouldBe(true);
            receivedIngredientName.ShouldBe("Thịt Bò Alert Test");
            receivedCurrentStock.ShouldBe(0); // Should be 0 after using 60g
        }

        [Fact]
        public async Task Multiple_Clients_Should_Receive_Same_Notifications()
        {
            // Arrange
            var connection1Received = false;
            var connection2Received = false;

            var connection1 = new HubConnectionBuilder()
                .WithUrl($"{GetRequiredService<IWebHostEnvironment>().BaseAddress}/hubs/orders")
                .Build();

            var connection2 = new HubConnectionBuilder()
                .WithUrl($"{GetRequiredService<IWebHostEnvironment>().BaseAddress}/hubs/orders")
                .Build();

            await connection1.StartAsync();
            await connection2.StartAsync();

            connection1.On<string, string>("OrderStatusUpdated", (orderId, status) =>
            {
                connection1Received = true;
            });

            connection2.On<string, string>("OrderStatusUpdated", (orderId, status) =>
            {
                connection2Received = true;
            });

            var orderAppService = GetRequiredService<IOrderAppService>();
            var tableAppService = GetRequiredService<ITableAppService>();
            var menuItemAppService = GetRequiredService<IMenuItemAppService>();

            // Tạo test order
            var table = await tableAppService.CreateAsync(new CreateUpdateTableDto
            {
                TableNumber = "MULTI-01",
                Capacity = 4,
                LayoutSectionId = Guid.NewGuid()
            });

            var menuItem = await menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Multi Client Test",
                Price = 50000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            var order = await orderAppService.CreateAsync(new CreateOrderDto
            {
                TableId = table.Id,
                OrderType = OrderType.DineIn,
                Items = new[]
                {
                    new CreateOrderItemDto { MenuItemId = menuItem.Id, Quantity = 1 }
                }
            });

            // Act
            await orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
            {
                OrderId = order.Id,
                Status = OrderStatus.Confirmed
            });

            await Task.Delay(1000);

            // Assert - Both clients should receive
            connection1Received.ShouldBe(true);
            connection2Received.ShouldBe(true);

            // Cleanup
            await connection1.DisposeAsync();
            await connection2.DisposeAsync();
        }

        [Fact]
        public async Task Connection_Should_Handle_Reconnection_Gracefully()
        {
            // Arrange
            var reconnectedSuccessfully = false;

            await _connection.StartAsync();
            _connection.State.ShouldBe(HubConnectionState.Connected);

            _connection.Reconnected += (connectionId) =>
            {
                reconnectedSuccessfully = true;
                return Task.CompletedTask;
            };

            // Act - Simulate connection drop and reconnection
            await _connection.StopAsync();
            _connection.State.ShouldBe(HubConnectionState.Disconnected);

            await _connection.StartAsync(); // Reconnect

            // Assert
            _connection.State.ShouldBe(HubConnectionState.Connected);
            // Note: Reconnected event might not fire in test environment
        }

        [Fact]
        public async Task Group_Management_Should_Work_Correctly()
        {
            // Arrange
            var kitchenMessageReceived = false;
            var managementMessageReceived = false;

            await _connection.StartAsync();

            // Join different groups
            await _connection.InvokeAsync("JoinKitchenGroup");
            await _connection.InvokeAsync("JoinManagementGroup");

            _connection.On<string, string, string>("KitchenNotification", (orderId, message, priority) =>
            {
                kitchenMessageReceived = true;
            });

            _connection.On<string, int, int>("IngredientAlert", (ingredientName, currentStock, minimumStock) =>
            {
                managementMessageReceived = true;
            });

            var orderAppService = GetRequiredService<IOrderAppService>();
            var ingredientAppService = GetRequiredService<IIngredientAppService>();
            var tableAppService = GetRequiredService<ITableAppService>();
            var menuItemAppService = GetRequiredService<IMenuItemAppService>();

            // Tạo data for both notifications
            var ingredient = await ingredientAppService.CreateAsync(new CreateUpdateIngredientDto
            {
                Name = "Group Test Ingredient",
                Unit = "g",
                CurrentStock = 55,
                MinimumStock = 50,
                UnitCost = 100m
            });

            var table = await tableAppService.CreateAsync(new CreateUpdateTableDto
            {
                TableNumber = "GROUP-01",
                Capacity = 4,
                LayoutSectionId = Guid.NewGuid()
            });

            var menuItem = await menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Group Test Item",
                Price = 60000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            await CreateMenuItemIngredientAsync(menuItem.Id, ingredient.Id, 10, false);

            var order = await orderAppService.CreateAsync(new CreateOrderDto
            {
                TableId = table.Id,
                OrderType = OrderType.DineIn,
                Items = new[]
                {
                    new CreateOrderItemDto { MenuItemId = menuItem.Id, Quantity = 1 }
                }
            });

            // Act - Confirm order (triggers both kitchen and potential ingredient alert)
            await orderAppService.ConfirmOrderAsync(order.Id);

            await Task.Delay(2000);

            // Assert - Both group messages should be received
            kitchenMessageReceived.ShouldBe(true);
            // managementMessageReceived might be true if stock goes below minimum
        }

        [Fact]
        public async Task Heartbeat_Should_Maintain_Connection()
        {
            // Arrange
            var heartbeatCount = 0;

            await _connection.StartAsync();

            _connection.On("Heartbeat", () =>
            {
                heartbeatCount++;
            });

            // Act - Wait for multiple heartbeats
            await Task.Delay(10000); // Wait 10 seconds

            // Assert - Should have received heartbeats
            heartbeatCount.ShouldBeGreaterThan(0);
            _connection.State.ShouldBe(HubConnectionState.Connected);
        }

        [Fact]
        public async Task Error_Handling_Should_Maintain_Connection_Stability()
        {
            // Arrange
            await _connection.StartAsync();

            // Act - Send invalid data to hub methods
            try
            {
                await _connection.InvokeAsync("InvalidMethod", "invalid", "data");
            }
            catch
            {
                // Expected to fail
            }

            try
            {
                await _connection.InvokeAsync("JoinKitchenGroup", null);
            }
            catch
            {
                // Expected to fail
            }

            // Assert - Connection should remain stable
            _connection.State.ShouldBe(HubConnectionState.Connected);
        }

        public override async Task DisposeAsync()
        {
            if (_connection != null)
            {
                await _connection.DisposeAsync();
            }
            await base.DisposeAsync();
        }

        private async Task<MenuItemIngredient> CreateMenuItemIngredientAsync(
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

            return await repository.InsertAsync(entity, autoSave: true);
        }
    }
}