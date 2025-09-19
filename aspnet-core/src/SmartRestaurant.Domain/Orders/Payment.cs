using System;
using Volo.Abp.Domain.Entities.Auditing;
using SmartRestaurant.Application.Contracts.Orders.Dto;

namespace SmartRestaurant.Orders;

/// <summary>
/// Entity Payment lưu thông tin chi tiết thanh toán
/// </summary>
public class Payment : FullAuditedEntity<Guid>
{
    /// <summary>ID đơn hàng được thanh toán</summary>
    public Guid OrderId { get; set; }
    
    /// <summary>Thời gian thanh toán</summary>
    public DateTime PaymentTime { get; set; }
    
    /// <summary>Tổng tiền thanh toán</summary>
    public int TotalAmount { get; set; }
    
    /// <summary>Tiền khách đưa</summary>
    public int CustomerMoney { get; set; }
    
    /// <summary>Phương thức thanh toán</summary>
    public PaymentMethod PaymentMethod { get; set; }
    
    /// <summary>Ghi chú thanh toán</summary>
    public string? Notes { get; set; }
    
    // Navigation properties
    /// <summary>Đơn hàng được thanh toán</summary>
    public virtual Order Order { get; set; } = null!;
    
    // Constructor
    protected Payment()
    {
        // For EF Core
    }
    
    public Payment(
        Guid id,
        Guid orderId,
        int totalAmount,
        int customerMoney,
        PaymentMethod paymentMethod,
        string? notes = null) : base(id)
    {
        OrderId = orderId;
        TotalAmount = totalAmount;
        CustomerMoney = customerMoney;
        PaymentMethod = paymentMethod;
        Notes = notes;
        PaymentTime = DateTime.Now;
    }
}