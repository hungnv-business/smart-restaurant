using Volo.Abp;

namespace SmartRestaurant.Orders;

/// <summary>
/// Exception được ném khi chuyển đổi trạng thái đơn hàng không hợp lệ
/// Business Exception: Không thể chuyển trạng thái đơn hàng theo quy tắc kinh doanh
/// </summary>
public class OrderStatusTransitionException : BusinessException
{
    public OrderStatusTransitionException(OrderStatus currentStatus, OrderStatus targetStatus)
        : base(OrdersErrorCodes.InvalidStatusTransition)
    {
        WithData("CurrentStatus", currentStatus.ToString())
             .WithData("TargetStatus", targetStatus.ToString());
    }
}