using System;
using System.Collections.Generic;
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
    /// Đơn hàng takeaway/delivery thiếu thông tin khách hàng
    /// </summary>
    public static OrderValidationException TakeawayWithoutCustomerInfo()
    {
        return new OrderValidationException("Đơn hàng mang về/giao hàng phải có tên và số điện thoại khách hàng");
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

    /// <summary>
    /// Không tìm thấy món trong order
    /// </summary>
    public static OrderValidationException OrderItemNotFoundInOrder(Guid orderItemId, Guid orderId)
    {
        return new OrderValidationException($"Không tìm thấy món với ID {orderItemId} trong order {orderId}");
    }

    /// <summary>
    /// Chỉ có thể xóa món khỏi order đang hoạt động
    /// </summary>
    public static OrderValidationException CannotRemoveItemFromInactiveOrder()
    {
        return new OrderValidationException("Chỉ có thể xóa món khỏi order đang hoạt động");
    }

    /// <summary>
    /// Chỉ có thể xóa món ở trạng thái Pending
    /// </summary>
    public static OrderValidationException CannotRemoveNonPendingOrderItem(string menuItemName, OrderItemStatus status)
    {
        return new OrderValidationException($"Không thể xóa món '{menuItemName}' ở trạng thái {status}. Chỉ có thể xóa món ở trạng thái Pending");
    }

    /// <summary>
    /// Không thể xóa món cuối cùng trong order
    /// </summary>
    public static OrderValidationException CannotRemoveLastOrderItem()
    {
        return new OrderValidationException("Không thể xóa món cuối cùng trong order. Vui lòng hủy toàn bộ order thay vì xóa món này");
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

    /// <summary>
    /// Không tìm thấy bàn với ID cụ thể
    /// </summary>
    public static OrderValidationException TableNotFound(Guid tableId)
    {
        return new OrderValidationException($"Không tìm thấy bàn với ID {tableId}");
    }

    /// <summary>
    /// Bàn không khả dụng cho đơn hàng
    /// </summary>
    public static OrderValidationException TableNotAvailable(string tableNumber)
    {
        return new OrderValidationException($"Bàn {tableNumber} không khả dụng");
    }

    // OrderItem validation exceptions

    /// <summary>
    /// Tên món ăn không được để trống
    /// </summary>
    public static OrderValidationException MenuItemNameRequired()
    {
        return new OrderValidationException("Tên món ăn không được để trống");
    }

    /// <summary>
    /// Số lượng phải lớn hơn 0
    /// </summary>
    public static OrderValidationException InvalidQuantity()
    {
        return new OrderValidationException("Số lượng phải lớn hơn 0");
    }

    /// <summary>
    /// Giá không được âm
    /// </summary>
    public static OrderValidationException InvalidPrice()
    {
        return new OrderValidationException("Giá không được âm");
    }

    /// <summary>
    /// Món ăn hiện không có sẵn
    /// </summary>
    public static OrderValidationException MenuItemNotAvailable(string menuItemName)
    {
        return new OrderValidationException($"Món '{menuItemName}' hiện không có sẵn");
    }

    /// <summary>
    /// Không tìm thấy đơn hàng với ID cụ thể
    /// </summary>
    public static OrderValidationException OrderNotFound(Guid orderId)
    {
        return new OrderValidationException($"Không tìm thấy đơn hàng với ID: {orderId}");
    }

    /// <summary>
    /// Chỉ có thể cập nhật số lượng món đang chờ chuẩn bị
    /// </summary>
    public static OrderValidationException CannotUpdateQuantityNonPendingItem()
    {
        return new OrderValidationException("Chỉ có thể chỉnh sửa số lượng món đang chờ chuẩn bị");
    }

    /// <summary>
    /// Chỉ có thể thêm món vào order đang hoạt động
    /// </summary>
    public static OrderValidationException CannotAddItemsToInactiveOrder()
    {
        return new OrderValidationException("Chỉ có thể thêm món vào order đang hoạt động");
    }

    /// <summary>
    /// Những món được chọn không khả dụng
    /// </summary>
    public static OrderValidationException MenuItemsNotAvailable(List<string> unavailableItems)
    {
        return new OrderValidationException($"Những món sau không khả dụng: {string.Join(", ", unavailableItems)}");
    }

    // Payment validation exceptions

    /// <summary>
    /// Không thể thanh toán order không ở trạng thái Active
    /// </summary>
    public static OrderValidationException CannotCompletePaymentForNonActiveOrder()
    {
        return new OrderValidationException("Chỉ có thể thanh toán order đang hoạt động (Active)");
    }

    /// <summary>
    /// Không thể thêm payment vào order không ở trạng thái Active
    /// </summary>
    public static OrderValidationException CannotAddPaymentToNonActiveOrder()
    {
        return new OrderValidationException("Chỉ có thể thêm payment vào order đang hoạt động (Active)");
    }

    /// <summary>
    /// Không thể thanh toán khi còn món chưa được phục vụ
    /// </summary>
    public static OrderValidationException CannotCompletePaymentWithUnservedItems(int unservedCount)
    {
        return new OrderValidationException($"Không thể thanh toán vì còn {unservedCount} món chưa được phục vụ hoặc hủy");
    }

    /// <summary>
    /// Thanh toán tiền mặt yêu cầu số tiền khách đưa
    /// </summary>
    public static OrderValidationException CashPaymentRequiresCustomerMoney()
    {
        return new OrderValidationException("Thanh toán tiền mặt yêu cầu số tiền khách đưa");
    }

    /// <summary>
    /// Số tiền thanh toán quá thấp
    /// </summary>
    public static OrderValidationException PaymentAmountTooLow(decimal orderTotal, decimal customerPayment)
    {
        return new OrderValidationException($"Số tiền thanh toán quá thấp. Hóa đơn: {orderTotal:C}, Khách trả: {customerPayment:C}. Vui lòng kiểm tra lại.");
    }

    /// <summary>
    /// Phương thức thanh toán không được hỗ trợ
    /// </summary>
    public static OrderValidationException UnsupportedPaymentMethod(string paymentMethod)
    {
        return new OrderValidationException($"Phương thức thanh toán {paymentMethod} không được hỗ trợ");
    }

    /// <summary>
    /// Không thể chuyển từ trạng thái này sang trạng thái kia
    /// </summary>
    public static OrderValidationException InvalidStatusTransition(OrderItemStatus currentStatus, OrderItemStatus newStatus)
    {
        return new OrderValidationException($"Không thể chuyển từ trạng thái {currentStatus} sang {newStatus}");
    }
}