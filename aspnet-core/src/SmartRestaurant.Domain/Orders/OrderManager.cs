using System;
using System.Threading.Tasks;
using Volo.Abp.Domain.Services;
using Volo.Abp.Domain.Repositories;
using SmartRestaurant.TableManagement.Tables;
using SmartRestaurant.MenuManagement.MenuItems;
using SmartRestaurant.Application.Contracts.Orders.Dto;

namespace SmartRestaurant.Orders;

/// <summary>
/// Domain service cho Order aggregate, chứa các logic kinh doanh phức tạp
/// </summary>
public class OrderManager : DomainService
{
    private readonly ITableRepository _tableRepository;
    private readonly IOrderRepository _orderRepository;
    private readonly IMenuItemRepository _menuItemRepository;

    public OrderManager(
        ITableRepository tableRepository, 
        IOrderRepository orderRepository,
        IMenuItemRepository menuItemRepository)
    {
        _tableRepository = tableRepository;
        _orderRepository = orderRepository;
        _menuItemRepository = menuItemRepository;
    }

    /// <summary>
    /// Tạo đơn hàng mới với validation logic kinh doanh
    /// </summary>
    /// <param name="orderNumber">Số đơn hàng</param>
    /// <param name="orderType">Loại đơn hàng</param>
    /// <param name="tableId">ID bàn (nếu có)</param>
    /// <param name="notes">Ghi chú</param>
    /// <returns>Order mới được tạo</returns>
    public async Task<Order> CreateAsync(
        string orderNumber,
        OrderType orderType,
        Guid? tableId = null,
        string? notes = null)
    {
        // Validate bàn nếu là đơn hàng ăn tại chỗ
        if (orderType == OrderType.DineIn)
        {
            await ValidateTableAvailabilityAsync(tableId);
        }

        var order = new Order(
            GuidGenerator.Create(),
            orderNumber,
            orderType,
            tableId,
            notes);

        return order;
    }

    /// <summary>
    /// Validate tính khả dụng của bàn cho đơn hàng ăn tại chỗ
    /// </summary>
    /// <param name="tableId">ID bàn cần kiểm tra</param>
    public async Task ValidateTableAvailabilityAsync(Guid? tableId)
    {
        if (tableId == null)
        {
            throw new ArgumentException("Đơn hàng ăn tại chỗ phải có bàn", nameof(tableId));
        }

        var table = await _tableRepository.GetAsync(tableId.Value);
        ArgumentNullException.ThrowIfNull(table, $"Không tìm thấy bàn với ID {tableId}");

        // Kiểm tra trạng thái bàn
        if (table.Status != TableStatus.Available && table.Status != TableStatus.Occupied)
        {
            throw new InvalidOperationException($"Bàn {table.TableNumber} không khả dụng");
        }
    }

    // /// <summary>
    // /// Tính tổng tiền đơn hàng dựa trên các OrderItem
    // /// </summary>
    // /// <param name="order">Đơn hàng cần tính</param>
    // /// <returns>Tổng tiền</returns>
    // public decimal CalculateTotalAmount(Order order)
    // {
    //     if (order.OrderItems == null || order.OrderItems.Count == 0)
    //     {
    //         return 0;
    //     }

    //     return order.OrderItems.Sum(item => item.GetTotalPrice());
    // }

    // /// <summary>
    // /// Validate đơn hàng có thể được xác nhận không
    // /// </summary>
    // /// <param name="order">Đơn hàng cần validate</param>
    // public void ValidateOrderForConfirmation(Order order)
    // {
    //     if (order.Status != OrderStatus.Active)
    //     {
    //         // Business Exception: Chỉ có thể xác nhận đơn hàng ở trạng thái Pending
    //         throw OrderValidationException.CannotConfirmNonPendingOrder();
    //     }

    //     if (order.OrderItems == null || order.OrderItems.Count == 0)
    //     {
    //         // Business Exception: Đơn hàng trống
    //         throw OrderValidationException.EmptyOrder();
    //     }

    //     if (order.OrderType == OrderType.DineIn && order.TableId == null)
    //     {
    //         // Business Exception: Đơn hàng ăn tại chỗ không có bàn
    //         throw OrderValidationException.DineInWithoutTable();
    //     }

    //     var totalAmount = CalculateTotalAmount(order);
    //     if (totalAmount <= 0)
    //     {
    //         // Business Exception: Tổng tiền không hợp lệ
    //         throw OrderValidationException.InvalidTotalAmount();
    //     }
    // }

    // /// <summary>
    // /// Xác nhận đơn hàng và cập nhật trạng thái
    // /// </summary>
    // /// <param name="order">Đơn hàng cần xác nhận</param>
    // public void ConfirmOrder(Order order)
    // {
    //     ValidateOrderForConfirmation(order);
    //     
    //     // Cập nhật tổng tiền
    //     order.TotalAmount = CalculateTotalAmount(order);
    //     
    //     // Chuyển trạng thái
    //     // Với OrderStatus đơn giản, không cần thay đổi status khi confirm
    //     // order.UpdateStatus(OrderStatus.Confirmed);
    // }

    /// <summary>
    /// Tạo OrderItem mới với validation
    /// </summary>
    /// <param name="orderId">ID đơn hàng</param>
    /// <param name="menuItemId">ID món ăn</param>
    /// <param name="menuItemName">Tên món ăn</param>
    /// <param name="quantity">Số lượng</param>
    /// <param name="unitPrice">Giá đơn vị</param>
    /// <param name="notes">Ghi chú</param>
    /// <returns>OrderItem mới</returns>
    public OrderItem CreateOrderItem(
        Guid orderId,
        Guid menuItemId,
        string menuItemName,
        int quantity,
        decimal unitPrice,
        string? notes = null)
    {
        if (string.IsNullOrWhiteSpace(menuItemName))
        {
            throw new ArgumentException("Tên món ăn không được để trống", nameof(menuItemName));
        }

        if (quantity <= 0)
        {
            throw new ArgumentException("Số lượng phải lớn hơn 0", nameof(quantity));
        }

        if (unitPrice < 0)
        {
            throw new ArgumentException("Giá không được âm", nameof(unitPrice));
        }

        return new OrderItem(
            GuidGenerator.Create(),
            orderId,
            menuItemId,
            menuItemName.Trim(),
            quantity,
            unitPrice,
            notes?.Trim());
    }

    // /// <summary>
    // /// Thông báo đơn hàng mới cho bếp
    // /// </summary>
    // /// <param name="order">Đơn hàng cần thông báo</param>
    // public async Task NotifyKitchenAsync(Order order)
    // {
    //     // TODO: Triển khai khi có SignalR Hub
    //     // await _kitchenHubContext.Clients.All.SendAsync("NewOrder", order);
    //     await Task.CompletedTask;
    // }

    // /// <summary>
    // /// In bill bếp cho đơn hàng
    // /// </summary>
    // /// <param name="order">Đơn hàng cần in bill</param>
    // /// <param name="selectedItems">Các món cụ thể cần in (nếu null thì in tất cả)</param>
    // public async Task PrintKitchenBillAsync(Order order, List<Guid>? selectedItems = null)
    // {
    //     // TODO: Triển khai chức năng in bill
    //     // Tích hợp với máy in bếp hoặc dịch vụ in
    //     await Task.CompletedTask;
    // }

    // /// <summary>
    // /// Xử lý trừ kho nguyên liệu tự động khi đơn hàng được xác nhận
    // /// </summary>
    // /// <param name="order">Đơn hàng đã được xác nhận</param>
    // public async Task ProcessInventoryDeductionAsync(Order order)
    // {
    //     // TODO: Triển khai khi có MenuItemIngredient entity và IngredientManager
    //     // Tự động trừ kho dựa trên recipe của từng món
    //     await Task.CompletedTask;
    // }

    // /// <summary>
    // /// Hoàn thành quy trình phục vụ đơn hàng
    // /// </summary>
    // /// <param name="order">Đơn hàng cần hoàn thành</param>
    // public void CompleteOrderService(Order order)
    // {
    //     if (order.Status != OrderStatus.Active)
    //     {
    //         // Business Exception: Chỉ có thể hoàn thành phục vụ khi đơn hàng đang Active
    //         throw new InvalidOperationException("Chỉ có thể hoàn thành phục vụ khi đơn hàng đang Active");
    //     }

    //     // Với OrderStatus đơn giản: Active → Paid khi hoàn thành
    //     order.MarkAsPaid();
    //     
    //     // TODO: Cập nhật trạng thái bàn về Available khi có Table.Status
    //     // if (order.TableId.HasValue)
    //     // {
    //     //     var table = await _tableRepository.GetAsync(order.TableId.Value);
    //     //     table.SetStatus(TableStatus.Available);
    //     // }
    // }

    /// <summary>
    /// Tạo số đơn hàng tự động theo ngày
    /// </summary>
    /// <returns>Số đơn hàng mới</returns>
    public async Task<string> GenerateOrderNumberAsync()
    {
        var today = DateTime.UtcNow.Date;
        var orderCount = await GetOrderCountByDateAsync(today);
        var nextNumber = orderCount + 1;
        
        return $"ORD-{today:yyyyMMdd}-{nextNumber:D3}";
    }

    /// <summary>
    /// Đếm số đơn hàng theo ngày (cần implement trong repository)
    /// </summary>
    /// <param name="date">Ngày cần đếm</param>
    /// <returns>Số đơn hàng trong ngày</returns>
    private async Task<int> GetOrderCountByDateAsync(DateTime date)
    {
        return await _orderRepository.CountOrdersByDateAsync(date);
    }

    /// <summary>
    /// Validate toàn bộ input tạo đơn hàng với business rules và external dependencies
    /// </summary>
    /// <param name="input">Input tạo đơn hàng</param>
    public async Task ValidateCreateOrderInputAsync(CreateOrderDto input)
    {
        // 1. Validate table availability nếu là DineIn
        if (input.OrderType == OrderType.DineIn && input.TableId.HasValue)
        {
            await ValidateTableAvailabilityAsync(input.TableId);
        }

        // 2. Validate menu items exist và available, auto-fill price và name
        foreach (var itemDto in input.OrderItems)
        {
            // Check availability và lấy menu item
            if (!await _menuItemRepository.IsMenuItemAvailableAsync(itemDto.MenuItemId))
            {
                var unavailableItem = await _menuItemRepository.GetAsync(itemDto.MenuItemId);
                throw new InvalidOperationException($"Món '{unavailableItem.Name}' hiện không có sẵn");
            }
            
            var menuItem = await _menuItemRepository.GetAsync(itemDto.MenuItemId);

            // Auto-update price and name if not provided
            if (itemDto.UnitPrice <= 0)
            {
                itemDto.UnitPrice = menuItem.Price;
            }

            if (string.IsNullOrWhiteSpace(itemDto.MenuItemName))
            {
                itemDto.MenuItemName = menuItem.Name;
            }
        }
    }
}