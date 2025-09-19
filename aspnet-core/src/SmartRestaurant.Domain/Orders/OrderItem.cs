using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using Volo.Abp.Domain.Entities.Auditing;
using SmartRestaurant.MenuManagement.MenuItems;

namespace SmartRestaurant.Orders;

/// <summary>
/// Entity OrderItem đại diện cho một món ăn trong đơn hàng
/// 
/// DOMAIN EVENTS NOTE:
/// - Hiện tại không sử dụng domain events để giữ code đơn giản
/// - Khi cần real-time features (kitchen dashboard, notifications), 
///   có thể thêm domain events vào các methods: StartPreparation(), MarkAsReady(), MarkAsServed()
/// - Events sẽ handle: SignalR notifications, analytics logging, auto-printing
/// </summary>
public class OrderItem : FullAuditedEntity<Guid>
{
    /// <summary>
    /// ID của đơn hàng chứa món này
    /// </summary>
    [Required]
    public Guid OrderId { get; set; }

    /// <summary>
    /// ID của món ăn từ menu
    /// </summary>
    [Required]
    public Guid MenuItemId { get; set; }

    /// <summary>
    /// Tên món ăn (lưu để tránh mất thông tin khi menu thay đổi)
    /// </summary>
    [Required]
    [StringLength(200)]
    public string MenuItemName { get; set; } = string.Empty;

    /// <summary>
    /// Số lượng món được đặt
    /// </summary>
    [Range(1, int.MaxValue, ErrorMessage = "Số lượng phải lớn hơn 0")]
    public int Quantity { get; set; } = 1;

    /// <summary>
    /// Giá đơn vị của món (VND) tại thời điểm đặt hàng
    /// </summary>
    [Range(0, int.MaxValue, ErrorMessage = "Giá phải lớn hơn hoặc bằng 0")]
    public int UnitPrice { get; set; }

    /// <summary>
    /// Ghi chú riêng cho món này (ví dụ: "Không cay", "Thêm hành")
    /// </summary>
    [StringLength(300)]
    public string? Notes { get; set; }

    /// <summary>
    /// Trạng thái chuẩn bị của món này
    /// </summary>
    public OrderItemStatus Status { get; private set; } = OrderItemStatus.Pending;

    /// <summary>
    /// Thời gian xác nhận đơn hàng (Pending)
    /// </summary>
    public DateTime? PendingTime { get; private set; }

    /// <summary>
    /// Thời gian bắt đầu chuẩn bị món này (Preparing)
    /// </summary>
    public DateTime? PreparationStartTime { get; private set; }

    /// <summary>
    /// Thời gian hoàn thành chuẩn bị món này (Ready)
    /// </summary>
    public DateTime? PreparationCompleteTime { get; private set; }

    /// <summary>
    /// Thời gian phục vụ món này (Served)
    /// </summary>
    public DateTime? ServedTime { get; private set; }

    /// <summary>
    /// Thời gian hủy món này (Canceled)
    /// </summary>
    public DateTime? CanceledTime { get; private set; }

    // Navigation Properties

    /// <summary>
    /// Đơn hàng chứa món này
    /// </summary>
    public virtual Order Order { get; set; } = null!;

    /// <summary>
    /// Thông tin món ăn từ menu
    /// </summary>
    public virtual MenuItem MenuItem { get; set; } = null!;

    // Constructor
    protected OrderItem()
    {
        // Parameterless constructor for EF Core
    }

    public OrderItem(
        Guid id,
        Guid orderId,
        Guid menuItemId,
        string menuItemName,
        int quantity,
        int unitPrice,
        string? notes = null) : base(id)
    {
        // Validate input parameters
        if (string.IsNullOrWhiteSpace(menuItemName))
        {
            throw OrderValidationException.MenuItemNameRequired();
        }

        if (quantity <= 0)
        {
            throw OrderValidationException.InvalidQuantity();
        }

        if (unitPrice < 0)
        {
            throw OrderValidationException.InvalidPrice();
        }

        OrderId = orderId;
        MenuItemId = menuItemId;
        MenuItemName = menuItemName.Trim();
        Quantity = quantity;
        UnitPrice = unitPrice;
        Notes = notes?.Trim();
        Status = OrderItemStatus.Pending;
        PendingTime = DateTime.UtcNow;
    }

    /// <summary>
    /// Tính tổng tiền của item này
    /// </summary>
    public int GetTotalPrice()
    {
        return UnitPrice * Quantity;
    }

    /// <summary>
    /// Bắt đầu chuẩn bị món (Pending → Preparing)
    /// </summary>
    public void StartPreparation()
    {
        if (!IsPending())
        {
            throw OrderItemValidationException.CannotStartPreparationNonPendingItem();
        }

        Status = OrderItemStatus.Preparing;
        PreparationStartTime = DateTime.UtcNow;
        
        // TODO: Thêm domain event khi cần real-time kitchen dashboard
        // AddLocalEvent(new OrderItemPreparationStartedEvent(Id, OrderId, MenuItemName));
    }

    /// <summary>
    /// Đánh dấu món đã hoàn thành (Preparing → Ready)
    /// </summary>
    public void MarkAsReady()
    {
        if (!IsPreparing())
        {
            throw OrderItemValidationException.CannotMarkReadyNonPreparingItem();
        }

        Status = OrderItemStatus.Ready;
        PreparationCompleteTime = DateTime.UtcNow;
        
        // TODO: Thêm domain event khi cần real-time notifications cho nhân viên phục vụ
        // AddLocalEvent(new OrderItemReadyEvent(Id, OrderId, MenuItemName));
    }

    /// <summary>
    /// Đánh dấu món đã được phục vụ (Ready → Served)  
    /// </summary>
    public void MarkAsServed()
    {
        if (!IsReady())
        {
            throw OrderItemValidationException.CannotServeNonReadyItem();
        }

        Status = OrderItemStatus.Served;
        ServedTime = DateTime.UtcNow;
        
        // TODO: Thêm domain event khi cần analytics và tracking
        // AddLocalEvent(new OrderItemServedEvent(Id, OrderId, MenuItemName));
    }

    /// <summary>
    /// Kiểm tra món ăn có đang ở trạng thái chờ xử lý không
    /// </summary>
    public bool IsPending() => Status == OrderItemStatus.Pending;

    /// <summary>
    /// Kiểm tra món ăn có đang được chuẩn bị không
    /// </summary>
    public bool IsPreparing() => Status == OrderItemStatus.Preparing;

    /// <summary>
    /// Kiểm tra món ăn có đã sẵn sàng phục vụ không
    /// </summary>
    public bool IsReady() => Status == OrderItemStatus.Ready;

    /// <summary>
    /// Kiểm tra món ăn có đã được phục vụ không
    /// </summary>
    public bool IsServed() => Status == OrderItemStatus.Served;

    /// <summary>
    /// Kiểm tra món ăn có bị hủy không
    /// </summary>
    public bool IsCanceled() => Status == OrderItemStatus.Canceled;

    /// <summary>
    /// Kiểm tra có thể chuyển sang trạng thái mới không
    /// </summary>
    public bool CanTransitionTo(OrderItemStatus newStatus)
    {
        return Status switch
        {
            OrderItemStatus.Pending => newStatus == OrderItemStatus.Preparing || newStatus == OrderItemStatus.Canceled,
            OrderItemStatus.Preparing => newStatus == OrderItemStatus.Ready,
            OrderItemStatus.Ready => newStatus == OrderItemStatus.Served,
            OrderItemStatus.Served => false,
            OrderItemStatus.Canceled => false,
            _ => false
        };
    }

    /// <summary>
    /// Tính thời gian chuẩn bị món (phút)
    /// </summary>
    public int? GetPreparationTimeInMinutes()
    {
        if (PreparationStartTime.HasValue && PreparationCompleteTime.HasValue)
        {
            return (int)(PreparationCompleteTime.Value - PreparationStartTime.Value).TotalMinutes;
        }
        return null;
    }

    /// <summary>
    /// Lấy thời gian audit cho trạng thái hiện tại
    /// </summary>
    public DateTime? GetCurrentStatusTimestamp()
    {
        return Status switch
        {
            OrderItemStatus.Pending => PendingTime,
            OrderItemStatus.Preparing => PreparationStartTime,
            OrderItemStatus.Ready => PreparationCompleteTime,
            OrderItemStatus.Served => ServedTime,
            OrderItemStatus.Canceled => CanceledTime,
            _ => null
        };
    }

    /// <summary>
    /// Tính tổng thời gian từ pending đến trạng thái hiện tại (phút)
    /// </summary>
    public int? GetTotalProcessingTimeInMinutes()
    {
        var currentTime = GetCurrentStatusTimestamp();
        if (PendingTime.HasValue && currentTime.HasValue)
        {
            return (int)(currentTime.Value - PendingTime.Value).TotalMinutes;
        }
        return null;
    }

    /// <summary>
    /// Tính thời gian chờ từ khi ready đến khi served (phút)
    /// </summary>
    public int? GetWaitingTimeInMinutes()
    {
        if (PreparationCompleteTime.HasValue && ServedTime.HasValue)
        {
            return (int)(ServedTime.Value - PreparationCompleteTime.Value).TotalMinutes;
        }
        return null;
    }

    /// <summary>
    /// Lấy tất cả timestamps audit theo thứ tự thời gian
    /// </summary>
    public Dictionary<OrderItemStatus, DateTime?> GetAuditTimestamps()
    {
        return new Dictionary<OrderItemStatus, DateTime?>
        {
            { OrderItemStatus.Pending, PendingTime },
            { OrderItemStatus.Preparing, PreparationStartTime },
            { OrderItemStatus.Ready, PreparationCompleteTime },
            { OrderItemStatus.Served, ServedTime },
            { OrderItemStatus.Canceled, CanceledTime }
        };
    }

    /// <summary>
    /// Cập nhật số lượng món (chỉ khi đơn hàng chưa được xác nhận)
    /// </summary>
    /// <param name="newQuantity">Số lượng mới</param>
    public void UpdateQuantity(int newQuantity)
    {
        if (newQuantity <= 0)
        {
            throw new ArgumentException("Số lượng phải lớn hơn 0", nameof(newQuantity));
        }

        Quantity = newQuantity;
    }

    /// <summary>
    /// Cập nhật ghi chú cho món
    /// </summary>
    /// <param name="notes">Ghi chú mới</param>
    public void UpdateNotes(string? notes)
    {
        Notes = notes?.Trim();
    }

    /// <summary>
    /// Hủy món ăn (chỉ cho phép hủy khi chưa bắt đầu chuẩn bị)
    /// </summary>
    public void Cancel()
    {
        if (!IsPending())
        {
            throw OrderItemValidationException.CannotCancelNonPendingItem(Status);
        }

        Status = OrderItemStatus.Canceled;
        CanceledTime = DateTime.UtcNow;
        
        // TODO: Thêm domain event khi cần thông báo hủy món
        // AddLocalEvent(new OrderItemCancelledEvent(Id, OrderId, MenuItemName));
    }

}