using System;
using Volo.Abp;

namespace SmartRestaurant.MenuManagement.MenuItems;

/// <summary>
/// Exception được ném khi tên món ăn đã tồn tại trong cùng danh mục
/// </summary>
public class MenuItemNameAlreadyExistsInCategoryException : BusinessException
{
    /// <summary>
    /// Khởi tạo exception với tên món ăn và ID danh mục bị trùng
    /// </summary>
    /// <param name="name">Tên món ăn bị trùng</param>
    /// <param name="categoryId">ID danh mục</param>
    public MenuItemNameAlreadyExistsInCategoryException(string name, Guid categoryId) 
        : base(SmartRestaurantDomainErrorCodes.MenuItems.NameAlreadyExistsInCategory)
    {
        WithData("Name", name);
        WithData("CategoryId", categoryId);
    }
}