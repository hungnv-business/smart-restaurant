using System;
using Xunit;
using Shouldly;
using SmartRestaurant.Orders;

namespace SmartRestaurant.Domain.Tests.Orders;

public class OrderTests : SmartRestaurantDomainTestBase<SmartRestaurantDomainTestModule>
{
    [Fact]
    public void Order_Creation_Should_Work()
    {
        // Arrange & Act
        var order = new Order(
            Guid.NewGuid(),
            "ORD-001",
            OrderType.DineIn,
            Guid.NewGuid(),
            "Ghi chú test");

        // Assert
        order.OrderNumber.ShouldBe("ORD-001");
        order.OrderType.ShouldBe(OrderType.DineIn);
        order.Status.ShouldBe(OrderStatus.Pending);
        order.TotalAmount.ShouldBe(0);
        order.Notes.ShouldBe("Ghi chú test");
        order.TableId.ShouldNotBeNull();
    }

    [Fact]
    public void Order_Status_Transition_Should_Follow_Business_Rules()
    {
        // Arrange
        var order = new Order(
            Guid.NewGuid(),
            "ORD-002",
            OrderType.DineIn);

        // Act & Assert - Valid transitions
        order.CanTransitionTo(OrderStatus.Confirmed).ShouldBeTrue();
        order.UpdateStatus(OrderStatus.Confirmed);
        order.Status.ShouldBe(OrderStatus.Confirmed);
        order.ConfirmedTime.ShouldNotBeNull();

        order.CanTransitionTo(OrderStatus.Preparing).ShouldBeTrue();
        order.UpdateStatus(OrderStatus.Preparing);
        order.Status.ShouldBe(OrderStatus.Preparing);
        order.PreparingTime.ShouldNotBeNull();

        order.CanTransitionTo(OrderStatus.Ready).ShouldBeTrue();
        order.UpdateStatus(OrderStatus.Ready);
        order.Status.ShouldBe(OrderStatus.Ready);
        order.ReadyTime.ShouldNotBeNull();

        order.CanTransitionTo(OrderStatus.Served).ShouldBeTrue();
        order.UpdateStatus(OrderStatus.Served);
        order.Status.ShouldBe(OrderStatus.Served);
        order.ServedTime.ShouldNotBeNull();

        order.CanTransitionTo(OrderStatus.Paid).ShouldBeTrue();
        order.UpdateStatus(OrderStatus.Paid);
        order.Status.ShouldBe(OrderStatus.Paid);
        order.PaidTime.ShouldNotBeNull();
    }

    [Fact]
    public void Order_Invalid_Status_Transition_Should_Throw_Exception()
    {
        // Arrange
        var order = new Order(
            Guid.NewGuid(),
            "ORD-003",
            OrderType.DineIn);

        // Act & Assert - Invalid transitions
        order.CanTransitionTo(OrderStatus.Preparing).ShouldBeFalse();
        
        Should.Throw<InvalidOperationException>(() =>
            order.UpdateStatus(OrderStatus.Preparing))
            .Message.ShouldContain("Không thể chuyển trạng thái từ");

        // Test from Paid status (final state)
        order.UpdateStatus(OrderStatus.Confirmed);
        order.UpdateStatus(OrderStatus.Preparing);
        order.UpdateStatus(OrderStatus.Ready);
        order.UpdateStatus(OrderStatus.Served);
        order.UpdateStatus(OrderStatus.Paid);

        order.CanTransitionTo(OrderStatus.Served).ShouldBeFalse();
        Should.Throw<InvalidOperationException>(() =>
            order.UpdateStatus(OrderStatus.Served));
    }

    [Fact]
    public void Order_AddItem_Should_Work_In_Pending_Status()
    {
        // Arrange
        var order = new Order(
            Guid.NewGuid(),
            "ORD-004",
            OrderType.DineIn);

        var orderItem = new OrderItem(
            Guid.NewGuid(),
            order.Id,
            Guid.NewGuid(),
            "Phở Bò",
            2,
            85000,
            "Không hành");

        // Act
        order.AddItem(orderItem);

        // Assert
        order.OrderItems.Count.ShouldBe(1);
        order.TotalAmount.ShouldBe(170000); // 2 * 85000
        order.OrderItems.ShouldContain(orderItem);
    }

    [Fact]
    public void Order_AddItem_Should_Throw_Exception_If_Not_Pending()
    {
        // Arrange
        var order = new Order(
            Guid.NewGuid(),
            "ORD-005",
            OrderType.DineIn);
        
        order.UpdateStatus(OrderStatus.Confirmed);

        var orderItem = new OrderItem(
            Guid.NewGuid(),
            order.Id,
            Guid.NewGuid(),
            "Phở Bò",
            2,
            85000);

        // Act & Assert
        Should.Throw<InvalidOperationException>(() =>
            order.AddItem(orderItem))
            .Message.ShouldContain("chờ xác nhận");
    }

    [Fact]
    public void Order_RemoveItem_Should_Work_In_Pending_Status()
    {
        // Arrange
        var order = new Order(
            Guid.NewGuid(),
            "ORD-006",
            OrderType.DineIn);

        var orderItem1 = new OrderItem(
            Guid.NewGuid(),
            order.Id,
            Guid.NewGuid(),
            "Phở Bò",
            1,
            85000);

        var orderItem2 = new OrderItem(
            Guid.NewGuid(),
            order.Id,
            Guid.NewGuid(),
            "Bún Bò Huế",
            1,
            75000);

        order.AddItem(orderItem1);
        order.AddItem(orderItem2);
        order.TotalAmount.ShouldBe(160000);

        // Act
        order.RemoveItem(orderItem1.Id);

        // Assert
        order.OrderItems.Count.ShouldBe(1);
        order.TotalAmount.ShouldBe(75000);
        order.OrderItems.ShouldNotContain(orderItem1);
    }

    [Fact]
    public void Order_ValidateForConfirmation_Should_Enforce_Business_Rules()
    {
        // Arrange
        var order = new Order(
            Guid.NewGuid(),
            "ORD-007",
            OrderType.DineIn,
            Guid.NewGuid());

        // Act & Assert - Empty order
        Should.Throw<InvalidOperationException>(() =>
            order.ValidateForConfirmation())
            .Message.ShouldContain("ít nhất một món");

        // Add items
        var orderItem = new OrderItem(
            Guid.NewGuid(),
            order.Id,
            Guid.NewGuid(),
            "Phở Bò",
            1,
            85000);
        order.AddItem(orderItem);

        // Should work now
        Should.NotThrow(() => order.ValidateForConfirmation());
    }

    [Fact]
    public void Order_ValidateForConfirmation_Should_Require_Table_For_DineIn()
    {
        // Arrange - DineIn order without table
        var order = new Order(
            Guid.NewGuid(),
            "ORD-008",
            OrderType.DineIn,
            null); // No table

        var orderItem = new OrderItem(
            Guid.NewGuid(),
            order.Id,
            Guid.NewGuid(),
            "Phở Bò",
            1,
            85000);
        order.AddItem(orderItem);

        // Act & Assert
        Should.Throw<InvalidOperationException>(() =>
            order.ValidateForConfirmation())
            .Message.ShouldContain("phải có bàn");
    }

    [Fact]
    public void Order_ValidateForConfirmation_Should_Allow_Takeaway_Without_Table()
    {
        // Arrange - Takeaway order without table
        var order = new Order(
            Guid.NewGuid(),
            "ORD-009",
            OrderType.Takeaway,
            null); // No table for takeaway

        var orderItem = new OrderItem(
            Guid.NewGuid(),
            order.Id,
            Guid.NewGuid(),
            "Phở Bò",
            1,
            85000);
        order.AddItem(orderItem);

        // Act & Assert - Should not throw
        Should.NotThrow(() => order.ValidateForConfirmation());
    }
}