using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using Volo.Abp.Domain.Entities.Auditing;
using SmartRestaurant.TableManagement.Tables;

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
    /// Thêm món vào đơn hàng
    /// </summary>
    /// <param name="orderItem">Món cần thêm</param>
    public void AddItem(OrderItem orderItem)
    {
        OrderItems.Add(orderItem);
        RecalculateTotalAmount();
    }

    /// <summary>
    /// Thêm nhiều món vào đơn hàng
    /// </summary>
    /// <param name="orderItems">Danh sách món cần thêm</param>
    public void AddItems(IEnumerable<OrderItem> orderItems)
    {
        if (Status != OrderStatus.Active)
        {
            throw OrderValidationException.CannotModifyNonActiveOrder();
        }

        foreach (var orderItem in orderItems)
        {
            AddItem(orderItem);
        }
    }

    /// <summary>
    /// Xóa món khỏi đơn hàng
    /// </summary>
    /// <param name="orderItemId">ID của món cần xóa</param>
    public void RemoveItem(Guid orderItemId)
    {
        if (Status != OrderStatus.Active)
        {
            // Business Exception: Chỉ có thể sửa đổi đơn hàng ở trạng thái Active  
            throw new InvalidOperationException("Chỉ có thể sửa đổi đơn hàng ở trạng thái Active");
        }

        var item = OrderItems.FirstOrDefault(x => x.Id == orderItemId);
        if (item != null)
        {
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
        if (Status != OrderStatus.Active)
        {
            throw OrderValidationException.CannotCancelItemsInNonActiveOrder();
        }

        var item = OrderItems.FirstOrDefault(x => x.Id == orderItemId);
        if (item == null)
        {
            throw OrderValidationException.OrderItemNotFound(orderItemId);
        }

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
        if (!OrderItems.Any())
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
}