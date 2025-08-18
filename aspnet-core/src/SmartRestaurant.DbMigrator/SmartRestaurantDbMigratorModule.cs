using SmartRestaurant.EntityFrameworkCore;
using Volo.Abp.Autofac;
using Volo.Abp.Modularity;

namespace SmartRestaurant.DbMigrator;

[DependsOn(
    typeof(AbpAutofacModule),
    typeof(SmartRestaurantEntityFrameworkCoreModule),
    typeof(SmartRestaurantApplicationContractsModule)
    )]
public class SmartRestaurantDbMigratorModule : AbpModule
{
}
