using System;
using System.Linq;
using System.Threading.Tasks;
using SmartRestaurant.Entities.MenuManagement;
using Volo.Abp.Data;
using Volo.Abp.DependencyInjection;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.MenuManagement;

public class MenuItemDataSeedContributor : IDataSeedContributor, ITransientDependency
{
    private readonly IRepository<MenuItem, Guid> _menuItemRepository;
    private readonly IRepository<MenuCategory, Guid> _menuCategoryRepository;

    public MenuItemDataSeedContributor(
        IRepository<MenuItem, Guid> menuItemRepository,
        IRepository<MenuCategory, Guid> menuCategoryRepository)
    {
        _menuItemRepository = menuItemRepository;
        _menuCategoryRepository = menuCategoryRepository;
    }

    public async Task SeedAsync(DataSeedContext context)
    {
        if (await _menuItemRepository.GetCountAsync() > 0)
        {
            return;
        }

        // Load categories to get their IDs
        var categories = await _menuCategoryRepository.GetListAsync();
        var phoCategory = categories.FirstOrDefault(c => c.Name == "Món Phở");
        var riceCategory = categories.FirstOrDefault(c => c.Name == "Cơm");
        var noodlesCategory = categories.FirstOrDefault(c => c.Name == "Bún - Mì");
        var sideDishesCategory = categories.FirstOrDefault(c => c.Name == "Món Ăn Kèm");
        var drinksCategory = categories.FirstOrDefault(c => c.Name == "Đồ Uống");
        var dessertsCategory = categories.FirstOrDefault(c => c.Name == "Tráng Miệng");

        // Ensure all required categories exist
        if (phoCategory == null || riceCategory == null || noodlesCategory == null || 
            sideDishesCategory == null || drinksCategory == null || dessertsCategory == null)
        {
            return; // Categories not yet seeded
        }

        var menuItems = new[]
        {
            // Món Phở
            new MenuItem(
                Guid.NewGuid(),
                "Phở Bò Tái",
                "Phở bò với thịt bò tái, hành lá và ngò gai",
                85000m,
                true,
                "https://example.com/images/pho-bo-tai.jpg",
                phoCategory.Id
            ),
            new MenuItem(
                Guid.NewGuid(),
                "Phở Bò Chín",
                "Phở bò với thịt bò chín mềm, hành lá và ngò gai",
                80000m,
                true,
                "https://example.com/images/pho-bo-chin.jpg",
                phoCategory.Id
            ),
            new MenuItem(
                Guid.NewGuid(),
                "Phở Gà",
                "Phở gà truyền thống với thịt gà thái nhỏ",
                75000m,
                true,
                "https://example.com/images/pho-ga.jpg",
                phoCategory.Id
            ),
            new MenuItem(
                Guid.NewGuid(),
                "Phở Đặc Biệt",
                "Phở bò đặc biệt với đầy đủ loại thịt",
                95000m,
                true,
                "https://example.com/images/pho-dac-biet.jpg",
                phoCategory.Id
            ),

            // Cơm
            new MenuItem(
                Guid.NewGuid(),
                "Cơm Tấm Sườn Nướng",
                "Cơm tấm với sườn nướng, trứng ốp la và chả",
                65000m,
                true,
                "https://example.com/images/com-tam-suon-nuong.jpg",
                riceCategory.Id
            ),
            new MenuItem(
                Guid.NewGuid(),
                "Cơm Gà Teriyaki",
                "Cơm với gà teriyaki và rau củ",
                70000m,
                true,
                "https://example.com/images/com-ga-teriyaki.jpg",
                riceCategory.Id
            ),
            new MenuItem(
                Guid.NewGuid(),
                "Cơm Chiên Hải Sản",
                "Cơm chiên với tôm, mực và cua",
                85000m,
                true,
                "https://example.com/images/com-chien-hai-san.jpg",
                riceCategory.Id
            ),
            new MenuItem(
                Guid.NewGuid(),
                "Cơm Niêu Singapore",
                "Cơm niêu đặc biệt kiểu Singapore",
                120000m,
                true,
                "https://example.com/images/com-nieu-singapore.jpg",
                riceCategory.Id
            ),

            // Bún - Mì
            new MenuItem(
                Guid.NewGuid(),
                "Bún Bò Huế",
                "Bún bò Huế cay truyền thống",
                60000m,
                true,
                "https://example.com/images/bun-bo-hue.jpg",
                noodlesCategory.Id
            ),
            new MenuItem(
                Guid.NewGuid(),
                "Bún Chả Hà Nội",
                "Bún chả Hà Nội với thịt nướng và nem",
                55000m,
                true,
                "https://example.com/images/bun-cha-ha-noi.jpg",
                noodlesCategory.Id
            ),
            new MenuItem(
                Guid.NewGuid(),
                "Bún Riêu Cua",
                "Bún riêu cua đồng với cà chua",
                50000m,
                true,
                "https://example.com/images/bun-rieu-cua.jpg",
                noodlesCategory.Id
            ),
            new MenuItem(
                Guid.NewGuid(),
                "Mì Quảng",
                "Mì Quảng với tôm thịt và trứng cút",
                65000m,
                true,
                "https://example.com/images/mi-quang.jpg",
                noodlesCategory.Id
            ),

            // Món Ăn Kèm
            new MenuItem(
                Guid.NewGuid(),
                "Gỏi Cuốn Tôm Thịt",
                "Gỏi cuốn tươi với tôm, thịt và rau thơm",
                45000m,
                true,
                "https://example.com/images/goi-cuon-tom-thit.jpg",
                sideDishesCategory.Id
            ),
            new MenuItem(
                Guid.NewGuid(),
                "Chả Giò Sài Gòn",
                "Chả giò chiên giòn kiểu Sài Gòn",
                40000m,
                true,
                "https://example.com/images/cha-gio-sai-gon.jpg",
                sideDishesCategory.Id
            ),
            new MenuItem(
                Guid.NewGuid(),
                "Bánh Xèo",
                "Bánh xèo miền Nam với tôm thịt và giá đỗ",
                55000m,
                true,
                "https://example.com/images/banh-xeo.jpg",
                sideDishesCategory.Id
            ),

            // Đồ Uống
            new MenuItem(
                Guid.NewGuid(),
                "Nước Chanh Tươi",
                "Nước chanh tươi mát với đường phèn",
                25000m,
                true,
                "https://example.com/images/nuoc-chanh-tuoi.jpg",
                drinksCategory.Id
            ),
            new MenuItem(
                Guid.NewGuid(),
                "Cà Phê Đen Đá",
                "Cà phê đen truyền thống với đá",
                20000m,
                true,
                "https://example.com/images/ca-phe-den-da.jpg",
                drinksCategory.Id
            ),
            new MenuItem(
                Guid.NewGuid(),
                "Cà Phê Sữa Đá",
                "Cà phê sữa đá kiểu Sài Gòn",
                25000m,
                true,
                "https://example.com/images/ca-phe-sua-da.jpg",
                drinksCategory.Id
            ),
            new MenuItem(
                Guid.NewGuid(),
                "Trá Đá",
                "Trà đá lạnh truyền thống",
                10000m,
                true,
                "https://example.com/images/tra-da.jpg",
                drinksCategory.Id
            ),
            new MenuItem(
                Guid.NewGuid(),
                "Sinh Tố Bơ",
                "Sinh tố bơ sánh mịn với sữa đặc",
                35000m,
                true,
                "https://example.com/images/sinh-to-bo.jpg",
                drinksCategory.Id
            ),

            // Tráng Miệng
            new MenuItem(
                Guid.NewGuid(),
                "Chè Ba Màu",
                "Chè ba màu truyền thống với đậu đỏ, đậu xanh",
                30000m,
                true,
                "https://example.com/images/che-ba-mau.jpg",
                dessertsCategory.Id
            ),
            new MenuItem(
                Guid.NewGuid(),
                "Chè Thái Lan",
                "Chè Thái Lan với thạch và dừa tươi",
                35000m,
                true,
                "https://example.com/images/che-thai-lan.jpg",
                dessertsCategory.Id
            ),
            new MenuItem(
                Guid.NewGuid(),
                "Kem Flan",
                "Kem flan mát lạnh kiểu Việt",
                25000m,
                true,
                "https://example.com/images/kem-flan.jpg",
                dessertsCategory.Id
            ),
        };

        await _menuItemRepository.InsertManyAsync(menuItems.Where(item => 
            item.CategoryId != Guid.Empty).ToArray());
    }
}