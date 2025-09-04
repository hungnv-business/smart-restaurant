using System;
using System.ComponentModel.DataAnnotations;
using SmartRestaurant.Common;
using Volo.Abp.Domain.Entities.Auditing;

namespace SmartRestaurant.InventoryManagement.Ingredients;

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
    /// Thứ tự hiển thị (để sắp xếp theo thứ tự người dùng thêm vào)
    /// </summary>
    [Required]
    public int DisplayOrder { get; set; }
    
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
        int displayOrder,
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
        DisplayOrder = displayOrder;
        PurchasePrice = purchasePrice;
        IsActive = isActive;
    }
    
    // === Business Methods cho Unit Conversion ===
    
    /// <summary>
    /// Chuyển đổi số lượng từ đơn vị mua hàng này sang đơn vị cơ sở
    /// </summary>
    /// <param name="quantity">Số lượng trong đơn vị mua hàng</param>
    /// <returns>Số lượng tương ứng trong đơn vị cơ sở</returns>
    public int ConvertToBaseUnit(int quantity)
    {
        if (quantity < 0)
        {
            throw new ArgumentException("Quantity cannot be negative", nameof(quantity));
        }
        
        return quantity * ConversionRatio;
    }
    
    /// <summary>
    /// Chuyển đổi số lượng từ đơn vị cơ sở sang đơn vị mua hàng này
    /// </summary>
    /// <param name="baseQuantity">Số lượng trong đơn vị cơ sở</param>
    /// <returns>Số lượng tương ứng trong đơn vị mua hàng (làm tròn xuống)</returns>
    public int ConvertFromBaseUnit(int baseQuantity)
    {
        if (baseQuantity < 0)
        {
            throw new ArgumentException("Base quantity cannot be negative", nameof(baseQuantity));
        }
        
        return baseQuantity / ConversionRatio; // Integer division - làm tròn xuống
    }
    
}