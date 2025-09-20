using System;
using System.Collections.Generic;
using Volo.Abp.Application.Dtos;
using SmartRestaurant.TableManagement.Tables;

namespace SmartRestaurant.Application.Contracts.Orders.Dto;

/// <summary>
/// DTO tối ưu cho danh sách bàn trong màn hình DineIn mobile
/// Kế thừa từ ActiveTableDto nhưng thêm thông tin tối ưu cho mobile
/// </summary>
public class DineInTableDto : EntityDto<Guid>
{
    /// <summary>
    /// Số bàn hiển thị
    /// </summary>
    public string TableNumber { get; set; } = string.Empty;

    /// <summary>
    /// Thứ tự hiển thị trên UI
    /// </summary>
    public int DisplayOrder { get; set; }

    /// <summary>
    /// Trạng thái bàn (Available/Occupied/Reserved)
    /// </summary>
    public TableStatus Status { get; set; }

    /// <summary>
    /// Tên trạng thái hiển thị bằng tiếng Việt
    /// </summary>
    public string StatusDisplay { get; set; } = string.Empty;

    /// <summary>
    /// ID khu vực bàn
    /// </summary>
    public Guid LayoutSectionId { get; set; }

    /// <summary>
    /// Tên khu vực (VIP, Tầng 1, Tầng 2...)
    /// </summary>
    public string LayoutSectionName { get; set; } = string.Empty;

    /// <summary>
    /// Có đơn hàng đang hoạt động không
    /// </summary>
    public bool HasActiveOrders { get; set; }

    /// <summary>
    /// ID đơn hàng hiện tại (nếu có)
    /// </summary>
    public Guid? CurrentOrderId { get; set; }

    /// <summary>
    /// Số món chờ phục vụ
    /// </summary>
    public string PendingItemsDisplay { get; set; }

    /// <summary>
    /// Số món đã sẵn sàng (ready)
    /// </summary>
    public string ReadyItemsCountDisplay { get; set; }

    /// <summary>
    /// Thời gian tạo đơn hàng hiện tại
    /// </summary>
    public DateTime? OrderCreatedTime { get; set; }
}

/// <summary>
/// DTO cho filter danh sách bàn DineIn
/// </summary>
public class GetDineInTablesDto
{
    /// <summary>
    /// Lọc theo tên bàn (tìm kiếm gần đúng)
    /// </summary>
    public string? TableNameFilter { get; set; }

    /// <summary>
    /// Lọc theo trạng thái bàn
    /// </summary>
    public TableStatus? StatusFilter { get; set; }
}