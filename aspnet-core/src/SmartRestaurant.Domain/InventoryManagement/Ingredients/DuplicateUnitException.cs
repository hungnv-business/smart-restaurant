using System;
using Volo.Abp;

namespace SmartRestaurant.InventoryManagement.Ingredients;

/// <summary>
/// Exception được ném khi đơn vị đã tồn tại trong nguyên liệu
/// </summary>
public class DuplicateUnitException : BusinessException
{
    /// <summary>
    /// Khởi tạo exception với thông tin đơn vị trùng lặp
    /// </summary>
    /// <param name="ingredientName">Tên nguyên liệu</param>
    /// <param name="unitName">Tên đơn vị bị trùng</param>
    public DuplicateUnitException(string ingredientName, string unitName)
        : base(SmartRestaurantDomainErrorCodes.Ingredients.DuplicateUnit)
    {
        WithData("IngredientName", ingredientName);
        WithData("UnitName", unitName);
    }
}