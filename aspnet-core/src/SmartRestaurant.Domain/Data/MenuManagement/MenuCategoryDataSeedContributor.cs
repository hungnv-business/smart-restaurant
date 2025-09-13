using System;
using System.Threading.Tasks;
using Volo.Abp.Data;
using Volo.Abp.DependencyInjection;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.MenuManagement.MenuCategories;

public class MenuCategoryDataSeedContributor : ITransientDependency
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
            new MenuCategory(Guid.NewGuid(), "Đồ Uống", "Bia tươi và nước ngọt các loại", 1, true, "https://example.com/images/drinks-category.jpg"),
            new MenuCategory(Guid.NewGuid(), "Đồ Nhậu", "Mực khô, cá khô và các món nhậu", 2, true, "https://example.com/images/snacks-category.jpg")
        };

        await _menuCategoryRepository.InsertManyAsync(categories, autoSave: true);
    }
}