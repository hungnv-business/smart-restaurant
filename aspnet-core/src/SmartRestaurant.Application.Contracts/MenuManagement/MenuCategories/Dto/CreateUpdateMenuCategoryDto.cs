using System.ComponentModel.DataAnnotations;
using SmartRestaurant.MenuManagement;

namespace SmartRestaurant.MenuManagement.MenuCategories.Dto;

/// <summary>
/// Đối tượng truyền dữ liệu để tạo hoặc cập nhật danh mục món ăn
/// </summary>
public class CreateUpdateMenuCategoryDto
{
    /// <summary>
    /// Tên danh mục món ăn (bắt buộc, tối đa 128 ký tự)
    /// </summary>
    [Required]
    [StringLength(MenuCategoryConsts.MaxNameLength)]
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// Mô tả chi tiết của danh mục (không bắt buộc, tối đa 512 ký tự)
    /// </summary>
    [StringLength(MenuCategoryConsts.MaxDescriptionLength)]
    public string? Description { get; set; }

    /// <summary>
    /// Thứ tự hiển thị của danh mục trên menu (0 = tự động gán thứ tự tiếp theo)
    /// </summary>
    public int DisplayOrder { get; set; }

    /// <summary>
    /// Danh mục có được kích hoạt để kiểm soát theo mùa hay không (mặc định: true)
    /// </summary>
    public bool IsEnabled { get; set; } = true;

    /// <summary>
    /// URL hình ảnh đại diện cho danh mục (không bắt buộc, tối đa 2048 ký tự)
    /// </summary>
    [StringLength(MenuCategoryConsts.MaxImageUrlLength)]
    public string? ImageUrl { get; set; }

}