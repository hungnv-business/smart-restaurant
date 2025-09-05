using System;
using System.ComponentModel.DataAnnotations;
using Volo.Abp.Domain.Entities.Auditing;
using SmartRestaurant.MenuManagement.MenuItems;

namespace SmartRestaurant.Orders;

/// <summary>
/// Entity OrderItem đại diện cho một món ăn trong đơn hàng
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
    [Range(0, double.MaxValue, ErrorMessage = "Giá phải lớn hơn hoặc bằng 0")]
    public decimal UnitPrice { get; set; }

    /// <summary>
    /// Ghi chú riêng cho món này (ví dụ: "Không cay", "Thêm hành")
    /// </summary>
    [StringLength(300)]
    public string? Notes { get; set; }

    /// <summary>
    /// Trạng thái chuẩn bị của món này
    /// </summary>
    public OrderItemStatus Status { get; set; } = OrderItemStatus.Pending;

    /// <summary>
    /// Thời gian bắt đầu chuẩn bị món này
    /// </summary>
    public DateTime? PreparationStartTime { get; set; }

    /// <summary>
    /// Thời gian hoàn thành chuẩn bị món này
    /// </summary>
    public DateTime? PreparationCompleteTime { get; set; }

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
        decimal unitPrice,
        string? notes = null) : base(id)
    {
        OrderId = orderId;
        MenuItemId = menuItemId;
        MenuItemName = menuItemName;
        Quantity = quantity;
        UnitPrice = unitPrice;
        Notes = notes;
        Status = OrderItemStatus.Pending;
    }

    /// <summary>
    /// Tính tổng tiền của item này
    /// </summary>
    public decimal GetTotalPrice()
    {
        return UnitPrice * Quantity;
    }

    /// <summary>
    /// Cập nhật trạng thái chuẩn bị của món
    /// </summary>
    /// <param name="newStatus">Trạng thái mới</param>
    public void UpdatePreparationStatus(OrderItemStatus newStatus)
    {
        Status = newStatus;
        var now = DateTime.UtcNow;

        switch (newStatus)
        {
            case OrderItemStatus.Preparing:
                PreparationStartTime = now;
                break;
            case OrderItemStatus.Ready:
                PreparationCompleteTime = now;
                break;
        }
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
}