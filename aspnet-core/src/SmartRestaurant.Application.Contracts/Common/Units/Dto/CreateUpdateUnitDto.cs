using System.ComponentModel.DataAnnotations;

namespace SmartRestaurant.Common.Units.Dto;

/// <summary>
/// DTO cho Create/Update Unit operations
/// </summary>
public class CreateUpdateUnitDto
{
    /// <summary>
    /// Tên đơn vị (kg, gram, lít, cái, hộp...)
    /// </summary>
    [Required]
    [MaxLength(64)]
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// Thứ tự hiển thị trong danh sách
    /// </summary>
    [Range(0, int.MaxValue)]
    public int DisplayOrder { get; set; }

    /// <summary>
    /// Trạng thái kích hoạt
    /// </summary>
    public bool IsActive { get; set; } = true;
}