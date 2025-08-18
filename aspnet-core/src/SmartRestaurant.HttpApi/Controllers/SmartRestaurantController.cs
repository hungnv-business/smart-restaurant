using SmartRestaurant.Localization;
using Volo.Abp.AspNetCore.Mvc;

namespace SmartRestaurant.Controllers;

/* Inherit your controllers from this class.
 */
public abstract class SmartRestaurantController : AbpControllerBase
{
    protected SmartRestaurantController()
    {
        LocalizationResource = typeof(SmartRestaurantResource);
    }
}
