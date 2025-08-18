using System;
using System.Collections.Generic;
using System.Text;
using SmartRestaurant.Localization;
using Volo.Abp.Application.Services;

namespace SmartRestaurant;

/* Inherit your application services from this class.
 */
public abstract class SmartRestaurantAppService : ApplicationService
{
    protected SmartRestaurantAppService()
    {
        LocalizationResource = typeof(SmartRestaurantResource);
    }
}
