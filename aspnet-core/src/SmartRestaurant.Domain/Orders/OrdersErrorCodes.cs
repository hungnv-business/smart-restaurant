namespace SmartRestaurant.Orders;

/// <summary>
/// Mã lỗi cho Order domain
/// Phục vụ việc localization và xử lý lỗi thống nhất
/// </summary>
public static class OrdersErrorCodes
{
    /// <summary>
    /// Chuyển đổi trạng thái đơn hàng không hợp lệ
    /// </summary>
    public const string InvalidStatusTransition = "Orders:InvalidStatusTransition";

    /// <summary>
    /// Validation đơn hàng thất bại
    /// </summary>
    public const string OrderValidationFailed = "Orders:ValidationFailed";

    /// <summary>
    /// Không tìm thấy bàn
    /// </summary>
    public const string TableNotFound = "Orders:TableNotFound";

    /// <summary>
    /// Bàn không khả dụng
    /// </summary>
    public const string TableNotAvailable = "Orders:TableNotAvailable";

    /// <summary>
    /// Validation OrderItem thất bại
    /// </summary>
    public const string OrderItemValidationFailed = "Orders:OrderItemValidationFailed";

    /// <summary>
    /// Bàn đã có đơn hàng khác
    /// </summary>
    public const string TableAlreadyHasOrder = "Orders:TableAlreadyHasOrder";

    /// <summary>
    /// Bàn không có đơn hàng để hoàn thành
    /// </summary>
    public const string TableHasNoOrder = "Orders:TableHasNoOrder";

    /// <summary>
    /// Không thể đặt trước bàn không Available
    /// </summary>
    public const string CannotReserveTable = "Orders:CannotReserveTable";

    /// <summary>
    /// Không thể hủy đặt trước bàn không Reserved
    /// </summary>
    public const string CannotCancelReservation = "Orders:CannotCancelReservation";
}