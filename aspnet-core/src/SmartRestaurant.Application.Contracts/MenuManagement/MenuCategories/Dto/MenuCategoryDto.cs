using System;
using Volo.Abp.Application.Dtos;

namespace SmartRestaurant.MenuManagement.MenuCategories.Dto;

/// <summary>
/// Đối tượng truyền dữ liệu cho danh mục món ăn với thông tin kiểm toán
/// </summary>
public class MenuCategoryDto : FullAuditedEntityDto<Guid>
{
    /// <summary>
    /// Tên danh mục món ăn (ví dụ: "Món khai vị", "Món chính", "Đồ uống")
    /// </summary>
    public string Name { get; set; } = string.Empty;
    
    /// <summary>
    /// Mô tả chi tiết của danh mục
    /// </summary>
    public string? Description { get; set; }
    
    /// <summary>
    /// Thứ tự hiển thị của danh mục trên menu (số nhỏ hơn hiển thị trước)
    /// </summary>
    public int DisplayOrder { get; set; }
    
    /// <summary>
    /// Danh mục có được kích hoạt hay không để kiểm soát theo mùa
    /// </summary>
    public bool IsEnabled { get; set; }
    
    /// <summary>
    /// URL hình ảnh đại diện cho danh mục
    /// </summary>
    public string? ImageUrl { get; set; }
    
}