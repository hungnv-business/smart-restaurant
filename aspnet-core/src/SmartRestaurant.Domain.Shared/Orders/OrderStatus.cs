using System.ComponentModel;

namespace SmartRestaurant.Orders;

/// <summary>
/// Enum định nghĩa các trạng thái của đơn hàng trong quy trình quản lý nhà hàng
/// </summary>
public enum OrderStatus
{
    /// <summary>
    /// Chờ xác nhận - Đơn hàng đã được tạo nhưng chưa được xác nhận
    /// </summary>
    [Description("Chờ xác nhận")]
    Pending = 0,

    /// <summary>
    /// Đã xác nhận - Đơn hàng đã được xác nhận và gửi đến bếp
    /// </summary>
    [Description("Đã xác nhận")]
    Confirmed = 1,

    /// <summary>
    /// Đang chuẩn bị - Bếp đang chuẩn bị các món trong đơn hàng
    /// </summary>
    [Description("Đang chuẩn bị")]
    Preparing = 2,

    /// <summary>
    /// Sẵn sàng - Tất cả món đã được chuẩn bị xong, sẵn sàng phục vụ
    /// </summary>
    [Description("Sẵn sàng")]
    Ready = 3,

    /// <summary>
    /// Đã phục vụ - Đã phục vụ cho khách hàng
    /// </summary>
    [Description("Đã phục vụ")]
    Served = 4,

    /// <summary>
    /// Đã thanh toán - Khách hàng đã thanh toán đơn hàng
    /// </summary>
    [Description("Đã thanh toán")]
    Paid = 5
}