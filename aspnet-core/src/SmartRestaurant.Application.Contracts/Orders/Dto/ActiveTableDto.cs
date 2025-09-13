using System;
using Volo.Abp.Application.Dtos;

namespace SmartRestaurant.Application.Contracts.Orders.Dto;

/// <summary>
/// DTO cho bàn active trong danh sách bàn (đơn giản để hiển thị danh sách)
/// </summary>
public class ActiveTableDto : EntityDto<Guid>
{
    /// <summary>Số bàn hiển thị (ví dụ: "B06")</summary>
    public string TableNumber { get; set; }
    
    /// <summary>Số thứ tự bàn trong khu vực</summary>
    public int DisplayOrder { get; set; }
    
    /// <summary>Trạng thái bàn hiện tại</summary>
    public SmartRestaurant.TableStatus Status { get; set; }
    
    /// <summary>Trạng thái bàn dưới dạng chữ</summary>
    public string StatusDisplay { get; set; }
    
    /// <summary>ID khu vực mà bàn này thuộc về</summary>
    public Guid? LayoutSectionId { get; set; }
    
    /// <summary>Tên khu vực (được lấy từ LayoutSection)</summary>
    public string LayoutSectionName { get; set; }
    
    /// <summary>Có đơn hàng đang hoạt động hay không</summary>
    public bool HasActiveOrders { get; set; }
    
    /// <summary>Trạng thái đơn hàng đơn giản cho hiển thị (Có đơn hàng, Món chờ phục vụ)</summary>
    public string OrderStatusDisplay { get; set; }
    
    /// <summary>Số món đang chờ phục vụ</summary>
    public int PendingItemsCount { get; set; }
}