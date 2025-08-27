using System;
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

    public IngredientDataSeedContributor(
        IRepository<Ingredient, Guid> ingredientRepository,
        IRepository<IngredientCategory, Guid> categoryRepository,
        IRepository<Unit, Guid> unitRepository)
    {
        _ingredientRepository = ingredientRepository;
        _categoryRepository = categoryRepository;
        _unitRepository = unitRepository;
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
        var giaViCategory = categories.FirstOrDefault(x => x.Name == "Gia vị");
        var doKhoCategory = categories.FirstOrDefault(x => x.Name == "Đồ khô");
        var doUongCategory = categories.FirstOrDefault(x => x.Name == "Đồ uống");

        // Tìm units theo tên
        var kgUnit = units.FirstOrDefault(x => x.Name == "kg");
        var goiUnit = units.FirstOrDefault(x => x.Name == "gói");
        var chaiUnit = units.FirstOrDefault(x => x.Name == "chai");
        var lonUnit = units.FirstOrDefault(x => x.Name == "lon");

        // Kiểm tra có đủ dữ liệu không
        if (rauCuCategory == null || thitCaCategory == null || giaViCategory == null || 
            doKhoCategory == null || doUongCategory == null ||
            kgUnit == null || goiUnit == null || chaiUnit == null || lonUnit == null)
        {
            return; // Thiếu dữ liệu cần thiết
        }

        var ingredients = new[]
        {
            // Rau củ
            new Ingredient { CategoryId = rauCuCategory.Id, Name = "Cà chua", UnitId = kgUnit.Id, CostPerUnit = 25000m, SupplierInfo = "Chợ Bến Thành", IsActive = true },
            new Ingredient { CategoryId = rauCuCategory.Id, Name = "Hành tây", UnitId = kgUnit.Id, CostPerUnit = 20000m, SupplierInfo = "Chợ Bến Thành", IsActive = true },
            new Ingredient { CategoryId = rauCuCategory.Id, Name = "Rau muống", UnitId = kgUnit.Id, CostPerUnit = 15000m, SupplierInfo = "Chợ Bến Thành", IsActive = true },
            
            // Thịt cá
            new Ingredient { CategoryId = thitCaCategory.Id, Name = "Thịt bò", UnitId = kgUnit.Id, CostPerUnit = 300000m, SupplierInfo = "Lò mổ Sài Gòn", IsActive = true },
            new Ingredient { CategoryId = thitCaCategory.Id, Name = "Thịt heo", UnitId = kgUnit.Id, CostPerUnit = 180000m, SupplierInfo = "Lò mổ Sài Gòn", IsActive = true },
            new Ingredient { CategoryId = thitCaCategory.Id, Name = "Cá tra", UnitId = kgUnit.Id, CostPerUnit = 85000m, SupplierInfo = "Chợ cá Bình Điền", IsActive = true },
            
            // Gia vị
            new Ingredient { CategoryId = giaViCategory.Id, Name = "Muối", UnitId = goiUnit.Id, CostPerUnit = 5000m, SupplierInfo = "Cty Vissan", IsActive = true },
            new Ingredient { CategoryId = giaViCategory.Id, Name = "Đường", UnitId = kgUnit.Id, CostPerUnit = 22000m, SupplierInfo = "Cty Biên Hòa", IsActive = true },
            new Ingredient { CategoryId = giaViCategory.Id, Name = "Nước mắm", UnitId = chaiUnit.Id, CostPerUnit = 45000m, SupplierInfo = "Cty Phú Quốc", IsActive = true },
            
            // Đồ khô
            new Ingredient { CategoryId = doKhoCategory.Id, Name = "Gạo tẻ", UnitId = kgUnit.Id, CostPerUnit = 18000m, SupplierInfo = "Cty Lương thực", IsActive = true },
            new Ingredient { CategoryId = doKhoCategory.Id, Name = "Bún tươi", UnitId = kgUnit.Id, CostPerUnit = 12000m, SupplierInfo = "Lò bánh tráng", IsActive = true },
            
            // Đồ uống
            new Ingredient { CategoryId = doUongCategory.Id, Name = "Coca Cola", UnitId = chaiUnit.Id, CostPerUnit = 15000m, SupplierInfo = "Đại lý Coca", IsActive = true },
            new Ingredient { CategoryId = doUongCategory.Id, Name = "Bia Saigon", UnitId = lonUnit.Id, CostPerUnit = 18000m, SupplierInfo = "Đại lý bia", IsActive = true }
        };

        await _ingredientRepository.InsertManyAsync(ingredients, autoSave: true);
    }
}