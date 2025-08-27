using Volo.Abp;

namespace SmartRestaurant.Exceptions;

/// <summary>
/// Exception được ném khi tên danh mục nguyên liệu đã tồn tại trong hệ thống
/// </summary>
public class IngredientCategoryNameAlreadyExistsException : BusinessException
{
    /// <summary>
    /// Khởi tạo exception với tên danh mục bị trùng
    /// </summary>
    /// <param name="categoryName">Tên danh mục bị trùng</param>
    public IngredientCategoryNameAlreadyExistsException(string categoryName) 
        : base(SmartRestaurantDomainErrorCodes.IngredientCategories.NameAlreadyExists)
    {
        WithData("CategoryName", categoryName);
    }
}