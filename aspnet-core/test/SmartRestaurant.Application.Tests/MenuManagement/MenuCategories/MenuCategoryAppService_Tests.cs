using System;
using System.Threading.Tasks;
using Shouldly;
using SmartRestaurant.MenuManagement.MenuCategories;
using SmartRestaurant.MenuManagement.MenuCategories.Dto;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Validation;
using Volo.Abp.Domain.Entities;
using Xunit;

namespace SmartRestaurant.MenuManagement.MenuCategories;

public class MenuCategoryAppService_Tests : SmartRestaurantApplicationTestBase<SmartRestaurantApplicationTestModule>
{
    private readonly IMenuCategoryAppService _menuCategoryAppService;

    public MenuCategoryAppService_Tests()
    {
        _menuCategoryAppService = GetRequiredService<IMenuCategoryAppService>();
    }

    [Fact]
    public async Task Should_Get_List_Of_MenuCategories()
    {
        // Act
        var result = await _menuCategoryAppService.GetListAsync(
            new PagedAndSortedResultRequestDto()
        );

        // Assert
        result.Items.ShouldNotBeNull();
        result.Items.Count.ShouldBeGreaterThan(0);
    }

    [Fact]
    public async Task Should_Create_A_Valid_MenuCategory()
    {
        // Arrange
        var input = new CreateUpdateMenuCategoryDto
        {
            Name = "Món khai vị",
            Description = "Các món khai vị truyền thống Việt Nam",
            DisplayOrder = 1,
            IsEnabled = true,
            ImageUrl = "https://example.com/appetizer.jpg"
        };

        // Act
        var result = await _menuCategoryAppService.CreateAsync(input);

        // Assert
        result.Id.ShouldNotBe(Guid.Empty);
        result.Name.ShouldBe(input.Name);
        result.Description.ShouldBe(input.Description);
        result.DisplayOrder.ShouldBe(input.DisplayOrder);
        result.IsEnabled.ShouldBe(input.IsEnabled);
        result.ImageUrl.ShouldBe(input.ImageUrl);
    }

    [Fact]
    public async Task Should_Not_Create_MenuCategory_With_Empty_Name()
    {
        // Arrange
        var input = new CreateUpdateMenuCategoryDto
        {
            Name = string.Empty,
            DisplayOrder = 1,
            IsEnabled = true
        };

        // Act & Assert
        await Assert.ThrowsAsync<AbpValidationException>(async () =>
        {
            await _menuCategoryAppService.CreateAsync(input);
        });
    }

    [Fact]
    public async Task Should_Update_MenuCategory()
    {
        // Arrange - Create a menu category first
        var createInput = new CreateUpdateMenuCategoryDto
        {
            Name = "Món chính",
            Description = "Các món chính",
            DisplayOrder = 2,
            IsEnabled = true
        };

        var created = await _menuCategoryAppService.CreateAsync(createInput);

        // Act - Update the category
        var updateInput = new CreateUpdateMenuCategoryDto
        {
            Name = "Món chính cập nhật",
            Description = "Các món chính được cập nhật",
            DisplayOrder = 3,
            IsEnabled = false,
            ImageUrl = "https://example.com/main-dish.jpg"
        };

        var updated = await _menuCategoryAppService.UpdateAsync(created.Id, updateInput);

        // Assert
        updated.Id.ShouldBe(created.Id);
        updated.Name.ShouldBe(updateInput.Name);
        updated.Description.ShouldBe(updateInput.Description);
        updated.DisplayOrder.ShouldBe(updateInput.DisplayOrder);
        updated.IsEnabled.ShouldBe(updateInput.IsEnabled);
        updated.ImageUrl.ShouldBe(updateInput.ImageUrl);
    }

    [Fact]
    public async Task Should_Delete_MenuCategory()
    {
        // Arrange - Create a menu category first
        var createInput = new CreateUpdateMenuCategoryDto
        {
            Name = $"Delete Test {Guid.NewGuid().ToString("N")[..8]}", // Unique name
            DisplayOrder = 4,
            IsEnabled = true
        };

        var created = await _menuCategoryAppService.CreateAsync(createInput);

        // Act
        await _menuCategoryAppService.DeleteAsync(created.Id);

        // Assert
        await Assert.ThrowsAsync<Volo.Abp.Domain.Entities.EntityNotFoundException>(async () =>
        {
            await _menuCategoryAppService.GetAsync(created.Id);
        });
    }

    [Fact]
    public async Task Should_Get_MenuCategory_By_Id()
    {
        // Arrange & Act - Wrap in UnitOfWork to ensure transaction consistency
        await WithUnitOfWorkAsync(async () =>
        {
            var createInput = new CreateUpdateMenuCategoryDto
            {
                Name = $"Test Category {Guid.NewGuid().ToString("N")[..8]}", // Unique name
                Description = "Các loại đồ uống",
                DisplayOrder = 5,
                IsEnabled = true
            };

            var created = await _menuCategoryAppService.CreateAsync(createInput);
            
            // Act - Get the created category
            var result = await _menuCategoryAppService.GetAsync(created.Id);

            // Assert
            result.ShouldNotBeNull();
            result.Id.ShouldBe(created.Id);
            result.Name.ShouldBe(created.Name);
            result.Description.ShouldBe(created.Description);
        });
    }
}