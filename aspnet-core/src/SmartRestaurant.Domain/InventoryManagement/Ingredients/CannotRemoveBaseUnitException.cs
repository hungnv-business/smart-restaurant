using System;
using Volo.Abp;

namespace SmartRestaurant.InventoryManagement.Ingredients;

/// <summary>
/// Exception được ném khi cố gắng xóa đơn vị cơ sở
/// </summary>
public class CannotRemoveBaseUnitException : BusinessException
{
    /// <summary>
    /// Khởi tạo exception với thông tin đơn vị cơ sở
    /// </summary>
    /// <param name="unitName">Tên đơn vị cơ sở</param>
    /// <param name="ingredientName">Tên nguyên liệu</param>
    public CannotRemoveBaseUnitException(string unitName, string ingredientName) 
        : base(SmartRestaurantDomainErrorCodes.Ingredients.CannotRemoveBaseUnit)
    {
        WithData("UnitName", unitName);
        WithData("IngredientName", ingredientName);
    }
}