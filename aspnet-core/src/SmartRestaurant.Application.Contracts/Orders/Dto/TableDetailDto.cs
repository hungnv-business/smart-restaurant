using System;
using System.Collections.Generic;
using Volo.Abp.Application.Dtos;
using SmartRestaurant.Orders;

namespace SmartRestaurant.Application.Contracts.Orders.Dto;

/// <summary>
/// DTO cho chi tiết bàn với đầy đủ thông tin đơn hàng (dùng khi click vào bàn)
/// </summary>
public class TableDetailDto : EntityDto<Guid>
{
    /// <summary>Số bàn hiển thị (ví dụ: "B06")</summary>
    public string TableNumber { get; set; }
    
    /// <summary>Tên khu vực (ví dụ: "Dãy 1")</summary>
    public string LayoutSectionName { get; set; }
    
    /// <summary>Trạng thái bàn hiện tại</summary>
    public SmartRestaurant.TableStatus Status { get; set; }
    
    /// <summary>Trạng thái bàn dưới dạng chữ</summary>
    public string StatusDisplay { get; set; }
    
    /// <summary>ID của order đang active (nếu có)</summary>
    public Guid? OrderId { get; set; }
    
    /// <summary>Thông tin tổng quan đơn hàng</summary>
    public TableOrderSummaryDto OrderSummary { get; set; }
    
    /// <summary>Danh sách món trong đơn hàng hiện tại</summary>
    public List<TableOrderItemDto> OrderItems { get; set; } = new();
}

/// <summary>
/// DTO tổng quan đơn hàng của bàn
/// </summary>
public class TableOrderSummaryDto
{
    /// <summary>Số món đã có đơn hàng</summary>
    public int TotalItemsCount { get; set; }
    
    /// <summary>Số món đang chờ phục vụ</summary>
    public int PendingServeCount { get; set; }
    
    /// <summary>Tổng tiền đơn hàng</summary>
    public decimal TotalAmount { get; set; }
    
}

/// <summary>
/// DTO món ăn trong đơn hàng của bàn
/// </summary>
public class TableOrderItemDto
{
    /// <summary>ID của order item</summary>
    public Guid Id { get; set; }
    
    /// <summary>Tên món ăn</summary>
    public string MenuItemName { get; set; }
    
    /// <summary>Số lượng</summary>
    public int Quantity { get; set; }
    
    /// <summary>Đơn giá</summary>
    public decimal UnitPrice { get; set; }
    
    /// <summary>Thành tiền</summary>
    public decimal TotalPrice { get; set; }
    
    /// <summary>Trạng thái món ăn</summary>
    public OrderItemStatus Status { get; set; }
    
    
    /// <summary>Có thể chỉnh sửa hay không</summary>
    public bool CanEdit { get; set; }
    
    /// <summary>Có thể xóa hay không</summary>
    public bool CanDelete { get; set; }
    
    /// <summary>Ghi chú đặc biệt (nếu có)</summary>
    public string SpecialRequest { get; set; }
    
    /// <summary>Có thiếu nguyên liệu không</summary>
    public bool HasMissingIngredients { get; set; }
    
    /// <summary>Danh sách nguyên liệu thiếu (nếu có)</summary>
    public List<MissingIngredientDto> MissingIngredients { get; set; } = new();
}