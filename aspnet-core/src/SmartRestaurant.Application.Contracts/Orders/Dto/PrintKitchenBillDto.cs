using System;
using System.Collections.Generic;

namespace SmartRestaurant.Application.Contracts.Orders.Dto;

/// <summary>
/// DTO cho việc in bill bếp (chọn món cụ thể)
/// </summary>
public class PrintKitchenBillDto
{
    /// <summary>
    /// Danh sách ID các OrderItem cần in
    /// Nếu null hoặc empty thì in tất cả món trong đơn hàng
    /// </summary>
    public List<Guid>? SelectedOrderItemIds { get; set; }

    /// <summary>
    /// Ghi chú thêm cho bill bếp
    /// </summary>
    public string? Notes { get; set; }

    /// <summary>
    /// Loại in (Normal/Urgent/Reprint)
    /// </summary>
    public string PrintType { get; set; } = "Normal";
}