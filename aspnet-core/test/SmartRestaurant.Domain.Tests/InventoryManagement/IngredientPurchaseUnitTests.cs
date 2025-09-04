using System;
using SmartRestaurant.InventoryManagement.Ingredients;
using Shouldly;
using Xunit;

namespace SmartRestaurant.InventoryManagement;

public class IngredientPurchaseUnitTests
{
    [Fact]
    public void ConvertToBaseUnit_WithValidQuantity_ShouldCalculateCorrectly()
    {
        // Arrange
        var purchaseUnit = new IngredientPurchaseUnit(
            Guid.NewGuid(),
            Guid.NewGuid(),
            Guid.NewGuid(),
            24, // 1 thùng = 24 lon
            false,
            1); // displayOrder

        // Act
        var result = purchaseUnit.ConvertToBaseUnit(2);

        // Assert
        result.ShouldBe(48); // 2 * 24 = 48 lon
    }

    [Fact]
    public void ConvertToBaseUnit_WithZeroQuantity_ShouldThrowException()
    {
        // Arrange
        var purchaseUnit = new IngredientPurchaseUnit(
            Guid.NewGuid(),
            Guid.NewGuid(),
            Guid.NewGuid(),
            24,
            false,
            1); // displayOrder

        // Act & Assert
        Should.Throw<ArgumentException>(() => purchaseUnit.ConvertToBaseUnit(-1));
    }

    [Fact]
    public void ConvertFromBaseUnit_WithValidQuantity_ShouldCalculateCorrectly()
    {
        // Arrange
        var purchaseUnit = new IngredientPurchaseUnit(
            Guid.NewGuid(),
            Guid.NewGuid(),
            Guid.NewGuid(),
            50000, // 1 thùng bia = 50000ml
            false,
            1); // displayOrder

        // Act
        var result = purchaseUnit.ConvertFromBaseUnit(100000);

        // Assert
        result.ShouldBe(2); // 100000 / 50000 = 2 thùng
    }

    [Fact]
    public void ConvertFromBaseUnit_WithIntegerDivision_ShouldRoundDown()
    {
        // Arrange
        var purchaseUnit = new IngredientPurchaseUnit(
            Guid.NewGuid(),
            Guid.NewGuid(),
            Guid.NewGuid(),
            24, // 1 thùng = 24 lon
            false,
            1); // displayOrder

        // Act
        var result = purchaseUnit.ConvertFromBaseUnit(50);

        // Assert
        result.ShouldBe(2); // 50 / 24 = 2.08... -> 2 (integer division)
    }

    [Theory]
    [InlineData(1, 1)]
    [InlineData(6, 6)]
    [InlineData(24, 24)]
    [InlineData(100, 100)]
    public void ConversionRatios_ShouldWorkForVariousValues(int conversionRatio, int quantity)
    {
        // Arrange
        var purchaseUnit = new IngredientPurchaseUnit(
            Guid.NewGuid(),
            Guid.NewGuid(),
            Guid.NewGuid(),
            conversionRatio,
            false,
            1); // displayOrder

        // Act
        var toBase = purchaseUnit.ConvertToBaseUnit(quantity);
        var fromBase = purchaseUnit.ConvertFromBaseUnit(toBase);

        // Assert
        toBase.ShouldBe(quantity * conversionRatio);
        fromBase.ShouldBe(quantity);
    }

    [Fact]
    public void Constructor_WithInvalidConversionRatio_ShouldThrowException()
    {
        // Act & Assert
        Should.Throw<ArgumentException>(() => new IngredientPurchaseUnit(
            Guid.NewGuid(),
            Guid.NewGuid(),
            Guid.NewGuid(),
            0, // Invalid conversion ratio
            false,
            1)); // displayOrder

        Should.Throw<ArgumentException>(() => new IngredientPurchaseUnit(
            Guid.NewGuid(),
            Guid.NewGuid(),
            Guid.NewGuid(),
            -1, // Invalid conversion ratio
            false,
            1)); // displayOrder
    }
}