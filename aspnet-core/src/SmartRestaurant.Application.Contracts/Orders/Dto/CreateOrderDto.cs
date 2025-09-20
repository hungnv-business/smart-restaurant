using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using SmartRestaurant.Orders;

namespace SmartRestaurant.Application.Contracts.Orders.Dto;

/// <summary>
/// DTO cho việc tạo đơn hàng mới
/// Validation theo yêu cầu business logic
/// </summary>
public class CreateOrderDto
{
    /// <summary>
    /// ID của bàn (bắt buộc cho DineIn, nullable cho Takeaway/Delivery)
    /// </summary>
    public Guid? TableId { get; set; }

    /// <summary>
    /// Loại đơn hàng - mặc định là ăn tại chỗ
    /// </summary>
    [Required]
    public OrderType OrderType { get; set; } = OrderType.DineIn;

    /// <summary>
    /// Ghi chú chung của khách hàng hoặc nhân viên
    /// </summary>
    [StringLength(500, ErrorMessage = "Ghi chú không được vượt quá 500 ký tự")]
    public string? Notes { get; set; }

    /// <summary>
    /// Tên khách hàng (bắt buộc cho Takeaway/Delivery)
    /// </summary>
    [StringLength(100, ErrorMessage = "Tên khách hàng không được vượt quá 100 ký tự")]
    public string? CustomerName { get; set; }

    /// <summary>
    /// Số điện thoại khách hàng (bắt buộc cho Takeaway/Delivery)
    /// </summary>
    [StringLength(20, ErrorMessage = "Số điện thoại không được vượt quá 20 ký tự")]
    public string? CustomerPhone { get; set; }

    /// <summary>
    /// Danh sách món được đặt (tối thiểu 1 món)
    /// </summary>
    [Required]
    [MinLength(1, ErrorMessage = "Đơn hàng phải có ít nhất một món")]
    public List<CreateOrderItemDto> OrderItems { get; set; } = new();

    /// <summary>
    /// Validate business rules
    /// </summary>
    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        // Validate DineIn requires table
        if (OrderType == OrderType.DineIn && !TableId.HasValue)
        {
            yield return new ValidationResult(
                "Đơn hàng ăn tại chỗ phải có bàn",
                new[] { nameof(TableId) });
        }

        // Validate Takeaway/Delivery requires customer info
        if ((OrderType == OrderType.Takeaway || OrderType == OrderType.Delivery))
        {
            if (string.IsNullOrWhiteSpace(CustomerName))
            {
                yield return new ValidationResult(
                    "Đơn hàng mang về/giao hàng phải có tên khách hàng",
                    new[] { nameof(CustomerName) });
            }

            if (string.IsNullOrWhiteSpace(CustomerPhone))
            {
                yield return new ValidationResult(
                    "Đơn hàng mang về/giao hàng phải có số điện thoại khách hàng",
                    new[] { nameof(CustomerPhone) });
            }
        }

        // Validate OrderItems not empty
        if (OrderItems == null || OrderItems.Count == 0)
        {
            yield return new ValidationResult(
                "Đơn hàng phải có ít nhất một món",
                new[] { nameof(OrderItems) });
        }

        // Validate each OrderItem
        for (int i = 0; i < OrderItems?.Count; i++)
        {
            var item = OrderItems[i];
            if (item.Quantity <= 0)
            {
                yield return new ValidationResult(
                    $"Số lượng món thứ {i + 1} phải lớn hơn 0",
                    new[] { $"{nameof(OrderItems)}[{i}].{nameof(CreateOrderItemDto.Quantity)}" });
            }

            if (item.UnitPrice < 0)
            {
                yield return new ValidationResult(
                    $"Giá món thứ {i + 1} không được âm",
                    new[] { $"{nameof(OrderItems)}[{i}].{nameof(CreateOrderItemDto.UnitPrice)}" });
            }
        }
    }
}