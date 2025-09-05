using Volo.Abp;

namespace SmartRestaurant.Orders;

/// <summary>
/// Exception được ném khi validation đơn hàng thất bại
/// Business Exception: Đơn hàng không đáp ứng các quy tắc kinh doanh
/// </summary>
public class OrderValidationException : BusinessException
{
    public OrderValidationException(string validationMessage)
        : base(OrdersErrorCodes.OrderValidationFailed)
    {
        WithData("ValidationMessage", validationMessage);
    }

    /// <summary>
    /// Đơn hàng trống - không có món nào
    /// </summary>
    public static OrderValidationException EmptyOrder()
    {
        return new OrderValidationException("Đơn hàng phải có ít nhất một món");
    }

    /// <summary>
    /// Đơn hàng ăn tại chỗ không có bàn
    /// </summary>
    public static OrderValidationException DineInWithoutTable()
    {
        return new OrderValidationException("Đơn hàng ăn tại chỗ phải có bàn");
    }

    /// <summary>
    /// Chỉ có thể sửa đổi đơn hàng ở trạng thái Pending
    /// </summary>
    public static OrderValidationException NotInPendingStatus()
    {
        return new OrderValidationException("Chỉ có thể sửa đổi đơn hàng khi đang ở trạng thái chờ xác nhận");
    }

    /// <summary>
    /// Chỉ có thể xác nhận đơn hàng ở trạng thái Pending
    /// </summary>
    public static OrderValidationException CannotConfirmNonPendingOrder()
    {
        return new OrderValidationException("Chỉ có thể xác nhận đơn hàng ở trạng thái Pending");
    }

    /// <summary>
    /// Chỉ có thể hoàn thành phục vụ khi đơn hàng đã sẵn sàng
    /// </summary>
    public static OrderValidationException CannotCompleteNonReadyOrder()
    {
        return new OrderValidationException("Chỉ có thể hoàn thành phục vụ khi đơn hàng đã sẵn sàng");
    }

    /// <summary>
    /// Tổng tiền đơn hàng phải lớn hơn 0
    /// </summary>
    public static OrderValidationException InvalidTotalAmount()
    {
        return new OrderValidationException("Tổng tiền đơn hàng phải lớn hơn 0");
    }
}