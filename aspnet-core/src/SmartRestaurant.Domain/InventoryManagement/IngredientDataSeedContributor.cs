using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using SmartRestaurant.Entities.InventoryManagement;
using SmartRestaurant.Entities.Common;
using Volo.Abp.Data;
using Volo.Abp.DependencyInjection;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.InventoryManagement;

/// <summary>
/// Seed dữ liệu mẫu cho các nguyên liệu trong từng danh mục
/// Chạy sau UnitDataSeedContributor và IngredientCategoryDataSeedContributor
/// </summary>
public class IngredientDataSeedContributor : IDataSeedContributor, ITransientDependency
{
    private readonly IRepository<Ingredient, Guid> _ingredientRepository;
    private readonly IRepository<IngredientCategory, Guid> _categoryRepository;
    private readonly IRepository<Unit, Guid> _unitRepository;
    private readonly IRepository<IngredientPurchaseUnit, Guid> _purchaseUnitRepository;

    public IngredientDataSeedContributor(
        IRepository<Ingredient, Guid> ingredientRepository,
        IRepository<IngredientCategory, Guid> categoryRepository,
        IRepository<Unit, Guid> unitRepository,
        IRepository<IngredientPurchaseUnit, Guid> purchaseUnitRepository)
    {
        _ingredientRepository = ingredientRepository;
        _categoryRepository = categoryRepository;
        _unitRepository = unitRepository;
        _purchaseUnitRepository = purchaseUnitRepository;
    }

    public async Task SeedAsync(DataSeedContext context)
    {
        // Kiểm tra đã có dữ liệu chưa
        if (await _ingredientRepository.GetCountAsync() > 0)
        {
            return;
        }

        // Lấy categories và units
        var categories = await _categoryRepository.GetListAsync();
        var units = await _unitRepository.GetListAsync();
        
        if (!categories.Any() || !units.Any())
        {
            return; // Chờ seed categories và units trước
        }

        // Tìm categories theo tên
        var rauCuCategory = categories.FirstOrDefault(x => x.Name == "Rau củ");
        var thitCaCategory = categories.FirstOrDefault(x => x.Name == "Thịt cá");
        var doUongCategory = categories.FirstOrDefault(x => x.Name == "Đồ uống");

        // Tìm units theo tên
        var kgUnit = units.FirstOrDefault(x => x.Name == "kg");
        var lonUnit = units.FirstOrDefault(x => x.Name == "lon");
        var mlUnit = units.FirstOrDefault(x => x.Name == "ml");
        var thungUnit = units.FirstOrDefault(x => x.Name == "thùng");
        var locUnit = units.FirstOrDefault(x => x.Name == "lốc");

        // Kiểm tra có đủ dữ liệu không
        if (rauCuCategory == null || thitCaCategory == null || doUongCategory == null ||
            kgUnit == null || lonUnit == null || mlUnit == null || thungUnit == null || locUnit == null)
        {
            return; // Thiếu dữ liệu cần thiết
        }

        // Create sample ingredients với multi-unit support
        var ingredients = new[]
        {
            // Rau củ - simple single unit
            new Ingredient { CategoryId = rauCuCategory.Id, Name = "Cà chua", Description = "Cà chua tươi", 
                UnitId = kgUnit.Id, CostPerUnit = 25000m, SupplierInfo = "Chợ Bến Thành", IsActive = true },
            
            // Thịt cá - simple single unit  
            new Ingredient { CategoryId = thitCaCategory.Id, Name = "Thịt bò", Description = "Thịt bò tươi", 
                UnitId = kgUnit.Id, CostPerUnit = 300000m, SupplierInfo = "Lò mổ Sài Gòn", IsActive = true },
            
            // Đồ uống - multi-unit examples
            new Ingredient { CategoryId = doUongCategory.Id, Name = "Coca Cola", Description = "Coca Cola 330ml", 
                UnitId = lonUnit.Id, CostPerUnit = 15000m, SupplierInfo = "Đại lý Coca", IsActive = true },
                
            new Ingredient { CategoryId = doUongCategory.Id, Name = "Bia Saigon", Description = "Bia Saigon 330ml", 
                UnitId = mlUnit.Id, CostPerUnit = 18000m, SupplierInfo = "Đại lý bia", IsActive = true }
        };

        await _ingredientRepository.InsertManyAsync(ingredients, autoSave: true);
        
        // Create purchase units for multi-unit ingredients
        var purchaseUnits = new List<IngredientPurchaseUnit>();
        
        var cocaColaIngredient = ingredients.FirstOrDefault(i => i.Name == "Coca Cola");
        var biaIngredient = ingredients.FirstOrDefault(i => i.Name == "Bia Saigon");
        
        if (cocaColaIngredient != null)
        {
            purchaseUnits.AddRange(new[]
            {
                new IngredientPurchaseUnit(Guid.NewGuid(), cocaColaIngredient.Id, lonUnit.Id, 1, true, 12000m, true),     // Base: lon - 12,000đ/lon
                new IngredientPurchaseUnit(Guid.NewGuid(), cocaColaIngredient.Id, locUnit.Id, 6, false, 70000m, true),    // 1 lốc = 6 lon - 70,000đ/lốc
                new IngredientPurchaseUnit(Guid.NewGuid(), cocaColaIngredient.Id, thungUnit.Id, 24, false, 260000m, true)  // 1 thùng = 24 lon - 260,000đ/thùng
            });
        }
        
        if (biaIngredient != null)
        {
            purchaseUnits.AddRange(new[]
            {
                new IngredientPurchaseUnit(Guid.NewGuid(), biaIngredient.Id, mlUnit.Id, 1, true, 50m, true),      // Base: ml - 50đ/ml
                new IngredientPurchaseUnit(Guid.NewGuid(), biaIngredient.Id, lonUnit.Id, 330, false, 15000m, true),  // 1 lon = 330ml - 15,000đ/lon
                new IngredientPurchaseUnit(Guid.NewGuid(), biaIngredient.Id, thungUnit.Id, 50000, false, 750000m, true) // 1 thùng = 50000ml - 750,000đ/thùng
            });
        }
        
        await _purchaseUnitRepository.InsertManyAsync(purchaseUnits, autoSave: true);
    }
}