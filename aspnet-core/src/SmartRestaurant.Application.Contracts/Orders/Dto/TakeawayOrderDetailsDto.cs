using System;
using System.Collections.Generic;
using Volo.Abp.Application.Dtos;
using SmartRestaurant.Orders;

namespace SmartRestaurant.Application.Contracts.Orders.Dto;

/// <summary>
/// DTO cho chi tiết takeaway order - tương tự TableDetailDto nhưng cho takeaway
/// </summary>
public class TakeawayOrderDetailsDto : EntityDto<Guid>
{
    /// <summary>
    /// Số đơn hàng hiển thị
    /// </summary>
    public string OrderNumber { get; set; } = string.Empty;

    /// <summary>
    /// Tên khách hàng
    /// </summary>
    public string CustomerName { get; set; } = string.Empty;

    /// <summary>
    /// Số điện thoại khách hàng
    /// </summary>
    public string CustomerPhone { get; set; } = string.Empty;

    /// <summary>
    /// Trạng thái đơn hàng takeaway
    /// </summary>
    public TakeawayStatus Status { get; set; }

    /// <summary>
    /// Tổng số tiền (VND)
    /// </summary>
    public int TotalAmount { get; set; }

    /// <summary>
    /// Ghi chú đơn hàng
    /// </summary>
    public string? Notes { get; set; }

    /// <summary>
    /// Thời gian tạo đơn
    /// </summary>
    public DateTime CreatedTime { get; set; }

    /// <summary>
    /// Thời gian dự kiến nhận hàng
    /// </summary>
    public DateTime? PickupTime { get; set; }

    /// <summary>
    /// Tóm tắt đơn hàng
    /// </summary>
    public TakeawayOrderSummaryDto OrderSummary { get; set; } = new();

    /// <summary>
    /// Danh sách chi tiết các món trong đơn
    /// </summary>
    public List<TakeawayOrderItemDto> OrderItems { get; set; } = new();
}

/// <summary>
/// DTO tóm tắt đơn takeaway
/// </summary>
public class TakeawayOrderSummaryDto
{
    /// <summary>
    /// Tổng số món
    /// </summary>
    public int TotalItemsCount { get; set; }

    /// <summary>
    /// Số món chờ phục vụ
    /// </summary>
    public int PendingServeCount { get; set; }

    /// <summary>
    /// Tổng tiền
    /// </summary>
    public int TotalAmount { get; set; }
}

/// <summary>
/// DTO chi tiết từng món trong takeaway order
/// </summary>
public class TakeawayOrderItemDto : EntityDto<Guid>
{
    /// <summary>
    /// Tên món ăn
    /// </summary>
    public string MenuItemName { get; set; } = string.Empty;

    /// <summary>
    /// Số lượng
    /// </summary>
    public int Quantity { get; set; }

    /// <summary>
    /// Đơn giá (VND)
    /// </summary>
    public int UnitPrice { get; set; }

    /// <summary>
    /// Thành tiền (VND)
    /// </summary>
    public int TotalPrice { get; set; }

    /// <summary>
    /// Trạng thái món ăn
    /// </summary>
    public OrderItemStatus Status { get; set; }

    /// <summary>
    /// Yêu cầu đặc biệt
    /// </summary>
    public string? SpecialRequest { get; set; }

    /// <summary>
    /// Có thể chỉnh sửa không
    /// </summary>
    public bool CanEdit { get; set; }

    /// <summary>
    /// Có thể xóa không
    /// </summary>
    public bool CanDelete { get; set; }

    /// <summary>
    /// Có thiếu nguyên liệu không
    /// </summary>
    public bool HasMissingIngredients { get; set; }

    /// <summary>
    /// Danh sách nguyên liệu thiếu
    /// </summary>
    public List<string> MissingIngredients { get; set; } = new();

    /// <summary>
    /// Cần nấu không
    /// </summary>
    public bool RequiresCooking { get; set; }
}