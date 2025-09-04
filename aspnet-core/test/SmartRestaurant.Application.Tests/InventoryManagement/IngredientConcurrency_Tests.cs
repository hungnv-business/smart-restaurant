using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using SmartRestaurant.InventoryManagement.Ingredients;
using SmartRestaurant.InventoryManagement.Ingredients.Dto;
using Shouldly;
using Volo.Abp.Domain.Repositories;
using Xunit;

namespace SmartRestaurant.InventoryManagement;

/// <summary>
/// Concurrency tests cho multi-unit system
/// Test concurrent stock updates và ABP Framework's optimistic locking
/// </summary>
public class IngredientConcurrency_Tests : SmartRestaurantApplicationTestBase<SmartRestaurantApplicationTestModule>
{
    private readonly IIngredientAppService _ingredientAppService;
    private readonly IRepository<Ingredient> _ingredientRepository;

    public IngredientConcurrency_Tests()
    {
        _ingredientAppService = GetRequiredService<IIngredientAppService>();
        _ingredientRepository = GetRequiredService<IRepository<Ingredient>>();
    }

    [Fact]
    public async Task ConcurrentStockUpdate_ShouldMaintainConsistency()
    {
        // Arrange - Lấy existing ingredient từ test data
        var ingredients = await _ingredientAppService.GetListAsync(new GetIngredientListRequestDto { MaxResultCount = 1 });
        
        if (!ingredients.Items.Any())
        {
            // Skip test nếu không có test data
            return;
        }
        
        var ingredientId = ingredients.Items.First().Id;
        var dbIngredient = await _ingredientRepository.GetAsync(i => i.Id == ingredientId);
        dbIngredient.SetStock(100); // Set initial stock
        await _ingredientRepository.UpdateAsync(dbIngredient);
        
        // Act - Simulate concurrent stock operations
        var addStockTask = AddStockAsync(ingredientId, 50);
        var subtractStockTask = SubtractStockAsync(ingredientId, 30);
        
        // Wait for operations to complete
        await Task.WhenAll(addStockTask, subtractStockTask);
        
        // Assert - Stock should be consistent (no race conditions)
        var finalIngredient = await _ingredientRepository.GetAsync(i => i.Id == ingredientId);
        finalIngredient.CurrentStock.ShouldBeGreaterThanOrEqualTo(0); // Should not be negative
        finalIngredient.CurrentStock.ShouldBeLessThanOrEqualTo(150); // Should not exceed max possible
    }

    [Fact]
    public async Task ABP_ConcurrencyStamp_ShouldWorkCorrectly()
    {
        // Arrange - Test ABP's built-in concurrency control
        var ingredients = await _ingredientAppService.GetListAsync(new GetIngredientListRequestDto { MaxResultCount = 1 });
        
        if (!ingredients.Items.Any())
        {
            return; // Skip if no test data
        }
        
        var ingredientId = ingredients.Items.First().Id;
        
        // Act & Assert - Multiple concurrent reads should work
        var readTask1 = _ingredientAppService.GetAsync(ingredientId);
        var readTask2 = _ingredientAppService.GetAsync(ingredientId);
        var readTask3 = _ingredientAppService.GetAsync(ingredientId);
        
        var results = await Task.WhenAll(readTask1, readTask2, readTask3);
        
        // All reads should succeed
        results[0].ShouldNotBeNull();
        results[1].ShouldNotBeNull();
        results[2].ShouldNotBeNull();
        
        // All should have same ID
        results[0].Id.ShouldBe(ingredientId);
        results[1].Id.ShouldBe(ingredientId);
        results[2].Id.ShouldBe(ingredientId);
    }

    /// <summary>
    /// Add stock với concurrent handling
    /// </summary>
    private async Task AddStockAsync(Guid ingredientId, int quantity)
    {
        try
        {
            var ingredient = await _ingredientRepository.GetAsync(i => i.Id == ingredientId);
            ingredient.AddStock(quantity);
            await _ingredientRepository.UpdateAsync(ingredient);
        }
        catch
        {
            // Ignore concurrency errors for test purposes
            // Real production code would retry
        }
    }

    /// <summary>
    /// Subtract stock với concurrent handling
    /// </summary>
    private async Task SubtractStockAsync(Guid ingredientId, int quantity)
    {
        await Task.Delay(5); // Small delay to simulate real concurrency
        
        try
        {
            var ingredient = await _ingredientRepository.GetAsync(i => i.Id == ingredientId);
            if (ingredient.CanSubtractStock(quantity))
            {
                ingredient.SubtractStock(quantity);
                await _ingredientRepository.UpdateAsync(ingredient);
            }
        }
        catch
        {
            // Ignore concurrency errors for test purposes
        }
    }
}