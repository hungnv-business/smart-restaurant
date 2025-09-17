using System;

namespace SmartRestaurant.Application.Contracts.Orders.Dto;

/// <summary>
/// DTO cho thông báo cập nhật số lượng món ăn
/// </summary>
public class OrderItemQuantityUpdateNotificationDto
{
    public required string TableName { get; set; }
    public Guid OrderItemId { get; set; }
    public required string MenuItemName { get; set; }
    public int NewQuantity { get; set; }
}

/// <summary>
/// DTO cho thông báo thêm món mới vào đơn hàng
/// </summary>
public class OrderItemsAddedNotificationDto
{
    public required string TableName { get; set; }
    public required string AddedItemsDetail { get; set; } // VD: "1 món đậu, 2 món rau"
}

/// <summary>
/// DTO cho thông báo xóa món khỏi đơn hàng
/// </summary>
public class OrderItemRemovedNotificationDto
{
    public required string TableName { get; set; }
    public Guid OrderItemId { get; set; }
    public required string MenuItemName { get; set; }
    public int Quantity { get; set; }
}

/// <summary>
/// DTO cho thông báo món ăn đã được phục vụ
/// </summary>
public class OrderItemServedNotificationDto
{
    public required string TableName { get; set; }
    public Guid OrderId { get; set; }
    public required string OrderNumber { get; set; }
    public required string MenuItemName { get; set; }
    public int Quantity { get; set; }
    public Guid? TableId { get; set; }
}