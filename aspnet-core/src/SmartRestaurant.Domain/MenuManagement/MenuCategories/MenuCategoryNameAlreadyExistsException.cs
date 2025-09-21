using Volo.Abp;

namespace SmartRestaurant.MenuManagement.MenuCategories;

/// <summary>
/// Exception được ném khi tên danh mục món ăn đã tồn tại trong hệ thống
/// </summary>
public class MenuCategoryNameAlreadyExistsException : BusinessException
{
    /// <summary>
    /// Khởi tạo exception với tên danh mục bị trùng
    /// </summary>
    /// <param name="categoryName">Tên danh mục bị trùng</param>
    public MenuCategoryNameAlreadyExistsException(string categoryName)
        : base(SmartRestaurantDomainErrorCodes.MenuCategories.NameAlreadyExists)
    {
        WithData("CategoryName", categoryName);
    }
}