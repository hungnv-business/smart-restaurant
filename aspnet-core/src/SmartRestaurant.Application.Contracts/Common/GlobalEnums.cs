using System.Collections.Generic;
using System.Collections.ObjectModel;
using SmartRestaurant.Orders;

namespace SmartRestaurant.Application.Contracts.Common;

/// <summary>
/// Class tĩnh chứa thông tin tất cả các enum trong hệ thống SmartRestaurant
/// Cung cấp mapping từ enum values sang display names tiếng Việt
/// </summary>
public static class GlobalEnums
{
    // Public properties to expose read-only dictionaries
    public static IReadOnlyDictionary<TableStatus, string> TableStatuses => SortedTableStatus;
    public static IReadOnlyDictionary<OrderStatus, string> OrderStatuses => SortedOrderStatus;
    public static IReadOnlyDictionary<OrderItemStatus, string> OrderItemStatuses => SortedOrderItemStatus;
    public static IReadOnlyDictionary<OrderType, string> OrderTypes => SortedOrderType;

    // Table Status mappings
    private static readonly ReadOnlyDictionary<TableStatus, string> SortedTableStatus = new(
        new Dictionary<TableStatus, string>
        {
            { TableStatus.Available, "Có sẵn" },
            { TableStatus.Occupied, "Đang sử dụng" },
            { TableStatus.Reserved, "Đã đặt trước" }
        });

    // Order Status mappings
    private static readonly ReadOnlyDictionary<OrderStatus, string> SortedOrderStatus = new(
        new Dictionary<OrderStatus, string>
        {
            { OrderStatus.Serving, "Đang phục vụ" },
            { OrderStatus.Paid, "Đã thanh toán" }
        });

    // Order Item Status mappings  
    private static readonly ReadOnlyDictionary<OrderItemStatus, string> SortedOrderItemStatus = new(
        new Dictionary<OrderItemStatus, string>
        {
            { OrderItemStatus.Pending, "Chờ chuẩn bị" },
            { OrderItemStatus.Preparing, "Đang chuẩn bị" },
            { OrderItemStatus.Ready, "Đã hoàn thành" },
            { OrderItemStatus.Served, "Đã phục vụ" }
        });

    // Order Type mappings
    private static readonly ReadOnlyDictionary<OrderType, string> SortedOrderType = new(
        new Dictionary<OrderType, string>
        {
            { OrderType.DineIn, "Ăn tại chỗ" },
            { OrderType.Takeaway, "Mang về" },
            { OrderType.Delivery, "Giao hàng" }
        });

    /// <summary>
    /// Lấy display name tiếng Việt cho TableStatus
    /// </summary>
    /// <param name="status">Table status</param>
    /// <returns>Display name tiếng Việt</returns>
    public static string GetTableStatusDisplayName(TableStatus status)
    {
        return TableStatuses.TryGetValue(status, out var displayName) ? displayName : status.ToString();
    }

    /// <summary>
    /// Lấy display name tiếng Việt cho OrderStatus
    /// </summary>
    /// <param name="status">Order status</param>
    /// <returns>Display name tiếng Việt</returns>
    public static string GetOrderStatusDisplayName(OrderStatus status)
    {
        return OrderStatuses.TryGetValue(status, out var displayName) ? displayName : status.ToString();
    }

    /// <summary>
    /// Lấy display name tiếng Việt cho OrderItemStatus
    /// </summary>
    /// <param name="status">Order item status</param>
    /// <returns>Display name tiếng Việt</returns>
    public static string GetOrderItemStatusDisplayName(OrderItemStatus status)
    {
        return OrderItemStatuses.TryGetValue(status, out var displayName) ? displayName : status.ToString();
    }

    /// <summary>
    /// Lấy display name tiếng Việt cho OrderType
    /// </summary>
    /// <param name="type">Order type</param>
    /// <returns>Display name tiếng Việt</returns>
    public static string GetOrderTypeDisplayName(OrderType type)
    {
        return OrderTypes.TryGetValue(type, out var displayName) ? displayName : type.ToString();
    }

    /// <summary>
    /// Lấy màu sắc cho trạng thái order item
    /// </summary>
    /// <param name="status">Order item status</param>
    /// <returns>Color string for UI</returns>
    public static string GetOrderItemStatusColor(OrderItemStatus status)
    {
        return status switch
        {
            OrderItemStatus.Pending => "orange",
            OrderItemStatus.Preparing => "orange", 
            OrderItemStatus.Ready => "blue",
            OrderItemStatus.Served => "success",
            OrderItemStatus.Canceled => "error",
            _ => "default"
        };
    }

    /// <summary>
    /// Lấy màu sắc cho trạng thái table
    /// </summary>
    /// <param name="status">Table status</param>
    /// <returns>Color string for UI</returns>
    public static string GetTableStatusColor(TableStatus status)
    {
        return status switch
        {
            TableStatus.Available => "success",
            TableStatus.Occupied => "warning", 
            TableStatus.Reserved => "info",
            _ => "default"
        };
    }

    /// <summary>
    /// Kiểm tra xem order item có thể chỉnh sửa không
    /// </summary>
    /// <param name="status">Order item status</param>
    /// <returns>True nếu có thể chỉnh sửa</returns>
    public static bool CanEditOrderItem(OrderItemStatus status)
    {
        return status == OrderItemStatus.Pending;
    }

    /// <summary>
    /// Kiểm tra xem order item có thể xóa không
    /// </summary>
    /// <param name="status">Order item status</param>
    /// <returns>True nếu có thể xóa</returns>
    public static bool CanDeleteOrderItem(OrderItemStatus status)
    {
        return status == OrderItemStatus.Pending;
    }
}