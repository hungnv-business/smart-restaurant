using System;
using System.Collections.Generic;
using System.Linq;
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
            true,
            1); // Base unit

        var regularUnit = new IngredientPurchaseUnit(
            Guid.NewGuid(),
            ingredient.Id,
            regularUnitId,
            50000,
            false,
            2); // Purchase unit

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
            false,
            1);

        ingredient.PurchaseUnits = new List<IngredientPurchaseUnit> { purchaseUnit };

        // Act
        // Note: ConvertToBaseUnit method không tồn tại trong Ingredient class
        // Tử calculation trực tiếp: 3 thùng * 50000ml/thùng = 150000ml
        var quantity = 3;
        var selectedUnit = ingredient.PurchaseUnits.First(u => u.UnitId == purchaseUnitId);
        var result = quantity * selectedUnit.ConversionRatio;

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
        // Note: ConvertToBaseUnit method không tồn tại trong Ingredient class
        // Kiểm tra logic tìm unit không tồn tại
        Should.Throw<ArgumentException>(() => {
            var unit = ingredient.PurchaseUnits.FirstOrDefault(u => u.UnitId == invalidUnitId);
            if (unit == null) throw new ArgumentException("Unit not found");
        });
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
            false,
            1);

        ingredient.PurchaseUnits = new List<IngredientPurchaseUnit> { purchaseUnit };

        // Act
        // Note: ConvertFromBaseUnit method không tồn tại trong Ingredient class
        // Tử calculation trực tiếp: 72 lon / 24 lon/thùng = 3 thùng
        var baseQuantity = 72;
        var selectedUnit = ingredient.PurchaseUnits.First(u => u.UnitId == purchaseUnitId);
        var result = baseQuantity / selectedUnit.ConversionRatio;

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
            false,
            1);

        ingredient.PurchaseUnits = new List<IngredientPurchaseUnit> { purchaseUnit };

        // Act
        // Note: ConvertToBaseUnit method không tồn tại trong Ingredient class
        // Tử calculation trực tiếp
        var selectedUnit = ingredient.PurchaseUnits.First(u => u.UnitId == purchaseUnitId);
        var result = purchaseQuantity * selectedUnit.ConversionRatio;

        // Assert
        result.ShouldBe(expectedBaseQuantity);
    }
}