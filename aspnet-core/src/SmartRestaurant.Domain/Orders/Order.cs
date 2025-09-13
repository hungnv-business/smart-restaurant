using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using Volo.Abp.Domain.Entities.Auditing;
using SmartRestaurant.TableManagement.Tables;
using Volo.Abp.Guids;
using SmartRestaurant.Application.Contracts.Orders.Dto;

namespace SmartRestaurant.Orders;

/// <summary>
/// Entity Order đại diện cho một đơn hàng trong hệ thống nhà hàng
/// Kế thừa FullAuditedAggregateRoot để hỗ trợ audit trail đầy đủ
/// </summary>
public class Order : FullAuditedAggregateRoot<Guid>
{
    /// <summary>
    /// Số đơn hàng hiển thị (ví dụ: #001, #002)
    /// </summary>
    [Required]
    [StringLength(20)]
    public string OrderNumber { get; set; } = string.Empty;

    /// <summary>
    /// ID của bàn được phục vụ (bắt buộc cho đơn hàng ăn tại chỗ)
    /// </summary>
    public Guid? TableId { get; set; }

    /// <summary>
    /// Loại đơn hàng (Ăn tại chỗ/Mang về/Giao hàng)
    /// </summary>
    [Required]
    public OrderType OrderType { get; set; } = OrderType.DineIn;

    /// <summary>
    /// Trạng thái hiện tại của đơn hàng
    /// </summary>
    [Required]
    public OrderStatus Status { get; private set; } = OrderStatus.Active;

    /// <summary>
    /// Tổng số tiền của đơn hàng (VND)
    /// </summary>
    [Range(0, double.MaxValue, ErrorMessage = "Tổng tiền phải lớn hơn 0")]
    public decimal TotalAmount { get; set; }

    /// <summary>
    /// Ghi chú chung của khách hàng hoặc nhân viên
    /// </summary>
    [StringLength(500)]
    public string? Notes { get; set; }

    /// <summary>
    /// Thời gian tạo đơn hàng
    /// </summary>
    public DateTime CreatedTime { get; set; }

    /// <summary>
    /// Thời gian thanh toán (kết thúc đơn hàng)
    /// </summary>
    public DateTime? PaidTime { get; set; }

    // Navigation Properties

    /// <summary>
    /// Bàn được phục vụ (đối với đơn hàng ăn tại chỗ)
    /// </summary>
    public virtual Table? Table { get; set; }

    /// <summary>
    /// Danh sách các món trong đơn hàng
    /// </summary>
    public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();

    /// <summary>
    /// Danh sách thanh toán cho đơn hàng (thường sẽ có 1 payment khi thanh toán)
    /// </summary>
    public virtual ICollection<Payment> Payments { get; set; } = new List<Payment>();

    // Constructor
    protected Order()
    {
        // Parameterless constructor for EF Core
    }

    public Order(
        Guid id,
        string orderNumber,
        OrderType orderType,
        Guid? tableId = null,
        string? notes = null) : base(id)
    {
        OrderNumber = orderNumber;
        OrderType = orderType;
        TableId = tableId;
        Notes = notes;
        Status = OrderStatus.Active;
        TotalAmount = 0;
        CreatedTime = DateTime.Now;
    }

    /// <summary>
    /// Đánh dấu đơn hàng đã thanh toán
    /// Chỉ cho phép thanh toán khi tất cả món ăn đã phục vụ hoặc hủy
    /// </summary>
    public void MarkAsPaid()
    {
        if (Status == OrderStatus.Paid)
        {
            throw OrderValidationException.OrderAlreadyPaid();
        }

        if (!IsCompleted())
        {
            throw OrderValidationException.CannotPayWithIncompleteItems();
        }

        Status = OrderStatus.Paid;
        PaidTime = DateTime.Now;
    }

    /// <summary>
    /// Kiểm tra đơn hàng có đang active không
    /// </summary>
    public bool IsActive() => Status == OrderStatus.Active;

    /// <summary>
    /// Kiểm tra đơn hàng đã thanh toán chưa
    /// </summary>
    public bool IsPaid() => Status == OrderStatus.Paid;

    /// <summary>
    /// Kiểm tra đơn hàng đã hoàn tất (tất cả món đã phục vụ hoặc hủy)
    /// </summary>
    public bool IsCompleted()
    {
        return OrderItems.All(item =>
            item.Status == OrderItemStatus.Served ||
            item.Status == OrderItemStatus.Canceled);
    }

    /// <summary>
    /// Kiểm tra OrderItem có tồn tại trong Order không
    /// </summary>
    /// <param name="orderItemId">ID của OrderItem cần kiểm tra</param>
    /// <returns>True nếu OrderItem tồn tại, False nếu không</returns>
    public bool IsOrderItemIn(Guid orderItemId)
    {
        return OrderItems.Any(item => item.Id == orderItemId);
    }

    /// <summary>
    /// Thêm món vào đơn hàng
    /// </summary>
    /// <param name="orderItem">Món cần thêm</param>
    public void AddItem(IGuidGenerator guidGenerator, OrderItem orderItem)
    {
        var item = new OrderItem(
            guidGenerator.Create(),
            orderItem.OrderId,
            orderItem.MenuItemId,
            orderItem.MenuItemName,
            orderItem.Quantity,
            orderItem.UnitPrice,
            orderItem.Notes
         );
        OrderItems.Add(item);
        RecalculateTotalAmount();
    }

    /// <summary>
    /// Thêm nhiều món vào đơn hàng
    /// </summary>
    /// <param name="orderItems">Danh sách món cần thêm</param>
    public void AddItems(IGuidGenerator guidGenerator, IEnumerable<OrderItem> orderItems)
    {
        if (!IsActive())
        {
            throw OrderValidationException.CannotModifyNonActiveOrder();
        }

        foreach (var orderItem in orderItems)
        {
            AddItem(guidGenerator, orderItem);
        }
    }

    /// <summary>
    /// Xóa món khỏi đơn hàng
    /// </summary>
    /// <param name="orderItemId">ID của món cần xóa</param>
    public void RemoveItem(Guid orderItemId)
    {
        if (!IsActive())
        {
            // Business Exception: Chỉ có thể sửa đổi đơn hàng ở trạng thái Active  
            throw OrderValidationException.CannotModifyNonActiveOrder();
        }

        if (IsOrderItemIn(orderItemId))
        {
            var item = OrderItems.First(x => x.Id == orderItemId);
            OrderItems.Remove(item);
            RecalculateTotalAmount();
        }
    }

    /// <summary>
    /// Hủy món trong đơn hàng
    /// </summary>
    /// <param name="orderItemId">ID của món cần hủy</param>
    public void CancelItem(Guid orderItemId)
    {
        if (!IsActive())
        {
            throw OrderValidationException.CannotCancelItemsInNonActiveOrder();
        }

        if (!IsOrderItemIn(orderItemId))
        {
            throw OrderValidationException.OrderItemNotFound(orderItemId);
        }

        var item = OrderItems.First(x => x.Id == orderItemId);

        item.Cancel();
        RecalculateTotalAmount();
    }

    /// <summary>
    /// Tính lại tổng tiền đơn hàng
    /// </summary>
    private void RecalculateTotalAmount()
    {
        // Chỉ tính tiền những món không bị hủy
        TotalAmount = OrderItems
            .Where(item => item.Status != OrderItemStatus.Canceled)
            .Sum(item => item.UnitPrice * item.Quantity);
    }

    /// <summary>
    /// Validate đơn hàng trước khi xác nhận
    /// </summary>
    public void ValidateForConfirmation()
    {
        if (OrderItems.Count == 0)
        {
            // Business Exception: Đơn hàng trống
            throw OrderValidationException.EmptyOrder();
        }

        if (OrderType == OrderType.DineIn && TableId == null)
        {
            // Business Exception: Đơn hàng ăn tại chỗ không có bàn
            throw OrderValidationException.DineInWithoutTable();
        }

        if (TotalAmount <= 0)
        {
            // Business Exception: Tổng tiền không hợp lệ
            throw OrderValidationException.InvalidTotalAmount();
        }
    }

    /// <summary>
    /// Tính lại tổng tiền đơn hàng (public method)
    /// Sử dụng khi cập nhật số lượng OrderItem từ bên ngoài
    /// </summary>
    public void RecalculateTotal()
    {
        RecalculateTotalAmount();
    }

    /// <summary>
    /// Hoàn thành thanh toán cho đơn hàng
    /// </summary>
    public void CompletePayment()
    {
        if (!IsActive())
        {
            throw OrderValidationException.CannotCompletePaymentForNonActiveOrder();
        }

        // Kiểm tra tất cả món đã được phục vụ hoặc hủy
        var unservedItems = GetUnservedItems();

        if (unservedItems.Count != 0)
        {
            throw OrderValidationException.CannotCompletePaymentWithUnservedItems(unservedItems.Count);
        }

        // Cập nhật trạng thái order
        Status = OrderStatus.Paid;
        PaidTime = DateTime.Now;

        // Tính lại tổng tiền cuối cùng
        RecalculateTotalAmount();

        // Cập nhật trạng thái bàn về Available (nếu có bàn)
        if (Table != null)
        {
            Table.CompleteOrder();
        }

        // Domain event có thể được thêm sau để notify các service khác
        // AddLocalEvent(new OrderPaymentCompletedEvent(this));
    }

    /// <summary>
    /// Kiểm tra có thể thanh toán không
    /// </summary>
    /// <returns>True nếu có thể thanh toán</returns>
    public bool CanCompletePayment()
    {
        if (!IsActive()) return false;

        // Tất cả món phải đã được phục vụ hoặc hủy (không còn món unserved)
        return GetUnservedItems().Count == 0;
    }

    /// <summary>
    /// Lấy danh sách món chưa được phục vụ
    /// </summary>
    /// <returns>Danh sách món chưa phục vụ</returns>
    public List<OrderItem> GetUnservedItems()
    {
        return OrderItems.Where(oi =>
            oi.Status != OrderItemStatus.Served &&
            oi.Status != OrderItemStatus.Canceled).ToList();
    }

    /// <summary>
    /// Thêm Payment vào đơn hàng với business validation
    /// </summary>
    /// <param name="guidGenerator">GUID generator</param>
    /// <param name="totalAmount">Tổng tiền hóa đơn</param>
    /// <param name="customerMoney">Tiền khách trả</param>
    /// <param name="paymentMethod">Phương thức thanh toán</param>
    /// <param name="notes">Ghi chú thanh toán</param>
    /// <returns>Payment đã được tạo</returns>
    public Payment AddPayment(
        IGuidGenerator guidGenerator,
        decimal totalAmount,
        decimal customerMoney,
        PaymentMethod paymentMethod,
        string? notes = null)
    {
        if (!IsActive())
        {
            throw OrderValidationException.CannotAddPaymentToNonActiveOrder();
        }

        var payment = new Payment(
            guidGenerator.Create(),
            Id,
            totalAmount,
            customerMoney,
            paymentMethod,
            notes);

        Payments.Add(payment);
        return payment;
    }
}