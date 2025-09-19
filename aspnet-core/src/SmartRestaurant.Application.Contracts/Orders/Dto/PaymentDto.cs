using System;
using System.Collections.Generic;
using Volo.Abp.Application.Dtos;
using SmartRestaurant.Orders;

namespace SmartRestaurant.Application.Contracts.Orders.Dto;

/// <summary>
/// DTO cho việc thanh toán hóa đơn
/// </summary>
public class PaymentRequestDto
{
    /// <summary>ID đơn hàng cần thanh toán</summary>
    public Guid OrderId { get; set; }
    
    /// <summary>Phương thức thanh toán</summary>
    public PaymentMethod PaymentMethod { get; set; }
    
    /// <summary>Tiền khách đưa (nếu thanh toán tiền mặt)</summary>
    public int? CustomerMoney { get; set; }
    
    /// <summary>Ghi chú thêm cho thanh toán</summary>
    public string? Notes { get; set; }
}

/// <summary>
/// DTO để lấy thông tin đơn hàng cho việc thanh toán
/// </summary>
public class OrderForPaymentDto
{
    /// <summary>ID đơn hàng</summary>
    public Guid Id { get; set; }
    
    /// <summary>Số đơn hàng</summary>
    public string OrderNumber { get; set; } = string.Empty;
    
    /// <summary>Loại đơn hàng</summary>
    public OrderType OrderType { get; set; }
    
    /// <summary>Trạng thái đơn hàng</summary>
    public OrderStatus Status { get; set; }
    
    /// <summary>Tổng tiền đơn hàng</summary>
    public int TotalAmount { get; set; }
    
    /// <summary>Ghi chú đơn hàng</summary>
    public string? Notes { get; set; }
    
    /// <summary>Thời gian tạo đơn</summary>
    public DateTime CreationTime { get; set; }
    
    /// <summary>Thông tin bàn (nếu có)</summary>
    public string? TableInfo { get; set; }
    
    /// <summary>Danh sách món ăn trong đơn</summary>
    public List<OrderItemDto> OrderItems { get; set; } = new();
}

/// <summary>
/// Enum phương thức thanh toán
/// </summary>
public enum PaymentMethod
{
    /// <summary>Tiền mặt</summary>
    Cash = 0,
    
    /// <summary>Chuyển khoản ngân hàng</summary>
    BankTransfer = 1,
    
    /// <summary>Nợ (trả sau)</summary>
    Credit = 2
}