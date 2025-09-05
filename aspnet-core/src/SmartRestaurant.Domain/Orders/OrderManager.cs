using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Volo.Abp.Domain.Services;
using SmartRestaurant.TableManagement.Tables;

namespace SmartRestaurant.Orders;

/// <summary>
/// Domain service cho Order aggregate, chứa các logic kinh doanh phức tạp
/// </summary>
public class OrderManager : DomainService
{
    private readonly ITableRepository _tableRepository;

    public OrderManager(ITableRepository tableRepository)
    {
        _tableRepository = tableRepository;
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

        // TODO: Kiểm tra trạng thái bàn khi Table entity có thuộc tính Status
        // if (table.Status != TableStatus.Available)
        // {
        //     throw new InvalidOperationException($"Bàn {table.Name} không khả dụng");
        // }
    }

    /// <summary>
    /// Tính tổng tiền đơn hàng dựa trên các OrderItem
    /// </summary>
    /// <param name="order">Đơn hàng cần tính</param>
    /// <returns>Tổng tiền</returns>
    public decimal CalculateTotalAmount(Order order)
    {
        if (order.OrderItems == null || order.OrderItems.Count == 0)
        {
            return 0;
        }

        return order.OrderItems.Sum(item => item.GetTotalPrice());
    }

    /// <summary>
    /// Validate đơn hàng có thể được xác nhận không
    /// </summary>
    /// <param name="order">Đơn hàng cần validate</param>
    public void ValidateOrderForConfirmation(Order order)
    {
        if (order.Status != OrderStatus.Pending)
        {
            // Business Exception: Chỉ có thể xác nhận đơn hàng ở trạng thái Pending
            throw OrderValidationException.CannotConfirmNonPendingOrder();
        }

        if (order.OrderItems == null || order.OrderItems.Count == 0)
        {
            // Business Exception: Đơn hàng trống
            throw OrderValidationException.EmptyOrder();
        }

        if (order.OrderType == OrderType.DineIn && order.TableId == null)
        {
            // Business Exception: Đơn hàng ăn tại chỗ không có bàn
            throw OrderValidationException.DineInWithoutTable();
        }

        var totalAmount = CalculateTotalAmount(order);
        if (totalAmount <= 0)
        {
            // Business Exception: Tổng tiền không hợp lệ
            throw OrderValidationException.InvalidTotalAmount();
        }
    }

    /// <summary>
    /// Xác nhận đơn hàng và cập nhật trạng thái
    /// </summary>
    /// <param name="order">Đơn hàng cần xác nhận</param>
    public void ConfirmOrder(Order order)
    {
        ValidateOrderForConfirmation(order);
        
        // Cập nhật tổng tiền
        order.TotalAmount = CalculateTotalAmount(order);
        
        // Chuyển trạng thái
        order.UpdateStatus(OrderStatus.Confirmed);
    }

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

    /// <summary>
    /// Thông báo đơn hàng mới cho bếp
    /// </summary>
    /// <param name="order">Đơn hàng cần thông báo</param>
    public async Task NotifyKitchenAsync(Order order)
    {
        // TODO: Triển khai khi có SignalR Hub
        // await _kitchenHubContext.Clients.All.SendAsync("NewOrder", order);
        await Task.CompletedTask;
    }

    /// <summary>
    /// In bill bếp cho đơn hàng
    /// </summary>
    /// <param name="order">Đơn hàng cần in bill</param>
    /// <param name="selectedItems">Các món cụ thể cần in (nếu null thì in tất cả)</param>
    public async Task PrintKitchenBillAsync(Order order, List<Guid>? selectedItems = null)
    {
        // TODO: Triển khai chức năng in bill
        // Tích hợp với máy in bếp hoặc dịch vụ in
        await Task.CompletedTask;
    }

    /// <summary>
    /// Xử lý trừ kho nguyên liệu tự động khi đơn hàng được xác nhận
    /// </summary>
    /// <param name="order">Đơn hàng đã được xác nhận</param>
    public async Task ProcessInventoryDeductionAsync(Order order)
    {
        // TODO: Triển khai khi có MenuItemIngredient entity và IngredientManager
        // Tự động trừ kho dựa trên recipe của từng món
        await Task.CompletedTask;
    }

    /// <summary>
    /// Hoàn thành quy trình phục vụ đơn hàng
    /// </summary>
    /// <param name="order">Đơn hàng cần hoàn thành</param>
    public void CompleteOrderService(Order order)
    {
        if (order.Status != OrderStatus.Ready)
        {
            // Business Exception: Chỉ có thể hoàn thành phục vụ khi đơn hàng đã sẵn sàng
            throw OrderValidationException.CannotCompleteNonReadyOrder();
        }

        order.UpdateStatus(OrderStatus.Served);
        
        // TODO: Cập nhật trạng thái bàn về Available khi có Table.Status
        // if (order.TableId.HasValue)
        // {
        //     var table = await _tableRepository.GetAsync(order.TableId.Value);
        //     table.SetStatus(TableStatus.Available);
        // }
    }

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
        // TODO: Triển khai khi có IOrderRepository.CountOrdersByDateAsync
        await Task.CompletedTask;
        return 0;
    }
}