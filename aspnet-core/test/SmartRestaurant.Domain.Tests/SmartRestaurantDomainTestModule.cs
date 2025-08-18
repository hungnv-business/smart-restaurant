using Volo.Abp.Modularity;

namespace SmartRestaurant;

[DependsOn(
    typeof(SmartRestaurantDomainModule),
    typeof(SmartRestaurantTestBaseModule)
)]
public class SmartRestaurantDomainTestModule : AbpModule
{

}
