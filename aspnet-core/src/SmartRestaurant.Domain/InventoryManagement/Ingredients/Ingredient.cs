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
    /// Kiểm tra đơn vị có trong danh sách purchase units không (theo ID)
    /// </summary>
    public bool IsInPurchaseUnits(Guid id)
    {
        return PurchaseUnits.Any(pu => pu.Id == id);
    }
    
    /// <summary>
    /// Lấy đơn vị cơ sở cho nguyên liệu
    /// </summary>
    public IngredientPurchaseUnit GetBaseUnit()
    {
        var baseUnit = PurchaseUnits.FirstOrDefault(pu => pu.IsBaseUnit && pu.IsActive);
        if (baseUnit == null)
        {
            throw new BaseUnitNotConfiguredException(Name);
        }
        return baseUnit;
    }
    
    // === Purchase Units Management Methods ===
    
    /// <summary>
    /// Thêm đơn vị mua hàng mới hoặc cập nhật nếu đã tồn tại
    /// </summary>
    public void AddPurchaseUnit(Guid id, Guid unitId, string unitName, int conversionRatio, bool isBaseUnit, decimal? purchasePrice = null, int displayOrder = 1, bool isActive = true)
    {
        // Validation: Đơn vị cơ sở phải có tỷ lệ = 1
        if (isBaseUnit && conversionRatio != 1)
        {
            throw new InvalidBaseUnitConversionException(conversionRatio);
        }
        
        if (IsInPurchaseUnits(id))
        {
            // Validation cho update: Không cho phép trùng UnitId (trừ chính nó)
            if (PurchaseUnits.Any(pu => pu.UnitId == unitId && pu.Id != id))
            {
                throw new DuplicateUnitException(Name, unitName);
            }
            
            // Validation cho update: Chỉ cho phép 1 đơn vị cơ sở (trừ chính nó)
            if (isBaseUnit && PurchaseUnits.Any(pu => pu.IsBaseUnit && pu.Id != id))
            {
                throw new MultipleBaseUnitException(Name);
            }
            
            // Cập nhật đơn vị đã tồn tại
            UpdatePurchaseUnit(id, unitId, unitName, conversionRatio, isBaseUnit, purchasePrice, displayOrder, isActive);
            return;
        }
        
        // Validation cho create: Không cho phép trùng UnitId
        if (PurchaseUnits.Any(pu => pu.UnitId == unitId))
        {
            throw new DuplicateUnitException(Name, unitName);
        }
        
        // Validation cho create: Chỉ cho phép 1 đơn vị cơ sở
        if (isBaseUnit && PurchaseUnits.Any(pu => pu.IsBaseUnit))
        {
            throw new MultipleBaseUnitException(Name);
        }
        
        // Thêm đơn vị mới
        var purchaseUnit = new IngredientPurchaseUnit(
            id: id,
            ingredientId: Id,
            unitId: unitId,
            conversionRatio: conversionRatio,
            isBaseUnit: isBaseUnit,
            displayOrder: displayOrder,
            purchasePrice: purchasePrice
        );
        purchaseUnit.IsActive = isActive;
        
        PurchaseUnits.Add(purchaseUnit);
    }
    
    /// <summary>
    /// Thêm nhiều đơn vị mua hàng cùng lúc (gọi AddPurchaseUnit cho từng unit)
    /// </summary>
    public void AddPurchaseUnits(IEnumerable<(Guid id, Guid unitId, string unitName, int conversionRatio, bool isBaseUnit, decimal? purchasePrice, bool isActive)> units)
    {
        if (units == null)
        {
            return;
        }
        
        var unitsList = units.ToList();
        
        // Thêm từng đơn vị - AddPurchaseUnit sẽ handle tất cả validation
        var index = 1;
        foreach (var (id, unitId, unitName, conversionRatio, isBaseUnit, purchasePrice, isActive) in unitsList)
        {
            AddPurchaseUnit(id, unitId, unitName, conversionRatio, isBaseUnit, purchasePrice, index, isActive);
            index++;
        }
    }
    
    /// <summary>
    /// Cập nhật đơn vị mua hàng
    /// </summary>
    public void UpdatePurchaseUnit(Guid id, Guid unitId, string unitName, int conversionRatio, bool isBaseUnit, decimal? purchasePrice, int displayOrder = 1, bool isActive = true)
    {
        var purchaseUnit = PurchaseUnits.FirstOrDefault(pu => pu.Id == id);
        if (purchaseUnit == null)
        {
            throw new ArgumentException($"Purchase unit {id} not found for ingredient {Name}");
        }
        
        // Cập nhật thông tin (validation đã được xử lý ở AddPurchaseUnit)
        purchaseUnit.UnitId = unitId;
        purchaseUnit.ConversionRatio = conversionRatio;
        purchaseUnit.IsBaseUnit = isBaseUnit;
        purchaseUnit.PurchasePrice = purchasePrice;
        purchaseUnit.DisplayOrder = displayOrder;
        purchaseUnit.IsActive = isActive;
    }
    
    /// <summary>
    /// Xóa đơn vị mua hàng
    /// </summary>
    public void RemovePurchaseUnit(Guid unitId, string unitName)
    {
        var purchaseUnit = PurchaseUnits.FirstOrDefault(pu => pu.UnitId == unitId);
        if (purchaseUnit == null)
        {
            return;
        }
        
        // Không cho phép xóa đơn vị cơ sở
        if (purchaseUnit.IsBaseUnit)
        {
            throw new CannotRemoveBaseUnitException(unitName, Name);
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
    
    /// <summary>
    /// Constructor mặc định cho EF Core và data seeding
    /// </summary>
    public Ingredient()
    {
    }

    /// <summary>
    /// Constructor với tham số để tạo nguyên liệu mới
    /// </summary>
    /// <param name="id">ID duy nhất của nguyên liệu</param>
    /// <param name="categoryId">ID danh mục nguyên liệu</param>
    /// <param name="name">Tên nguyên liệu</param>
    /// <param name="unitId">ID đơn vị đo lường cơ sở</param>
    /// <param name="description">Mô tả nguyên liệu</param>
    /// <param name="costPerUnit">Giá thành trên đơn vị</param>
    /// <param name="supplierInfo">Thông tin nhà cung cấp</param>
    /// <param name="isStockTrackingEnabled">Có theo dõi kho hay không</param>
    /// <param name="isActive">Trạng thái hoạt động</param>
    public Ingredient(
        Guid id,
        Guid categoryId,
        string name,
        Guid unitId,
        string? description = null,
        decimal? costPerUnit = null,
        string? supplierInfo = null,
        bool isStockTrackingEnabled = true,
        bool isActive = true
    ) : base(id)
    {
        CategoryId = categoryId;
        Name = name;
        UnitId = unitId;
        Description = description;
        CostPerUnit = costPerUnit;
        SupplierInfo = supplierInfo;
        IsStockTrackingEnabled = isStockTrackingEnabled;
        IsActive = isActive;
        CurrentStock = 0; // Bắt đầu với stock = 0
    }
    
}