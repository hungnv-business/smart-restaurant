using Volo.Abp.Modularity;

namespace SmartRestaurant;

/* Inherit from this class for your domain layer tests. */
public abstract class SmartRestaurantDomainTestBase<TStartupModule> : SmartRestaurantTestBase<TStartupModule>
    where TStartupModule : IAbpModule
{

}
