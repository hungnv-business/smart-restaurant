using System;
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
    /// Chỉ có thể xác nhận đơn hàng ở trạng thái Pending
    /// </summary>
    public static OrderValidationException CannotConfirmNonPendingOrder()
    {
        return new OrderValidationException("Chỉ có thể xác nhận đơn hàng ở trạng thái Pending");
    }

    /// <summary>
    /// Tổng tiền đơn hàng phải lớn hơn 0
    /// </summary>
    public static OrderValidationException InvalidTotalAmount()
    {
        return new OrderValidationException("Tổng tiền đơn hàng phải lớn hơn 0");
    }

    /// <summary>
    /// Đơn hàng đã được thanh toán
    /// </summary>
    public static OrderValidationException OrderAlreadyPaid()
    {
        return new OrderValidationException("Đơn hàng đã được thanh toán");
    }

    /// <summary>
    /// Không thể thanh toán khi còn món chưa hoàn tất
    /// </summary>
    public static OrderValidationException CannotPayWithIncompleteItems()
    {
        return new OrderValidationException("Không thể thanh toán khi còn món chưa phục vụ hoặc hủy");
    }

    /// <summary>
    /// Chỉ có thể sửa đổi đơn hàng khi đang Active
    /// </summary>
    public static OrderValidationException CannotModifyNonActiveOrder()
    {
        return new OrderValidationException("Chỉ có thể sửa đổi đơn hàng ở trạng thái Active");
    }

    /// <summary>
    /// Chỉ có thể hủy món khi đơn hàng đang Active
    /// </summary>
    public static OrderValidationException CannotCancelItemsInNonActiveOrder()
    {
        return new OrderValidationException("Chỉ có thể hủy món khi đơn hàng đang Active");
    }

    /// <summary>
    /// Không tìm thấy món với ID cụ thể
    /// </summary>
    public static OrderValidationException OrderItemNotFound(Guid itemId)
    {
        return new OrderValidationException($"Không tìm thấy món có ID: {itemId}");
    }

    // Table validation exceptions

    /// <summary>
    /// Bàn đã có đơn hàng khác
    /// </summary>
    public static OrderValidationException TableAlreadyHasOrder(string tableNumber, Guid currentOrderId)
    {
        return new OrderValidationException($"Bàn {tableNumber} đã có đơn hàng {currentOrderId}. Phải hoàn thành đơn hàng hiện tại trước.");
    }

    /// <summary>
    /// Bàn không có đơn hàng để hoàn thành
    /// </summary>
    public static OrderValidationException TableHasNoOrder(string tableNumber)
    {
        return new OrderValidationException($"Bàn {tableNumber} không có đơn hàng nào để hoàn thành.");
    }

    /// <summary>
    /// Không thể đặt trước bàn không Available
    /// </summary>
    public static OrderValidationException CannotReserveTable(string tableNumber)
    {
        return new OrderValidationException($"Không thể đặt trước bàn {tableNumber}. Bàn phải ở trạng thái Available.");
    }

    /// <summary>
    /// Không thể hủy đặt trước bàn không Reserved
    /// </summary>
    public static OrderValidationException CannotCancelReservation(string tableNumber)
    {
        return new OrderValidationException($"Không thể hủy đặt trước bàn {tableNumber}. Bàn không ở trạng thái Reserved.");
    }
}