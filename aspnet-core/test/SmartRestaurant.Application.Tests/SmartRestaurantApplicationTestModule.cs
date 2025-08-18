using Volo.Abp.Modularity;

namespace SmartRestaurant;

[DependsOn(
    typeof(SmartRestaurantApplicationModule),
    typeof(SmartRestaurantDomainTestModule)
)]
public class SmartRestaurantApplicationTestModule : AbpModule
{

}
