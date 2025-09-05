using System.ComponentModel;

namespace SmartRestaurant.Orders;

/// <summary>
/// Enum trạng thái chuẩn bị của từng món trong đơn hàng
/// </summary>
public enum OrderItemStatus
{
    /// <summary>
    /// Chờ chuẩn bị
    /// </summary>
    [Description("Chờ chuẩn bị")]
    Pending = 0,

    /// <summary>
    /// Đang chuẩn bị
    /// </summary>
    [Description("Đang chuẩn bị")]
    Preparing = 1,

    /// <summary>
    /// Đã hoàn thành
    /// </summary>
    [Description("Đã hoàn thành")]
    Ready = 2,

    /// <summary>
    /// Đã phục vụ
    /// </summary>
    [Description("Đã phục vụ")]
    Served = 3,

    /// <summary>
    /// Đã Huỷ
    /// </summary>
    [Description("Đã Huỷ")]
    Canceled = 4
}