using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using SmartRestaurant.Orders;
using SmartRestaurant.TableManagement.Tables;
using SmartRestaurant.MenuManagement.MenuItems;
using SmartRestaurant.MenuManagement;
using SmartRestaurant.InventoryManagement.Ingredients;
using SmartRestaurant.Application.Contracts.Orders.Dto;
using Shouldly;
using Volo.Abp.Domain.Repositories;
using Xunit;
using NSubstitute;
using Volo.Abp.Guids;

namespace SmartRestaurant.Domain.Tests.Orders
{
    /// <summary>
    /// Unit tests cho OrderManager Domain Service
    /// Kiểm thử tất cả business logic và validation rules
    /// </summary>
    public sealed class OrderManager_Tests : SmartRestaurantDomainTestBase
    {
        private readonly OrderManager _orderManager;
        private readonly ITableRepository _tableRepository;
        private readonly IOrderRepository _orderRepository;
        private readonly IPaymentRepository _paymentRepository;
        private readonly IMenuItemRepository _menuItemRepository;
        private readonly RecipeManager _recipeManager;
        private readonly IngredientManager _ingredientManager;
        private readonly IGuidGenerator _guidGenerator;

        public OrderManager_Tests()
        {
            _tableRepository = Substitute.For<ITableRepository>();
            _orderRepository = Substitute.For<IOrderRepository>();
            _paymentRepository = Substitute.For<IPaymentRepository>();
            _menuItemRepository = Substitute.For<IMenuItemRepository>();
            _recipeManager = Substitute.For<RecipeManager>();
            _ingredientManager = Substitute.For<IngredientManager>();
            _guidGenerator = Substitute.For<IGuidGenerator>();

            _orderManager = new OrderManager(
                _tableRepository,
                _orderRepository,
                _paymentRepository,
                _menuItemRepository,
                _recipeManager,
                _ingredientManager);
        }

        #region Tạo đơn hàng Tests

        [Fact]
        public async Task CreateOrderAsync_WithValidDineInData_ShouldCreateOrder()
        {
            // Arrange
            var tableId = Guid.NewGuid();
            var orderId = Guid.NewGuid();
            var orderNumber = "DH001";
            
            var table = new Table(tableId, "T01", 4, Guid.NewGuid(), 1, 1);
            table.SetAvailable();
            
            _tableRepository.GetAsync(tableId, true, default).Returns(table);
            _guidGenerator.Create().Returns(orderId);

            // Act
            var order = await _orderManager.CreateOrderAsync(
                _guidGenerator,
                orderNumber,
                OrderType.DineIn,
                tableId);

            // Assert
            order.ShouldNotBeNull();
            order.Id.ShouldBe(orderId);
            order.OrderNumber.ShouldBe(orderNumber);
            order.OrderType.ShouldBe(OrderType.DineIn);
            order.TableId.ShouldBe(tableId);
            order.Status.ShouldBe(OrderStatus.Active);
            order.TotalAmount.ShouldBe(0);
            
            // Verify table status updated
            table.Status.ShouldBe(TableStatus.Occupied);
        }

        [Fact]
        public async Task CreateOrderAsync_WithTakeawayOrder_ShouldCreateOrderWithoutTable()
        {
            // Arrange
            var orderId = Guid.NewGuid();
            var orderNumber = "TA001";
            
            _guidGenerator.Create().Returns(orderId);

            // Act
            var order = await _orderManager.CreateOrderAsync(
                _guidGenerator,
                orderNumber,
                OrderType.Takeaway);

            // Assert
            order.ShouldNotBeNull();
            order.OrderNumber.ShouldBe(orderNumber);
            order.OrderType.ShouldBe(OrderType.Takeaway);
            order.TableId.ShouldBeNull();
            order.Status.ShouldBe(OrderStatus.Active);

            // Verify table repository không được gọi
            await _tableRepository.DidNotReceive().GetAsync(Arg.Any<Guid>(), Arg.Any<bool>(), Arg.Any<System.Threading.CancellationToken>());
        }

        [Fact]
        public async Task CreateOrderAsync_WithOccupiedTable_ShouldThrowBusinessException()
        {
            // Arrange
            var tableId = Guid.NewGuid();
            var table = new Table(tableId, "T01", 4, Guid.NewGuid(), 1, 1);
            table.SetOccupied();
            
            _tableRepository.GetAsync(tableId, true, default).Returns(table);

            // Act & Assert
            var exception = await Should.ThrowAsync<Volo.Abp.BusinessException>(
                async () => await _orderManager.CreateOrderAsync(
                    _guidGenerator,
                    "DH001",
                    OrderType.DineIn,
                    tableId));
            
            exception.Code.ShouldBe(OrdersErrorCodes.TableNotAvailable);
        }

        [Fact]
        public async Task CreateOrderAsync_WithReservedTable_ShouldThrowBusinessException()
        {
            // Arrange
            var tableId = Guid.NewGuid();
            var table = new Table(tableId, "T01", 4, Guid.NewGuid(), 1, 1);
            table.SetReserved();
            
            _tableRepository.GetAsync(tableId, true, default).Returns(table);

            // Act & Assert
            var exception = await Should.ThrowAsync<Volo.Abp.BusinessException>(
                async () => await _orderManager.CreateOrderAsync(
                    _guidGenerator,
                    "DH001",
                    OrderType.DineIn,
                    tableId));
            
            exception.Code.ShouldBe(OrdersErrorCodes.TableNotAvailable);
        }

        #endregion

        #region Validation Tests

        [Fact]
        public async Task ValidateOrderForConfirmationAsync_WithValidOrder_ShouldNotThrow()
        {
            // Arrange
            var order = CreateTestOrder();
            var orderItem = CreateTestOrderItem(order.Id);
            order.OrderItems.Add(orderItem);

            var menuItem = CreateTestMenuItem();
            _menuItemRepository.GetAsync(orderItem.MenuItemId, true, default).Returns(menuItem);

            var missingIngredients = new List<MissingIngredientDto>();
            _recipeManager.CheckMissingIngredientsAsync(Arg.Any<List<CreateOrderItemDto>>())
                .Returns(missingIngredients);

            // Act & Assert - Should not throw
            await _orderManager.ValidateOrderForConfirmationAsync(order);
        }

        [Fact]
        public async Task ValidateOrderForConfirmationAsync_WithEmptyOrder_ShouldThrowException()
        {
            // Arrange
            var order = CreateTestOrder();
            order.OrderItems.Clear();

            // Act & Assert
            var exception = await Should.ThrowAsync<Volo.Abp.BusinessException>(
                async () => await _orderManager.ValidateOrderForConfirmationAsync(order));
            
            exception.Code.ShouldBe(OrdersErrorCodes.EmptyOrder);
        }

        [Fact]
        public async Task ValidateOrderForConfirmationAsync_WithDineInWithoutTable_ShouldThrowException()
        {
            // Arrange
            var order = new Order(
                Guid.NewGuid(),
                "DH001",
                OrderType.DineIn);
            
            var orderItem = CreateTestOrderItem(order.Id);
            order.OrderItems.Add(orderItem);

            // Act & Assert
            var exception = await Should.ThrowAsync<Volo.Abp.BusinessException>(
                async () => await _orderManager.ValidateOrderForConfirmationAsync(order));
            
            exception.Code.ShouldBe(OrdersErrorCodes.DineInWithoutTable);
        }

        [Fact]
        public async Task ValidateOrderForConfirmationAsync_WithMissingIngredients_ShouldThrowException()
        {
            // Arrange
            var order = CreateTestOrder();
            var orderItem = CreateTestOrderItem(order.Id);
            order.OrderItems.Add(orderItem);

            var menuItem = CreateTestMenuItem();
            _menuItemRepository.GetAsync(orderItem.MenuItemId, true, default).Returns(menuItem);

            var missingIngredients = new List<MissingIngredientDto>
            {
                new MissingIngredientDto
                {
                    IngredientName = "Thịt bò",
                    MenuItemName = "Phở Bò",
                    RequiredQuantity = 200,
                    CurrentStock = 50,
                    Unit = "gram"
                }
            };
            _recipeManager.CheckMissingIngredientsAsync(Arg.Any<List<CreateOrderItemDto>>())
                .Returns(missingIngredients);

            // Act & Assert
            var exception = await Should.ThrowAsync<Volo.Abp.BusinessException>(
                async () => await _orderManager.ValidateOrderForConfirmationAsync(order));
            
            exception.Code.ShouldBe(OrdersErrorCodes.InsufficientIngredients);
        }

        #endregion

        #region Recipe Management Tests

        [Fact]
        public async Task ProcessInventoryDeductionAsync_WithValidOrder_ShouldCallRecipeManager()
        {
            // Arrange
            var order = CreateTestOrder();
            var orderItem = CreateTestOrderItem(order.Id);
            order.OrderItems.Add(orderItem);

            // Act
            await _orderManager.ProcessInventoryDeductionAsync(order);

            // Assert
            await _recipeManager.Received(1).ProcessAutomaticDeductionAsync(Arg.Any<List<CreateOrderItemDto>>());
        }

        [Fact]
        public async Task ProcessInventoryDeductionAsync_WithEmptyOrder_ShouldNotCallRecipeManager()
        {
            // Arrange
            var order = CreateTestOrder();
            order.OrderItems.Clear();

            // Act
            await _orderManager.ProcessInventoryDeductionAsync(order);

            // Assert
            await _recipeManager.DidNotReceive().ProcessAutomaticDeductionAsync(Arg.Any<List<CreateOrderItemDto>>());
        }

        #endregion

        #region Payment Processing Tests

        [Fact]
        public async Task ProcessPaymentAsync_WithValidPayment_ShouldCreatePaymentAndUpdateOrder()
        {
            // Arrange
            var order = CreateTestOrder();
            var paymentId = Guid.NewGuid();
            var totalAmount = 100000m;
            var customerMoney = 120000m;
            var paymentMethod = PaymentMethod.Cash;

            _guidGenerator.Create().Returns(paymentId);

            // Act
            var payment = await _orderManager.ProcessPaymentAsync(
                order,
                _guidGenerator,
                totalAmount,
                customerMoney,
                paymentMethod);

            // Assert
            payment.ShouldNotBeNull();
            payment.OrderId.ShouldBe(order.Id);
            payment.TotalAmount.ShouldBe(totalAmount);
            payment.CustomerMoney.ShouldBe(customerMoney);
            payment.PaymentMethod.ShouldBe(paymentMethod);
            payment.ChangeAmount.ShouldBe(20000m);

            order.Status.ShouldBe(OrderStatus.Paid);
            order.PaidTime.ShouldNotBeNull();
        }

        [Fact]
        public async Task ProcessPaymentAsync_WithInactiveOrder_ShouldThrowException()
        {
            // Arrange
            var order = CreateTestOrder();
            order.MarkAsPaid(); // Make order inactive

            // Act & Assert
            var exception = await Should.ThrowAsync<Volo.Abp.BusinessException>(
                async () => await _orderManager.ProcessPaymentAsync(
                    order,
                    _guidGenerator,
                    100000m,
                    120000m,
                    PaymentMethod.Cash));
            
            exception.Code.ShouldBe(OrdersErrorCodes.CannotProcessPaymentForNonActiveOrder);
        }

        #endregion

        #region Business Rules Tests

        [Theory]
        [InlineData(0)]
        [InlineData(-1)]
        [InlineData(-100)]
        public void ValidateOrderItem_WithInvalidQuantity_ShouldThrowException(int quantity)
        {
            // Arrange
            var menuItemId = Guid.NewGuid();
            var unitPrice = 50000m;

            // Act & Assert
            var exception = Should.Throw<Volo.Abp.BusinessException>(
                () => _orderManager.ValidateOrderItem(menuItemId, quantity, unitPrice));
            
            exception.Code.ShouldBe(OrdersErrorCodes.InvalidOrderItemQuantity);
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
            var exception = Should.Throw<Volo.Abp.BusinessException>(
                () => _orderManager.ValidateOrderItem(menuItemId, quantity, unitPrice));
            
            exception.Code.ShouldBe(OrdersErrorCodes.InvalidOrderItemPrice);
        }

        [Fact]
        public void ValidateOrderItem_WithEmptyMenuItemId_ShouldThrowException()
        {
            // Arrange
            var menuItemId = Guid.Empty;
            var quantity = 1;
            var unitPrice = 50000m;

            // Act & Assert
            var exception = Should.Throw<Volo.Abp.BusinessException>(
                () => _orderManager.ValidateOrderItem(menuItemId, quantity, unitPrice));
            
            exception.Code.ShouldBe(OrdersErrorCodes.InvalidMenuItemId);
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

        #endregion

        #region Helper Methods

        private Order CreateTestOrder()
        {
            return new Order(
                Guid.NewGuid(),
                "DH001",
                OrderType.DineIn,
                Guid.NewGuid());
        }

        private OrderItem CreateTestOrderItem(Guid orderId)
        {
            return new OrderItem(
                Guid.NewGuid(),
                orderId,
                Guid.NewGuid(),
                "Phở Bò",
                2,
                50000m);
        }

        private MenuItem CreateTestMenuItem()
        {
            return new MenuItem(
                Guid.NewGuid(),
                "Phở Bò",
                "Phở bò tái nạm",
                50000m,
                Guid.NewGuid());
        }

        #endregion
    }
}