using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Volo.Abp.Authorization;
using Volo.Abp.Modularity;

namespace SmartRestaurant;

[DependsOn(
    typeof(SmartRestaurantApplicationModule),
    typeof(SmartRestaurantDomainTestModule)
)]
public class SmartRestaurantApplicationTestModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        // Disable authorization for tests
        context.Services.Replace(ServiceDescriptor.Singleton<IAuthorizationService, AlwaysAllowAuthorizationService>());
    }
}
