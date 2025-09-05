using System;
using System.Threading.Tasks;
using Xunit;
using Shouldly;
using NSubstitute;
using SmartRestaurant.Orders;
using SmartRestaurant.TableManagement.Tables;

namespace SmartRestaurant.Domain.Tests.Orders;

public class OrderManagerTests : SmartRestaurantDomainTestBase<SmartRestaurantDomainTestModule>
{
    private readonly ITableRepository _tableRepository;
    private readonly OrderManager _orderManager;

    public OrderManagerTests()
    {
        _tableRepository = Substitute.For<ITableRepository>();
        _orderManager = new OrderManager(_tableRepository);
    }

    [Fact]
    public async Task CreateAsync_Should_Create_Order_With_Valid_Data()
    {
        // Arrange
        var tableId = Guid.NewGuid();
        var table = Substitute.For<Table>(); // Mock table
        _tableRepository.GetAsync(tableId).Returns(table);

        // Act
        var order = await _orderManager.CreateAsync(
            "ORD-001", 
            OrderType.DineIn, 
            tableId, 
            "Test order");

        // Assert
        order.ShouldNotBeNull();
        order.OrderNumber.ShouldBe("ORD-001");
        order.OrderType.ShouldBe(OrderType.DineIn);
        order.TableId.ShouldBe(tableId);
        order.Notes.ShouldBe("Test order");
        order.Status.ShouldBe(OrderStatus.Pending);
        order.TotalAmount.ShouldBe(0);
    }

    [Fact]
    public async Task CreateAsync_Should_Create_Takeaway_Order_Without_Table()
    {
        // Act
        var order = await _orderManager.CreateAsync(
            "ORD-002", 
            OrderType.Takeaway, 
            null, 
            "Takeaway order");

        // Assert
        order.ShouldNotBeNull();
        order.OrderNumber.ShouldBe("ORD-002");
        order.OrderType.ShouldBe(OrderType.Takeaway);
        order.TableId.ShouldBeNull();
        order.Notes.ShouldBe("Takeaway order");
    }

    [Fact]
    public async Task ValidateTableAvailabilityAsync_Should_Throw_Exception_For_Null_TableId_In_DineIn()
    {
        // Act & Assert
        var exception = await Should.ThrowAsync<ArgumentException>(
            () => _orderManager.ValidateTableAvailabilityAsync(null));
        
        exception.Message.ShouldContain("phải có bàn");
        exception.ParamName.ShouldBe("tableId");
    }

    [Fact]
    public async Task ValidateTableAvailabilityAsync_Should_Throw_Exception_For_NonExistent_Table()
    {
        // Arrange
        var tableId = Guid.NewGuid();
        _tableRepository.GetAsync(tableId).Returns((Table?)null);

        // Act & Assert
        var exception = await Should.ThrowAsync<ArgumentException>(
            () => _orderManager.ValidateTableAvailabilityAsync(tableId));
        
        exception.Message.ShouldContain($"Không tìm thấy bàn với ID {tableId}");
        exception.ParamName.ShouldBe("tableId");
    }

    [Fact]
    public async Task ValidateTableAvailabilityAsync_Should_Pass_For_Valid_Table()
    {
        // Arrange
        var tableId = Guid.NewGuid();
        var table = Substitute.For<Table>(); // Mock valid table
        _tableRepository.GetAsync(tableId).Returns(table);

        // Act & Assert
        await Should.NotThrowAsync(() => _orderManager.ValidateTableAvailabilityAsync(tableId));
    }

    [Fact]
    public void CalculateTotalAmount_Should_Return_Zero_For_Empty_Order()
    {
        // Arrange
        var order = new Order(Guid.NewGuid(), "ORD-003", OrderType.DineIn);

        // Act
        var total = _orderManager.CalculateTotalAmount(order);

        // Assert
        total.ShouldBe(0);
    }

    [Fact]
    public void CalculateTotalAmount_Should_Calculate_Correctly()
    {
        // Arrange
        var order = new Order(Guid.NewGuid(), "ORD-004", OrderType.DineIn);
        
        var item1 = new OrderItem(Guid.NewGuid(), order.Id, Guid.NewGuid(), "Phở Bò", 2, 85000);
        var item2 = new OrderItem(Guid.NewGuid(), order.Id, Guid.NewGuid(), "Cà phê", 1, 25000);
        
        order.AddItem(item1);
        order.AddItem(item2);

        // Act
        var total = _orderManager.CalculateTotalAmount(order);

        // Assert
        total.ShouldBe(195000); // (2 * 85000) + (1 * 25000)
    }

    [Fact]
    public void ValidateOrderForConfirmation_Should_Throw_For_Non_Pending_Status()
    {
        // Arrange
        var order = new Order(Guid.NewGuid(), "ORD-005", OrderType.DineIn);
        order.UpdateStatus(OrderStatus.Confirmed);

        // Act & Assert
        Should.Throw<InvalidOperationException>(
            () => _orderManager.ValidateOrderForConfirmation(order))
            .Message.ShouldContain("Pending");
    }

    [Fact]
    public void ValidateOrderForConfirmation_Should_Throw_For_Empty_Order()
    {
        // Arrange
        var order = new Order(Guid.NewGuid(), "ORD-006", OrderType.DineIn, Guid.NewGuid());

        // Act & Assert
        Should.Throw<InvalidOperationException>(
            () => _orderManager.ValidateOrderForConfirmation(order))
            .Message.ShouldContain("ít nhất một món");
    }

    [Fact]
    public void ValidateOrderForConfirmation_Should_Throw_For_DineIn_Without_Table()
    {
        // Arrange
        var order = new Order(Guid.NewGuid(), "ORD-007", OrderType.DineIn, null);
        var item = new OrderItem(Guid.NewGuid(), order.Id, Guid.NewGuid(), "Phở Bò", 1, 85000);
        order.AddItem(item);

        // Act & Assert
        Should.Throw<InvalidOperationException>(
            () => _orderManager.ValidateOrderForConfirmation(order))
            .Message.ShouldContain("phải có bàn");
    }

    [Fact]
    public void ValidateOrderForConfirmation_Should_Pass_For_Valid_Order()
    {
        // Arrange
        var order = new Order(Guid.NewGuid(), "ORD-008", OrderType.DineIn, Guid.NewGuid());
        var item = new OrderItem(Guid.NewGuid(), order.Id, Guid.NewGuid(), "Phở Bò", 1, 85000);
        order.AddItem(item);

        // Act & Assert
        Should.NotThrow(() => _orderManager.ValidateOrderForConfirmation(order));
    }

    [Fact]
    public void ConfirmOrder_Should_Update_Status_And_Total()
    {
        // Arrange
        var order = new Order(Guid.NewGuid(), "ORD-009", OrderType.DineIn, Guid.NewGuid());
        var item = new OrderItem(Guid.NewGuid(), order.Id, Guid.NewGuid(), "Phở Bò", 2, 85000);
        order.AddItem(item);

        // Act
        _orderManager.ConfirmOrder(order);

        // Assert
        order.Status.ShouldBe(OrderStatus.Confirmed);
        order.TotalAmount.ShouldBe(170000); // Updated total
        order.ConfirmedTime.ShouldNotBeNull();
    }

    [Fact]
    public void CreateOrderItem_Should_Create_Valid_OrderItem()
    {
        // Arrange
        var orderId = Guid.NewGuid();
        var menuItemId = Guid.NewGuid();

        // Act
        var orderItem = _orderManager.CreateOrderItem(
            orderId, menuItemId, "Phở Bò Tái", 2, 85000, "Không hành");

        // Assert
        orderItem.ShouldNotBeNull();
        orderItem.OrderId.ShouldBe(orderId);
        orderItem.MenuItemId.ShouldBe(menuItemId);
        orderItem.MenuItemName.ShouldBe("Phở Bò Tái");
        orderItem.Quantity.ShouldBe(2);
        orderItem.UnitPrice.ShouldBe(85000);
        orderItem.Notes.ShouldBe("Không hành");
        orderItem.Status.ShouldBe(OrderItemStatus.Pending);
    }

    [Theory]
    [InlineData("", "Tên món ăn không được để trống")]
    [InlineData("   ", "Tên món ăn không được để trống")]
    public void CreateOrderItem_Should_Validate_MenuItemName(string menuItemName, string expectedMessage)
    {
        // Act & Assert
        var exception = Should.Throw<ArgumentException>(
            () => _orderManager.CreateOrderItem(
                Guid.NewGuid(), Guid.NewGuid(), menuItemName, 1, 85000));
        
        exception.Message.ShouldContain(expectedMessage);
        exception.ParamName.ShouldBe("menuItemName");
    }

    [Fact]
    public void CreateOrderItem_Should_Validate_Null_MenuItemName()
    {
        // Act & Assert
        var exception = Should.Throw<ArgumentException>(
            () => _orderManager.CreateOrderItem(
                Guid.NewGuid(), Guid.NewGuid(), null!, 1, 85000));
        
        exception.Message.ShouldContain("Tên món ăn không được để trống");
        exception.ParamName.ShouldBe("menuItemName");
    }

    [Theory]
    [InlineData(0)]
    [InlineData(-1)]
    public void CreateOrderItem_Should_Validate_Quantity(int quantity)
    {
        // Act & Assert
        var exception = Should.Throw<ArgumentException>(
            () => _orderManager.CreateOrderItem(
                Guid.NewGuid(), Guid.NewGuid(), "Phở Bò", quantity, 85000));
        
        exception.Message.ShouldContain("lớn hơn 0");
        exception.ParamName.ShouldBe("quantity");
    }

    [Fact]
    public void CreateOrderItem_Should_Validate_UnitPrice()
    {
        // Act & Assert
        var exception = Should.Throw<ArgumentException>(
            () => _orderManager.CreateOrderItem(
                Guid.NewGuid(), Guid.NewGuid(), "Phở Bò", 1, -1000));
        
        exception.Message.ShouldContain("không được âm");
        exception.ParamName.ShouldBe("unitPrice");
    }

    [Fact]
    public void CreateOrderItem_Should_Trim_Notes()
    {
        // Act
        var orderItem = _orderManager.CreateOrderItem(
            Guid.NewGuid(), Guid.NewGuid(), "  Phở Bò  ", 1, 85000, "  Ghi chú  ");

        // Assert
        orderItem.MenuItemName.ShouldBe("Phở Bò");
        orderItem.Notes.ShouldBe("Ghi chú");
    }
}