using System;
using System.ComponentModel.DataAnnotations;
using SmartRestaurant.Entities.Common;
using SmartRestaurant.Exceptions;
using Volo.Abp.Domain.Entities.Auditing;

namespace SmartRestaurant.Entities.InventoryManagement;

/// <summary>
/// Nguyên liệu cụ thể trong danh mục
/// </summary>
public class Ingredient : FullAuditedEntity<Guid>
{
    /// <summary>
    /// ID danh mục nguyên liệu
    /// </summary>
    [Required]
    public Guid CategoryId { get; set; }
    
    /// <summary>
    /// Tên nguyên liệu (ví dụ: "Cà chua", "Thịt bò", "Hành tây")
    /// </summary>
    [Required]
    [MaxLength(128)]
    public string Name { get; set; } = string.Empty;
    
    /// <summary>
    /// Mô tả chi tiết về nguyên liệu
    /// </summary>
    [MaxLength(512)]
    public string? Description { get; set; }
    
    /// <summary>
    /// ID đơn vị đo lường
    /// </summary>
    [Required]
    public Guid UnitId { get; set; }
    
    /// <summary>
    /// Giá thành trên đơn vị (VND) - có thể null khi chưa có giá
    /// </summary>
    public decimal? CostPerUnit { get; set; }
    
    /// <summary>
    /// Thông tin nhà cung cấp (JSON hoặc simple string)
    /// </summary>
    [MaxLength(512)]
    public string? SupplierInfo { get; set; }
    
    /// <summary>
    /// Số lượng hiện tại trong kho - không cho phép set trực tiếp
    /// </summary>
    [Required]
    public int CurrentStock { get; private set; } = 0;
    
    /// <summary>
    /// Nguyên liệu có đang sử dụng hay không
    /// </summary>
    public bool IsActive { get; set; } = true;
    
    // Navigation properties
    /// <summary>
    /// Danh mục chứa nguyên liệu này
    /// </summary>
    public virtual IngredientCategory Category { get; set; } = null!;

    /// <summary>
    /// Đơn vị đo lường của nguyên liệu
    /// </summary>
    public virtual Unit Unit { get; set; } = null!;

    /// <summary>
    /// Cộng thêm vào kho
    /// </summary>
    public void AddStock(int quantity)
    {
        if (quantity <= 0)
        {
            throw new InvalidQuantityException(quantity);
        }

        CurrentStock += quantity;
    }

    /// <summary>
    /// Trừ khỏi kho
    /// </summary>
    public void SubtractStock(int quantity)
    {
        if (quantity <= 0)
        {
            throw new InvalidQuantityException(quantity);
        }

        if (!CanSubtractStock(quantity))
        {
            throw new InsufficientStockException(Name, CurrentStock, quantity);
        }

        CurrentStock -= quantity;
    }

    /// <summary>
    /// Kiểm tra có thể trừ stock không
    /// </summary>
    public bool CanSubtractStock(int quantity)
    {
        return CurrentStock >= quantity;
    }

    /// <summary>
    /// Set stock trực tiếp (chỉ dùng cho migration/seed data)
    /// </summary>
    public void SetStock(int stock)
    {
        if (stock < 0)
        {
            throw new InvalidQuantityException(stock);
        }

        CurrentStock = stock;
    }
}