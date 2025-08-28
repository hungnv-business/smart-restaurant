using System;
using System.Threading.Tasks;
using Shouldly;
using SmartRestaurant.MenuManagement.MenuItems;
using SmartRestaurant.MenuManagement.MenuItems.Dto;
using SmartRestaurant.MenuManagement.MenuCategories;
using SmartRestaurant.MenuManagement.MenuCategories.Dto;
using SmartRestaurant.Exceptions;
using SmartRestaurant.Permissions;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Authorization;
using Volo.Abp.Validation;
using Volo.Abp.Domain.Entities;
using Xunit;

namespace SmartRestaurant.MenuManagement.MenuItems;

public class MenuItemAppService_Tests : SmartRestaurantApplicationTestBase<SmartRestaurantApplicationTestModule>
{
    private readonly IMenuItemAppService _menuItemAppService;
    private readonly IMenuCategoryAppService _menuCategoryAppService;

    public MenuItemAppService_Tests()
    {
        _menuItemAppService = GetRequiredService<IMenuItemAppService>();
        _menuCategoryAppService = GetRequiredService<IMenuCategoryAppService>();
    }

    [Fact]
    public async Task Should_Get_List_Of_MenuItems()
    {
        // Arrange - Create a category and menu item
        var category = await CreateTestCategoryAsync();
        await CreateTestMenuItemAsync(category.Id);

        // Act
        var result = await _menuItemAppService.GetListAsync(
            new PagedAndSortedResultRequestDto()
        );

        // Assert
        result.Items.ShouldNotBeNull();
        result.Items.Count.ShouldBeGreaterThan(0);
    }

    [Fact]
    public async Task Should_Create_A_Valid_MenuItem()
    {
        // Arrange
        var category = await CreateTestCategoryAsync();
        var input = new CreateUpdateMenuItemDto
        {
            Name = "Phở Bò Tái",
            Description = "Phở bò với thịt bò tái, hành lá và ngò gai",
            Price = 85000m,
            IsAvailable = true,
            ImageUrl = "https://example.com/pho-bo-tai.jpg",
            CategoryId = category.Id
        };

        // Act
        var result = await _menuItemAppService.CreateAsync(input);

        // Assert
        result.Id.ShouldNotBe(Guid.Empty);
        result.Name.ShouldBe(input.Name);
        result.Description.ShouldBe(input.Description);
        result.Price.ShouldBe(input.Price);
        result.IsAvailable.ShouldBe(input.IsAvailable);
        result.ImageUrl.ShouldBe(input.ImageUrl);
        result.CategoryId.ShouldBe(input.CategoryId);
    }

    [Fact]
    public async Task Should_Not_Create_MenuItem_With_Empty_Name()
    {
        // Arrange
        var category = await CreateTestCategoryAsync();
        var input = new CreateUpdateMenuItemDto
        {
            Name = string.Empty,
            Price = 50000m,
            IsAvailable = true,
            CategoryId = category.Id
        };

        // Act & Assert
        await Assert.ThrowsAsync<AbpValidationException>(async () =>
        {
            await _menuItemAppService.CreateAsync(input);
        });
    }

    [Fact]
    public async Task Should_Not_Create_MenuItem_With_Invalid_CategoryId()
    {
        // Arrange
        var input = new CreateUpdateMenuItemDto
        {
            Name = "Phở Gà",
            Price = 75000m,
            IsAvailable = true,
            CategoryId = Guid.NewGuid() // Invalid category ID
        };

        // Act & Assert
        await Assert.ThrowsAsync<MenuItemCategoryNotFoundException>(async () =>
        {
            await _menuItemAppService.CreateAsync(input);
        });
    }

    [Fact]
    public async Task Should_Not_Create_MenuItem_With_Duplicate_Name_In_Same_Category()
    {
        // Arrange
        var category = await CreateTestCategoryAsync();
        
        // Create first menu item
        var firstItem = new CreateUpdateMenuItemDto
        {
            Name = "Phở Bò Chín",
            Price = 80000m,
            IsAvailable = true,
            CategoryId = category.Id
        };
        await _menuItemAppService.CreateAsync(firstItem);

        // Try to create second menu item with same name in same category
        var duplicateItem = new CreateUpdateMenuItemDto
        {
            Name = "Phở Bò Chín",
            Price = 85000m,
            IsAvailable = true,
            CategoryId = category.Id
        };

        // Act & Assert
        await Assert.ThrowsAsync<MenuItemNameAlreadyExistsInCategoryException>(async () =>
        {
            await _menuItemAppService.CreateAsync(duplicateItem);
        });
    }

    [Fact]
    public async Task Should_Allow_Same_Name_In_Different_Categories()
    {
        // Arrange
        var category1 = await CreateTestCategoryAsync("Món Phở");
        var category2 = await CreateTestCategoryAsync("Cơm");

        var menuItem1 = new CreateUpdateMenuItemDto
        {
            Name = "Đặc biệt",
            Price = 90000m,
            IsAvailable = true,
            CategoryId = category1.Id
        };

        var menuItem2 = new CreateUpdateMenuItemDto
        {
            Name = "Đặc biệt",
            Price = 95000m,
            IsAvailable = true,
            CategoryId = category2.Id
        };

        // Act
        var result1 = await _menuItemAppService.CreateAsync(menuItem1);
        var result2 = await _menuItemAppService.CreateAsync(menuItem2);

        // Assert
        result1.Id.ShouldNotBe(Guid.Empty);
        result2.Id.ShouldNotBe(Guid.Empty);
        result1.Name.ShouldBe(result2.Name);
        result1.CategoryId.ShouldNotBe(result2.CategoryId);
    }

    [Fact]
    public async Task Should_Update_MenuItem()
    {
        // Arrange
        var category = await CreateTestCategoryAsync();
        var created = await CreateTestMenuItemAsync(category.Id);

        var updateInput = new CreateUpdateMenuItemDto
        {
            Name = "Phở Bò Tái Nạm - Cập nhật",
            Description = "Mô tả được cập nhật",
            Price = 95000m,
            IsAvailable = false,
            ImageUrl = "https://example.com/updated.jpg",
            CategoryId = category.Id
        };

        // Act
        var updated = await _menuItemAppService.UpdateAsync(created.Id, updateInput);

        // Assert
        updated.Id.ShouldBe(created.Id);
        updated.Name.ShouldBe(updateInput.Name);
        updated.Description.ShouldBe(updateInput.Description);
        updated.Price.ShouldBe(updateInput.Price);
        updated.IsAvailable.ShouldBe(updateInput.IsAvailable);
        updated.ImageUrl.ShouldBe(updateInput.ImageUrl);
        updated.CategoryId.ShouldBe(updateInput.CategoryId);
    }

    [Fact]
    public async Task Should_Delete_MenuItem()
    {
        // Arrange
        var category = await CreateTestCategoryAsync();
        var created = await CreateTestMenuItemAsync(category.Id);

        // Act
        await _menuItemAppService.DeleteAsync(created.Id);

        // Assert
        await Assert.ThrowsAsync<EntityNotFoundException>(async () =>
        {
            await _menuItemAppService.GetAsync(created.Id);
        });
    }

    [Fact]
    public async Task Should_Get_MenuItem_By_Id()
    {
        // Arrange
        var category = await CreateTestCategoryAsync();
        var created = await CreateTestMenuItemAsync(category.Id);

        // Act
        var result = await _menuItemAppService.GetAsync(created.Id);

        // Assert
        result.ShouldNotBeNull();
        result.Id.ShouldBe(created.Id);
        result.Name.ShouldBe(created.Name);
        result.CategoryId.ShouldBe(category.Id);
    }

    [Fact]
    public async Task Should_Update_MenuItem_Availability()
    {
        // Arrange
        var category = await CreateTestCategoryAsync();
        var created = await CreateTestMenuItemAsync(category.Id, isAvailable: true);

        // Act
        await _menuItemAppService.UpdateAvailabilityAsync(created.Id, false);

        // Assert
        var updated = await _menuItemAppService.GetAsync(created.Id);
        updated.IsAvailable.ShouldBeFalse();
    }

    [Fact]
    public async Task Should_Not_Update_Availability_For_NonExistent_MenuItem()
    {
        // Arrange
        var nonExistentId = Guid.NewGuid();

        // Act & Assert
        await Assert.ThrowsAsync<EntityNotFoundException>(async () =>
        {
            await _menuItemAppService.UpdateAvailabilityAsync(nonExistentId, false);
        });
    }

    [Fact]
    public async Task Should_Not_Create_MenuItem_With_Negative_Price()
    {
        // Arrange
        var category = await CreateTestCategoryAsync();
        var input = new CreateUpdateMenuItemDto
        {
            Name = "Món ăn giá âm",
            Price = -10000m,
            IsAvailable = true,
            CategoryId = category.Id
        };

        // Act & Assert
        await Assert.ThrowsAsync<AbpValidationException>(async () =>
        {
            await _menuItemAppService.CreateAsync(input);
        });
    }

    [Fact]
    public async Task Should_Require_Permission_For_GetList()
    {
        // Arrange
        await WithUnitOfWorkAsync(async () =>
        {
            // Remove all permissions from current user
            await SetCurrentUserAsync(null);
        });

        // Act & Assert
        await Assert.ThrowsAsync<AbpAuthorizationException>(async () =>
        {
            await _menuItemAppService.GetListAsync(new PagedAndSortedResultRequestDto());
        });
    }

    [Fact]
    public async Task Should_Require_Create_Permission_For_Create()
    {
        // Arrange
        var category = await CreateTestCategoryAsync();
        var input = new CreateUpdateMenuItemDto
        {
            Name = "Test Item",
            Price = 50000m,
            IsAvailable = true,
            CategoryId = category.Id
        };

        await WithUnitOfWorkAsync(async () =>
        {
            // Remove create permission from current user
            await SetCurrentUserAsync(null);
        });

        // Act & Assert
        await Assert.ThrowsAsync<AbpAuthorizationException>(async () =>
        {
            await _menuItemAppService.CreateAsync(input);
        });
    }

    [Fact]
    public async Task Should_Require_Edit_Permission_For_Update()
    {
        // Arrange
        var category = await CreateTestCategoryAsync();
        var created = await CreateTestMenuItemAsync(category.Id);
        
        var updateInput = new CreateUpdateMenuItemDto
        {
            Name = "Updated Item",
            Price = 60000m,
            IsAvailable = true,
            CategoryId = category.Id
        };

        await WithUnitOfWorkAsync(async () =>
        {
            // Remove edit permission from current user
            await SetCurrentUserAsync(null);
        });

        // Act & Assert
        await Assert.ThrowsAsync<AbpAuthorizationException>(async () =>
        {
            await _menuItemAppService.UpdateAsync(created.Id, updateInput);
        });
    }

    [Fact]
    public async Task Should_Require_Delete_Permission_For_Delete()
    {
        // Arrange
        var category = await CreateTestCategoryAsync();
        var created = await CreateTestMenuItemAsync(category.Id);

        await WithUnitOfWorkAsync(async () =>
        {
            // Remove delete permission from current user
            await SetCurrentUserAsync(null);
        });

        // Act & Assert
        await Assert.ThrowsAsync<AbpAuthorizationException>(async () =>
        {
            await _menuItemAppService.DeleteAsync(created.Id);
        });
    }

    [Fact]
    public async Task Should_Require_UpdateAvailability_Permission_For_UpdateAvailability()
    {
        // Arrange
        var category = await CreateTestCategoryAsync();
        var created = await CreateTestMenuItemAsync(category.Id);

        await WithUnitOfWorkAsync(async () =>
        {
            // Remove update availability permission from current user
            await SetCurrentUserAsync(null);
        });

        // Act & Assert
        await Assert.ThrowsAsync<AbpAuthorizationException>(async () =>
        {
            await _menuItemAppService.UpdateAvailabilityAsync(created.Id, false);
        });
    }

    #region Helper Methods

    private async Task<MenuCategoryDto> CreateTestCategoryAsync(string name = "Test Category")
    {
        var input = new CreateUpdateMenuCategoryDto
        {
            Name = name,
            Description = "Test category description",
            DisplayOrder = 1,
            IsEnabled = true
        };

        return await _menuCategoryAppService.CreateAsync(input);
    }

    private async Task<MenuItemDto> CreateTestMenuItemAsync(Guid categoryId, bool isAvailable = true)
    {
        var input = new CreateUpdateMenuItemDto
        {
            Name = "Test Menu Item",
            Description = "Test menu item description",
            Price = 50000m,
            IsAvailable = isAvailable,
            CategoryId = categoryId
        };

        return await _menuItemAppService.CreateAsync(input);
    }

    #endregion
}