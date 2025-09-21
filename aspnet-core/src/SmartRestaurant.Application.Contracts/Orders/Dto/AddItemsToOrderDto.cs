using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SmartRestaurant.Application.Contracts.Orders.Dto;

/// <summary>
/// DTO cho việc gọi thêm món vào order hiện có
/// Được sử dụng khi khách hàng muốn order thêm món sau khi đã có order ban đầu
/// </summary>
public class AddItemsToOrderDto
{
    /// <summary>
    /// Danh sách món muốn thêm vào order
    /// Tối thiểu phải có 1 món
    /// </summary>
    [Required]
    [MinLength(1, ErrorMessage = "Phải có ít nhất 1 món để thêm vào order")]
    public List<CreateOrderItemDto> Items { get; set; } = new();

    /// <summary>
    /// Ghi chú chung cho lần gọi thêm này
    /// Ví dụ: "Khách yêu cầu thêm món sau khi ăn xong món đầu"
    /// </summary>
    [StringLength(500, ErrorMessage = "Ghi chú không được vượt quá 500 ký tự")]
    public string? AdditionalNotes { get; set; }
}