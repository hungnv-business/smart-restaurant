using System.Threading.Tasks;
using Volo.Abp.DependencyInjection;

namespace SmartRestaurant.Data;

/* This is used if database provider does't define
 * ISmartRestaurantDbSchemaMigrator implementation.
 */
public class NullSmartRestaurantDbSchemaMigrator : ISmartRestaurantDbSchemaMigrator, ITransientDependency
{
    public Task MigrateAsync()
    {
        return Task.CompletedTask;
    }
}
