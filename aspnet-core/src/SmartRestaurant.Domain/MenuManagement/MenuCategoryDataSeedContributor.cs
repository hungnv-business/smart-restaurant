using System;
using System.Threading.Tasks;
using SmartRestaurant.Entities.MenuManagement;
using Volo.Abp.Data;
using Volo.Abp.DependencyInjection;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Guids;

namespace SmartRestaurant.MenuManagement;

public class MenuCategoryDataSeedContributor : IDataSeedContributor, ITransientDependency
{
    private readonly IRepository<MenuCategory, Guid> _menuCategoryRepository;

    public MenuCategoryDataSeedContributor(IRepository<MenuCategory, Guid> menuCategoryRepository)
    {
        _menuCategoryRepository = menuCategoryRepository;
    }

    public async Task SeedAsync(DataSeedContext context)
    {
        if (await _menuCategoryRepository.GetCountAsync() > 0)
        {
            return;
        }

        var categories = new[]
        {
            new MenuCategory(Guid.NewGuid(), "Món Phở", "Các loại phở truyền thống Việt Nam", 1, true, "https://example.com/images/pho-category.jpg"),
            new MenuCategory(Guid.NewGuid(), "Cơm", "Cơm tấm và các món cơm", 2, true, "https://example.com/images/rice-category.jpg"),
            new MenuCategory(Guid.NewGuid(), "Bún - Mì", "Bún bò Huế, bún chả và các loại mì", 3, true, "https://example.com/images/noodles-category.jpg"),
            new MenuCategory(Guid.NewGuid(), "Món Ăn Kèm", "Gỏi cuốn, chả giò và các món ăn kèm", 4, true, "https://example.com/images/side-dishes-category.jpg"),
            new MenuCategory(Guid.NewGuid(), "Đồ Uống", "Trà đá, cà phê và nước uống các loại", 5, true, "https://example.com/images/drinks-category.jpg"),
            new MenuCategory(Guid.NewGuid(), "Tráng Miệng", "Chè, kem và các món tráng miệng", 6, true, "https://example.com/images/desserts-category.jpg")
        };

        await _menuCategoryRepository.InsertManyAsync(categories);
    }
}