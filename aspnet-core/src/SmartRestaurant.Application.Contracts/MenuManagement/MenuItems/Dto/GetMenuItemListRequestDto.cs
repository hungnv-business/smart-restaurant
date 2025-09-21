using System;
using Volo.Abp.Application.Dtos;

namespace SmartRestaurant.MenuManagement.MenuItems.Dto;

public class GetMenuItemListRequestDto : PagedAndSortedResultRequestDto
{
    /// <summary>
    /// Tìm kiếm theo tên hoặc mô tả món ăn
    /// </summary>
    public string? Filter { get; set; }

    /// <summary>
    /// Lọc theo ID danh mục menu (null = tất cả danh mục)
    /// </summary>
    public Guid? CategoryId { get; set; }

    /// <summary>
    /// Chỉ lấy món ăn có sẵn (mặc định: false - lấy tất cả)
    /// </summary>
    public bool OnlyAvailable { get; set; } = false;
}