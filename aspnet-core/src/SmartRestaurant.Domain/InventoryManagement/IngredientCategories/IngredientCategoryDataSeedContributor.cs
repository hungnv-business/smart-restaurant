using System;
using System.Threading.Tasks;
using Volo.Abp.Data;
using Volo.Abp.DependencyInjection;
using Volo.Abp.Domain.Repositories;

namespace SmartRestaurant.InventoryManagement.IngredientCategories;

public class IngredientCategoryDataSeedContributor : IDataSeedContributor, ITransientDependency
{
    private readonly IRepository<IngredientCategory, Guid> _ingredientCategoryRepository;

    public IngredientCategoryDataSeedContributor(IRepository<IngredientCategory, Guid> ingredientCategoryRepository)
    {
        _ingredientCategoryRepository = ingredientCategoryRepository;
    }

    public async Task SeedAsync(DataSeedContext context)
    {
        if (await _ingredientCategoryRepository.GetCountAsync() > 0)
        {
            return;
        }

        var categories = new[]
        {
            new IngredientCategory { Name = "Rau củ", Description = "Rau xanh và củ quả tươi", DisplayOrder = 1, IsActive = true },
            new IngredientCategory { Name = "Thịt cá", Description = "Thịt tươi và hải sản", DisplayOrder = 2, IsActive = true },
            new IngredientCategory { Name = "Gia vị", Description = "Các loại gia vị và condiment", DisplayOrder = 3, IsActive = true },
            new IngredientCategory { Name = "Đồ khô", Description = "Gạo, bún, mì và các loại đồ khô", DisplayOrder = 4, IsActive = true },
            new IngredientCategory { Name = "Đồ uống", Description = "Nước ngọt, bia và các loại đồ uống", DisplayOrder = 5, IsActive = true }
        };

        await _ingredientCategoryRepository.InsertManyAsync(categories);
    }
}