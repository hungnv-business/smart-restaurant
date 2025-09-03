using System;
using Volo.Abp;

namespace SmartRestaurant.InventoryManagement.Ingredients;

/// <summary>
/// Exception được ném khi nguyên liệu không có đơn vị cơ sở
/// </summary>
public class BaseUnitNotConfiguredException : BusinessException
{
    /// <summary>
    /// Khởi tạo exception với thông tin nguyên liệu
    /// </summary>
    /// <param name="ingredientName">Tên nguyên liệu</param>
    public BaseUnitNotConfiguredException(string ingredientName) 
        : base(SmartRestaurantDomainErrorCodes.Ingredients.BaseUnitNotConfigured)
    {
        WithData("IngredientName", ingredientName);
    }
}