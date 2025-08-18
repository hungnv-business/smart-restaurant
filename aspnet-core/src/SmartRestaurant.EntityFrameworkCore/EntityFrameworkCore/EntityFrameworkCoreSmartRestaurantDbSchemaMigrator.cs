using System;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using SmartRestaurant.Data;
using Volo.Abp.DependencyInjection;

namespace SmartRestaurant.EntityFrameworkCore;

public class EntityFrameworkCoreSmartRestaurantDbSchemaMigrator
    : ISmartRestaurantDbSchemaMigrator, ITransientDependency
{
    private readonly IServiceProvider _serviceProvider;

    public EntityFrameworkCoreSmartRestaurantDbSchemaMigrator(
        IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    public async Task MigrateAsync()
    {
        /* We intentionally resolve the SmartRestaurantDbContext
         * from IServiceProvider (instead of directly injecting it)
         * to properly get the connection string of the current tenant in the
         * current scope.
         */

        await _serviceProvider
            .GetRequiredService<SmartRestaurantDbContext>()
            .Database
            .MigrateAsync();
    }
}
