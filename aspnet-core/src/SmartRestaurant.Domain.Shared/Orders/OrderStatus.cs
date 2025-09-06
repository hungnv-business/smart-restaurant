using System.ComponentModel;

namespace SmartRestaurant.Orders;

/// <summary>
/// Enum định nghĩa các trạng thái của đơn hàng trong quy trình quản lý nhà hàng (Simplified)
/// </summary>
public enum OrderStatus
{
    /// <summary>
    /// Đang hoạt động - Đơn hàng đang được phục vụ (mặc định khi tạo)
    /// </summary>
    [Description("Đang hoạt động")]
    Active = 0,

    /// <summary>
    /// Đã thanh toán - Khách hàng đã ăn xong và thanh toán (đơn hàng hoàn thành)
    /// </summary>
    [Description("Đã thanh toán")]
    Paid = 1
}