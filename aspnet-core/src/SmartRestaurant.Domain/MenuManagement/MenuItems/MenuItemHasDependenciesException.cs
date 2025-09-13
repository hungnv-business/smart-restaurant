using System;
using Volo.Abp;

namespace SmartRestaurant.MenuManagement.MenuItems
{
    /// <summary>
    /// Exception khi MenuItem có dependencies và không thể xóa
    /// </summary>
    public class MenuItemHasDependenciesException : BusinessException
    {
        public MenuItemHasDependenciesException(Guid menuItemId)
            : base(SmartRestaurantDomainErrorCodes.MenuItems.HasDependencies)
        {
            WithData("MenuItemId", menuItemId);
        }
    }
}