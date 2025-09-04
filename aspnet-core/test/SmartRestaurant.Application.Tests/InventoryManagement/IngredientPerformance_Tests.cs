using System;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using SmartRestaurant.InventoryManagement.Ingredients;
using SmartRestaurant.InventoryManagement.Ingredients.Dto;
using Shouldly;
using Volo.Abp.Application.Dtos;
using Xunit;

namespace SmartRestaurant.InventoryManagement;

/// <summary>
/// Performance tests cho multi-unit system với existing data
/// Đảm bảo queries không bị chậm khi có nhiều ingredients và purchase units
/// </summary>
public class IngredientPerformance_Tests : SmartRestaurantApplicationTestBase<SmartRestaurantApplicationTestModule>
{
    private readonly IIngredientAppService _ingredientAppService;

    public IngredientPerformance_Tests()
    {
        _ingredientAppService = GetRequiredService<IIngredientAppService>();
    }

    [Fact]
    public async Task GetList_Performance_ShouldBeUnder2Seconds()
    {
        // Arrange
        var request = new GetIngredientListRequestDto
        {
            MaxResultCount = 100,
            SkipCount = 0,
            Sorting = "name"
        };

        // Act - Measure performance
        var stopwatch = Stopwatch.StartNew();
        var result = await _ingredientAppService.GetListAsync(request);
        stopwatch.Stop();

        // Assert - Performance should be under 2 seconds
        stopwatch.ElapsedMilliseconds.ShouldBeLessThan(2000);
        result.ShouldNotBeNull();
        result.Items.ShouldNotBeNull();
    }

    [Fact]
    public async Task IndexedQueries_ShouldPerformWell()
    {
        // Arrange - Simple performance test using existing repository
        var request = new GetIngredientListRequestDto
        {
            MaxResultCount = 20,
            SkipCount = 0,
            Filter = null
        };

        // Act - Measure indexed query performance
        var stopwatch = Stopwatch.StartNew();
        var result = await _ingredientAppService.GetListAsync(request);
        stopwatch.Stop();

        // Assert - Should complete quickly
        stopwatch.ElapsedMilliseconds.ShouldBeLessThan(1000);
        result.ShouldNotBeNull();
    }
}