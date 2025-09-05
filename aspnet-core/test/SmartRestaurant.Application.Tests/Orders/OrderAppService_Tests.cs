using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using SmartRestaurant.Orders;
using SmartRestaurant.Orders.Dtos;
using SmartRestaurant.Orders.Exceptions;
using SmartRestaurant.MenuManagement.MenuItems;
using SmartRestaurant.TableManagement.Tables;
using Shouldly;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Validation;
using Xunit;
using NSubstitute;

namespace SmartRestaurant.Application.Tests.Orders
{
    public sealed class OrderAppService_Tests : SmartRestaurantApplicationTestBase
    {
        private readonly IOrderAppService _orderAppService;
        private readonly IRepository<Order, Guid> _orderRepository;
        private readonly IRepository<MenuItem, Guid> _menuItemRepository;
        private readonly IRepository<Table, Guid> _tableRepository;
        private readonly OrderManager _orderManager;

        public OrderAppService_Tests()
        {
            _orderRepository = GetRequiredService<IRepository<Order, Guid>>();
            _menuItemRepository = GetRequiredService<IRepository<MenuItem, Guid>>();
            _tableRepository = GetRequiredService<IRepository<Table, Guid>>();
            _orderManager = GetRequiredService<OrderManager>();
            _orderAppService = GetRequiredService<IOrderAppService>();
        }

        [Fact]
        public async Task CreateAsync_WithValidData_ShouldCreateOrder()
        {
            // Arrange
            var tableId = Guid.NewGuid();
            var menuItemId = Guid.NewGuid();

            // Tạo test data
            var table = new Table(tableId, "T01", 4, Guid.NewGuid());
            table.SetStatus(TableStatus.Available);
            await _tableRepository.InsertAsync(table);

            var menuItem = new MenuItem(
                menuItemId,
                "Phở Bò",
                "Phở bò truyền thống",
                50000m,
                true,
                null,
                Guid.NewGuid()
            );
            await _menuItemRepository.InsertAsync(menuItem);

            var createDto = new CreateOrderDto
            {
                OrderType = OrderType.DineIn,
                TableId = tableId,
                Notes = "Ghi chú đơn hàng",
                Items = new List<CreateOrderItemDto>
                {
                    new CreateOrderItemDto
                    {
                        MenuItemId = menuItemId,
                        Quantity = 2,
                        Notes = "Không cay"
                    }
                }
            };

            // Act
            var result = await _orderAppService.CreateAsync(createDto);

            // Assert
            result.ShouldNotBeNull();
            result.OrderNumber.ShouldNotBeNullOrEmpty();
            result.OrderType.ShouldBe(OrderType.DineIn);
            result.TableId.ShouldBe(tableId);
            result.Status.ShouldBe(OrderStatus.Pending);
            result.Notes.ShouldBe("Ghi chú đơn hàng");
            result.Items.Count.ShouldBe(1);
            result.Items.First().MenuItemId.ShouldBe(menuItemId);
            result.Items.First().Quantity.ShouldBe(2);
        }

        [Fact]
        public async Task CreateAsync_WithOccupiedTable_ShouldThrowException()
        {
            // Arrange
            var tableId = Guid.NewGuid();
            var menuItemId = Guid.NewGuid();

            var table = new Table(tableId, "T01", 4, Guid.NewGuid());
            table.SetStatus(TableStatus.Occupied);
            await _tableRepository.InsertAsync(table);

            var menuItem = new MenuItem(
                menuItemId,
                "Phở Bò",
                "Phở bò truyền thống",
                50000m,
                true,
                null,
                Guid.NewGuid()
            );
            await _menuItemRepository.InsertAsync(menuItem);

            var createDto = new CreateOrderDto
            {
                OrderType = OrderType.DineIn,
                TableId = tableId,
                Items = new List<CreateOrderItemDto>
                {
                    new CreateOrderItemDto
                    {
                        MenuItemId = menuItemId,
                        Quantity = 1
                    }
                }
            };

            // Act & Assert
            await Should.ThrowAsync<TableNotAvailableException>(
                async () => await _orderAppService.CreateAsync(createDto)
            );
        }

        [Fact]
        public async Task CreateAsync_WithUnavailableMenuItem_ShouldThrowException()
        {
            // Arrange
            var tableId = Guid.NewGuid();
            var menuItemId = Guid.NewGuid();

            var table = new Table(tableId, "T01", 4, Guid.NewGuid());
            table.SetStatus(TableStatus.Available);
            await _tableRepository.InsertAsync(table);

            var menuItem = new MenuItem(
                menuItemId,
                "Phở Bò",
                "Phở bò truyền thống",
                50000m,
                false, // Không có sẵn
                null,
                Guid.NewGuid()
            );
            await _menuItemRepository.InsertAsync(menuItem);

            var createDto = new CreateOrderDto
            {
                OrderType = OrderType.DineIn,
                TableId = tableId,
                Items = new List<CreateOrderItemDto>
                {
                    new CreateOrderItemDto
                    {
                        MenuItemId = menuItemId,
                        Quantity = 1
                    }
                }
            };

            // Act & Assert
            await Should.ThrowAsync<MenuItemNotAvailableException>(
                async () => await _orderAppService.CreateAsync(createDto)
            );
        }

        [Fact]
        public async Task CreateAsync_WithEmptyItems_ShouldThrowValidationException()
        {
            // Arrange
            var createDto = new CreateOrderDto
            {
                OrderType = OrderType.Takeaway,
                Items = new List<CreateOrderItemDto>()
            };

            // Act & Assert
            await Should.ThrowAsync<AbpValidationException>(
                async () => await _orderAppService.CreateAsync(createDto)
            );
        }

        [Fact]
        public async Task UpdateStatusAsync_WithValidTransition_ShouldUpdateStatus()
        {
            // Arrange
            var order = new Order(
                Guid.NewGuid(),
                "DH001",
                OrderType.Takeaway
            );
            await _orderRepository.InsertAsync(order);

            var updateDto = new UpdateOrderStatusDto
            {
                Status = OrderStatus.Confirmed,
                Notes = "Đã xác nhận"
            };

            // Act
            var result = await _orderAppService.UpdateStatusAsync(order.Id, updateDto);

            // Assert
            result.Status.ShouldBe(OrderStatus.Confirmed);
            
            // Verify trong database
            var updatedOrder = await _orderRepository.GetAsync(order.Id);
            updatedOrder.Status.ShouldBe(OrderStatus.Confirmed);
        }

        [Fact]
        public async Task UpdateStatusAsync_WithInvalidTransition_ShouldThrowException()
        {
            // Arrange
            var order = new Order(
                Guid.NewGuid(),
                "DH001",
                OrderType.Takeaway
            );
            order.UpdateStatus(OrderStatus.Paid); // Đã thanh toán
            await _orderRepository.InsertAsync(order);

            var updateDto = new UpdateOrderStatusDto
            {
                Status = OrderStatus.Pending
            };

            // Act & Assert
            await Should.ThrowAsync<InvalidOrderStatusTransitionException>(
                async () => await _orderAppService.UpdateStatusAsync(order.Id, updateDto)
            );
        }

        [Fact]
        public async Task GetListAsync_WithFiltering_ShouldReturnFilteredResults()
        {
            // Arrange
            var tableId = Guid.NewGuid();

            var order1 = new Order(Guid.NewGuid(), "DH001", OrderType.DineIn, tableId);
            var order2 = new Order(Guid.NewGuid(), "TA001", OrderType.Takeaway);
            var order3 = new Order(Guid.NewGuid(), "DH002", OrderType.DineIn, tableId);

            await _orderRepository.InsertAsync(order1);
            await _orderRepository.InsertAsync(order2);
            await _orderRepository.InsertAsync(order3);

            var input = new GetOrdersInput
            {
                OrderType = OrderType.DineIn,
                MaxResultCount = 10
            };

            // Act
            var result = await _orderAppService.GetListAsync(input);

            // Assert
            result.Items.Count.ShouldBe(2);
            result.Items.All(x => x.OrderType == OrderType.DineIn).ShouldBeTrue();
        }

        [Fact]
        public async Task GetAsync_WithExistingId_ShouldReturnOrder()
        {
            // Arrange
            var order = new Order(
                Guid.NewGuid(),
                "DH001",
                OrderType.Takeaway
            );
            await _orderRepository.InsertAsync(order);

            // Act
            var result = await _orderAppService.GetAsync(order.Id);

            // Assert
            result.ShouldNotBeNull();
            result.Id.ShouldBe(order.Id);
            result.OrderNumber.ShouldBe("DH001");
            result.OrderType.ShouldBe(OrderType.Takeaway);
        }

        [Fact]
        public async Task GetOrdersForTableAsync_WithValidTableId_ShouldReturnTableOrders()
        {
            // Arrange
            var tableId = Guid.NewGuid();
            var otherTableId = Guid.NewGuid();

            var order1 = new Order(Guid.NewGuid(), "DH001", OrderType.DineIn, tableId);
            var order2 = new Order(Guid.NewGuid(), "DH002", OrderType.DineIn, otherTableId);
            var order3 = new Order(Guid.NewGuid(), "DH003", OrderType.DineIn, tableId);

            await _orderRepository.InsertAsync(order1);
            await _orderRepository.InsertAsync(order2);
            await _orderRepository.InsertAsync(order3);

            // Act
            var result = await _orderAppService.GetOrdersForTableAsync(tableId);

            // Assert
            result.Count.ShouldBe(2);
            result.All(x => x.TableId == tableId).ShouldBeTrue();
        }

        [Fact]
        public async Task GetKitchenOrdersAsync_ShouldReturnProcessingOrders()
        {
            // Arrange
            var order1 = new Order(Guid.NewGuid(), "DH001", OrderType.DineIn);
            order1.UpdateStatus(OrderStatus.Confirmed);

            var order2 = new Order(Guid.NewGuid(), "DH002", OrderType.DineIn);
            order2.UpdateStatus(OrderStatus.Preparing);

            var order3 = new Order(Guid.NewGuid(), "DH003", OrderType.DineIn);
            order3.UpdateStatus(OrderStatus.Paid); // Đã hoàn thành

            await _orderRepository.InsertAsync(order1);
            await _orderRepository.InsertAsync(order2);
            await _orderRepository.InsertAsync(order3);

            // Act
            var result = await _orderAppService.GetKitchenOrdersAsync();

            // Assert
            result.Count.ShouldBe(2);
            result.All(x => x.Status == OrderStatus.Confirmed || 
                           x.Status == OrderStatus.Preparing ||
                           x.Status == OrderStatus.Ready).ShouldBeTrue();
        }
    }
}