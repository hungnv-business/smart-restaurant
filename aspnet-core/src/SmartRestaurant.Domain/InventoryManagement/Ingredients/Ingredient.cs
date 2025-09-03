using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using SmartRestaurant.Common;
using SmartRestaurant.InventoryManagement.IngredientCategories;
using SmartRestaurant.InventoryManagement.PurchaseInvoices;
using Volo.Abp.Domain.Entities.Auditing;

namespace SmartRestaurant.InventoryManagement.Ingredients;

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
    /// Có theo dõi và cập nhật kho hay không
    /// </summary>
    public bool IsStockTrackingEnabled { get; set; } = true;
    
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
    /// Danh sách các đơn vị mua hàng với tỷ lệ quy đổi
    /// </summary>
    public virtual ICollection<IngredientPurchaseUnit> PurchaseUnits { get; set; } = new List<IngredientPurchaseUnit>();

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
    
    // === Purchase Units Query Methods ===
    
    /// <summary>
    /// Kiểm tra đơn vị có trong danh sách purchase units không
    /// </summary>
    public bool IsInPurchaseUnits(Guid unitId)
    {
        return PurchaseUnits.Any(pu => pu.UnitId == unitId);
    }
    
    /// <summary>
    /// Lấy đơn vị cơ sở cho nguyên liệu
    /// </summary>
    public IngredientPurchaseUnit GetBaseUnit()
    {
        var baseUnit = PurchaseUnits.FirstOrDefault(pu => pu.IsBaseUnit && pu.IsActive);
        if (baseUnit == null)
        {
            throw new InvalidOperationException($"Ingredient {Name} does not have a base unit configured.");
        }
        return baseUnit;
    }
    
    // === Purchase Units Management Methods ===
    
    /// <summary>
    /// Thêm đơn vị mua hàng mới hoặc cập nhật nếu đã tồn tại
    /// </summary>
    public void AddPurchaseUnit(Guid unitId, int conversionRatio, bool isBaseUnit, decimal? purchasePrice = null, bool isActive = true)
    {
        if (IsInPurchaseUnits(unitId))
        {
            // Cập nhật đơn vị đã tồn tại
            UpdatePurchaseUnit(unitId, conversionRatio, isBaseUnit, purchasePrice, isActive);
            return;
        }
        
        // Validation: Chỉ cho phép 1 đơn vị cơ sở
        if (isBaseUnit && PurchaseUnits.Any(pu => pu.IsBaseUnit))
        {
            throw new InvalidOperationException($"Ingredient {Name} already has a base unit configured");
        }
        
        // Validation: Đơn vị cơ sở phải có tỷ lệ = 1
        if (isBaseUnit && conversionRatio != 1)
        {
            throw new InvalidOperationException("Base unit must have conversion ratio = 1");
        }
        
        // Thêm đơn vị mới
        var purchaseUnit = new IngredientPurchaseUnit(
            id: Guid.NewGuid(),
            ingredientId: Id,
            unitId: unitId,
            conversionRatio: conversionRatio,
            isBaseUnit: isBaseUnit,
            purchasePrice: purchasePrice
        );
        purchaseUnit.IsActive = isActive;
        
        PurchaseUnits.Add(purchaseUnit);
    }
    
    /// <summary>
    /// Thêm nhiều đơn vị mua hàng cùng lúc (gọi AddPurchaseUnit cho từng unit)
    /// </summary>
    public void AddPurchaseUnits(IEnumerable<(Guid unitId, int conversionRatio, bool isBaseUnit, decimal? purchasePrice, bool isActive)> units)
    {
        if (units == null)
        {
            return;
        }
        
        var unitsList = units.ToList();
        
        // Validation: Kiểm tra trùng unitId trong input
        var unitIds = unitsList.Select(u => u.unitId).ToList();
        var duplicateInInput = unitIds.GroupBy(id => id).Where(g => g.Count() > 1).Select(g => g.Key);
        if (duplicateInInput.Any())
        {
            throw new InvalidOperationException($"Duplicate units in input: {string.Join(", ", duplicateInInput)}");
        }
        
        // Validation: Kiểm tra nhiều đơn vị cơ sở trong input
        var newBaseUnits = unitsList.Where(u => u.isBaseUnit).ToList();
        if (newBaseUnits.Count > 1)
        {
            throw new InvalidOperationException("Cannot add multiple base units");
        }
        
        // Thêm từng đơn vị - AddPurchaseUnit sẽ handle logic thêm mới/update
        foreach (var (unitId, conversionRatio, isBaseUnit, purchasePrice, isActive) in unitsList)
        {
            AddPurchaseUnit(unitId, conversionRatio, isBaseUnit, purchasePrice, isActive);
        }
    }
    
    /// <summary>
    /// Cập nhật đơn vị mua hàng
    /// </summary>
    public void UpdatePurchaseUnit(Guid unitId, int conversionRatio, bool isBaseUnit, decimal? purchasePrice, bool isActive)
    {
        var purchaseUnit = PurchaseUnits.FirstOrDefault(pu => pu.UnitId == unitId);
        if (purchaseUnit == null)
        {
            throw new ArgumentException($"Purchase unit {unitId} not found for ingredient {Name}");
        }
        
        // Validation: Chỉ cho phép 1 đơn vị cơ sở
        if (isBaseUnit && PurchaseUnits.Any(pu => pu.IsBaseUnit && pu.UnitId != unitId))
        {
            throw new InvalidOperationException($"Ingredient {Name} already has a base unit configured");
        }
        
        // Validation: Đơn vị cơ sở phải có tỷ lệ = 1
        if (isBaseUnit && conversionRatio != 1)
        {
            throw new InvalidOperationException("Base unit must have conversion ratio = 1");
        }
        
        purchaseUnit.ConversionRatio = conversionRatio;
        purchaseUnit.IsBaseUnit = isBaseUnit;
        purchaseUnit.PurchasePrice = purchasePrice;
        purchaseUnit.IsActive = isActive;
    }
    
    /// <summary>
    /// Xóa đơn vị mua hàng
    /// </summary>
    public void RemovePurchaseUnit(Guid unitId)
    {
        var purchaseUnit = PurchaseUnits.FirstOrDefault(pu => pu.UnitId == unitId);
        if (purchaseUnit == null)
        {
            return;
        }
        
        // Không cho phép xóa đơn vị cơ sở
        if (purchaseUnit.IsBaseUnit)
        {
            throw new InvalidOperationException("Cannot remove base unit");
        }
        
        PurchaseUnits.Remove(purchaseUnit);
    }
    
    /// <summary>
    /// Xóa tất cả đơn vị mua hàng
    /// </summary>
    public void ClearPurchaseUnits()
    {
        PurchaseUnits.Clear();
    }
    
}