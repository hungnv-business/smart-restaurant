using System;
using System.Collections.Generic;
using Volo.Abp.Application.Dtos;
using SmartRestaurant.Orders;

namespace SmartRestaurant.Application.Contracts.Orders.Dto;

/// <summary>
/// DTO thống nhất cho chi tiết đơn hàng (cả DineIn và Takeaway)
/// Thay thế TableDetailDto và TakeawayOrderDetailsDto riêng biệt
/// </summary>
public class OrderDetailsDto : EntityDto<Guid>
{
    /// <summary>
    /// Số đơn hàng hiển thị
    /// </summary>
    public string OrderNumber { get; set; } = string.Empty;

    /// <summary>
    /// Loại đơn hàng (DineIn/Takeaway)
    /// </summary>
    public OrderType OrderType { get; set; }

    /// <summary>
    /// Trạng thái đơn hàng
    /// </summary>
    public OrderStatus Status { get; set; }

    /// <summary>
    /// Tên trạng thái hiển thị
    /// </summary>
    public string StatusDisplay { get; set; } = string.Empty;

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

    // =============================================================
    // Takeaway-specific fields (null for DineIn orders)
    // =============================================================

    /// <summary>
    /// Tên khách hàng (chỉ cho Takeaway)
    /// </summary>
    public string? CustomerName { get; set; }

    /// <summary>
    /// Số điện thoại khách hàng (chỉ cho Takeaway)
    /// </summary>
    public string? CustomerPhone { get; set; }

    /// <summary>
    /// Thời gian thanh toán (chỉ cho Takeaway)
    /// </summary>
    public DateTime? PaymentTime { get; set; }

    // =============================================================
    // DineIn-specific fields (null for Takeaway orders)
    // =============================================================

    /// <summary>
    /// Số bàn (chỉ cho DineIn)
    /// </summary>
    public string? TableNumber { get; set; }

    /// <summary>
    /// Tên khu vực bàn (chỉ cho DineIn)
    /// </summary>
    public string? LayoutSectionName { get; set; }

    // =============================================================
    // Common order details
    // =============================================================

    /// <summary>
    /// Tóm tắt đơn hàng
    /// </summary>
    public OrderSummaryDto OrderSummary { get; set; } = new();

    /// <summary>
    /// Danh sách chi tiết các món trong đơn
    /// </summary>
    public List<OrderItemDetailDto> OrderItems { get; set; } = new();
}

/// <summary>
/// DTO thống nhất cho chi tiết từng món trong đơn hàng
/// Gộp chung logic từ TableOrderItemDto và TakeawayOrderItemDto
/// </summary>
public class OrderItemDetailDto : EntityDto<Guid>
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
    public string SpecialRequest { get; set; } = string.Empty;

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
    public List<MissingIngredientDto> MissingIngredients { get; set; } = new();

    /// <summary>
    /// Cần nấu không
    /// </summary>
    public bool RequiresCooking { get; set; }
}

/// <summary>
/// DTO tóm tắt đơn hàng (dùng chung cho cả DineIn và Takeaway)
/// </summary>
public class OrderSummaryDto
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