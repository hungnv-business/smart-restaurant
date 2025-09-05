using System;
using System.Threading.Tasks;
using Shouldly;
using Volo.Abp.Domain.Entities;
using Volo.Abp.Validation;
using Xunit;
using SmartRestaurant.Orders;
using SmartRestaurant.Tables;
using SmartRestaurant.MenuManagement.MenuItems;

namespace SmartRestaurant.Orders
{
    public class OrderAppServiceIntegrationTests : SmartRestaurantApplicationTestBase
    {
        private readonly IOrderAppService _orderAppService;
        private readonly ITableAppService _tableAppService;
        private readonly IMenuItemAppService _menuItemAppService;

        public OrderAppServiceIntegrationTests()
        {
            _orderAppService = GetRequiredService<IOrderAppService>();
            _tableAppService = GetRequiredService<ITableAppService>();
            _menuItemAppService = GetRequiredService<IMenuItemAppService>();
        }

        [Fact]
        public async Task CreateOrderAsync_Should_Create_Valid_Order()
        {
            // Arrange - Tạo bàn test và menu item
            var testTable = await _tableAppService.CreateAsync(new CreateUpdateTableDto
            {
                TableNumber = "TEST-01",
                Capacity = 4,
                LayoutSectionId = Guid.NewGuid()
            });

            var testMenuItem = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Phở Bò Test",
                Description = "Phở bò test cho integration testing",
                Price = 65000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            var createOrderDto = new CreateOrderDto
            {
                TableId = testTable.Id,
                OrderType = OrderType.DineIn,
                CustomerNote = "Test order từ integration test",
                Items = new[]
                {
                    new CreateOrderItemDto
                    {
                        MenuItemId = testMenuItem.Id,
                        Quantity = 2,
                        Notes = "Ít muối, không cay"
                    }
                }
            };

            // Act - Tạo đơn hàng
            var result = await _orderAppService.CreateAsync(createOrderDto);

            // Assert - Kiểm tra kết quả
            result.ShouldNotBeNull();
            result.Id.ShouldNotBe(Guid.Empty);
            result.OrderNumber.ShouldNotBeEmpty();
            result.Status.ShouldBe(OrderStatus.Pending);
            result.OrderType.ShouldBe(OrderType.DineIn);
            result.TableId.ShouldBe(testTable.Id);
            result.CustomerNote.ShouldBe("Test order từ integration test");
            result.TotalAmount.ShouldBe(130000m); // 65000 * 2
            result.Items.Count.ShouldBe(1);
            result.Items[0].Quantity.ShouldBe(2);
            result.Items[0].Notes.ShouldBe("Ít muối, không cay");
        }

        [Fact]
        public async Task CreateOrderAsync_Should_Validate_Required_Fields()
        {
            // Arrange - DTO rỗng
            var emptyOrderDto = new CreateOrderDto();

            // Act & Assert - Kiểm tra validation
            var exception = await Should.ThrowAsync<AbpValidationException>(
                () => _orderAppService.CreateAsync(emptyOrderDto)
            );
            
            exception.ValidationErrors.ShouldNotBeEmpty();
        }

        [Fact]
        public async Task CreateOrderAsync_DineIn_Should_Require_Table()
        {
            // Arrange - Order tại chỗ không có bàn
            var testMenuItem = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = "Test MenuItem",
                Price = 50000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            var orderDto = new CreateOrderDto
            {
                OrderType = OrderType.DineIn,
                // Không có TableId cho DineIn
                Items = new[]
                {
                    new CreateOrderItemDto
                    {
                        MenuItemId = testMenuItem.Id,
                        Quantity = 1
                    }
                }
            };

            // Act & Assert - Phải báo lỗi business logic
            var exception = await Should.ThrowAsync<BusinessException>(
                () => _orderAppService.CreateAsync(orderDto)
            );
            
            exception.Code.ShouldBe(OrderErrorCodes.TableRequiredForDineIn);
        }

        [Fact]
        public async Task ConfirmOrderAsync_Should_Update_Status()
        {
            // Arrange - Tạo order test
            var order = await CreateTestOrderAsync();

            // Act - Xác nhận order
            await _orderAppService.ConfirmOrderAsync(order.Id);

            // Assert - Kiểm tra status đã thay đổi
            var updatedOrder = await _orderAppService.GetAsync(order.Id);
            updatedOrder.Status.ShouldBe(OrderStatus.Confirmed);
        }

        [Fact]
        public async Task UpdateOrderStatusAsync_Should_Follow_Workflow()
        {
            // Arrange - Tạo và confirm order
            var order = await CreateTestOrderAsync();
            await _orderAppService.ConfirmOrderAsync(order.Id);

            // Act - Chuyển sang preparing
            await _orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
            {
                OrderId = order.Id,
                Status = OrderStatus.Preparing,
                Notes = "Bắt đầu chuẩn bị món ăn"
            });

            // Assert - Kiểm tra workflow transition
            var updatedOrder = await _orderAppService.GetAsync(order.Id);
            updatedOrder.Status.ShouldBe(OrderStatus.Preparing);
        }

        [Fact]
        public async Task UpdateOrderStatusAsync_Should_Reject_Invalid_Transitions()
        {
            // Arrange - Tạo order mới (Pending)
            var order = await CreateTestOrderAsync();

            // Act & Assert - Không thể skip từ Pending thẳng sang Ready
            var exception = await Should.ThrowAsync<BusinessException>(
                () => _orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
                {
                    OrderId = order.Id,
                    Status = OrderStatus.Ready,
                    Notes = "Invalid transition"
                })
            );

            exception.Code.ShouldBe(OrderErrorCodes.InvalidStatusTransition);
        }

        [Fact]
        public async Task CancelOrderAsync_Should_Only_Allow_Pending_Orders()
        {
            // Arrange - Tạo và confirm order
            var order = await CreateTestOrderAsync();
            await _orderAppService.ConfirmOrderAsync(order.Id);

            // Act & Assert - Không thể cancel order đã confirmed
            var exception = await Should.ThrowAsync<BusinessException>(
                () => _orderAppService.CancelOrderAsync(order.Id, "Test cancellation")
            );

            exception.Code.ShouldBe(OrderErrorCodes.CannotCancelNonPendingOrder);
        }

        [Fact]
        public async Task GetOrdersByTableIdAsync_Should_Return_Table_Orders()
        {
            // Arrange - Tạo bàn và 2 orders cho bàn đó
            var testTable = await _tableAppService.CreateAsync(new CreateUpdateTableDto
            {
                TableNumber = "TEST-02",
                Capacity = 6,
                LayoutSectionId = Guid.NewGuid()
            });

            var order1 = await CreateTestOrderAsync(testTable.Id);
            var order2 = await CreateTestOrderAsync(testTable.Id);

            // Act - Lấy orders theo bàn
            var tableOrders = await _orderAppService.GetOrdersByTableIdAsync(testTable.Id);

            // Assert - Phải có 2 orders
            tableOrders.Count.ShouldBe(2);
            tableOrders.ShouldAllBe(o => o.TableId == testTable.Id);
        }

        [Fact]
        public async Task GetTodayOrdersAsync_Should_Return_Today_Orders_Only()
        {
            // Arrange - Tạo order hôm nay
            var todayOrder = await CreateTestOrderAsync();

            // Act - Lấy orders hôm nay
            var todayOrders = await _orderAppService.GetTodayOrdersAsync();

            // Assert - Phải chứa order vừa tạo
            todayOrders.ShouldContain(o => o.Id == todayOrder.Id);
            todayOrders.ShouldAllBe(o => o.CreationTime.Date == DateTime.Today);
        }

        [Fact]
        public async Task GetOrderStatisticsAsync_Should_Calculate_Correctly()
        {
            // Arrange - Tạo nhiều orders với status khác nhau
            var order1 = await CreateTestOrderAsync();
            var order2 = await CreateTestOrderAsync();
            await _orderAppService.ConfirmOrderAsync(order1.Id);
            await _orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
            {
                OrderId = order1.Id,
                Status = OrderStatus.Preparing
            });

            // Act - Lấy thống kê
            var stats = await _orderAppService.GetOrderStatisticsAsync();

            // Assert - Kiểm tra số liệu
            stats.ShouldNotBeNull();
            stats.TotalOrdersToday.ShouldBeGreaterThanOrEqualTo(2);
            stats.PendingOrders.ShouldBeGreaterThanOrEqualTo(1);
            stats.PreparingOrders.ShouldBeGreaterThanOrEqualTo(1);
        }

        [Fact]
        public async Task UpdateOrderItemStatusAsync_Should_Update_Individual_Items()
        {
            // Arrange - Tạo order với nhiều items
            var order = await CreateTestOrderWithMultipleItemsAsync();
            await _orderAppService.ConfirmOrderAsync(order.Id);
            await _orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
            {
                OrderId = order.Id,
                Status = OrderStatus.Preparing
            });

            // Act - Cập nhật status của item đầu tiên
            var firstItem = order.Items[0];
            await _orderAppService.UpdateOrderItemStatusAsync(new UpdateOrderItemStatusDto
            {
                OrderItemId = firstItem.Id,
                Status = OrderItemStatus.Ready,
                Notes = "Món đầu tiên đã sẵn sàng"
            });

            // Assert - Kiểm tra item đã được cập nhật
            var updatedOrder = await _orderAppService.GetAsync(order.Id);
            var updatedItem = updatedOrder.Items.Find(i => i.Id == firstItem.Id);
            updatedItem.Status.ShouldBe(OrderItemStatus.Ready);
        }

        [Fact]
        public async Task Order_Should_Auto_Update_Status_When_All_Items_Ready()
        {
            // Arrange - Tạo order với 2 items
            var order = await CreateTestOrderWithMultipleItemsAsync();
            await _orderAppService.ConfirmOrderAsync(order.Id);
            await _orderAppService.UpdateOrderStatusAsync(new UpdateOrderStatusDto
            {
                OrderId = order.Id,
                Status = OrderStatus.Preparing
            });

            // Act - Đặt tất cả items thành Ready
            foreach (var item in order.Items)
            {
                await _orderAppService.UpdateOrderItemStatusAsync(new UpdateOrderItemStatusDto
                {
                    OrderItemId = item.Id,
                    Status = OrderItemStatus.Ready
                });
            }

            // Assert - Order status phải tự động chuyển thành Ready
            var updatedOrder = await _orderAppService.GetAsync(order.Id);
            updatedOrder.Status.ShouldBe(OrderStatus.Ready);
        }

        [Fact]
        public async Task CompleteOrderAsync_Should_Mark_As_Served_And_Update_Table()
        {
            // Arrange - Tạo order và chuyển đến Ready
            var order = await CreateTestOrderAsync();
            await _orderAppService.ConfirmOrderAsync(order.Id);
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

            // Act - Complete order
            await _orderAppService.CompleteOrderAsync(order.Id, "Đã phục vụ khách hàng");

            // Assert - Kiểm tra status và table
            var completedOrder = await _orderAppService.GetAsync(order.Id);
            completedOrder.Status.ShouldBe(OrderStatus.Served);

            // Kiểm tra bàn đã được giải phóng (nếu có logic này)
            if (order.TableId.HasValue)
            {
                var table = await _tableAppService.GetAsync(order.TableId.Value);
                table.Status.ShouldBe(TableStatus.Available);
            }
        }

        private async Task<OrderDto> CreateTestOrderAsync(Guid? tableId = null)
        {
            if (tableId == null)
            {
                var testTable = await _tableAppService.CreateAsync(new CreateUpdateTableDto
                {
                    TableNumber = $"TEST-{DateTime.Now:HHmmss}",
                    Capacity = 4,
                    LayoutSectionId = Guid.NewGuid()
                });
                tableId = testTable.Id;
            }

            var testMenuItem = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = $"Test Món {DateTime.Now:HHmmss}",
                Description = "Món ăn test cho integration testing",
                Price = 50000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            return await _orderAppService.CreateAsync(new CreateOrderDto
            {
                TableId = tableId,
                OrderType = OrderType.DineIn,
                CustomerNote = "Test note",
                Items = new[]
                {
                    new CreateOrderItemDto
                    {
                        MenuItemId = testMenuItem.Id,
                        Quantity = 1,
                        Notes = "Test item note"
                    }
                }
            });
        }

        private async Task<OrderDto> CreateTestOrderWithMultipleItemsAsync()
        {
            var testTable = await _tableAppService.CreateAsync(new CreateUpdateTableDto
            {
                TableNumber = $"TEST-MULTI-{DateTime.Now:HHmmss}",
                Capacity = 6,
                LayoutSectionId = Guid.NewGuid()
            });

            var menuItem1 = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = $"Test Phở {DateTime.Now:HHmmss}",
                Price = 65000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            var menuItem2 = await _menuItemAppService.CreateAsync(new CreateUpdateMenuItemDto
            {
                Name = $"Test Cơm {DateTime.Now:HHmmss}",
                Price = 55000m,
                CategoryId = Guid.NewGuid(),
                IsAvailable = true
            });

            return await _orderAppService.CreateAsync(new CreateOrderDto
            {
                TableId = testTable.Id,
                OrderType = OrderType.DineIn,
                Items = new[]
                {
                    new CreateOrderItemDto
                    {
                        MenuItemId = menuItem1.Id,
                        Quantity = 1,
                        Notes = "Item 1 notes"
                    },
                    new CreateOrderItemDto
                    {
                        MenuItemId = menuItem2.Id,
                        Quantity = 2,
                        Notes = "Item 2 notes"
                    }
                }
            });
        }
    }
}