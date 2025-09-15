using System;
using System.Linq;
using SmartRestaurant.Orders;
using SmartRestaurant.Application.Contracts.Orders.Dto;
using Shouldly;
using Volo.Abp.Guids;
using Xunit;
using NSubstitute;

namespace SmartRestaurant.Domain.Tests.Orders
{
    /// <summary>
    /// Unit tests cho Order Entity
    /// Kiểm thử business logic và domain rules
    /// </summary>
    public sealed class Order_Tests : SmartRestaurantDomainTestBase
    {
        private readonly IGuidGenerator _guidGenerator;

        public Order_Tests()
        {
            _guidGenerator = Substitute.For<IGuidGenerator>();
        }

        #region Constructor Tests

        [Fact]
        public void Constructor_WithValidData_ShouldCreateOrder()
        {
            // Arrange
            var id = Guid.NewGuid();
            var orderNumber = "DH001";
            var orderType = OrderType.DineIn;
            var tableId = Guid.NewGuid();
            var notes = "Ghi chú đặc biệt";

            // Act
            var order = new Order(id, orderNumber, orderType, tableId, notes);

            // Assert
            order.Id.ShouldBe(id);
            order.OrderNumber.ShouldBe(orderNumber);
            order.OrderType.ShouldBe(orderType);
            order.TableId.ShouldBe(tableId);
            order.Notes.ShouldBe(notes);
            order.Status.ShouldBe(OrderStatus.Active);
            order.TotalAmount.ShouldBe(0);
            order.CreatedTime.ShouldNotBe(default);
            order.PaidTime.ShouldBeNull();
            order.OrderItems.ShouldBeEmpty();
            order.Payments.ShouldBeEmpty();
        }

        [Fact]
        public void Constructor_WithTakeawayType_ShouldAllowNullTableId()
        {
            // Arrange & Act
            var order = new Order(
                Guid.NewGuid(),
                "TA001",
                OrderType.Takeaway);

            // Assert
            order.OrderType.ShouldBe(OrderType.Takeaway);
            order.TableId.ShouldBeNull();
            order.Status.ShouldBe(OrderStatus.Active);
        }

        #endregion

        #region Status Management Tests

        [Fact]
        public void IsActive_WithActiveStatus_ShouldReturnTrue()
        {
            // Arrange
            var order = CreateTestOrder();

            // Act & Assert
            order.IsActive().ShouldBeTrue();
            order.Status.ShouldBe(OrderStatus.Active);
        }

        [Fact]
        public void IsPaid_WithPaidStatus_ShouldReturnTrue()
        {
            // Arrange
            var order = CreateTestOrder();
            order.MarkAsPaid();

            // Act & Assert
            order.IsPaid().ShouldBeTrue();
            order.Status.ShouldBe(OrderStatus.Paid);
        }

        [Fact]
        public void MarkAsPaid_WithActiveOrderAndCompletedItems_ShouldUpdateStatus()
        {
            // Arrange
            var order = CreateTestOrder();
            var orderItem = CreateTestOrderItem(order.Id);
            orderItem.MarkAsServed(); // Complete the item
            order.OrderItems.Add(orderItem);

            // Act
            order.MarkAsPaid();

            // Assert
            order.Status.ShouldBe(OrderStatus.Paid);
            order.PaidTime.ShouldNotBeNull();
        }

        [Fact]
        public void MarkAsPaid_WithAlreadyPaidOrder_ShouldThrowException()
        {
            // Arrange
            var order = CreateTestOrder();
            var orderItem = CreateTestOrderItem(order.Id);
            orderItem.MarkAsServed();
            order.OrderItems.Add(orderItem);
            order.MarkAsPaid(); // Already paid

            // Act & Assert
            var exception = Should.Throw<Volo.Abp.BusinessException>(
                () => order.MarkAsPaid());
            
            exception.Code.ShouldBe(OrdersErrorCodes.OrderAlreadyPaid);
        }

        [Fact]
        public void MarkAsPaid_WithIncompleteItems_ShouldThrowException()
        {
            // Arrange
            var order = CreateTestOrder();
            var orderItem = CreateTestOrderItem(order.Id);
            // Don't mark as served - item is incomplete
            order.OrderItems.Add(orderItem);

            // Act & Assert
            var exception = Should.Throw<Volo.Abp.BusinessException>(
                () => order.MarkAsPaid());
            
            exception.Code.ShouldBe(OrdersErrorCodes.CannotPayWithIncompleteItems);
        }

        #endregion

        #region Order Items Management Tests

        [Fact]
        public void AddItem_WithValidItem_ShouldAddAndRecalculateTotal()
        {
            // Arrange
            var order = CreateTestOrder();
            var orderItem = CreateTestOrderItem(order.Id);
            var newItemId = Guid.NewGuid();
            _guidGenerator.Create().Returns(newItemId);

            // Act
            order.AddItem(_guidGenerator, orderItem);

            // Assert
            order.OrderItems.Count.ShouldBe(1);
            order.TotalAmount.ShouldBe(orderItem.UnitPrice * orderItem.Quantity);
            
            var addedItem = order.OrderItems.First();
            addedItem.Id.ShouldBe(newItemId);
            addedItem.MenuItemName.ShouldBe(orderItem.MenuItemName);
        }

        [Fact]
        public void AddItems_WithMultipleItems_ShouldAddAllAndRecalculateTotal()
        {
            // Arrange
            var order = CreateTestOrder();
            var orderItems = new[]
            {
                CreateTestOrderItem(order.Id, "Phở Bò", 2, 50000m),
                CreateTestOrderItem(order.Id, "Cà phê", 1, 25000m)
            };

            _guidGenerator.Create().Returns(Guid.NewGuid(), Guid.NewGuid());

            // Act
            order.AddItems(_guidGenerator, orderItems);

            // Assert
            order.OrderItems.Count.ShouldBe(2);
            order.TotalAmount.ShouldBe(125000m); // (2 * 50000) + (1 * 25000)
        }

        [Fact]
        public void AddItems_WithPaidOrder_ShouldThrowException()
        {
            // Arrange
            var order = CreateTestOrder();
            var completedItem = CreateTestOrderItem(order.Id);
            completedItem.MarkAsServed();
            order.OrderItems.Add(completedItem);
            order.MarkAsPaid(); // Make order paid (inactive)

            var newItem = CreateTestOrderItem(order.Id);

            // Act & Assert
            var exception = Should.Throw<Volo.Abp.BusinessException>(
                () => order.AddItems(_guidGenerator, new[] { newItem }));
            
            exception.Code.ShouldBe(OrdersErrorCodes.CannotModifyNonActiveOrder);
        }

        [Fact]
        public void RemoveItem_WithExistingItem_ShouldRemoveAndRecalculateTotal()
        {
            // Arrange
            var order = CreateTestOrder();
            var orderItem = CreateTestOrderItem(order.Id);
            _guidGenerator.Create().Returns(orderItem.Id);
            order.AddItem(_guidGenerator, orderItem);

            // Act
            order.RemoveItem(orderItem.Id);

            // Assert
            order.OrderItems.ShouldBeEmpty();
            order.TotalAmount.ShouldBe(0);
        }

        [Fact]
        public void RemoveItem_WithNonActiveOrder_ShouldThrowException()
        {
            // Arrange
            var order = CreateTestOrder();
            var orderItem = CreateTestOrderItem(order.Id);
            orderItem.MarkAsServed();
            order.OrderItems.Add(orderItem);
            order.MarkAsPaid(); // Make order inactive

            // Act & Assert
            var exception = Should.Throw<Volo.Abp.BusinessException>(
                () => order.RemoveItem(orderItem.Id));
            
            exception.Code.ShouldBe(OrdersErrorCodes.CannotModifyNonActiveOrder);
        }

        [Fact]
        public void CancelItem_WithExistingItem_ShouldCancelAndRecalculateTotal()
        {
            // Arrange
            var order = CreateTestOrder();
            var orderItem = CreateTestOrderItem(order.Id, "Phở Bò", 2, 50000m);
            _guidGenerator.Create().Returns(orderItem.Id);
            order.AddItem(_guidGenerator, orderItem);

            // Act
            order.CancelItem(orderItem.Id);

            // Assert
            var canceledItem = order.OrderItems.First(x => x.Id == orderItem.Id);
            canceledItem.Status.ShouldBe(OrderItemStatus.Canceled);
            order.TotalAmount.ShouldBe(0); // Canceled items don't count
        }

        [Fact]
        public void CancelItem_WithNonExistentItem_ShouldThrowException()
        {
            // Arrange
            var order = CreateTestOrder();
            var nonExistentItemId = Guid.NewGuid();

            // Act & Assert
            var exception = Should.Throw<Volo.Abp.BusinessException>(
                () => order.CancelItem(nonExistentItemId));
            
            exception.Code.ShouldBe(OrdersErrorCodes.OrderItemNotFound);
        }

        #endregion

        #region Validation Tests

        [Fact]
        public void ValidateForConfirmation_WithValidDineInOrder_ShouldNotThrow()
        {
            // Arrange
            var order = CreateTestOrder(); // DineIn with TableId
            var orderItem = CreateTestOrderItem(order.Id);
            _guidGenerator.Create().Returns(orderItem.Id);
            order.AddItem(_guidGenerator, orderItem);

            // Act & Assert - Should not throw
            order.ValidateForConfirmation();
        }

        [Fact]
        public void ValidateForConfirmation_WithEmptyOrder_ShouldThrowException()
        {
            // Arrange
            var order = CreateTestOrder();

            // Act & Assert
            var exception = Should.Throw<Volo.Abp.BusinessException>(
                () => order.ValidateForConfirmation());
            
            exception.Code.ShouldBe(OrdersErrorCodes.EmptyOrder);
        }

        [Fact]
        public void ValidateForConfirmation_WithDineInWithoutTable_ShouldThrowException()
        {
            // Arrange
            var order = new Order(
                Guid.NewGuid(),
                "DH001",
                OrderType.DineIn); // No tableId

            var orderItem = CreateTestOrderItem(order.Id);
            _guidGenerator.Create().Returns(orderItem.Id);
            order.AddItem(_guidGenerator, orderItem);

            // Act & Assert
            var exception = Should.Throw<Volo.Abp.BusinessException>(
                () => order.ValidateForConfirmation());
            
            exception.Code.ShouldBe(OrdersErrorCodes.DineInWithoutTable);
        }

        [Fact]
        public void ValidateForConfirmation_WithZeroTotal_ShouldThrowException()
        {
            // Arrange
            var order = CreateTestOrder();
            var orderItem = CreateTestOrderItem(order.Id, "Free Item", 1, 0m); // Zero price
            _guidGenerator.Create().Returns(orderItem.Id);
            order.AddItem(_guidGenerator, orderItem);

            // Act & Assert
            var exception = Should.Throw<Volo.Abp.BusinessException>(
                () => order.ValidateForConfirmation());
            
            exception.Code.ShouldBe(OrdersErrorCodes.InvalidTotalAmount);
        }

        #endregion

        #region Payment Management Tests

        [Fact]
        public void AddPayment_WithValidData_ShouldCreatePayment()
        {
            // Arrange
            var order = CreateTestOrder();
            var paymentId = Guid.NewGuid();
            var totalAmount = 100000m;
            var customerMoney = 120000m;
            var paymentMethod = PaymentMethod.Cash;

            _guidGenerator.Create().Returns(paymentId);

            // Act
            var payment = order.AddPayment(_guidGenerator, totalAmount, customerMoney, paymentMethod);

            // Assert
            payment.ShouldNotBeNull();
            payment.Id.ShouldBe(paymentId);
            payment.OrderId.ShouldBe(order.Id);
            payment.TotalAmount.ShouldBe(totalAmount);
            payment.CustomerMoney.ShouldBe(customerMoney);
            payment.PaymentMethod.ShouldBe(paymentMethod);
            payment.ChangeAmount.ShouldBe(20000m);

            order.Payments.Count.ShouldBe(1);
            order.Payments.First().ShouldBe(payment);
        }

        [Fact]
        public void AddPayment_WithInactiveOrder_ShouldThrowException()
        {
            // Arrange
            var order = CreateTestOrder();
            var orderItem = CreateTestOrderItem(order.Id);
            orderItem.MarkAsServed();
            order.OrderItems.Add(orderItem);
            order.MarkAsPaid(); // Make order inactive

            // Act & Assert
            var exception = Should.Throw<Volo.Abp.BusinessException>(
                () => order.AddPayment(_guidGenerator, 100000m, 120000m, PaymentMethod.Cash));
            
            exception.Code.ShouldBe(OrdersErrorCodes.CannotAddPaymentToNonActiveOrder);
        }

        #endregion

        #region Completion Tests

        [Fact]
        public void IsCompleted_WithAllServedItems_ShouldReturnTrue()
        {
            // Arrange
            var order = CreateTestOrder();
            var orderItem1 = CreateTestOrderItem(order.Id);
            var orderItem2 = CreateTestOrderItem(order.Id);
            
            orderItem1.MarkAsServed();
            orderItem2.MarkAsServed();
            
            order.OrderItems.Add(orderItem1);
            order.OrderItems.Add(orderItem2);

            // Act & Assert
            order.IsCompleted().ShouldBeTrue();
        }

        [Fact]
        public void IsCompleted_WithMixedServedAndCanceledItems_ShouldReturnTrue()
        {
            // Arrange
            var order = CreateTestOrder();
            var orderItem1 = CreateTestOrderItem(order.Id);
            var orderItem2 = CreateTestOrderItem(order.Id);
            
            orderItem1.MarkAsServed();
            orderItem2.Cancel();
            
            order.OrderItems.Add(orderItem1);
            order.OrderItems.Add(orderItem2);

            // Act & Assert
            order.IsCompleted().ShouldBeTrue();
        }

        [Fact]
        public void IsCompleted_WithPendingItems_ShouldReturnFalse()
        {
            // Arrange
            var order = CreateTestOrder();
            var orderItem1 = CreateTestOrderItem(order.Id); // Still pending
            var orderItem2 = CreateTestOrderItem(order.Id);
            orderItem2.MarkAsServed();
            
            order.OrderItems.Add(orderItem1);
            order.OrderItems.Add(orderItem2);

            // Act & Assert
            order.IsCompleted().ShouldBeFalse();
        }

        [Fact]
        public void GetUnservedItems_ShouldReturnOnlyPendingItems()
        {
            // Arrange
            var order = CreateTestOrder();
            var pendingItem = CreateTestOrderItem(order.Id, "Pending Item");
            var servedItem = CreateTestOrderItem(order.Id, "Served Item");
            var canceledItem = CreateTestOrderItem(order.Id, "Canceled Item");
            
            servedItem.MarkAsServed();
            canceledItem.Cancel();
            
            order.OrderItems.Add(pendingItem);
            order.OrderItems.Add(servedItem);
            order.OrderItems.Add(canceledItem);

            // Act
            var unservedItems = order.GetUnservedItems();

            // Assert
            unservedItems.Count.ShouldBe(1);
            unservedItems.First().ShouldBe(pendingItem);
        }

        #endregion

        #region Helper Methods

        private Order CreateTestOrder()
        {
            return new Order(
                Guid.NewGuid(),
                "DH001",
                OrderType.DineIn,
                Guid.NewGuid(),
                "Test notes");
        }

        private OrderItem CreateTestOrderItem(Guid orderId, string menuItemName = "Phở Bò", int quantity = 2, decimal unitPrice = 50000m)
        {
            return new OrderItem(
                Guid.NewGuid(),
                orderId,
                Guid.NewGuid(),
                menuItemName,
                quantity,
                unitPrice);
        }

        #endregion
    }
}