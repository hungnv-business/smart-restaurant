using System;
using Xunit;
using Shouldly;
using SmartRestaurant.Orders;

namespace SmartRestaurant.Domain.Tests.Orders;

public class OrderItemTests : SmartRestaurantDomainTestBase<SmartRestaurantDomainTestModule>
{
    [Fact]
    public void OrderItem_Creation_Should_Work()
    {
        // Arrange & Act
        var orderItem = new OrderItem(
            Guid.NewGuid(),
            Guid.NewGuid(),
            Guid.NewGuid(),
            "Phở Bò Tái",
            2,
            85000,
            "Không hành");

        // Assert
        orderItem.MenuItemName.ShouldBe("Phở Bò Tái");
        orderItem.Quantity.ShouldBe(2);
        orderItem.UnitPrice.ShouldBe(85000);
        orderItem.Notes.ShouldBe("Không hành");
        orderItem.Status.ShouldBe(OrderItemStatus.Pending);
        orderItem.PreparationStartTime.ShouldBeNull();
        orderItem.PreparationCompleteTime.ShouldBeNull();
    }

    [Fact]
    public void OrderItem_GetTotalPrice_Should_Calculate_Correctly()
    {
        // Arrange
        var orderItem = new OrderItem(
            Guid.NewGuid(),
            Guid.NewGuid(),
            Guid.NewGuid(),
            "Phở Bò Tái",
            3,
            85000);

        // Act
        var totalPrice = orderItem.GetTotalPrice();

        // Assert
        totalPrice.ShouldBe(255000); // 3 * 85000
    }

    [Fact]
    public void OrderItem_UpdateQuantity_Should_Work_With_Valid_Values()
    {
        // Arrange
        var orderItem = new OrderItem(
            Guid.NewGuid(),
            Guid.NewGuid(),
            Guid.NewGuid(),
            "Phở Bò Tái",
            2,
            85000);

        // Act
        orderItem.UpdateQuantity(5);

        // Assert
        orderItem.Quantity.ShouldBe(5);
    }

    [Fact]
    public void OrderItem_UpdateQuantity_Should_Throw_Exception_For_Invalid_Values()
    {
        // Arrange
        var orderItem = new OrderItem(
            Guid.NewGuid(),
            Guid.NewGuid(),
            Guid.NewGuid(),
            "Phở Bò Tái",
            2,
            85000);

        // Act & Assert
        Should.Throw<ArgumentException>(() =>
            orderItem.UpdateQuantity(0))
            .Message.ShouldContain("lớn hơn 0");

        Should.Throw<ArgumentException>(() =>
            orderItem.UpdateQuantity(-1))
            .Message.ShouldContain("lớn hơn 0");
    }

    [Fact]
    public void OrderItem_UpdateNotes_Should_Trim_Whitespace()
    {
        // Arrange
        var orderItem = new OrderItem(
            Guid.NewGuid(),
            Guid.NewGuid(),
            Guid.NewGuid(),
            "Phở Bò Tái",
            2,
            85000,
            "Original notes");

        // Act
        orderItem.UpdateNotes("  Ghi chú mới  ");

        // Assert
        orderItem.Notes.ShouldBe("Ghi chú mới");
    }

    [Fact]
    public void OrderItem_UpdateNotes_Should_Handle_Null()
    {
        // Arrange
        var orderItem = new OrderItem(
            Guid.NewGuid(),
            Guid.NewGuid(),
            Guid.NewGuid(),
            "Phở Bò Tái",
            2,
            85000,
            "Original notes");

        // Act
        orderItem.UpdateNotes(null);

        // Assert
        orderItem.Notes.ShouldBeNull();
    }

    [Fact]
    public void OrderItem_UpdatePreparationStatus_Should_Update_Timestamps()
    {
        // Arrange
        var orderItem = new OrderItem(
            Guid.NewGuid(),
            Guid.NewGuid(),
            Guid.NewGuid(),
            "Phở Bò Tái",
            1,
            85000);

        // Act & Assert - Preparing status
        orderItem.UpdatePreparationStatus(OrderItemStatus.Preparing);
        orderItem.Status.ShouldBe(OrderItemStatus.Preparing);
        orderItem.PreparationStartTime.ShouldNotBeNull();
        orderItem.PreparationCompleteTime.ShouldBeNull();

        // Act & Assert - Ready status
        orderItem.UpdatePreparationStatus(OrderItemStatus.Ready);
        orderItem.Status.ShouldBe(OrderItemStatus.Ready);
        orderItem.PreparationStartTime.ShouldNotBeNull();
        orderItem.PreparationCompleteTime.ShouldNotBeNull();
    }

    [Theory]
    [InlineData(OrderItemStatus.Pending)]
    [InlineData(OrderItemStatus.Preparing)]
    [InlineData(OrderItemStatus.Ready)]
    [InlineData(OrderItemStatus.Served)]
    public void OrderItem_UpdatePreparationStatus_Should_Accept_All_Valid_Statuses(OrderItemStatus status)
    {
        // Arrange
        var orderItem = new OrderItem(
            Guid.NewGuid(),
            Guid.NewGuid(),
            Guid.NewGuid(),
            "Phở Bò Tái",
            1,
            85000);

        // Act
        orderItem.UpdatePreparationStatus(status);

        // Assert
        orderItem.Status.ShouldBe(status);
    }

    [Fact]
    public void OrderItem_Multiple_Quantity_Updates_Should_Work()
    {
        // Arrange
        var orderItem = new OrderItem(
            Guid.NewGuid(),
            Guid.NewGuid(),
            Guid.NewGuid(),
            "Phở Bò Tái",
            1,
            85000);

        // Act & Assert
        orderItem.UpdateQuantity(3);
        orderItem.Quantity.ShouldBe(3);
        orderItem.GetTotalPrice().ShouldBe(255000);

        orderItem.UpdateQuantity(1);
        orderItem.Quantity.ShouldBe(1);
        orderItem.GetTotalPrice().ShouldBe(85000);
    }
}