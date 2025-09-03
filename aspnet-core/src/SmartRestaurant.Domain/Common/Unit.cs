using System;
using Volo.Abp.Domain.Entities.Auditing;

namespace SmartRestaurant.Common;

/// <summary>
/// Entity đơn vị đo lường - được sử dụng chung cho toàn hệ thống
/// Ví dụ: kg, gram, lít, ml, cái, hộp, gói, thùng...
/// </summary>
public class Unit : FullAuditedEntity<Guid>
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
    public bool IsActive { get; set; } = true;

    /// <summary>
    /// Constructor mặc định cho EF Core
    /// </summary>
    protected Unit()
    {
    }

    /// <summary>
    /// Constructor với tham số
    /// </summary>
    /// <param name="id">ID của unit</param>
    /// <param name="name">Tên đơn vị</param>
    /// <param name="displayOrder">Thứ tự hiển thị</param>
    /// <param name="isActive">Trạng thái kích hoạt</param>
    public Unit(Guid id, string name, int displayOrder = 0, bool isActive = true) 
        : base(id)
    {
        Name = name;
        DisplayOrder = displayOrder;
        IsActive = isActive;
    }
}