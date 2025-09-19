using System;
using System.Collections.Generic;
using Volo.Abp.Application.Dtos;

namespace SmartRestaurant.Application.Contracts.Orders.Dto;

/// <summary>
/// DTO cho thông tin chi tiết bàn khi click vào từ danh sách
/// Bao gồm thông tin bàn và các đơn hàng đang hoạt động
/// </summary>
public class TableDetailsDto : EntityDto<Guid>
{
    /// <summary>Số bàn hiển thị (ví dụ: "B01", "B02", "VIP1")</summary>
    public string TableNumber { get; set; }
    
    /// <summary>Số thứ tự bàn trong khu vực</summary>
    public int DisplayOrder { get; set; }
    
    /// <summary>Trạng thái bàn hiện tại</summary>
    public TableStatus Status { get; set; }
    
    /// <summary>Trạng thái bàn dưới dạng chữ</summary>
    public string StatusDisplay { get; set; }
    
    /// <summary>ID khu vực mà bàn này thuộc về</summary>
    public Guid? LayoutSectionId { get; set; }
    
    /// <summary>Tên khu vực (được lấy từ LayoutSection)</summary>
    public string LayoutSectionName { get; set; }
    
    /// <summary>Có đơn hàng đang hoạt động hay không</summary>
    public bool HasActiveOrders { get; set; }
    
    /// <summary>Số lượng đơn hàng đang hoạt động</summary>
    public int ActiveOrdersCount { get; set; }
    
    /// <summary>Tổng số món trong tất cả đơn hàng đang hoạt động</summary>
    public int TotalOrderItemsCount { get; set; }
    
    /// <summary>Số món đang chờ được phục vụ</summary>
    public int PendingServeOrdersCount { get; set; }
    
    /// <summary>Danh sách các đơn hàng đang hoạt động của bàn</summary>
    public List<OrderSummaryDto> ActiveOrders { get; set; } = new();
    
    /// <summary>Tổng tiền của tất cả đơn hàng đang hoạt động</summary>
    public int TotalAmount { get; set; }
    
    /// <summary>Thời gian bàn bắt đầu được sử dụng (từ đơn hàng đầu tiên)</summary>
    public DateTime? FirstOrderTime { get; set; }
    
    /// <summary>Thời gian đơn hàng gần nhất</summary>
    public DateTime? LastOrderTime { get; set; }
}

