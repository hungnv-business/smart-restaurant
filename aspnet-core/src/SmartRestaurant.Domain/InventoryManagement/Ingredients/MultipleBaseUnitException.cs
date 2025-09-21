using Volo.Abp;

namespace SmartRestaurant.InventoryManagement.Ingredients;

/// <summary>
/// Exception được ném khi cố gắng tạo nhiều đơn vị cơ sở cho một nguyên liệu
/// </summary>
public class MultipleBaseUnitException : BusinessException
{
    /// <summary>
    /// Khởi tạo exception với thông tin nguyên liệu
    /// </summary>
    /// <param name="ingredientName">Tên nguyên liệu</param>
    public MultipleBaseUnitException(string ingredientName)
        : base(SmartRestaurantDomainErrorCodes.Ingredients.MultipleBaseUnit)
    {
        WithData("IngredientName", ingredientName);
    }
}