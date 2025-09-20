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
    public OrderStatus Status { get; private set; } = OrderStatus.Serving;

    /// <summary>
    /// Tổng số tiền của đơn hàng (VND)
    /// </summary>
    [Range(0, int.MaxValue, ErrorMessage = "Tổng tiền phải lớn hơn 0")]
    public int TotalAmount { get; set; }

    /// <summary>
    /// Ghi chú chung của khách hàng hoặc nhân viên
    /// </summary>
    [StringLength(500)]
    public string? Notes { get; set; }

    /// <summary>
    /// Tên khách hàng (bắt buộc cho đơn takeaway/delivery)
    /// </summary>
    [StringLength(100)]
    public string? CustomerName { get; set; }

    /// <summary>
    /// Số điện thoại khách hàng (bắt buộc cho đơn takeaway/delivery)
    /// </summary>
    [StringLength(20)]
    public string? CustomerPhone { get; set; }

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
        string? notes = null,
        string? customerName = null,
        string? customerPhone = null) : base(id)
    {
        OrderNumber = orderNumber;
        OrderType = orderType;
        TableId = tableId;
        Notes = notes;
        CustomerName = customerName;
        CustomerPhone = customerPhone;
        Status = OrderStatus.Serving;
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
    /// Kiểm tra đơn hàng có đang phục vụ không (chưa thanh toán)
    /// </summary>
    public bool IsServing() => Status == OrderStatus.Serving;

    /// <summary>
    /// Kiểm tra đây có phải đơn hàng mang về/giao hàng không (không có bàn)
    /// </summary>
    public bool IsTakeaway => OrderType == OrderType.Takeaway || OrderType == OrderType.Delivery;

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
            item.IsServed() ||
            item.IsCanceled());
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
        if (!IsServing())
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
        if (!IsServing())
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
        if (!IsServing())
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
            .Where(item => !item.IsCanceled())
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

        if ((OrderType == OrderType.Takeaway || OrderType == OrderType.Delivery) && 
            (string.IsNullOrWhiteSpace(CustomerName) || string.IsNullOrWhiteSpace(CustomerPhone)))
        {
            // Business Exception: Đơn hàng takeaway/delivery thiếu thông tin khách hàng
            throw OrderValidationException.TakeawayWithoutCustomerInfo();
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
        if (!IsServing())
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
        if (!IsServing()) return false;

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
            !oi.IsServed() &&
            !oi.IsCanceled()).ToList();
    }

    /// <summary>
    /// Lấy danh sách món chưa được phục vụ
    /// </summary>
    /// <returns>Danh sách món chưa phục vụ</returns>
    public List<OrderItem> GetUnservedItemsForMoblie()
    {
        return OrderItems.Where(oi => oi.IsPending() || oi.IsPreparing()).ToList();
    }

    /// <summary>
    /// Lấy danh sách món cần nấu cho bếp
    /// Chỉ bao gồm các món có RequiresCooking = true và chưa hoàn thành
    /// </summary>
    /// <returns>Danh sách món cần nấu</returns>
    public List<OrderItem> GetCookingItems()
    {
        return OrderItems.Where(oi =>
            oi.MenuItem?.RequiresCooking == true &&
            !oi.IsServed() &&
            !oi.IsCanceled()).ToList();
    }

    /// <summary>
    /// Lấy tên hiển thị của bàn cho thông báo
    /// </summary>
    /// <returns>Tên bàn hoặc "Mang về" nếu không phải đơn hàng ăn tại chỗ</returns>
    public string GetTableDisplayName()
    {
        if (OrderType == OrderType.DineIn && Table != null)
        {
            return $"{Table.TableNumber}";
        }
        return "Mang về";
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
        int totalAmount,
        int customerMoney,
        PaymentMethod paymentMethod,
        string? notes = null)
    {
        if (!IsServing())
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