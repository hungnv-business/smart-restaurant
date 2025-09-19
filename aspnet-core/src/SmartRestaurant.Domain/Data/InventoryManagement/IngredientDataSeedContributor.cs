using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using SmartRestaurant.InventoryManagement.IngredientCategories;
using SmartRestaurant.Common;
using SmartRestaurant.Data;
using Volo.Abp.Data;
using Volo.Abp.DependencyInjection;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.InventoryManagement.Ingredients;

/// <summary>
/// Seed dữ liệu mẫu cho các nguyên liệu trong từng danh mục
/// Chạy sau UnitDataSeedContributor và IngredientCategoryDataSeedContributor
/// </summary>
public class IngredientDataSeedContributor : ITransientDependency
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
        var doUongCategory = categories.FirstOrDefault(x => x.Name == "Đồ uống");
        var doKhoCategory = categories.FirstOrDefault(x => x.Name == "Đồ khô");

        // Tìm units theo tên
        var conUnit = units.FirstOrDefault(x => x.Name == "con");
        var kgUnit = units.FirstOrDefault(x => x.Name == "kg");
        var caiUnit = units.FirstOrDefault(x => x.Name == "cái");
        var lonUnit = units.FirstOrDefault(x => x.Name == "lon");
        var mlUnit = units.FirstOrDefault(x => x.Name == "ml");
        var bomUnit = units.FirstOrDefault(x => x.Name == "bom");
        var locUnit = units.FirstOrDefault(x => x.Name == "lốc");

        // Kiểm tra có đủ dữ liệu không
        if (doUongCategory == null || doKhoCategory == null ||
            conUnit == null || kgUnit == null || caiUnit == null || lonUnit == null || mlUnit == null || bomUnit == null || locUnit == null)
        {
            return; // Thiếu dữ liệu cần thiết
        }

        // Create sample ingredients với multi-unit support
        var ingredients = new[]
        {
            // Đồ uống
            new Ingredient { CategoryId = doUongCategory.Id, Name = "Bia", Description = "Bia tươi",
                UnitId = mlUnit.Id, CostPerUnit = 16, SupplierInfo = "Đại lý bia", IsActive = true },

            new Ingredient { CategoryId = doUongCategory.Id, Name = "Coca", Description = "Coca Cola 330ml",
                UnitId = lonUnit.Id, CostPerUnit = 12000, SupplierInfo = "Đại lý Coca", IsActive = true },
            
            // Đồ khô
            new Ingredient { CategoryId = doKhoCategory.Id, Name = "Mực", Description = "Mực khô",
                UnitId = conUnit.Id, CostPerUnit = 20000, SupplierInfo = "Chợ hải sản", IsActive = true },

            new Ingredient { CategoryId = doKhoCategory.Id, Name = "Cá", Description = "Cá khô",
                UnitId = conUnit.Id, CostPerUnit = 15000, SupplierInfo = "Chợ hải sản", IsActive = true },

            new Ingredient { CategoryId = doKhoCategory.Id, Name = "Đậu", Description = "Đậu phộng rang",
                UnitId = caiUnit.Id, CostPerUnit = 5000, SupplierInfo = "Cửa hàng tạp hóa", IsActive = true }
        };

        await _ingredientRepository.InsertManyAsync(ingredients, autoSave: true);

        // Create purchase units for multi-unit ingredients
        var purchaseUnits = new List<IngredientPurchaseUnit>();

        var cocaIngredient = ingredients.FirstOrDefault(i => i.Name == "Coca");
        var biaIngredient = ingredients.FirstOrDefault(i => i.Name == "Bia");
        var mucIngredient = ingredients.FirstOrDefault(i => i.Name == "Mực");
        var caIngredient = ingredients.FirstOrDefault(i => i.Name == "Cá");
        var dauIngredient = ingredients.FirstOrDefault(i => i.Name == "Đậu");

        if (cocaIngredient != null)
        {
            purchaseUnits.AddRange(new[]
            {
                new IngredientPurchaseUnit(Guid.NewGuid(), cocaIngredient.Id, lonUnit.Id, 1, true, 1, 12000, true),     // Base: lon - 12,000đ/lon
                new IngredientPurchaseUnit(Guid.NewGuid(), cocaIngredient.Id, locUnit.Id, 6, false, 2, 70000, true)     // 1 lốc = 6 lon - 70,000đ/lốc
            });
        }

        if (biaIngredient != null)
        {
            purchaseUnits.AddRange(new[]
            {
                new IngredientPurchaseUnit(Guid.NewGuid(), biaIngredient.Id, mlUnit.Id, 1, true, 1, 16, true),        // Base: ml - 16đ/ml
                new IngredientPurchaseUnit(Guid.NewGuid(), biaIngredient.Id, bomUnit.Id, 50000, false, 2, 800000, true) // 1 bom = 50,000ml - 800,000đ/bom
            });
        }

        if (mucIngredient != null)
        {
            purchaseUnits.AddRange(new[]
            {
                new IngredientPurchaseUnit(Guid.NewGuid(), mucIngredient.Id, conUnit.Id, 1, true, 1, 20000, true),    // Base: con - 20,000đ/con
                new IngredientPurchaseUnit(Guid.NewGuid(), mucIngredient.Id, kgUnit.Id, 20, false, 2, 400000, true)   // 1 kg = 20 con - 400,000đ/kg
            });
        }

        if (caIngredient != null)
        {
            purchaseUnits.AddRange(new[]
            {
                new IngredientPurchaseUnit(Guid.NewGuid(), caIngredient.Id, conUnit.Id, 1, true, 1, 15000, true),     // Base: con - 15,000đ/con
                new IngredientPurchaseUnit(Guid.NewGuid(), caIngredient.Id, kgUnit.Id, 25, false, 2, 375000, true)    // 1 kg = 25 con - 375,000đ/kg
            });
        }

        if (dauIngredient != null)
        {
            purchaseUnits.AddRange(new[]
            {
                new IngredientPurchaseUnit(Guid.NewGuid(), dauIngredient.Id, caiUnit.Id, 1, true, 1, 3000, true),     // Base: cái - 3,000đ/cái
            });
        }

        await _purchaseUnitRepository.InsertManyAsync(purchaseUnits, autoSave: true);
    }
}