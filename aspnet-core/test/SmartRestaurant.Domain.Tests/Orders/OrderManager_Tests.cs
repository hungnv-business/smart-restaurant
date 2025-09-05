using System;
using System.Threading.Tasks;
using SmartRestaurant.Orders;
using SmartRestaurant.TableManagement.Tables;
using Shouldly;
using Volo.Abp.Domain.Repositories;
using Xunit;
using NSubstitute;

namespace SmartRestaurant.Domain.Tests.Orders
{
    public sealed class OrderManager_Tests : SmartRestaurantDomainTestBase<SmartRestaurantDomainTestModule>
    {
        private readonly OrderManager _orderManager;
        private readonly IRepository<Table, Guid> _tableRepository;

        public OrderManager_Tests()
        {
            _tableRepository = Substitute.For<IRepository<Table, Guid>>();
            _orderManager = new OrderManager(_tableRepository);
        }

        [Fact]
        public async Task CreateAsync_WithValidData_ShouldCreateOrder()
        {
            // Arrange
            var orderNumber = "DH001";
            var orderType = OrderType.DineIn;
            var tableId = Guid.NewGuid();
            var notes = "Ghi chú đơn hàng";

            var table = new Table(tableId, "T01", 4, Guid.NewGuid());
            table.SetStatus(TableStatus.Available);
            _tableRepository.GetAsync(tableId, true, default).Returns(table);

            // Act
            var order = await _orderManager.CreateAsync(orderNumber, orderType, tableId, notes);

            // Assert
            order.ShouldNotBeNull();
            order.OrderNumber.ShouldBe(orderNumber);
            order.OrderType.ShouldBe(orderType);
            order.TableId.ShouldBe(tableId);
            order.Notes.ShouldBe(notes);
            order.Status.ShouldBe(OrderStatus.Pending);
            order.TotalAmount.ShouldBe(0);
        }

        [Fact]
        public async Task CreateAsync_WithOccupiedTable_ShouldThrowException()
        {
            // Arrange
            var orderNumber = "DH001";
            var orderType = OrderType.DineIn;
            var tableId = Guid.NewGuid();

            var table = new Table(tableId, "T01", 4, Guid.NewGuid());
            table.SetStatus(TableStatus.Occupied);
            _tableRepository.GetAsync(tableId, true, default).Returns(table);

            // Act & Assert
            var exception = await Should.ThrowAsync<TableNotAvailableException>(
                async () => await _orderManager.CreateAsync(orderNumber, orderType, tableId)
            );
            
            // Kiểm tra table có đang được sử dụng không
            exception.Message.ShouldContain("đang được sử dụng");
            exception.TableId.ShouldBe(tableId);
        }

        [Fact]
        public async Task CreateAsync_WithReservedTable_ShouldThrowException()
        {
            // Arrange
            var orderNumber = "DH001";
            var orderType = OrderType.DineIn;
            var tableId = Guid.NewGuid();

            var table = new Table(tableId, "T01", 4, Guid.NewGuid());
            table.SetStatus(TableStatus.Reserved);
            _tableRepository.GetAsync(tableId, true, default).Returns(table);

            // Act & Assert
            var exception = await Should.ThrowAsync<TableNotAvailableException>(
                async () => await _orderManager.CreateAsync(orderNumber, orderType, tableId)
            );
            
            // Kiểm tra table có đã được đặt trước không
            exception.Message.ShouldContain("đã được đặt trước");
        }

        [Fact]
        public async Task CreateAsync_ForTakeaway_ShouldNotValidateTable()
        {
            // Arrange
            var orderNumber = "TA001";
            var orderType = OrderType.Takeaway;

            // Act
            var order = await _orderManager.CreateAsync(orderNumber, orderType);

            // Assert
            order.ShouldNotBeNull();
            order.OrderNumber.ShouldBe(orderNumber);
            order.OrderType.ShouldBe(orderType);
            order.TableId.ShouldBeNull();
            order.Status.ShouldBe(OrderStatus.Pending);

            // Verify table repository không được gọi cho takeaway
            await _tableRepository.DidNotReceive().GetAsync(Arg.Any<Guid>(), Arg.Any<bool>(), Arg.Any<System.Threading.CancellationToken>());
        }

        [Fact]
        public void ConfirmOrder_WithPendingStatus_ShouldUpdateStatus()
        {
            // Arrange
            var order = new Order(
                Guid.NewGuid(),
                "DH001",
                OrderType.DineIn,
                Guid.NewGuid()
            );

            // Act
            _orderManager.ConfirmOrder(order);

            // Assert
            order.Status.ShouldBe(OrderStatus.Confirmed);
        }

        [Fact]
        public void ConfirmOrder_WithNonPendingStatus_ShouldThrowException()
        {
            // Arrange
            var order = new Order(
                Guid.NewGuid(),
                "DH001",
                OrderType.DineIn,
                Guid.NewGuid()
            );
            order.UpdateStatus(OrderStatus.Confirmed);

            // Act & Assert
            var exception = Should.Throw<InvalidOrderStatusTransitionException>(
                () => _orderManager.ConfirmOrder(order)
            );
            
            // Chỉ có thể xác nhận đơn hàng đang chờ
            exception.Message.ShouldContain("Chỉ có thể xác nhận đơn hàng đang chờ");
            exception.OrderId.ShouldBe(order.Id);
        }

        [Fact]
        public async Task NotifyKitchenAsync_WithConfirmedOrder_ShouldNotThrow()
        {
            // Arrange
            var order = new Order(
                Guid.NewGuid(),
                "DH001",
                OrderType.DineIn,
                Guid.NewGuid()
            );
            order.UpdateStatus(OrderStatus.Confirmed);

            // Act & Assert - Should not throw
            await _orderManager.NotifyKitchenAsync(order);
        }

        [Fact]
        public void ValidateOrderItem_WithValidData_ShouldNotThrow()
        {
            // Arrange
            var menuItemId = Guid.NewGuid();
            var quantity = 2;
            var unitPrice = 50000m;

            // Act & Assert - Should not throw
            _orderManager.ValidateOrderItem(menuItemId, quantity, unitPrice);
        }

        [Theory]
        [InlineData(0)]
        [InlineData(-1)]
        public void ValidateOrderItem_WithInvalidQuantity_ShouldThrowException(int quantity)
        {
            // Arrange
            var menuItemId = Guid.NewGuid();
            var unitPrice = 50000m;

            // Act & Assert
            var exception = Should.Throw<InvalidOrderItemException>(
                () => _orderManager.ValidateOrderItem(menuItemId, quantity, unitPrice)
            );
            
            // Số lượng phải lớn hơn 0
            exception.Message.ShouldContain("Số lượng phải lớn hơn 0");
        }

        [Theory]
        [InlineData(-1)]
        [InlineData(-100)]
        public void ValidateOrderItem_WithNegativePrice_ShouldThrowException(decimal unitPrice)
        {
            // Arrange
            var menuItemId = Guid.NewGuid();
            var quantity = 1;

            // Act & Assert
            var exception = Should.Throw<InvalidOrderItemException>(
                () => _orderManager.ValidateOrderItem(menuItemId, quantity, unitPrice)
            );
            
            // Giá phải lớn hơn hoặc bằng 0
            exception.Message.ShouldContain("Giá phải lớn hơn hoặc bằng 0");
        }

        [Fact]
        public void ValidateOrderItem_WithEmptyMenuItemId_ShouldThrowException()
        {
            // Arrange
            var menuItemId = Guid.Empty;
            var quantity = 1;
            var unitPrice = 50000m;

            // Act & Assert
            var exception = Should.Throw<InvalidOrderItemException>(
                () => _orderManager.ValidateOrderItem(menuItemId, quantity, unitPrice)
            );
            
            // ID món ăn không hợp lệ
            exception.Message.ShouldContain("ID món ăn không hợp lệ");
        }

        [Fact]
        public void CalculateOrderTotal_WithItems_ShouldReturnCorrectTotal()
        {
            // Arrange
            var order = new Order(
                Guid.NewGuid(),
                "DH001",
                OrderType.DineIn,
                Guid.NewGuid()
            );

            var item1 = new OrderItem(
                Guid.NewGuid(),
                order.Id,
                Guid.NewGuid(),
                "Phở Bò",
                2,
                50000m
            );

            var item2 = new OrderItem(
                Guid.NewGuid(),
                order.Id,
                Guid.NewGuid(),
                "Cà phê đen",
                1,
                25000m
            );

            order.OrderItems.Add(item1);
            order.OrderItems.Add(item2);

            // Act
            var total = _orderManager.CalculateOrderTotal(order);

            // Assert
            total.ShouldBe(125000m); // (2 * 50000) + (1 * 25000)
        }

        [Fact]
        public void CalculateOrderTotal_WithEmptyOrder_ShouldReturnZero()
        {
            // Arrange
            var order = new Order(
                Guid.NewGuid(),
                "DH001",
                OrderType.DineIn,
                Guid.NewGuid()
            );

            // Act
            var total = _orderManager.CalculateOrderTotal(order);

            // Assert
            total.ShouldBe(0);
        }
    }
}