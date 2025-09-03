using System;
using System.ComponentModel.DataAnnotations;
using SmartRestaurant.Entities.Common;
using Volo.Abp.Domain.Entities.Auditing;

namespace SmartRestaurant.Entities.InventoryManagement;

/// <summary>
/// Đơn vị mua hàng của nguyên liệu với tỷ lệ quy đổi về đơn vị cơ sở
/// </summary>
public class IngredientPurchaseUnit : FullAuditedEntity<Guid>
{
    /// <summary>
    /// ID nguyên liệu
    /// </summary>
    [Required]
    public Guid IngredientId { get; set; }
    
    /// <summary>
    /// ID đơn vị mua hàng
    /// </summary>
    [Required]
    public Guid UnitId { get; set; }
    
    /// <summary>
    /// Tỷ lệ quy đổi về đơn vị cơ sở (phải > 0)
    /// Ví dụ: 1 thùng = 24 lon → ConversionRatio = 24
    /// </summary>
    [Required]
    public int ConversionRatio { get; set; }
    
    /// <summary>
    /// Có phải là đơn vị cơ sở không (mỗi ingredient chỉ có 1 base unit)
    /// </summary>
    [Required]
    public bool IsBaseUnit { get; set; }
    
    /// <summary>
    /// Giá mua cho đơn vị này (có thể null nếu sử dụng giá cơ sở)
    /// </summary>
    public decimal? PurchasePrice { get; set; }
    
    /// <summary>
    /// Trạng thái kích hoạt
    /// </summary>
    [Required]
    public bool IsActive { get; set; } = true;
    
    // Navigation properties
    /// <summary>
    /// Nguyên liệu liên kết
    /// </summary>
    public virtual Ingredient Ingredient { get; set; } = null!;
    
    /// <summary>
    /// Đơn vị đo lường
    /// </summary>
    public virtual Unit Unit { get; set; } = null!;
    
    protected IngredientPurchaseUnit()
    {
    }
    
    public IngredientPurchaseUnit(
        Guid id,
        Guid ingredientId,
        Guid unitId,
        int conversionRatio,
        bool isBaseUnit,
        decimal? purchasePrice = null,
        bool isActive = true) : base(id)
    {
        if (conversionRatio <= 0)
        {
            throw new ArgumentException("Conversion ratio must be greater than 0", nameof(conversionRatio));
        }
        
        IngredientId = ingredientId;
        UnitId = unitId;
        ConversionRatio = conversionRatio;
        IsBaseUnit = isBaseUnit;
        PurchasePrice = purchasePrice;
        IsActive = isActive;
    }
    
}