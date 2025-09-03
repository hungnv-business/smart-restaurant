using System;
using System.Collections.Generic;
using SmartRestaurant.InventoryManagement.Ingredients;
using SmartRestaurant.Common;
using Shouldly;
using Xunit;

namespace SmartRestaurant.InventoryManagement;

public class IngredientMultiUnitTests
{
    private Ingredient CreateTestIngredient()
    {
        var ingredient = new Ingredient
        {
            Name = "Test Beer",
            CategoryId = Guid.NewGuid(),
            UnitId = Guid.NewGuid(),
            IsActive = true
        };

        return ingredient;
    }

    [Fact]
    public void GetBaseUnit_WithValidBaseUnit_ShouldReturnCorrectUnit()
    {
        // Arrange
        var ingredient = CreateTestIngredient();
        var baseUnitId = Guid.NewGuid();
        var regularUnitId = Guid.NewGuid();

        var baseUnit = new IngredientPurchaseUnit(
            Guid.NewGuid(),
            ingredient.Id,
            baseUnitId,
            1,
            true); // Base unit

        var regularUnit = new IngredientPurchaseUnit(
            Guid.NewGuid(),
            ingredient.Id,
            regularUnitId,
            50000,
            false); // Purchase unit

        ingredient.PurchaseUnits = new List<IngredientPurchaseUnit> { baseUnit, regularUnit };

        // Act
        var result = ingredient.GetBaseUnit();

        // Assert
        result.ShouldBe(baseUnit);
        result.IsBaseUnit.ShouldBeTrue();
    }

    [Fact]
    public void GetBaseUnit_WithNoBaseUnit_ShouldThrowException()
    {
        // Arrange
        var ingredient = CreateTestIngredient();
        ingredient.PurchaseUnits = new List<IngredientPurchaseUnit>();

        // Act & Assert
        Should.Throw<InvalidOperationException>(() => ingredient.GetBaseUnit());
    }

    [Fact]
    public void ConvertToBaseUnit_WithValidPurchaseUnit_ShouldCalculateCorrectly()
    {
        // Arrange
        var ingredient = CreateTestIngredient();
        var purchaseUnitId = Guid.NewGuid();

        var purchaseUnit = new IngredientPurchaseUnit(
            Guid.NewGuid(),
            ingredient.Id,
            purchaseUnitId,
            50000, // 1 thùng = 50000ml
            false);

        ingredient.PurchaseUnits = new List<IngredientPurchaseUnit> { purchaseUnit };

        // Act
        var result = ingredient.ConvertToBaseUnit(3, purchaseUnitId); // 3 thùng

        // Assert
        result.ShouldBe(150000); // 3 * 50000 = 150000ml
    }

    [Fact]
    public void ConvertToBaseUnit_WithInvalidPurchaseUnit_ShouldThrowException()
    {
        // Arrange
        var ingredient = CreateTestIngredient();
        var invalidUnitId = Guid.NewGuid();
        ingredient.PurchaseUnits = new List<IngredientPurchaseUnit>();

        // Act & Assert
        Should.Throw<ArgumentException>(() => ingredient.ConvertToBaseUnit(1, invalidUnitId));
    }

    [Fact]
    public void ConvertFromBaseUnit_WithValidPurchaseUnit_ShouldCalculateCorrectly()
    {
        // Arrange
        var ingredient = CreateTestIngredient();
        var purchaseUnitId = Guid.NewGuid();

        var purchaseUnit = new IngredientPurchaseUnit(
            Guid.NewGuid(),
            ingredient.Id,
            purchaseUnitId,
            24, // 1 thùng = 24 lon
            false);

        ingredient.PurchaseUnits = new List<IngredientPurchaseUnit> { purchaseUnit };

        // Act
        var result = ingredient.ConvertFromBaseUnit(72, purchaseUnitId); // 72 lon

        // Assert
        result.ShouldBe(3); // 72 / 24 = 3 thùng
    }

    [Theory]
    [InlineData(50000, 2, 100000)] // Beer: 2 thùng -> 100000ml
    [InlineData(24, 5, 120)]       // Coca: 5 thùng -> 120 lon
    [InlineData(6, 8, 48)]         // Coca: 8 lốc -> 48 lon
    [InlineData(1, 100, 100)]      // Piece: 100 cái -> 100 cái
    public void RealWorldConversions_ShouldCalculateCorrectly(
        int conversionRatio, 
        int purchaseQuantity, 
        int expectedBaseQuantity)
    {
        // Arrange
        var ingredient = CreateTestIngredient();
        var purchaseUnitId = Guid.NewGuid();

        var purchaseUnit = new IngredientPurchaseUnit(
            Guid.NewGuid(),
            ingredient.Id,
            purchaseUnitId,
            conversionRatio,
            false);

        ingredient.PurchaseUnits = new List<IngredientPurchaseUnit> { purchaseUnit };

        // Act
        var result = ingredient.ConvertToBaseUnit(purchaseQuantity, purchaseUnitId);

        // Assert
        result.ShouldBe(expectedBaseQuantity);
    }
}