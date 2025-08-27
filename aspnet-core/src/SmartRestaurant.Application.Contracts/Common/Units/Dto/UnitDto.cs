using System;
using Volo.Abp.Application.Dtos;

namespace SmartRestaurant.Common.Units.Dto;

/// <summary>
/// DTO cho Unit - dùng cho output
/// </summary>
public class UnitDto : FullAuditedEntityDto<Guid>
{
    /// <summary>
    /// Tên đơn vị (kg, gram, lít, cái, hộp...)
    /// </summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// Thứ tự hiển thị trong danh sách
    /// </summary>
    public int DisplayOrder { get; set; }

    /// <summary>
    /// Trạng thái kích hoạt
    /// </summary>
    public bool IsActive { get; set; }
}