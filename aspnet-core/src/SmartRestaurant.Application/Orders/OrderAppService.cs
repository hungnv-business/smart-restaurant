using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Linq;
using SmartRestaurant.Application.Contracts.Orders;
using SmartRestaurant.Application.Contracts.Orders.Dto;
using SmartRestaurant.Orders;
using SmartRestaurant.MenuManagement.MenuItems;
using SmartRestaurant.TableManagement.Tables;

namespace SmartRestaurant.Application.Orders;

/// <summary>
/// Order Application Service implementation
/// Sử dụng IApplicationService thay vì ICrudAppService để hỗ trợ business logic phức tạp
/// </summary>
[Authorize] // Yêu cầu authentication cho tất cả methods
public class OrderAppService : ApplicationService, IOrderAppService
{
    private readonly IRepository<Order, Guid> _orderRepository;
    private readonly IRepository<MenuItem, Guid> _menuItemRepository;
    private readonly IRepository<Table, Guid> _tableRepository;
    private readonly OrderManager _orderManager;
    private readonly IOrderNotificationService _notificationService;

    public OrderAppService(
        IRepository<Order, Guid> orderRepository,
        IRepository<MenuItem, Guid> menuItemRepository,
        IRepository<Table, Guid> tableRepository,
        OrderManager orderManager,
        IOrderNotificationService notificationService)
    {
        _orderRepository = orderRepository;
        _menuItemRepository = menuItemRepository;
        _tableRepository = tableRepository;
        _orderManager = orderManager;
        _notificationService = notificationService;
    }

    /// <summary>
    /// Lấy danh sách đơn hàng với filtering và paging
    /// </summary>
    public async Task<PagedResultDto<OrderDto>> GetListAsync(GetOrderListDto input)
    {
        var queryable = await _orderRepository.GetQueryableAsync();

        // Apply filters
        if (input.TableId.HasValue)
        {
            queryable = queryable.Where(x => x.TableId == input.TableId);
        }

        if (input.Status.HasValue)
        {
            queryable = queryable.Where(x => x.Status == input.Status);
        }

        if (input.OrderType.HasValue)
        {
            queryable = queryable.Where(x => x.OrderType == input.OrderType);
        }

        if (input.CreatedDateFrom.HasValue)
        {
            queryable = queryable.Where(x => x.CreationTime >= input.CreatedDateFrom);
        }

        if (input.CreatedDateTo.HasValue)
        {
            queryable = queryable.Where(x => x.CreationTime <= input.CreatedDateTo);
        }

        if (input.ActiveOnly == true)
        {
            queryable = queryable.Where(x => x.Status != OrderStatus.Paid);
        }

        if (input.KitchenOnly == true)
        {
            queryable = queryable.Where(x => x.Status == OrderStatus.Confirmed || 
                                            x.Status == OrderStatus.Preparing);
        }

        if (!string.IsNullOrWhiteSpace(input.Filter))
        {
            var filter = input.Filter.Trim().ToLower();
            queryable = queryable.Where(x => 
                x.OrderNumber.ToLower().Contains(filter) ||
                (x.Notes != null && x.Notes.ToLower().Contains(filter)));
        }

        // Get total count
        var totalCount = await AsyncExecuter.CountAsync(queryable);

        // Apply sorting and paging
        queryable = ApplySorting(queryable, input);
        queryable = queryable.PageBy(input);

        // Execute query with includes
        var orders = await AsyncExecuter.ToListAsync(queryable);

        // Convert to DTOs
        var orderDtos = new List<OrderDto>();
        foreach (var order in orders)
        {
            var dto = await MapToOrderDtoAsync(order, input.IncludeOrderItems);
            orderDtos.Add(dto);
        }

        return new PagedResultDto<OrderDto>(totalCount, orderDtos);
    }

    // Helper method để apply sorting
    private IQueryable<Order> ApplySorting(IQueryable<Order> queryable, GetOrderListDto input)
    {
        if (!input.Sorting.IsNullOrWhiteSpace())
        {
            // Parse sorting string and apply to query
            // Format: "propertyName asc" hoặc "propertyName desc"
            var parts = input.Sorting.Split(' ');
            var property = parts[0];
            var direction = parts.Length > 1 ? parts[1].ToLower() : "asc";

            switch (property.ToLower())
            {
                case "ordernumber":
                    queryable = direction == "desc" 
                        ? queryable.OrderByDescending(x => x.OrderNumber)
                        : queryable.OrderBy(x => x.OrderNumber);
                    break;
                case "creationtime":
                    queryable = direction == "desc"
                        ? queryable.OrderByDescending(x => x.CreationTime)
                        : queryable.OrderBy(x => x.CreationTime);
                    break;
                case "status":
                    queryable = direction == "desc"
                        ? queryable.OrderByDescending(x => x.Status)
                        : queryable.OrderBy(x => x.Status);
                    break;
                case "ordertype":
                    queryable = direction == "desc"
                        ? queryable.OrderByDescending(x => x.OrderType)
                        : queryable.OrderBy(x => x.OrderType);
                    break;
                default:
                    // Mặc định sắp xếp theo thời gian tạo mới nhất
                    queryable = queryable.OrderByDescending(x => x.CreationTime);
                    break;
            }
        }
        else
        {
            // Mặc định sắp xếp theo thời gian tạo mới nhất
            queryable = queryable.OrderByDescending(x => x.CreationTime);
        }

        return queryable;
    }

    /// <summary>
    /// Lấy chi tiết đơn hàng theo ID
    /// </summary>
    public async Task<OrderDto> GetAsync(Guid id)
    {
        var order = await _orderRepository.GetAsync(id);
        return await MapToOrderDtoAsync(order, includeOrderItems: true);
    }

    /// <summary>
    /// Tạo đơn hàng mới với validation business logic
    /// </summary>
    public async Task<OrderDto> CreateAsync(CreateOrderDto input)
    {
        // Validate business rules first
        await ValidateCreateOrderInputAsync(input);

        // Generate order number
        var orderNumber = await _orderManager.GenerateOrderNumberAsync();

        // Create order using domain service
        var order = await _orderManager.CreateAsync(
            orderNumber,
            input.OrderType,
            input.TableId,
            input.Notes);

        // Add order items
        foreach (var itemDto in input.OrderItems)
        {
            var orderItem = _orderManager.CreateOrderItem(
                order.Id,
                itemDto.MenuItemId,
                itemDto.MenuItemName,
                itemDto.Quantity,
                itemDto.UnitPrice,
                itemDto.Notes);

            order.AddItem(orderItem);
        }

        // Save to database
        await _orderRepository.InsertAsync(order, autoSave: true);

        // Create DTO for notifications
        var orderDto = await MapToOrderDtoAsync(order, includeOrderItems: true);

        // Send real-time notifications  
        await _notificationService.NotifyNewOrderAsync(orderDto);

        return orderDto;
    }

    /// <summary>
    /// Cập nhật trạng thái đơn hàng theo workflow
    /// </summary>
    public async Task<OrderDto> UpdateStatusAsync(Guid id, UpdateOrderStatusDto input)
    {
        var order = await _orderRepository.GetAsync(id);
        
        // Business logic: Update status using domain method
        order.UpdateStatus(input.NewStatus);

        // Save changes
        await _orderRepository.UpdateAsync(order, autoSave: true);

        return await MapToOrderDtoAsync(order, includeOrderItems: true);
    }

    /// <summary>
    /// Xác nhận đơn hàng (Pending -> Confirmed)
    /// </summary>
    public async Task<OrderDto> ConfirmOrderAsync(Guid id)
    {
        var order = await _orderRepository.GetAsync(id);

        // Use domain service to confirm order with all business logic
        _orderManager.ConfirmOrder(order);

        // Process inventory deduction
        await _orderManager.ProcessInventoryDeductionAsync(order);

        // Notify kitchen
        await _orderManager.NotifyKitchenAsync(order);

        // Auto print kitchen bill
        await _orderManager.PrintKitchenBillAsync(order);

        // Save changes
        await _orderRepository.UpdateAsync(order, autoSave: true);

        // Create DTO for notifications
        var orderDto = await MapToOrderDtoAsync(order, includeOrderItems: true);

        // Send real-time notifications
        await _notificationService.NotifyOrderStatusChangedAsync(order.Id, order.OrderNumber, order.Status, order.TableId);
        await _notificationService.NotifyKitchenNewOrderAsync(orderDto);

        return orderDto;
    }

    /// <summary>
    /// Hoàn thành phục vụ đơn hàng (Ready -> Served)
    /// </summary>
    public async Task<OrderDto> CompleteOrderAsync(Guid id)
    {
        var order = await _orderRepository.GetAsync(id);

        // Use domain service for completion logic
        _orderManager.CompleteOrderService(order);

        // Save changes
        await _orderRepository.UpdateAsync(order, autoSave: true);

        return await MapToOrderDtoAsync(order, includeOrderItems: true);
    }

    /// <summary>
    /// In bill bếp cho đơn hàng
    /// </summary>
    public async Task PrintKitchenBillAsync(Guid id, PrintKitchenBillDto input)
    {
        var order = await _orderRepository.GetAsync(id);

        await _orderManager.PrintKitchenBillAsync(order, input.SelectedOrderItemIds);
    }

    /// <summary>
    /// Lấy danh sách đơn hàng theo ID bàn
    /// </summary>
    public async Task<ListResultDto<OrderDto>> GetOrdersByTableAsync(Guid tableId)
    {
        var orders = await _orderRepository.GetListAsync(x => x.TableId == tableId);
        
        var orderDtos = new List<OrderDto>();
        foreach (var order in orders)
        {
            var dto = await MapToOrderDtoAsync(order, includeOrderItems: true);
            orderDtos.Add(dto);
        }

        return new ListResultDto<OrderDto>(orderDtos);
    }

    /// <summary>
    /// Lấy danh sách đơn hàng cho bếp
    /// </summary>
    public async Task<ListResultDto<OrderDto>> GetKitchenOrdersAsync(bool includeOrderItems = true)
    {
        var orders = await _orderRepository.GetListAsync(x => 
            x.Status == OrderStatus.Confirmed || 
            x.Status == OrderStatus.Preparing);

        var orderDtos = new List<OrderDto>();
        foreach (var order in orders)
        {
            var dto = await MapToOrderDtoAsync(order, includeOrderItems);
            orderDtos.Add(dto);
        }

        // Sort by creation time (FIFO)
        return new ListResultDto<OrderDto>(orderDtos.OrderBy(x => x.CreationTime).ToList());
    }

    /// <summary>
    /// Lấy danh sách đơn hàng đang hoạt động
    /// </summary>
    public async Task<ListResultDto<OrderDto>> GetActiveOrdersAsync()
    {
        var orders = await _orderRepository.GetListAsync(x => x.Status != OrderStatus.Paid);
        
        var orderDtos = new List<OrderDto>();
        foreach (var order in orders)
        {
            var dto = await MapToOrderDtoAsync(order, includeOrderItems: false);
            orderDtos.Add(dto);
        }

        return new ListResultDto<OrderDto>(orderDtos.OrderBy(x => x.CreationTime).ToList());
    }

    /// <summary>
    /// Lấy đơn hàng theo số đơn hàng
    /// </summary>
    public async Task<OrderDto?> GetByOrderNumberAsync(string orderNumber)
    {
        var order = await _orderRepository.FirstOrDefaultAsync(x => x.OrderNumber == orderNumber);
        if (order == null) return null;

        return await MapToOrderDtoAsync(order, includeOrderItems: true);
    }

    /// <summary>
    /// Xóa đơn hàng (chỉ khi ở trạng thái Pending)
    /// </summary>
    public async Task DeleteAsync(Guid id)
    {
        var order = await _orderRepository.GetAsync(id);
        
        // Business validation
        if (order.Status != OrderStatus.Pending)
        {
            throw OrderValidationException.NotInPendingStatus();
        }

        await _orderRepository.DeleteAsync(order);
    }

    #region Private Helper Methods

    /// <summary>
    /// Validate create order input với business rules
    /// </summary>
    private async Task ValidateCreateOrderInputAsync(CreateOrderDto input)
    {
        // Validate table exists if DineIn
        if (input.OrderType == OrderType.DineIn && input.TableId.HasValue)
        {
            await _orderManager.ValidateTableAvailabilityAsync(input.TableId.Value);
        }

        // Validate menu items exist and get current prices
        foreach (var itemDto in input.OrderItems)
        {
            var menuItem = await _menuItemRepository.GetAsync(itemDto.MenuItemId);
            if (!menuItem.IsAvailable)
            {
                throw new InvalidOperationException($"Món '{menuItem.Name}' hiện không có sẵn");
            }

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
    /// Map Order entity to OrderDto
    /// </summary>
    private async Task<OrderDto> MapToOrderDtoAsync(Order order, bool includeOrderItems)
    {
        var dto = ObjectMapper.Map<Order, OrderDto>(order);

        // Add computed properties
        dto.StatusDisplay = GetStatusDisplayName(order.Status);
        
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
        dto.StatusDisplay = GetOrderItemStatusDisplayName(orderItem.Status);
        return dto;
    }

    /// <summary>
    /// Get display name for OrderStatus
    /// </summary>
    private string GetStatusDisplayName(OrderStatus status)
    {
        return status switch
        {
            OrderStatus.Pending => "Chờ xác nhận",
            OrderStatus.Confirmed => "Đã xác nhận",
            OrderStatus.Preparing => "Đang chuẩn bị",
            OrderStatus.Ready => "Sẵn sàng",
            OrderStatus.Served => "Đã phục vụ",
            OrderStatus.Paid => "Đã thanh toán",
            _ => status.ToString()
        };
    }

    /// <summary>
    /// Get display name for OrderItemStatus
    /// </summary>
    private string GetOrderItemStatusDisplayName(OrderItemStatus status)
    {
        return status switch
        {
            OrderItemStatus.Pending => "Chờ chuẩn bị",
            OrderItemStatus.Preparing => "Đang chuẩn bị",
            OrderItemStatus.Ready => "Đã hoàn thành",
            OrderItemStatus.Served => "Đã phục vụ",
            _ => status.ToString()
        };
    }

    #endregion
}