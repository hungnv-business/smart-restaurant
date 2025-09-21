using Volo.Abp;

namespace SmartRestaurant.MenuManagement.MenuCategories;

/// <summary>
/// Exception được ném khi không thể xóa danh mục món ăn vì còn chứa món ăn
/// </summary>
public class MenuCategoryCannotDeleteWithMenuItemsException : BusinessException
{
    /// <summary>
    /// Khởi tạo exception với tên danh mục không thể xóa
    /// </summary>
    /// <param name="categoryName">Tên danh mục không thể xóa</param>
    public MenuCategoryCannotDeleteWithMenuItemsException(string categoryName)
        : base(SmartRestaurantDomainErrorCodes.MenuCategories.CannotDeleteCategoryWithMenuItems)
    {
        WithData("CategoryName", categoryName);
    }
}