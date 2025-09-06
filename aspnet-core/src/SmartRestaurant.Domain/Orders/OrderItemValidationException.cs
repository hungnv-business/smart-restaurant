using Volo.Abp;

namespace SmartRestaurant.Orders;

/// <summary>
/// Exception được ném khi validation OrderItem thất bại
/// Business Exception: OrderItem không đáp ứng các quy tắc kinh doanh
/// </summary>
public class OrderItemValidationException : BusinessException
{
    public OrderItemValidationException(string validationMessage)
        : base(OrdersErrorCodes.OrderItemValidationFailed)
    {
        WithData("ValidationMessage", validationMessage);
    }

    /// <summary>
    /// Chỉ có thể bắt đầu chuẩn bị món ở trạng thái Pending
    /// </summary>
    public static OrderItemValidationException CannotStartPreparationNonPendingItem()
    {
        return new OrderItemValidationException("Chỉ có thể bắt đầu chuẩn bị món ở trạng thái Pending");
    }

    /// <summary>
    /// Chỉ có thể hoàn thành món đang được chuẩn bị
    /// </summary>
    public static OrderItemValidationException CannotMarkReadyNonPreparingItem()
    {
        return new OrderItemValidationException("Chỉ có thể hoàn thành món đang được chuẩn bị");
    }

    /// <summary>
    /// Chỉ có thể phục vụ món đã sẵn sàng
    /// </summary>
    public static OrderItemValidationException CannotServeNonReadyItem()
    {
        return new OrderItemValidationException("Chỉ có thể phục vụ món đã sẵn sàng");
    }

    /// <summary>
    /// Chỉ có thể hủy món ở trạng thái chờ chuẩn bị
    /// </summary>
    public static OrderItemValidationException CannotCancelNonPendingItem(OrderItemStatus currentStatus)
    {
        return new OrderItemValidationException(
            $"Chỉ có thể hủy món ở trạng thái chờ chuẩn bị. Trạng thái hiện tại: {currentStatus}");
    }
}