using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using SmartRestaurant.MenuManagement.MenuCategories;
using SmartRestaurant.MenuManagement.MenuItemIngredients;
using SmartRestaurant.InventoryManagement.Ingredients;
using Volo.Abp.Data;
using Volo.Abp.DependencyInjection;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Guids;
using Volo.Abp.Modularity;
namespace SmartRestaurant.MenuManagement.MenuItems;

public class MenuItemDataSeedContributor : ITransientDependency
{
    private readonly IRepository<MenuItem, Guid> _menuItemRepository;
    private readonly IRepository<MenuCategory, Guid> _menuCategoryRepository;
    private readonly IRepository<Ingredient, Guid> _ingredientRepository;
    private readonly IGuidGenerator _guidGenerator;

    public MenuItemDataSeedContributor(
        IRepository<MenuItem, Guid> menuItemRepository,
        IRepository<MenuCategory, Guid> menuCategoryRepository,
        IRepository<Ingredient, Guid> ingredientRepository,
        IGuidGenerator guidGenerator)
    {
        _menuItemRepository = menuItemRepository;
        _menuCategoryRepository = menuCategoryRepository;
        _ingredientRepository = ingredientRepository;
        _guidGenerator = guidGenerator;
    }

    public async Task SeedAsync(DataSeedContext context)
    {
        if (await _menuItemRepository.GetCountAsync() > 0)
        {
            return;
        }

        // Load categories to get their IDs
        var categories = await _menuCategoryRepository.GetListAsync();
        var drinksCategory = categories.FirstOrDefault(c => c.Name == "Đồ Uống");
        var snacksCategory = categories.FirstOrDefault(c => c.Name == "Đồ Nhậu");

        // Load ingredients to get their IDs
        var ingredients = await _ingredientRepository.GetListAsync();
        var biaIngredient = ingredients.FirstOrDefault(i => i.Name == "Bia");
        var cocaIngredient = ingredients.FirstOrDefault(i => i.Name == "Coca");
        var mucIngredient = ingredients.FirstOrDefault(i => i.Name == "Mực");
        var caIngredient = ingredients.FirstOrDefault(i => i.Name == "Cá");
        var dauIngredient = ingredients.FirstOrDefault(i => i.Name == "Đậu");

        // Ensure all required categories and ingredients exist
        if (drinksCategory == null || snacksCategory == null ||
            biaIngredient == null || cocaIngredient == null ||
            mucIngredient == null || caIngredient == null || dauIngredient == null)
        {
            return; // Dependencies not seeded yet, will retry later
        }

        // Menu items cho quán bia
        var menuItems = new List<MenuItem>();

        #region Bia cốc
        var biaCocMenuItem = new MenuItem(
            Guid.NewGuid(),
            "Bia cốc",
            "Bia tươi cốc 300ml",
            10000,
            true,
            "https://example.com/images/bia-ca.jpg",
            drinksCategory.Id
        );

        // Add ingredient cho Bia cốc
        var biaIngredientForBiaCoc = new MenuItemIngredient(
            _guidGenerator.Create(),
            biaCocMenuItem.Id,
            biaIngredient.Id,
            300, // 300ml bia cho 1 cốc
            1    // Display order
        );
        biaCocMenuItem.AddMenuItemIngredients(_guidGenerator, [biaIngredientForBiaCoc]);
        menuItems.Add(biaCocMenuItem);
        #endregion

        #region Bia Lít
        var biaLitMenuItem = new MenuItem(
            Guid.NewGuid(),
            "Bia Lít",
            "Bia tươi lít 1000ml",
            25000,
            true,
            "https://example.com/images/bia-lit.jpg",
            drinksCategory.Id
        );

        var biaIngredientForBiaLit = new MenuItemIngredient(
            _guidGenerator.Create(),
            biaLitMenuItem.Id,
            biaIngredient.Id,
            1000, // 1000ml bia cho 1 lít
            1
        );
        biaLitMenuItem.AddMenuItemIngredients(_guidGenerator, [biaIngredientForBiaLit]);
        menuItems.Add(biaLitMenuItem);
        #endregion

        #region Bia Ca (1300ml)
        var biaCanMenuItem = new MenuItem(
            Guid.NewGuid(),
            "Bia Ca",
            "Bia tươi can 1300ml",
            30000,
            true,
            "https://example.com/images/bia-can.jpg",
            drinksCategory.Id
        );

        var biaIngredientForBiaCan = new MenuItemIngredient(
            _guidGenerator.Create(),
            biaCanMenuItem.Id,
            biaIngredient.Id,
            1300, // 1300ml bia cho 1 can
            1
        );
        biaCanMenuItem.AddMenuItemIngredients(_guidGenerator, [biaIngredientForBiaCan]);
        menuItems.Add(biaCanMenuItem);
        #endregion

        #region Bia Tháp
        var biaTrapMenuItem = new MenuItem(
            Guid.NewGuid(),
            "Bia Tháp",
            "Bia tươi tháp 3000ml",
            75000,
            true,
            "https://example.com/images/bia-thap.jpg",
            drinksCategory.Id
        );

        var biaIngredientForBiaThap = new MenuItemIngredient(
            _guidGenerator.Create(),
            biaTrapMenuItem.Id,
            biaIngredient.Id,
            3000, // 3000ml bia cho 1 tháp
            1
        );
        biaTrapMenuItem.AddMenuItemIngredients(_guidGenerator, [biaIngredientForBiaThap]);
        menuItems.Add(biaTrapMenuItem);
        #endregion

        #region Coca Cola
        var cocaColaMenuItem = new MenuItem(
            Guid.NewGuid(),
            "Coca Cola",
            "Coca Cola 330ml",
            15000,
            true,
            "https://example.com/images/coca-cola.jpg",
            drinksCategory.Id
        );

        var cocaIngredientForCoca = new MenuItemIngredient(
            _guidGenerator.Create(),
            cocaColaMenuItem.Id,
            cocaIngredient.Id,
            1, // 1 lon coca
            1
        );
        cocaColaMenuItem.AddMenuItemIngredients(_guidGenerator, [cocaIngredientForCoca]);
        menuItems.Add(cocaColaMenuItem);
        #endregion

        #region Mực Nướng
        var mucNuongMenuItem = new MenuItem(
            Guid.NewGuid(),
            "Mực Nướng",
            "Mực nướng thơm ngon với 1 con",
            120000,
            true,
            "https://example.com/images/muc-nuong.jpg",
            snacksCategory.Id
        );

        var mucIngredientForMucNuong = new MenuItemIngredient(
            _guidGenerator.Create(),
            mucNuongMenuItem.Id,
            mucIngredient.Id,
            1, // 1 con mực
            1
        );
        mucNuongMenuItem.AddMenuItemIngredients(_guidGenerator, [mucIngredientForMucNuong]);
        menuItems.Add(mucNuongMenuItem);
        #endregion

        #region Cá Chỉ Nướng
        var caChiNuongMenuItem = new MenuItem(
            Guid.NewGuid(),
            "Cá Chỉ Nướng",
            "Cá chỉ nướng giòn rụm với 10 con",
            50000,
            true,
            "https://example.com/images/ca-chi-nuong.jpg",
            snacksCategory.Id
        );

        var caIngredientForCaNuong = new MenuItemIngredient(
            _guidGenerator.Create(),
            caChiNuongMenuItem.Id,
            caIngredient.Id,
            10, // 10 con cá
            1
        );
        caChiNuongMenuItem.AddMenuItemIngredients(_guidGenerator, [caIngredientForCaNuong]);
        menuItems.Add(caChiNuongMenuItem);
        #endregion

        #region Đậu Tẩm Hành
        var dauTamHanhMenuItem = new MenuItem(
            Guid.NewGuid(),
            "Đậu Tẩm Hành",
            "Đậu phộng tẩm hành tỏi với 3 cái",
            40000,
            true,
            "https://example.com/images/dau-tam-hanh.jpg",
            snacksCategory.Id
        );

        var dauIngredientForTamHanh = new MenuItemIngredient(
            _guidGenerator.Create(),
            dauTamHanhMenuItem.Id,
            dauIngredient.Id,
            3, // 3 cái đậu
            1
        );
        dauTamHanhMenuItem.AddMenuItemIngredients(_guidGenerator, [dauIngredientForTamHanh]);
        menuItems.Add(dauTamHanhMenuItem);
        #endregion

        #region Đậu Lướt
        var dauLuotMenuItem = new MenuItem(
            Guid.NewGuid(),
            "Đậu Lướt",
            "Đậu phộng lướt nước mắm với 3 cái",
            30000,
            true,
            "https://example.com/images/dau-luot.jpg",
            snacksCategory.Id
        );

        var dauIngredientForLuot = new MenuItemIngredient(
            _guidGenerator.Create(),
            dauLuotMenuItem.Id,
            dauIngredient.Id,
            3, // 3 cái đậu
            1
        );
        dauLuotMenuItem.AddMenuItemIngredients(_guidGenerator, [dauIngredientForLuot]);
        menuItems.Add(dauLuotMenuItem);
        #endregion

        await _menuItemRepository.InsertManyAsync(menuItems.Where(item =>
            item.CategoryId != Guid.Empty).ToArray());
    }
}