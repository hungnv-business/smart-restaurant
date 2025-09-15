using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Entities;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Linq;
using SmartRestaurant.Application.Contracts.Orders;
using SmartRestaurant.Application.Contracts.Orders.Dto;
using SmartRestaurant.Application.Contracts.Common;
using SmartRestaurant.Common.Dto;
using SmartRestaurant.Orders;
using SmartRestaurant.TableManagement.Tables;
using SmartRestaurant.MenuManagement.MenuCategories;
using SmartRestaurant.MenuManagement.MenuCategories.Dto;
using SmartRestaurant.MenuManagement.MenuItems;
using SmartRestaurant.MenuManagement.MenuItems.Dto;
using SmartRestaurant.MenuManagement;
using Microsoft.Extensions.Logging;
using Volo.Abp;

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
            input.Notes);

        // Create DTO for notifications
        var orderDto = await MapToOrderDtoAsync(order, includeOrderItems: true);

        // Send real-time notifications  
        await _notificationService.NotifyNewOrderAsync(orderDto);
    }


    /// <summary>
    /// Lấy danh sách tất cả các bàn active trong hệ thống
    /// </summary>
    public async Task<ListResultDto<ActiveTableDto>> GetActiveTablesAsync(
        string? tableNameFilter = null,
        TableStatus? statusFilter = null)
    {
        // Lấy tất cả bàn active với current order và order items
        var activeTables = await _tableRepository.GetAllActiveTablesWithOrdersAsync(tableNameFilter, statusFilter);

        // Tạo DTOs đơn giản cho danh sách bàn
        var activeTableDtos = new List<ActiveTableDto>();
        foreach (var table in activeTables)
        {
            // Count order items from current order
            var hasActiveOrders = table.CurrentOrder != null;
            var pendingServeCount = 0;
            var orderStatusDisplay = "Trống";

            if (hasActiveOrders && table.CurrentOrder?.OrderItems != null)
            {
                pendingServeCount = table.CurrentOrder.GetUnservedItems().Sum(oi => oi.Quantity);

                orderStatusDisplay = pendingServeCount > 0 ? "Món chờ phục vụ" : "Có đơn hàng";
            }

            var dto = new ActiveTableDto
            {
                Id = table.Id,
                TableNumber = table.TableNumber,
                DisplayOrder = table.DisplayOrder,
                Status = table.Status,
                StatusDisplay = GlobalEnums.GetTableStatusDisplayName(table.Status),
                LayoutSectionId = table.LayoutSectionId,
                LayoutSectionName = table.LayoutSection?.SectionName ?? "",
                HasActiveOrders = hasActiveOrders,
                OrderStatusDisplay = orderStatusDisplay,
                PendingItemsCount = pendingServeCount
            };

            activeTableDtos.Add(dto);
        }

        return new ListResultDto<ActiveTableDto>(activeTableDtos);
    }

    /// <summary>
    /// Lấy thông tin chi tiết bàn với đơn hàng để hiển thị trên mobile
    /// </summary>
    public async Task<TableDetailDto> GetTableDetailsAsync(Guid tableId)
    {
        // Lấy thông tin bàn với các đơn hàng đang hoạt động
        var table = await _tableRepository.GetTableWithActiveOrdersAsync(tableId) ?? throw OrderValidationException.TableNotFound(tableId);

        // Lấy danh sách đơn hàng đang hoạt động của bàn
        var activeOrders = await _orderRepository.GetActiveOrdersByTableIdAsync(tableId, includeOrderItems: true);

        // Tạo DTO cho table details
        var dto = new TableDetailDto
        {
            Id = table.Id,
            TableNumber = table.TableNumber,
            Status = table.Status,
            StatusDisplay = GlobalEnums.GetTableStatusDisplayName(table.Status),
            LayoutSectionName = table.LayoutSection?.SectionName ?? ""
        };

        // Nếu có đơn hàng đang hoạt động, tính toán thông tin chi tiết
        if (activeOrders.Count != 0)
        {
            var totalAmount = activeOrders.Sum(o => o.TotalAmount);
            var allOrderItems = activeOrders.SelectMany(o => o.OrderItems ?? new List<OrderItem>()).ToList();
            var pendingServeCount = activeOrders.SelectMany(o => o.GetUnservedItems()).Sum(oi => oi.Quantity);

            // Set OrderId từ order đầu tiên (giả sử chỉ có 1 active order per table)
            dto.OrderId = activeOrders.First().Id;

            // Tạo order summary
            dto.OrderSummary = new TableOrderSummaryDto
            {
                TotalItemsCount = allOrderItems.Sum(e => e.Quantity),
                PendingServeCount = pendingServeCount,
                TotalAmount = totalAmount
            };

            // Map order items to DTOs
            dto.OrderItems = allOrderItems.Select(oi =>
            {
                var totalPrice = oi.UnitPrice * oi.Quantity;
                return new TableOrderItemDto
                {
                    Id = oi.Id,
                    MenuItemName = oi.MenuItemName,
                    Quantity = oi.Quantity,
                    UnitPrice = oi.UnitPrice,
                    TotalPrice = totalPrice,
                    Status = oi.Status,
                    CanEdit = GlobalEnums.CanEditOrderItem(oi.Status),
                    CanDelete = GlobalEnums.CanDeleteOrderItem(oi.Status),
                    SpecialRequest = oi.Notes ?? string.Empty,
                };
            }).ToList();

            // Check ingredient availability cho những món unserved
            var unservedOrderItems = activeOrders.SelectMany(o => o.GetUnservedItems()).ToList();
            var itemsNeedIngredientCheck = dto.OrderItems
                .Where(oi => unservedOrderItems.Any(unserved => unserved.Id == oi.Id))
                .ToList();

            foreach (var orderItemDto in itemsNeedIngredientCheck)
            {
                try
                {
                    // Tìm OrderItem gốc để lấy MenuItemId
                    var originalOrderItem = allOrderItems.FirstOrDefault(oi => oi.Id == orderItemDto.Id);
                    if (originalOrderItem?.MenuItemId != null)
                    {
                        var missingIngredients = await _recipeManager
                            .CheckIngredientAvailabilityAsync(originalOrderItem.MenuItemId, orderItemDto.Quantity);

                        orderItemDto.HasMissingIngredients = missingIngredients.Any();
                        orderItemDto.MissingIngredients = missingIngredients.Select(mi => new MissingIngredientDto
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
                    // Log error nhưng không block việc trả về table details
                    Logger.LogWarning(ex, "Failed to check ingredient availability for order item {OrderItemId}", orderItemDto.Id);
                    // Graceful degradation: keep HasMissingIngredients = false
                }
            }
        }
        else
        {
            // Bàn không có đơn hàng
            dto.OrderSummary = new TableOrderSummaryDto
            {
                TotalItemsCount = 0,
                PendingServeCount = 0,
                TotalAmount = 0
            };
            dto.OrderItems = new List<TableOrderItemDto>();
        }

        return dto;
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

        // Sử dụng OrderManager để xử lý business logic
        var menuItemIds = input.Items.Select(i => i.MenuItemId).ToList();
        await _orderManager.AddItemsToOrderAsync(order, menuItemIds, input.Items, input.AdditionalNotes);
    }

    /// <summary>
    /// Xóa món khỏi order hiện có
    /// </summary>
    public async Task RemoveOrderItemAsync(Guid orderId, Guid orderItemId)
    {
        // Lấy order hiện có với order items
        var order = await _orderRepository.GetWithDetailsAsync(orderId) ?? throw OrderValidationException.OrderNotFound(orderId);

        // Sử dụng domain service để xử lý business logic
        await _orderManager.RemoveOrderItemAsync(order, orderItemId);
    }

    /// <summary>
    /// Cập nhật số lượng món ăn trong đơn hàng
    /// </summary>
    public async Task UpdateOrderItemQuantityAsync(Guid orderId, Guid orderItemId, UpdateOrderItemQuantityDto input)
    {
        // Lấy order hiện có với order items
        var order = await _orderRepository.GetWithDetailsAsync(orderId) ?? throw OrderValidationException.OrderNotFound(orderId);

        // Sử dụng OrderManager để xử lý business logic
        await _orderManager.UpdateOrderItemQuantityAsync(order, orderItemId, input.NewQuantity, input.Notes);
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
            TableInfo = order.Table?.TableNumber,
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
}