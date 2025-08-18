using Volo.Abp.Modularity;

namespace SmartRestaurant;

public abstract class SmartRestaurantApplicationTestBase<TStartupModule> : SmartRestaurantTestBase<TStartupModule>
    where TStartupModule : IAbpModule
{

}
