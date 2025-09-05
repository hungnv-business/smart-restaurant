using System;
using Volo.Abp.Application.Dtos;
using SmartRestaurant.Orders;

namespace SmartRestaurant.Application.Contracts.Orders.Dto;

/// <summary>
/// DTO cho việc lọc và tìm kiếm đơn hàng
/// Hỗ trợ các scenario khác nhau: bếp, nhân viên, quản lý
/// </summary>
public class GetOrderListDto : PagedAndSortedResultRequestDto
{
    /// <summary>
    /// ID bàn cụ thể (để lọc đơn hàng của 1 bàn)
    /// </summary>
    public Guid? TableId { get; set; }

    /// <summary>
    /// Trạng thái đơn hàng cần lọc
    /// </summary>
    public OrderStatus? Status { get; set; }

    /// <summary>
    /// Loại đơn hàng cần lọc
    /// </summary>
    public OrderType? OrderType { get; set; }

    /// <summary>
    /// Từ khóa tìm kiếm (số đơn hàng, tên bàn, ghi chú)
    /// </summary>
    public string? Filter { get; set; }

    /// <summary>
    /// Lọc theo ngày tạo (từ ngày)
    /// </summary>
    public DateTime? CreatedDateFrom { get; set; }

    /// <summary>
    /// Lọc theo ngày tạo (đến ngày)
    /// </summary>
    public DateTime? CreatedDateTo { get; set; }

    /// <summary>
    /// Chỉ lấy đơn hàng đang hoạt động (chưa thanh toán)
    /// </summary>
    public bool? ActiveOnly { get; set; }

    /// <summary>
    /// Lấy đơn hàng cho bếp (Confirmed và Preparing)
    /// </summary>
    public bool? KitchenOnly { get; set; }

    /// <summary>
    /// Có bao gồm OrderItems không (để tối ưu performance)
    /// </summary>
    public bool IncludeOrderItems { get; set; } = true;

    /// <summary>
    /// Constructor mặc định với sorting
    /// </summary>
    public GetOrderListDto()
    {
        // Mặc định sắp xếp theo thời gian tạo, mới nhất trước
        Sorting = "CreationTime DESC";
        MaxResultCount = 50; // Giới hạn mặc định cho performance
    }
}