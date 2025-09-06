using System;

namespace SmartRestaurant.Application.Contracts.Orders.Dto;

/// <summary>
/// DTO để lấy danh sách món ăn khi tạo đơn hàng với các bộ lọc
/// </summary>
public class GetMenuItemsForOrderDto
{
    /// <summary>
    /// Tìm kiếm theo tên món ăn (tìm kiếm gần đúng)
    /// </summary>
    public string? NameFilter { get; set; }

    /// <summary>
    /// Lọc theo ID danh mục món ăn
    /// </summary>
    public Guid? CategoryId { get; set; }

    /// <summary>
    /// Chỉ lấy những món đang available (mặc định là true)
    /// </summary>
    public bool? OnlyAvailable { get; set; } = true;

}