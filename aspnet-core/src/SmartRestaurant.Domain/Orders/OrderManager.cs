using System;
using System.Threading.Tasks;
using Volo.Abp.Domain.Services;
using Volo.Abp.Domain.Repositories;
using SmartRestaurant.TableManagement.Tables;
using SmartRestaurant.MenuManagement.MenuItems;
using SmartRestaurant.Application.Contracts.Orders.Dto;
using SmartRestaurant.MenuManagement;
using SmartRestaurant.InventoryManagement.Ingredients;
using System.Linq;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using Volo.Abp;

namespace SmartRestaurant.Orders;

/// <summary>
/// Domain service cho Order aggregate, chứa các logic kinh doanh phức tạp
/// </summary>
public class OrderManager : DomainService
{
    #region Khởi tạo và thiết lập

    private readonly ITableRepository _tableRepository;
    private readonly IOrderRepository _orderRepository;
    private readonly IPaymentRepository _paymentRepository;
    private readonly IMenuItemRepository _menuItemRepository;
    private readonly RecipeManager _recipeManager;
    private readonly IngredientManager _ingredientManager;

    public OrderManager(
        ITableRepository tableRepository,
        IOrderRepository orderRepository,
        IPaymentRepository paymentRepository,
        IMenuItemRepository menuItemRepository,
        RecipeManager recipeManager,
        IngredientManager ingredientManager)
    {
        _tableRepository = tableRepository;
        _orderRepository = orderRepository;
        _paymentRepository = paymentRepository;
        _menuItemRepository = menuItemRepository;
        _recipeManager = recipeManager;
        _ingredientManager = ingredientManager;
    }

    #endregion

    #region Quản lý tạo đơn hàng

    /// <summary>
    /// Tạo đơn hàng mới với tất cả business logic (table assignment, inventory deduction)
    /// </summary>
    /// <param name="orderNumber">Số đơn hàng</param>
    /// <param name="orderType">Loại đơn hàng</param>
    /// <param name="orderItems">Danh sách món ăn</param>
    /// <param name="tableId">ID bàn (nếu có)</param>
    /// <param name="notes">Ghi chú</param>
    /// <returns>Order đã hoàn thành tất cả business logic</returns>
    public async Task<Order> CreateAsync(
        string orderNumber,
        OrderType orderType,
        IEnumerable<OrderItem> orderItems,
        Guid? tableId = null,
        string? notes = null
        )
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

        order.AddItems(GuidGenerator, orderItems);

        // Save to database (order đã hoàn thành tất cả business logic)
        await _orderRepository.InsertAsync(order);

        // Assign order to table nếu có tableId
        if (tableId.HasValue)
        {
            var table = await _tableRepository.GetAsync(tableId.Value);
            table.AssignOrder(order.Id);
        }

        // Tự động trừ kho nguyên liệu khi tạo order (auto-confirm)
        try
        {
            await _recipeManager.ProcessAutomaticDeductionForItemsAsync(order.OrderItems.ToList());
            Logger.LogInformation("Successfully processed inventory deduction for new order {OrderId}", order.Id);
        }
        catch (Exception ex)
        {
            // Log warning nhưng không fail toàn bộ create process
            // Business decision: Có thể tạo order ngay cả khi inventory update thất bại
            Logger.LogWarning(ex, "Failed to process inventory deduction for order {OrderId}, but order was created successfully", order.Id);
        }

        return order;
    }

    #endregion

    #region Quản lý món ăn trong đơn

    /// <summary>
    /// Xóa món khỏi order với business validation
    /// </summary>
    /// <param name="order">Order cần xóa món</param>
    /// <param name="orderItemId">ID của OrderItem cần xóa</param>
    /// <returns>Task</returns>
    public async Task RemoveOrderItemAsync(Order order, Guid orderItemId)
    {
        // Validate order phải ở trạng thái Active
        if (!order.IsServing())
        {
            throw OrderValidationException.CannotRemoveItemFromInactiveOrder();
        }

        // Validate OrderItem tồn tại trong order
        if (!order.IsOrderItemIn(orderItemId))
        {
            throw OrderValidationException.OrderItemNotFoundInOrder(orderItemId, order.Id);
        }

        var orderItem = order.OrderItems.First(oi => oi.Id == orderItemId);

        // Validate OrderItem phải ở trạng thái có thể xóa (Pending)
        if (!orderItem.IsPending())
        {
            throw OrderValidationException.CannotRemoveNonPendingOrderItem(orderItem.MenuItemName, orderItem.Status);
        }

        // Business rule: Không được xóa hết tất cả món trong order
        if (order.OrderItems.Count <= 1)
        {
            throw OrderValidationException.CannotRemoveLastOrderItem();
        }

        // Trước khi xóa, cần cộng lại stock cho các nguyên liệu đã sử dụng
        await RestoreIngredientStockAsync(orderItem.MenuItemId, orderItem.Quantity);

        // Xóa món khỏi order (sử dụng domain method)
        order.RemoveItem(orderItemId);
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
    //     if (order.Status != OrderStatus.Serving)
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
    //     // order.UpdateStatus(OrderStatus.Serving);
    // }

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
    //     if (order.Status != OrderStatus.Serving)
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
                throw OrderValidationException.MenuItemNotAvailable(unavailableItem.Name);
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

    /// <summary>
    /// Validate và cập nhật số lượng OrderItem với business rules
    /// </summary>
    /// <param name="order">Order chứa OrderItem cần cập nhật</param>
    /// <param name="orderItemId">ID OrderItem cần cập nhật</param>
    /// <param name="newQuantity">Số lượng mới</param>
    /// <param name="notes">Ghi chú mới (optional)</param>
    public async Task UpdateOrderItemQuantityAsync(Order order, Guid orderItemId, int newQuantity, string? notes = null)
    {
        // Validate order phải ở trạng thái Active
        if (!order.IsServing())
        {
            throw OrderValidationException.CannotModifyNonActiveOrder();
        }

        // Tìm order item cần cập nhật
        if (!order.IsOrderItemIn(orderItemId))
        {
            throw OrderValidationException.OrderItemNotFound(orderItemId);
        }

        var orderItem = order.OrderItems.First(x => x.Id == orderItemId);

        // Validate order item phải ở trạng thái Pending
        if (!orderItem.IsPending())
        {
            throw OrderValidationException.CannotUpdateQuantityNonPendingItem();
        }

        // Lưu số lượng cũ để tính toán sự khác biệt inventory
        var oldQuantity = orderItem.Quantity;
        var quantityDifference = newQuantity - oldQuantity;

        // Nếu có thay đổi số lượng, cần cập nhật inventory cho các nguyên liệu
        if (quantityDifference != 0)
        {
            // Lấy thông tin món ăn với danh sách nguyên liệu
            var menuItem = await _menuItemRepository.GetWithDetailsAsync(orderItem.MenuItemId);

            if (menuItem != null)
            {
                // Cập nhật inventory cho từng nguyên liệu trong món ăn
                foreach (var menuItemIngredient in menuItem.Ingredients)
                {
                    // Tính lượng nguyên liệu cần thay đổi
                    var ingredientQuantityChange = menuItemIngredient.RequiredQuantity * quantityDifference;

                    // Cập nhật stock sử dụng IngredientManager
                    // Nếu tăng số lượng món -> trừ thêm nguyên liệu (quantityChange âm)
                    // Nếu giảm số lượng món -> hoàn trả nguyên liệu (quantityChange dương)
                    await _ingredientManager.UpdateIngredientStockAsync(
                        menuItemIngredient.IngredientId,
                        -ingredientQuantityChange);
                }
            }
        }

        // Cập nhật số lượng sử dụng domain method
        orderItem.UpdateQuantity(newQuantity);

        // Cập nhật ghi chú nếu có
        if (!string.IsNullOrWhiteSpace(notes))
        {
            orderItem.UpdateNotes(notes);
        }

        // Tính lại tổng tiền đơn hàng
        order.RecalculateTotal();
    }

    /// <summary>
    /// Validate và thêm các món mới vào order với business rules
    /// </summary>
    /// <param name="order">Order cần thêm món</param>
    /// <param name="menuItemIds">Danh sách ID món cần thêm</param>
    /// <param name="items">Thông tin chi tiết các món cần thêm</param>
    /// <param name="additionalNotes">Ghi chú bổ sung</param>
    public async Task AddItemsToOrderAsync(Order order, List<Guid> menuItemIds, List<CreateOrderItemDto> items, string? additionalNotes = null)
    {
        // Validate order phải ở trạng thái Active
        if (!order.IsServing())
        {
            throw OrderValidationException.CannotAddItemsToInactiveOrder();
        }

        // Validate menu items exist và available
        var menuItems = await _menuItemRepository.GetListAsync(m => menuItemIds.Contains(m.Id));

        if (menuItems.Count != menuItemIds.Count)
        {
            throw new ArgumentException("Một số món không tồn tại trong menu");
        }

        // Validate tất cả món đều available
        var unavailableItems = menuItems.Where(m => !m.IsAvailable).Select(m => m.Name).ToList();
        if (unavailableItems.Count != 0)
        {
            throw OrderValidationException.MenuItemsNotAvailable(unavailableItems);
        }

        // Tạo danh sách OrderItem mới
        var newOrderItems = new List<OrderItem>();
        foreach (var itemDto in items)
        {
            var menuItem = menuItems.First(m => m.Id == itemDto.MenuItemId);

            var orderItem = new OrderItem(
                GuidGenerator.Create(),
                order.Id,
                itemDto.MenuItemId,
                menuItem.Name, // Sử dụng tên từ menu thay vì từ input
                itemDto.Quantity,
                menuItem.Price, // Sử dụng giá hiện tại từ menu
                itemDto.Notes);

            newOrderItems.Add(orderItem);
        }

        // Thêm các món mới vào order (sử dụng domain method)
        order.AddItems(GuidGenerator, newOrderItems);

        // Cập nhật ghi chú nếu có
        if (!string.IsNullOrWhiteSpace(additionalNotes))
        {
            var currentNotes = order.Notes ?? "";
            var newNotes = string.IsNullOrWhiteSpace(currentNotes)
                ? additionalNotes
                : $"{currentNotes}\n[Gọi thêm]: {additionalNotes}";
            order.Notes = newNotes.Trim();
        }

        // Tự động trừ kho nguyên liệu cho các món mới được thêm vào
        try
        {
            await _recipeManager.ProcessAutomaticDeductionForItemsAsync(newOrderItems);
            Logger.LogInformation("Successfully processed inventory deduction for added items to order {OrderId}", order.Id);
        }
        catch (Exception ex)
        {
            // Log warning nhưng không fail toàn bộ add items process
            // Business decision: Có thể thêm món ngay cả khi inventory update thất bại
            Logger.LogWarning(ex, "Failed to process inventory deduction for added items to order {OrderId}, but items were added successfully", order.Id);
        }
    }

    #endregion

    #region Quản lý thanh toán

    /// <summary>
    /// Xử lý thanh toán cho đơn hàng
    /// Domain Service chứa business logic thanh toán phức tạp
    /// </summary>
    /// <param name="orderId">ID đơn hàng cần thanh toán</param>
    /// <param name="paymentMethod">Phương thức thanh toán</param>
    /// <param name="customerMoney">Tiền khách đưa</param>
    /// <param name="notes">Ghi chú thanh toán</param>
    public async Task ProcessPaymentAsync(
        Guid orderId,
        PaymentMethod paymentMethod = PaymentMethod.Cash,
        int? customerMoney = null,
        string? notes = null)
    {
        // 1. Lấy order cần thanh toán với đầy đủ thông tin
        var activeOrder = await _orderRepository.GetOrderForPaymentAsync(orderId) ?? throw OrderValidationException.OrderNotFound(orderId);
        if (!activeOrder.IsServing())
        {
            throw OrderValidationException.CannotCompletePaymentForNonActiveOrder();
        }

        // 2. Validate order có thể thanh toán không
        if (!activeOrder.CanCompletePayment())
        {
            var unservedItems = activeOrder.GetUnservedItems();
            throw OrderValidationException.CannotCompletePaymentWithUnservedItems(unservedItems.Count);
        }

        // 3. Validate tiền khách đưa theo phương thức thanh toán
        int customerPayment;
        switch (paymentMethod)
        {
            case PaymentMethod.Cash:
            case PaymentMethod.BankTransfer:
            case PaymentMethod.Credit:
                {
                    if (!customerMoney.HasValue || customerMoney <= 0)
                        customerPayment = activeOrder.TotalAmount;
                    else
                        customerPayment = customerMoney.Value;

                    // Business rule: Cho phép giảm giá - khách có thể trả ít hơn tổng tiền hóa đơn
                    // Ví dụ: Hóa đơn 155.000đ, bớt 5.000đ, khách trả 150.000đ

                    // Chỉ cảnh báo nếu tiền khách đưa quá ít (nhỏ hơn 50% hóa đơn - có thể là lỗi nhập)
                    var minimumPayment = activeOrder.TotalAmount / 2;
                    if (customerPayment < minimumPayment)
                    {
                        throw OrderValidationException.PaymentAmountTooLow(activeOrder.TotalAmount, customerPayment);
                    }
                }
                break;

            default:
                throw OrderValidationException.UnsupportedPaymentMethod(paymentMethod.ToString());
        }

        // 4. Tạo Payment entity record để lưu chi tiết thanh toán thông qua domain method
        activeOrder.AddPayment(
            GuidGenerator,
            activeOrder.TotalAmount,
            customerPayment,
            paymentMethod,
            notes);

        // 5. Hoàn thành thanh toán trong domain model
        activeOrder.CompletePayment();
    }

    #endregion

    #region Validation và kiểm tra

    /// <summary>
    /// Validate tính khả dụng của bàn cho đơn hàng ăn tại chỗ
    /// </summary>
    /// <param name="tableId">ID bàn cần kiểm tra</param>
    public async Task ValidateTableAvailabilityAsync(Guid? tableId)
    {
        if (tableId == null)
        {
            throw OrderValidationException.DineInWithoutTable();
        }

        var table = await _tableRepository.GetAsync(tableId.Value);
        if (table == null)
        {
            throw OrderValidationException.TableNotFound(tableId.Value);
        }

        // Kiểm tra trạng thái bàn
        if (table.Status != TableStatus.Available && table.Status != TableStatus.Occupied)
        {
            throw OrderValidationException.TableNotAvailable(table.TableNumber);
        }
    }


    #endregion

    #region Tiện ích nội bộ
    /// <summary>
    /// Cộng lại stock cho các nguyên liệu khi xóa OrderItem
    /// </summary>
    /// <param name="menuItemId">ID món ăn bị xóa</param>
    /// <param name="quantity">Số lượng món bị xóa</param>
    private async Task RestoreIngredientStockAsync(Guid menuItemId, int quantity)
    {
        try
        {
            // Lấy danh sách nguyên liệu cho món ăn này
            var ingredients = await _recipeManager.GetIngredientsAsync(menuItemId);

            // Tạo danh sách stock changes để cộng lại
            var stockChanges = ingredients.Select(ingredient =>
                new StockChangeItem(ingredient.IngredientId, ingredient.Quantity * quantity) // Positive value để cộng lại
            ).ToList();

            // Cộng lại stock cho tất cả nguyên liệu liên quan
            await _ingredientManager.ProcessStockChangesAsync(stockChanges);
        }
        catch (Exception ex)
        {
            // Log error nhưng không throw để không block việc xóa OrderItem
            // Business decision: Có thể xóa OrderItem ngay cả khi không cộng lại được stock
            Logger.LogWarning(ex, "Không thể cộng lại stock cho món {MenuItemId} số lượng {Quantity}", menuItemId, quantity);
        }
    }


    #endregion
}