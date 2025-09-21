using System;
using Microsoft.Extensions.DependencyInjection;
using SmartRestaurant.EntityFrameworkCore.InventoryManagement.Ingredients;
using SmartRestaurant.EntityFrameworkCore.InventoryManagement.PurchaseInvoices;
using SmartRestaurant.EntityFrameworkCore.MenuManagement.MenuItems;
using SmartRestaurant.EntityFrameworkCore.TableManagement.Tables;
using SmartRestaurant.EntityFrameworkCore.TableManagement.LayoutSections;
using SmartRestaurant.InventoryManagement.Ingredients;
using SmartRestaurant.InventoryManagement.PurchaseInvoices;
using SmartRestaurant.MenuManagement.MenuItems;
using SmartRestaurant.TableManagement.Tables;
using SmartRestaurant.TableManagement.LayoutSections;
using Volo.Abp.AuditLogging.EntityFrameworkCore;
using Volo.Abp.BackgroundJobs.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore.PostgreSql;
using Volo.Abp.FeatureManagement.EntityFrameworkCore;
using Volo.Abp.Identity.EntityFrameworkCore;
using Volo.Abp.Modularity;
using Volo.Abp.OpenIddict.EntityFrameworkCore;
using Volo.Abp.PermissionManagement.EntityFrameworkCore;
using Volo.Abp.SettingManagement.EntityFrameworkCore;
using Volo.Abp.TenantManagement.EntityFrameworkCore;

namespace SmartRestaurant.EntityFrameworkCore;

[DependsOn(
    typeof(SmartRestaurantDomainModule),
    typeof(AbpIdentityEntityFrameworkCoreModule),
    typeof(AbpOpenIddictEntityFrameworkCoreModule),
    typeof(AbpPermissionManagementEntityFrameworkCoreModule),
    typeof(AbpSettingManagementEntityFrameworkCoreModule),
    typeof(AbpEntityFrameworkCorePostgreSqlModule),
    typeof(AbpBackgroundJobsEntityFrameworkCoreModule),
    typeof(AbpAuditLoggingEntityFrameworkCoreModule),
    typeof(AbpTenantManagementEntityFrameworkCoreModule),
    typeof(AbpFeatureManagementEntityFrameworkCoreModule)
    )]
public class SmartRestaurantEntityFrameworkCoreModule : AbpModule
{
    public override void PreConfigureServices(ServiceConfigurationContext context)
    {
        // https://www.npgsql.org/efcore/release-notes/6.0.html#opting-out-of-the-new-timestamp-mapping-logic
        AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true);

        SmartRestaurantEfCoreEntityExtensionMappings.Configure();
    }

    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        context.Services.AddAbpDbContext<SmartRestaurantDbContext>(options =>
        {
            /* Remove "includeAllEntities: true" to create
             * default repositories only for aggregate roots */
            options.AddDefaultRepositories(includeAllEntities: true);

            // Đăng ký custom repositories
            options.AddRepository<MenuItem, EfCoreMenuItemRepository>();
        });

        Configure<AbpDbContextOptions>(options =>
        {
            /* The main point to change your DBMS.
             * See also SmartRestaurantMigrationsDbContextFactory for EF Core tooling. */
            options.UseNpgsql();
        });
    }
}
