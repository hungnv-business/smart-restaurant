using System;
using SmartRestaurant.Orders;
using Volo.Abp.Application.Dtos;

namespace SmartRestaurant.Application.Contracts.Orders.Dto;

/// <summary>
/// DTO tóm tắt thông tin đơn hàng cho table details
/// </summary>
public class OrderSummaryDto : EntityDto<Guid>
{
    /// <summary>Số đơn hàng</summary>
    public string OrderNumber { get; set; }
    
    /// <summary>Trạng thái đơn hàng</summary>
    public OrderStatus Status { get; set; }
    
    /// <summary>Trạng thái đơn hàng dưới dạng chữ</summary>
    public string StatusDisplay { get; set; }
    
    /// <summary>Thời gian tạo đơn</summary>
    public DateTime CreationTime { get; set; }
    
    /// <summary>Số lượng món trong đơn</summary>
    public int ItemsCount { get; set; }
    
    /// <summary>Tổng tiền đơn hàng</summary>
    public int TotalAmount { get; set; }
    
    /// <summary>Ghi chú đơn hàng</summary>
    public string? Notes { get; set; }
}