using System.ComponentModel;

namespace SmartRestaurant.Orders;

/// <summary>
/// Enum định nghĩa các loại đơn hàng trong nhà hàng
/// </summary>
public enum OrderType
{
    /// <summary>
    /// Ăn tại chỗ - Khách hàng ăn tại nhà hàng
    /// </summary>
    [Description("Ăn tại chỗ")]
    DineIn = 0,

    /// <summary>
    /// Mang về - Khách hàng đặt món mang về
    /// </summary>
    [Description("Mang về")]
    Takeaway = 1,

    /// <summary>
    /// Giao hàng - Nhà hàng giao món đến địa chỉ khách hàng
    /// </summary>
    [Description("Giao hàng")]
    Delivery = 2
}