using System;
using System.Threading.Tasks;
using SmartRestaurant.InventoryManagement.IngredientCategories;
using SmartRestaurant.InventoryManagement.IngredientCategories.Dto;
using Shouldly;
using Volo.Abp.Application.Dtos;
using Xunit;

namespace SmartRestaurant.InventoryManagement;

public class IngredientCategoryAppService_Tests : SmartRestaurantApplicationTestBase<SmartRestaurantApplicationTestModule>
{
    private readonly IIngredientCategoryAppService _ingredientCategoryAppService;

    public IngredientCategoryAppService_Tests()
    {
        _ingredientCategoryAppService = GetRequiredService<IIngredientCategoryAppService>();
    }

    [Fact]
    public async Task Should_Get_List_Of_IngredientCategories()
    {
        // Act
        var result = await _ingredientCategoryAppService.GetListAsync(new PagedAndSortedResultRequestDto());

        // Assert
        result.Items.ShouldNotBeNull();
        result.Items.Count.ShouldBeGreaterThan(0);
    }

    [Fact]
    public async Task Should_Create_IngredientCategory_With_Vietnamese_Name()
    {
        // Arrange
        var createDto = new CreateUpdateIngredientCategoryDto
        {
            Name = "Rau xanh",
            Description = "Rau xanh và rau quả",
            DisplayOrder = 1,
            IsActive = true
        };

        // Act
        var result = await _ingredientCategoryAppService.CreateAsync(createDto);

        // Assert
        result.ShouldNotBeNull();
        result.Name.ShouldBe("Rau xanh");
        result.Description.ShouldBe("Rau xanh và rau quả");
        result.DisplayOrder.ShouldBe(1);
        result.IsActive.ShouldBeTrue();
    }

    [Fact]
    public async Task Should_Get_Next_Display_Order()
    {
        // Act
        var nextOrder = await _ingredientCategoryAppService.GetNextDisplayOrderAsync();

        // Assert
        nextOrder.ShouldBeGreaterThan(0);
    }
}