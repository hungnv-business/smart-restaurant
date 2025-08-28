using System;
using Volo.Abp;

namespace SmartRestaurant.Exceptions;

/// <summary>
/// Exception được ném khi danh mục món ăn không tồn tại trong hệ thống
/// </summary>
public class MenuItemCategoryNotFoundException : BusinessException
{
    /// <summary>
    /// Khởi tạo exception với ID danh mục không tồn tại
    /// </summary>
    /// <param name="categoryId">ID danh mục không tồn tại</param>
    public MenuItemCategoryNotFoundException(Guid categoryId) 
        : base(SmartRestaurantDomainErrorCodes.MenuItems.CategoryNotFound)
    {
        WithData("CategoryId", categoryId);
    }
}