using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Entities;
using Volo.Abp.Domain.Repositories;
using SmartRestaurant.Application.Contracts.Orders;
using SmartRestaurant.Application.Contracts.Orders.Dto;
using SmartRestaurant.Application.Contracts.Common;
using SmartRestaurant.Common.Dto;
using SmartRestaurant.Orders;
using SmartRestaurant.TableManagement.Tables;
using SmartRestaurant.MenuManagement.MenuCategories;
using SmartRestaurant.MenuManagement.MenuItems;
using SmartRestaurant.MenuManagement.MenuItems.Dto;
using SmartRestaurant.MenuManagement;
using Microsoft.Extensions.Logging;

namespace SmartRestaurant.Application.Orders;

/// <summary>
/// Order Application Service implementation
/// Sử dụng IApplicationService thay vì ICrudAppService để hỗ trợ business logic phức tạp
/// </summary>
// [Authorize] // Yêu cầu authentication cho tất cả methods
public class OrderAppService : ApplicationService, IOrderAppService
{
    private readonly IOrderRepository _orderRepository;
    private readonly ITableRepository _tableRepository;
    private readonly OrderManager _orderManager;
    private readonly IOrderNotificationService _notificationService;
    private readonly IRepository<MenuCategory, Guid> _menuCategoryRepository;
    private readonly IMenuItemRepository _menuItemRepository;
    private readonly RecipeManager _recipeManager;

    public OrderAppService(
        IOrderRepository orderRepository,
        ITableRepository tableRepository,
        OrderManager orderManager,
        IOrderNotificationService notificationService,
        IRepository<MenuCategory, Guid> menuCategoryRepository,
        IMenuItemRepository menuItemRepository,
        RecipeManager recipeManager)
    {
        _orderRepository = orderRepository;
        _tableRepository = tableRepository;
        _orderManager = orderManager;
        _notificationService = notificationService;
        _menuCategoryRepository = menuCategoryRepository;
        _menuItemRepository = menuItemRepository;
        _recipeManager = recipeManager;
    }


    /// <summary>
    /// Tạo đơn hàng mới với validation business logic
    /// </summary>
    public async Task CreateAsync(CreateOrderDto input)
    {
        // Validate business rules và external dependencies trong domain manager
        await _orderManager.ValidateCreateOrderInputAsync(input);

        // Generate order number
        var orderNumber = await _orderManager.GenerateOrderNumberAsync();

        var orderItems = this.ObjectMapper.Map<List<CreateOrderItemDto>, List<OrderItem>>(input.OrderItems);

        // Create order using domain service
        var order = await _orderManager.CreateAsync(
            orderNumber,
            input.OrderType,
            orderItems,
            input.TableId,
            input.Notes,
            input.CustomerName,
            input.CustomerPhone);

        // Create DTO for notifications
        var orderDto = await MapToOrderDtoAsync(order, includeOrderItems: true);

        Console.WriteLine($"📱 OrderAppService: Created order #{orderDto.OrderNumber}, sending notification...");

        // Send notification
        try
        {
            Console.WriteLine($"🔔 OrderAppService: Sending notification for order #{orderDto.OrderNumber}");
            await _notificationService.NotifyNewOrderAsync(orderDto);
            Console.WriteLine($"✅ OrderAppService: Notification sent for order #{orderDto.OrderNumber}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ OrderAppService: Failed to send notification for order #{orderDto.OrderNumber}: {ex.Message}");
        }
    }




    /// <summary>
    /// Định nghĩa thứ tự ưu tiên sắp xếp order items (số nhỏ hơn = ưu tiên cao hơn)
    /// </summary>
    private static int GetOrderItemSortPriority(OrderItemStatus status)
    {
        return status switch
        {
            OrderItemStatus.Ready => 1,          // Đã hoàn thành (ưu tiên cao nhất)
            OrderItemStatus.Preparing => 2,      // Đang chuẩn bị
            OrderItemStatus.Pending => 3,        // Chờ chuẩn bị
            OrderItemStatus.Served => 4,         // Đã phục vụ
            OrderItemStatus.Canceled => 5,       // Đã hủy (cuối cùng)
            _ => 99                              // Các trạng thái khác
        };
    }

    /// <summary>
    /// Lấy danh sách tất cả danh mục món ăn đang hoạt động
    /// </summary>
    public async Task<ListResultDto<GuidLookupItemDto>> GetActiveMenuCategoriesAsync()
    {
        var categories = await _menuCategoryRepository.GetListAsync(
            c => c.IsEnabled == true,
            includeDetails: false);

        // Sắp xếp theo DisplayOrder và map sang lookup DTO
        var lookupDtos = categories
            .OrderBy(c => c.DisplayOrder)
            .Select(c => new GuidLookupItemDto { Id = c.Id, DisplayName = c.Name })
            .ToList();

        return new ListResultDto<GuidLookupItemDto>(lookupDtos);
    }

    /// <summary>
    /// Lấy danh sách món ăn với filtering cho việc tạo đơn hàng
    /// </summary>
    public async Task<ListResultDto<MenuItemDto>> GetMenuItemsForOrderAsync(GetMenuItemsForOrderDto input)
    {
        // Sử dụng custom repository method với filtering được tối ưu
        var menuItems = await _menuItemRepository.GetMenuItemsAsync(
            categoryId: input.CategoryId,
            onlyAvailable: input.OnlyAvailable ?? true,
            nameFilter: input.NameFilter);

        // Lấy dữ liệu bán hàng và stock availability
        var menuItemIds = menuItems.Select(m => m.Id).ToList();
        var salesData = await _menuItemRepository.GetMenuItemSalesDataAsync(menuItemIds);
        var stockData = await _recipeManager.CalculateMaximumPossibleQuantitiesAsync(menuItemIds);

        // Map sang DTO với CategoryName được tự động map từ navigation property
        var menuItemDtos = ObjectMapper.Map<List<MenuItem>, List<MenuItemDto>>(menuItems);

        // Tính toán số lượng bán và xác định món phổ biến
        var totalSales = salesData.Values.Sum();
        var averageSales = totalSales > 0 ? totalSales / (double)salesData.Count : 0;

        foreach (var dto in menuItemDtos)
        {
            // Sales info
            dto.SoldQuantity = salesData.GetValueOrDefault(dto.Id, 0);
            dto.IsPopular = dto.SoldQuantity >= averageSales && dto.SoldQuantity >= 10;

            // Stock availability info
            var maxQuantity = stockData.GetValueOrDefault(dto.Id, 0);
            dto.MaximumQuantityAvailable = maxQuantity;
            dto.IsOutOfStock = maxQuantity == 0;
            dto.HasLimitedStock = maxQuantity > 0 && maxQuantity < 10; // < 10 phần là hạn chế
        }

        // Lọc theo stock thực tế nếu OnlyAvailable = true
        if (input.OnlyAvailable ?? true)
        {
            menuItemDtos = menuItemDtos.Where(dto => !dto.IsOutOfStock).ToList();
        }

        return new ListResultDto<MenuItemDto>(menuItemDtos);
    }

    /// <summary>
    /// Gọi thêm món vào order hiện có của bàn
    /// </summary>
    public async Task AddItemsToOrderAsync(Guid orderId, AddItemsToOrderDto input)
    {
        // Validate đầu vào
        if (input.Items == null || !input.Items.Any())
        {
            throw new ArgumentException("Danh sách món không được rỗng");
        }

        // Lấy order hiện có với order items
        var order = await _orderRepository.GetWithDetailsAsync(orderId) ?? throw OrderValidationException.OrderNotFound(orderId);

        Console.WriteLine($"📱 OrderAppService: Adding {input.Items.Count} items to order #{order.OrderNumber}");

        // Sử dụng OrderManager để xử lý business logic
        var menuItemIds = input.Items.Select(i => i.MenuItemId).ToList();
        await _orderManager.AddItemsToOrderAsync(order, menuItemIds, input.Items, input.AdditionalNotes);

        Console.WriteLine($"✅ OrderAppService: Added items to order #{order.OrderNumber}, scheduling notification...");

        // Tạo thông báo chi tiết về các món đã thêm
        var menuItems = await _menuItemRepository.GetListAsync();
        var addedItemsDetails = input.Items
            .GroupBy(item => menuItems.FirstOrDefault(m => m.Id == item.MenuItemId)?.Name ?? "Unknown")
            .Select(group => $"{group.Sum(x => x.Quantity)} {group.Key}")
            .ToList();
        var addedItemsDetail = string.Join(", ", addedItemsDetails);

        // Lấy tên hiển thị của bàn
        var tableName = order.GetTableDisplayName();

        // Gửi thông báo realtime về việc thêm món
        try
        {
            await _notificationService.NotifyOrderItemsAddedAsync(new OrderItemsAddedNotificationDto
            {
                TableName = tableName,
                AddedItemsDetail = addedItemsDetail
            });
            Console.WriteLine($"✅ OrderAppService: Add items notification sent for order #{order.OrderNumber}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ OrderAppService: Failed to send add items notification for order #{order.OrderNumber}: {ex.Message}");
        }
    }

    /// <summary>
    /// Xóa món khỏi order hiện có
    /// </summary>
    public async Task RemoveOrderItemAsync(Guid orderId, Guid orderItemId)
    {
        // Lấy order hiện có với order items
        var order = await _orderRepository.GetWithDetailsAsync(orderId) ?? throw OrderValidationException.OrderNotFound(orderId);

        // Lấy thông tin món ăn trước khi xóa để gửi notification
        var orderItem = order.OrderItems.FirstOrDefault(x => x.Id == orderItemId);
        var menuItemName = orderItem?.MenuItemName ?? "Unknown";
        var quantity = orderItem?.Quantity ?? 1;

        Console.WriteLine($"📱 OrderAppService: Removing item {menuItemName} from order #{order.OrderNumber}");

        // Sử dụng domain service để xử lý business logic
        await _orderManager.RemoveOrderItemAsync(order, orderItemId);

        Console.WriteLine($"✅ OrderAppService: Removed item from order #{order.OrderNumber}, sending notification...");

        // Lấy tên hiển thị của bàn
        var tableName = order.GetTableDisplayName();

        // Gửi thông báo realtime về việc xóa món
        await _notificationService.NotifyOrderItemRemovedAsync(new OrderItemRemovedNotificationDto
        {
            TableName = tableName,
            OrderItemId = orderItemId,
            MenuItemName = menuItemName,
            Quantity = quantity
        });
    }

    /// <summary>
    /// Cập nhật số lượng món ăn trong đơn hàng
    /// </summary>
    public async Task UpdateOrderItemQuantityAsync(Guid orderId, Guid orderItemId, UpdateOrderItemQuantityDto input)
    {
        // Lấy order hiện có với order items
        var order = await _orderRepository.GetWithDetailsAsync(orderId) ?? throw OrderValidationException.OrderNotFound(orderId);

        // Lấy thông tin món ăn để gửi notification
        var orderItem = order.OrderItems.FirstOrDefault(x => x.Id == orderItemId);
        var menuItemName = orderItem?.MenuItemName ?? "Unknown";

        Console.WriteLine($"📱 OrderAppService: Updating quantity for order #{order.OrderNumber}, item {menuItemName} to {input.NewQuantity}");

        // Sử dụng OrderManager để xử lý business logic
        await _orderManager.UpdateOrderItemQuantityAsync(order, orderItemId, input.NewQuantity, input.Notes);

        Console.WriteLine($"✅ OrderAppService: Updated quantity for order #{order.OrderNumber}, scheduling notification...");

        // Lấy tên hiển thị của bàn
        var tableName = order.GetTableDisplayName();

        // Gửi thông báo realtime về việc cập nhật số lượng
        try
        {
            await _notificationService.NotifyOrderItemQuantityUpdatedAsync(new OrderItemQuantityUpdateNotificationDto
            {
                TableName = tableName,
                OrderItemId = orderItemId,
                MenuItemName = menuItemName,
                NewQuantity = input.NewQuantity
            });
            Console.WriteLine($"✅ OrderAppService: Quantity update notification sent for order #{order.OrderNumber}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ OrderAppService: Failed to send quantity update notification for order #{order.OrderNumber}: {ex.Message}");
        }
    }

    /// <summary>
    /// Kiểm tra tình trạng nguyên liệu có đủ để làm các món trong order không
    /// </summary>
    public async Task<IngredientAvailabilityResultDto> VerifyIngredientsAvailabilityAsync(VerifyIngredientsRequestDto input)
    {
        var result = new IngredientAvailabilityResultDto
        {
            TotalItemsCount = input.Items.Count
        };

        var allMissingIngredients = new List<MissingIngredientDto>();
        var unavailableMenuItems = new List<string>();

        foreach (var item in input.Items)
        {
            // Kiểm tra nguyên liệu cho từng món với số lượng cụ thể
            var missingIngredientsForItem = await _recipeManager.CheckIngredientAvailabilityAsync(item.MenuItemId, item.Quantity);

            if (missingIngredientsForItem.Any())
            {
                // Convert từ domain model sang DTO (đã tính sẵn quantity trong domain layer)
                var missingDtos = missingIngredientsForItem.Select(mi => new MissingIngredientDto
                {
                    MenuItemId = mi.MenuItemId,
                    MenuItemName = mi.MenuItemName,
                    IngredientId = mi.IngredientId,
                    IngredientName = mi.IngredientName,
                    RequiredQuantity = mi.RequiredQuantity, // Đã nhân với quantity trong RecipeManager
                    CurrentStock = mi.CurrentStock,
                    Unit = mi.Unit,
                    ShortageAmount = mi.ShortageAmount, // Đã tính sẵn
                    DisplayMessage = $"{mi.MenuItemName} (x{item.Quantity}): thiếu {mi.IngredientName} (cần {mi.RequiredQuantity}{mi.Unit}, còn {mi.CurrentStock}{mi.Unit})"
                }).ToList();

                allMissingIngredients.AddRange(missingDtos);

                if (!unavailableMenuItems.Contains(missingIngredientsForItem.First().MenuItemName))
                {
                    unavailableMenuItems.Add(missingIngredientsForItem.First().MenuItemName);
                }
            }
        }

        // Set kết quả
        result.IsAvailable = !allMissingIngredients.Any();
        result.MissingIngredients = allMissingIngredients;
        result.UnavailableItemsCount = unavailableMenuItems.Count;
        result.UnavailableMenuItems = unavailableMenuItems;

        // Tạo summary message
        if (result.IsAvailable)
        {
            result.SummaryMessage = "Tất cả nguyên liệu đều có sẵn để làm các món đã chọn";
        }
        else
        {
            result.SummaryMessage = $"Thiếu nguyên liệu cho {result.UnavailableItemsCount}/{result.TotalItemsCount} món";
        }

        return result;
    }

    /// <summary>
    /// Lấy thông tin đơn hàng để chuẩn bị thanh toán
    /// </summary>
    public async Task<OrderForPaymentDto> GetOrderForPaymentAsync(Guid orderId)
    {
        var order = await _orderRepository.GetOrderForPaymentAsync(orderId);
        if (order == null)
        {
            throw new EntityNotFoundException(typeof(Order), orderId);
        }

        return new OrderForPaymentDto
        {
            Id = order.Id,
            OrderNumber = order.OrderNumber,
            OrderType = order.OrderType,
            Status = order.Status,
            TotalAmount = order.TotalAmount,
            Notes = order.Notes,
            CreationTime = order.CreationTime,
            TableInfo = order.GetTableDisplayName(),
            OrderItems = ObjectMapper.Map<List<OrderItem>, List<OrderItemDto>>(order.OrderItems.ToList())
        };
    }

    /// <summary>
    /// Thanh toán hóa đơn
    /// Delegate tất cả business logic cho OrderManager (Domain Service)
    /// </summary>
    public async Task ProcessPaymentAsync(PaymentRequestDto input)
    {
        // Delegate tất cả business logic cho OrderManager (Domain Service)
        await _orderManager.ProcessPaymentAsync(
            orderId: input.OrderId,
            paymentMethod: input.PaymentMethod,
            customerMoney: input.CustomerMoney,
            notes: input.Notes);
    }


    #region Private Helper Methods


    /// <summary>
    /// Map Order entity to OrderDto
    /// </summary>
    private async Task<OrderDto> MapToOrderDtoAsync(Order order, bool includeOrderItems)
    {
        var dto = ObjectMapper.Map<Order, OrderDto>(order);

        // Add computed properties
        dto.StatusDisplay = GlobalEnums.GetOrderStatusDisplayName(order.Status);

        // Get table name if exists
        if (order.TableId.HasValue)
        {
            var table = await _tableRepository.FirstOrDefaultAsync(x => x.Id == order.TableId.Value);
            dto.TableName = table?.TableNumber;
        }

        // Map order items if requested
        if (includeOrderItems)
        {
            dto.OrderItems = order.OrderItems.Select(MapToOrderItemDto).ToList();
        }

        return dto;
    }

    /// <summary>
    /// Map OrderItem entity to OrderItemDto
    /// </summary>
    private OrderItemDto MapToOrderItemDto(OrderItem orderItem)
    {
        var dto = ObjectMapper.Map<OrderItem, OrderItemDto>(orderItem);
        dto.StatusDisplay = GlobalEnums.GetOrderItemStatusDisplayName(orderItem.Status);
        return dto;
    }
    #endregion


    /// <summary>
    /// Cập nhật trạng thái món sang "Đã phục vụ" từ mobile app
    /// Chỉ cho phép khi món ở trạng thái "Ready" (đã hoàn thành)
    /// </summary>
    /// <param name="orderItemId">ID của món cần đánh dấu đã phục vụ</param>
    public async Task MarkOrderItemServedAsync(Guid orderItemId)
    {
        Logger.LogInformation("📱 OrderAppService: Marking order item {OrderItemId} as served", orderItemId);

        // Tìm order item và order tương ứng
        var order = await _orderRepository.GetByOrderItemIdAsync(orderItemId);
        if (order == null)
        {
            throw new EntityNotFoundException(typeof(Order), orderItemId);
        }

        var orderItem = order.OrderItems.FirstOrDefault(oi => oi.Id == orderItemId);
        if (orderItem == null)
        {
            throw new EntityNotFoundException(typeof(OrderItem), orderItemId);
        }

        // Cập nhật trạng thái
        orderItem.MarkAsServed();

        // Lưu thay đổi
        await _orderRepository.UpdateAsync(order);

        // Lấy tên hiển thị của bàn
        var tableName = order.GetTableDisplayName();

        // Thông báo món ăn đã phục vụ cho bếp qua SignalR
        await _notificationService.NotifyOrderServedAsync(new OrderItemServedNotificationDto
        {
            OrderId = order.Id,
            OrderNumber = order.OrderNumber,
            MenuItemName = orderItem.MenuItemName,
            Quantity = orderItem.Quantity,
            TableName = tableName,
            TableId = order.TableId
        });

        Logger.LogInformation("✅ OrderAppService: Successfully marked order item {OrderItemId} as served", orderItemId);

        // Log thông tin phục vụ thành công
        Console.WriteLine($"🍽️ OrderAppService: Món {orderItem.MenuItemName} đã được đánh dấu phục vụ cho {tableName}");
    }


    /// <summary>
    /// Cập nhật trạng thái đơn hàng takeaway
    /// </summary>
    public async Task UpdateTakeawayOrderStatusAsync(Guid orderId, TakeawayStatus status)
    {
        try
        {
            Logger.LogInformation("🔄 OrderAppService: Updating takeaway order {OrderId} to status {Status}", orderId, status);

            var order = await _orderRepository.GetAsync(orderId);

            if (order.OrderType != OrderType.Takeaway)
            {
                throw new InvalidOperationException($"Order {orderId} is not a takeaway order");
            }

            // Map TakeawayStatus sang OrderStatus tương ứng
            var newOrderStatus = MapTakeawayStatusToOrderStatus(status);

            // Cập nhật trạng thái order (logic cụ thể tùy vào business rules)
            // Hiện tại đơn giản chỉ update status
            var orderType = typeof(Order);
            var statusProperty = orderType.GetProperty("Status");
            statusProperty?.SetValue(order, newOrderStatus);

            await _orderRepository.UpdateAsync(order);

            Logger.LogInformation("✅ OrderAppService: Successfully updated takeaway order {OrderId} status to {Status}", orderId, status);
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, "❌ OrderAppService: Error updating takeaway order status");
            throw;
        }
    }

    #region Private Helper Methods

    /// <summary>
    /// Map Order entity sang TakeawayOrderDto
    /// </summary>
    private TakeawayOrderDto MapToTakeawayOrderDto(Order order)
    {
        return new TakeawayOrderDto
        {
            Id = order.Id,
            OrderNumber = order.OrderNumber,
            CustomerName = order.CustomerName ?? "",
            CustomerPhone = order.CustomerPhone ?? "",
            Status = MapOrderStatusToTakeawayStatus(order.Status),
            StatusDisplay = MapOrderStatusToTakeawayStatus(order.Status).GetDisplayName(),
            TotalAmount = order.TotalAmount,
            Notes = order.Notes,
            CreatedTime = order.CreatedTime,
            PaymentTime = order.Payment?.PaymentTime,
            ItemNames = order.OrderItems.Select(oi => oi.MenuItemName).ToList(),
            ItemCount = order.OrderItems.Count
        };
    }


    /// <summary>
    /// Map TakeawayStatus sang OrderStatus
    /// </summary>
    private OrderStatus MapTakeawayStatusToOrderStatus(TakeawayStatus takeawayStatus)
    {
        return takeawayStatus switch
        {
            TakeawayStatus.Preparing => OrderStatus.Serving,
            TakeawayStatus.Ready => OrderStatus.Serving, // Still serving but ready
            TakeawayStatus.Delivered => OrderStatus.Paid,
            _ => OrderStatus.Serving
        };
    }


    #endregion

    #region Separate List APIs - New Implementation

    /// <summary>
    /// Lấy danh sách bàn cho màn hình DineIn mobile (tối ưu hóa cho table grid)
    /// Logic base từ GetActiveTablesAsync nhưng response format tối ưu cho mobile
    /// </summary>
    public async Task<ListResultDto<DineInTableDto>> GetDineInTablesAsync(GetDineInTablesDto input)
    {
        try
        {
            Logger.LogInformation("🏪 OrderAppService: Getting DineIn tables with filters - Status: {Status}, TableName: {TableName}",
                input.StatusFilter, input.TableNameFilter);

            // Lấy tất cả bàn active với current order và order items
            var activeTables = await _tableRepository.GetAllActiveTablesWithOrdersAsync(
                input.TableNameFilter,
                input.StatusFilter);

            // Tạo DTOs tối ưu cho mobile DineIn screen
            var dineInTableDtos = new List<DineInTableDto>();
            foreach (var table in activeTables)
            {

                // Count order items from current order
                var hasActiveOrders = table.CurrentOrder != null;
                var pendingServeCount = 0;
                var readyItemsCount = 0;
                DateTime? orderCreatedTime = null;
                Guid? currentOrderId = null;

                if (hasActiveOrders && table.CurrentOrder?.OrderItems != null)
                {
                    var unservedItems = table.CurrentOrder.GetUnservedItemsForMoblie();
                    pendingServeCount = unservedItems.Sum(oi => oi.Quantity);

                    readyItemsCount = table.CurrentOrder.OrderItems
                        .Where(oi => oi.IsReady())
                        .Sum(oi => oi.Quantity);

                    orderCreatedTime = table.CurrentOrder.CreatedTime;
                    currentOrderId = table.CurrentOrder.Id;
                }

                var dto = new DineInTableDto
                {
                    Id = table.Id,
                    TableNumber = table.TableNumber,
                    DisplayOrder = table.DisplayOrder,
                    Status = table.Status,
                    StatusDisplay = GlobalEnums.GetTableStatusDisplayName(table.Status),
                    LayoutSectionId = table.LayoutSectionId ?? Guid.Empty,
                    LayoutSectionName = table.LayoutSection?.SectionName ?? "",
                    HasActiveOrders = hasActiveOrders,
                    CurrentOrderId = currentOrderId,
                    PendingItemsDisplay = $"{pendingServeCount} món đang chờ",
                    ReadyItemsCountDisplay = $"{readyItemsCount} món sẵn sàng",
                    OrderCreatedTime = orderCreatedTime
                };

                dineInTableDtos.Add(dto);
            }

            // Sắp xếp theo DisplayOrder (mặc định)
            dineInTableDtos = dineInTableDtos.OrderBy(t => t.DisplayOrder).ToList();

            Logger.LogInformation("✅ OrderAppService: Found {Count} DineIn tables", dineInTableDtos.Count);

            return new ListResultDto<DineInTableDto>(dineInTableDtos);
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, "❌ OrderAppService: Error getting DineIn tables");
            throw;
        }
    }

    /// <summary>
    /// Enhanced GetTakeawayOrdersAsync với filtering và sorting tốt hơn
    /// </summary>
    public async Task<ListResultDto<TakeawayOrderDto>> GetTakeawayOrdersAsync(GetTakeawayOrdersDto input)
    {
        try
        {
            Logger.LogInformation("🥡 OrderAppService: Getting takeaway orders with status filter: {Status}",
                input.StatusFilter);

            // Convert TakeawayStatus to OrderStatus for repository query
            OrderStatus? orderStatusFilter = null;
            if (input.StatusFilter.HasValue)
            {
                orderStatusFilter = MapTakeawayStatusToOrderStatus(input.StatusFilter.Value);
            }

            // Sử dụng unified repository method với đơn giản filtering
            var orders = await _orderRepository.GetOrdersAsync(
                orderTypeFilter: OrderType.Takeaway,
                statusFilter: orderStatusFilter,
                date: DateTime.Today,
                searchText: null
            );

            // Map sang TakeawayOrderDto và sắp xếp theo thời gian tạo
            var takeawayOrders = orders
                .Select(MapToTakeawayOrderDto)
                .OrderByDescending(o => o.CreatedTime)
                .ToList();

            Logger.LogInformation("✅ OrderAppService: Found {Count} takeaway orders", takeawayOrders.Count);

            return new ListResultDto<TakeawayOrderDto>(takeawayOrders);
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, "❌ OrderAppService: Error getting takeaway orders");
            throw;
        }
    }

    #region Private Helper Methods for New APIs



    #endregion

    #region Unified Order Details API

    /// <summary>
    /// API thống nhất lấy chi tiết đơn hàng cho cả DineIn và Takeaway
    /// Gộp logic từ GetTableDetailsAsync và GetTakeawayOrderDetailsAsync
    /// </summary>
    public async Task<OrderDetailsDto> GetOrderDetailsAsync(Guid orderId)
    {
        try
        {
            Logger.LogInformation("📋 OrderAppService: Getting unified order details for order {OrderId}", orderId);

            // Lấy order với đầy đủ thông tin
            var order = await _orderRepository.GetWithDetailsAsync(orderId);
            if (order == null)
            {
                throw new EntityNotFoundException(typeof(Order), orderId);
            }

            Logger.LogInformation("✅ OrderAppService: Found order {OrderNumber} of type {OrderType} with {ItemCount} items",
                order.OrderNumber, order.OrderType, order.OrderItems.Count);

            // Tạo DTO thống nhất
            var result = new OrderDetailsDto
            {
                Id = order.Id,
                OrderNumber = order.OrderNumber,
                OrderType = order.OrderType,
                Status = order.Status,
                StatusDisplay = GlobalEnums.GetOrderStatusDisplayName(order.Status),
                TotalAmount = order.TotalAmount,
                Notes = order.Notes,
                CreatedTime = order.CreationTime
            };

            // Set fields dựa trên OrderType
            if (order.OrderType == OrderType.Takeaway)
            {
                // Takeaway-specific fields
                result.CustomerName = order.CustomerName ?? "";
                result.CustomerPhone = order.CustomerPhone ?? "";
                result.PaymentTime = order.Payment?.PaymentTime;
            }
            else if (order.OrderType == OrderType.DineIn && order.Table != null)
            {
                // DineIn-specific fields
                result.TableNumber = order.Table.TableNumber;
                result.LayoutSectionName = order.Table.LayoutSection?.SectionName ?? "";
            }

            // Tính toán order summary
            var pendingServeCount = order.OrderItems.Count(i =>
                i.Status == OrderItemStatus.Pending || i.Status == OrderItemStatus.Preparing);

            result.OrderSummary = new OrderSummaryDto
            {
                TotalItemsCount = order.OrderItems.Count,
                PendingServeCount = pendingServeCount,
                TotalAmount = order.TotalAmount
            };

            // Lấy thông tin MenuItem cho ingredient availability check
            var menuItemIds = order.OrderItems.Select(oi => oi.MenuItemId).Distinct().ToList();
            var menuItems = await _menuItemRepository.GetListAsync(mi => menuItemIds.Contains(mi.Id));
            var menuItemDict = menuItems.ToDictionary(mi => mi.Id, mi => mi);

            // Map order items với ingredient availability check
            var orderItemDetails = new List<OrderItemDetailDto>();
            var unservedOrderItems = order.GetUnservedItems();

            foreach (var orderItem in order.OrderItems)
            {
                var menuItem = menuItemDict.GetValueOrDefault(orderItem.MenuItemId);
                var totalPrice = orderItem.UnitPrice * orderItem.Quantity;

                var itemDetail = new OrderItemDetailDto
                {
                    Id = orderItem.Id,
                    MenuItemName = orderItem.MenuItemName,
                    Quantity = orderItem.Quantity,
                    UnitPrice = orderItem.UnitPrice,
                    TotalPrice = totalPrice,
                    Status = orderItem.Status,
                    SpecialRequest = orderItem.Notes ?? string.Empty,
                    CanEdit = GlobalEnums.CanEditOrderItem(orderItem.Status),
                    CanDelete = GlobalEnums.CanDeleteOrderItem(orderItem.Status),
                    RequiresCooking = menuItem?.RequiresCooking ?? false,
                    HasMissingIngredients = false,
                    MissingIngredients = new List<MissingIngredientDto>()
                };

                // Check ingredient availability cho món chưa phục vụ
                if (unservedOrderItems.Any(unserved => unserved.Id == orderItem.Id))
                {
                    try
                    {
                        var missingIngredients = await _recipeManager
                            .CheckIngredientAvailabilityAsync(orderItem.MenuItemId, orderItem.Quantity);

                        if (missingIngredients.Any())
                        {
                            itemDetail.HasMissingIngredients = true;
                            itemDetail.MissingIngredients = missingIngredients.Select(mi => new MissingIngredientDto
                            {
                                MenuItemId = mi.MenuItemId,
                                MenuItemName = mi.MenuItemName,
                                IngredientId = mi.IngredientId,
                                IngredientName = mi.IngredientName,
                                RequiredQuantity = mi.RequiredQuantity,
                                CurrentStock = mi.CurrentStock,
                                Unit = mi.Unit,
                                ShortageAmount = mi.ShortageAmount,
                                DisplayMessage = mi.DisplayMessage ?? $"Thiếu {mi.IngredientName} ({mi.ShortageAmount}{mi.Unit})"
                            }).ToList();
                        }
                    }
                    catch (Exception ex)
                    {
                        Logger.LogWarning(ex, "Failed to check ingredient availability for order item {OrderItemId}", orderItem.Id);
                        // Graceful degradation: keep HasMissingIngredients = false
                    }
                }

                orderItemDetails.Add(itemDetail);
            }

            // Sắp xếp order items theo trạng thái ưu tiên
            result.OrderItems = orderItemDetails
                .OrderBy(oi => GetOrderItemSortPriority(oi.Status))
                .ThenBy(oi => oi.MenuItemName)
                .ToList();

            Logger.LogInformation("✅ OrderAppService: Successfully processed unified order details for order {OrderId}", orderId);

            return result;
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, "❌ OrderAppService: Error getting unified order details for order {OrderId}", orderId);
            throw;
        }
    }

    #endregion

    #region Private Helper Methods

    /// <summary>
    /// Map OrderStatus sang TakeawayStatus
    /// </summary>
    private TakeawayStatus MapOrderStatusToTakeawayStatus(OrderStatus orderStatus)
    {
        return orderStatus switch
        {
            OrderStatus.Serving => TakeawayStatus.Preparing,
            OrderStatus.Paid => TakeawayStatus.Delivered,
            _ => TakeawayStatus.Preparing
        };
    }

    #endregion

    #endregion
}