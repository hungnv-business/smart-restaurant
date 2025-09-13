using System.Threading.Tasks;
using SmartRestaurant.InventoryManagement.IngredientCategories;
using SmartRestaurant.InventoryManagement.Ingredients;
using SmartRestaurant.MenuManagement.MenuCategories;
using SmartRestaurant.MenuManagement.MenuItems;
using Volo.Abp.Data;
using Volo.Abp.DependencyInjection;

namespace SmartRestaurant.Data;

/// <summary>
/// Master DataSeedContributor để quản lý thứ tự seed tất cả data
/// </summary>
public class SmartRestaurantDataSeedContributor(
    UnitDataSeedContributor unitDataSeedContributor,
    IngredientCategoryDataSeedContributor ingredientCategoryDataSeedContributor,
    IngredientDataSeedContributor ingredientDataSeedContributor,
    MenuCategoryDataSeedContributor menuCategoryDataSeedContributor,
    MenuItemDataSeedContributor menuItemDataSeedContributor) : IDataSeedContributor, ITransientDependency
{
    private readonly UnitDataSeedContributor _unitDataSeedContributor = unitDataSeedContributor;
    private readonly IngredientCategoryDataSeedContributor _ingredientCategoryDataSeedContributor = ingredientCategoryDataSeedContributor;
    private readonly IngredientDataSeedContributor _ingredientDataSeedContributor = ingredientDataSeedContributor;
    private readonly MenuCategoryDataSeedContributor _menuCategoryDataSeedContributor = menuCategoryDataSeedContributor;
    private readonly MenuItemDataSeedContributor _menuItemDataSeedContributor = menuItemDataSeedContributor;

    public async Task SeedAsync(DataSeedContext context)
    {
        // Chạy theo thứ tự dependencies
        await _unitDataSeedContributor.SeedAsync(context);
        await _ingredientCategoryDataSeedContributor.SeedAsync(context);
        await _ingredientDataSeedContributor.SeedAsync(context);
        await _menuCategoryDataSeedContributor.SeedAsync(context);
        await _menuItemDataSeedContributor.SeedAsync(context);
    }
}