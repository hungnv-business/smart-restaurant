using Microsoft.Extensions.Localization;
using SmartRestaurant.Localization;
using Volo.Abp.DependencyInjection;
using Volo.Abp.Ui.Branding;

namespace SmartRestaurant;

[Dependency(ReplaceServices = true)]
public class SmartRestaurantBrandingProvider : DefaultBrandingProvider
{
    private IStringLocalizer<SmartRestaurantResource> _localizer;

    public SmartRestaurantBrandingProvider(IStringLocalizer<SmartRestaurantResource> localizer)
    {
        _localizer = localizer;
    }

    public override string AppName => _localizer["AppName"];
}
