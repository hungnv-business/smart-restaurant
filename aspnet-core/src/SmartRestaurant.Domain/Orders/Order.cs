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
    public OrderStatus Status { get; set; } = OrderStatus.Pending;

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
    /// Thời gian đơn hàng được xác nhận
    /// </summary>
    public DateTime? ConfirmedTime { get; set; }

    /// <summary>
    /// Thời gian bắt đầu chuẩn bị món
    /// </summary>
    public DateTime? PreparingTime { get; set; }

    /// <summary>
    /// Thời gian hoàn thành chuẩn bị
    /// </summary>
    public DateTime? ReadyTime { get; set; }

    /// <summary>
    /// Thời gian phục vụ khách hàng
    /// </summary>
    public DateTime? ServedTime { get; set; }

    /// <summary>
    /// Thời gian thanh toán
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
        Status = OrderStatus.Pending;
        TotalAmount = 0;
    }

    /// <summary>
    /// Cập nhật trạng thái đơn hàng với validation logic kinh doanh
    /// </summary>
    /// <param name="newStatus">Trạng thái mới</param>
    public void UpdateStatus(OrderStatus newStatus)
    {
        if (!CanTransitionTo(newStatus))
        {
            // Business Exception: Chuyển đổi trạng thái không hợp lệ theo quy tắc kinh doanh
            throw new OrderStatusTransitionException(Status, newStatus);
        }

        var oldStatus = Status;
        Status = newStatus;

        // Cập nhật thời gian theo trạng thái
        var now = DateTime.UtcNow;
        switch (newStatus)
        {
            case OrderStatus.Confirmed:
                ConfirmedTime = now;
                break;
            case OrderStatus.Preparing:
                PreparingTime = now;
                break;
            case OrderStatus.Ready:
                ReadyTime = now;
                break;
            case OrderStatus.Served:
                ServedTime = now;
                break;
            case OrderStatus.Paid:
                PaidTime = now;
                break;
        }

        // Thêm domain event để thông báo thay đổi trạng thái
        AddLocalEvent(new OrderStatusChangedEvent(Id, oldStatus, newStatus));
    }

    /// <summary>
    /// Kiểm tra xem có thể chuyển sang trạng thái mới không
    /// </summary>
    /// <param name="newStatus">Trạng thái đích</param>
    /// <returns>True nếu có thể chuyển, False nếu không</returns>
    public bool CanTransitionTo(OrderStatus newStatus)
    {
        return Status switch
        {
            OrderStatus.Pending => newStatus == OrderStatus.Confirmed,
            OrderStatus.Confirmed => newStatus == OrderStatus.Preparing,
            OrderStatus.Preparing => newStatus == OrderStatus.Ready,
            OrderStatus.Ready => newStatus == OrderStatus.Served,
            OrderStatus.Served => newStatus == OrderStatus.Paid,
            OrderStatus.Paid => false, // Không thể chuyển từ trạng thái cuối
            _ => false
        };
    }

    /// <summary>
    /// Thêm món vào đơn hàng
    /// </summary>
    /// <param name="orderItem">Món cần thêm</param>
    public void AddItem(OrderItem orderItem)
    {
        if (Status != OrderStatus.Pending)
        {
            // Business Exception: Chỉ có thể sửa đổi đơn hàng ở trạng thái Pending
            throw OrderValidationException.NotInPendingStatus();
        }

        OrderItems.Add(orderItem);
        RecalculateTotalAmount();
    }

    /// <summary>
    /// Xóa món khỏi đơn hàng
    /// </summary>
    /// <param name="orderItemId">ID của món cần xóa</param>
    public void RemoveItem(Guid orderItemId)
    {
        if (Status != OrderStatus.Pending)
        {
            // Business Exception: Chỉ có thể sửa đổi đơn hàng ở trạng thái Pending  
            throw OrderValidationException.NotInPendingStatus();
        }

        var item = OrderItems.FirstOrDefault(x => x.Id == orderItemId);
        if (item != null)
        {
            OrderItems.Remove(item);
            RecalculateTotalAmount();
        }
    }

    /// <summary>
    /// Tính lại tổng tiền đơn hàng
    /// </summary>
    private void RecalculateTotalAmount()
    {
        TotalAmount = OrderItems.Sum(item => item.UnitPrice * item.Quantity);
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