using System.Threading.Tasks;
using SmartRestaurant.Permissions;
using Volo.Abp.Authorization.Permissions;
using Volo.Abp.Data;
using Volo.Abp.DependencyInjection;
using Volo.Abp.Guids;
using Volo.Abp.Identity;
using Volo.Abp.PermissionManagement;
using Volo.Abp.Uow;

namespace SmartRestaurant.Data;

public class RestaurantRoleDataSeedContributor : IDataSeedContributor, ITransientDependency
{
    private readonly IIdentityRoleRepository _roleRepository;
    private readonly IPermissionManager _permissionManager;
    private readonly IPermissionDefinitionManager _permissionDefinitionManager;
    private readonly IGuidGenerator _guidGenerator;

    public RestaurantRoleDataSeedContributor(
        IIdentityRoleRepository roleRepository,
        IPermissionManager permissionManager,
        IPermissionDefinitionManager permissionDefinitionManager,
        IGuidGenerator guidGenerator)
    {
        _roleRepository = roleRepository;
        _permissionManager = permissionManager;
        _permissionDefinitionManager = permissionDefinitionManager;
        _guidGenerator = guidGenerator;
    }

    [UnitOfWork]
    public async Task SeedAsync(DataSeedContext context)
    {
        await SeedRolesAsync();
    }

    private async Task SeedRolesAsync()
    {
        // Admin Role - Full system access
        await CreateRoleIfNotExistsAsync("Admin", SmartRestaurantPermissions.GetAll());

        // Owner Role
        await CreateRoleIfNotExistsAsync("Owner", new[]
        {
            SmartRestaurantPermissions.Dashboard.Default,
            SmartRestaurantPermissions.Menu.Default,
            SmartRestaurantPermissions.Menu.Categories.Default,
            SmartRestaurantPermissions.Menu.Items,
            SmartRestaurantPermissions.Inventory.Default,
            SmartRestaurantPermissions.Customers.Default,
            SmartRestaurantPermissions.Payroll.Default,
            SmartRestaurantPermissions.Payroll.Salary,
            SmartRestaurantPermissions.Tables.Default,
            SmartRestaurantPermissions.Reports.Default,
            SmartRestaurantPermissions.Reports.Revenue,
            SmartRestaurantPermissions.Reports.Popular,
            SmartRestaurantPermissions.Reports.Staff
        });

        // Waiter Role
        await CreateRoleIfNotExistsAsync("Waiter", new[]
        {
            SmartRestaurantPermissions.Orders.Default,
            SmartRestaurantPermissions.Delivery.Default,
            SmartRestaurantPermissions.Delivery.Takeaway,
            SmartRestaurantPermissions.Tables.Default,
            SmartRestaurantPermissions.Menu.Default
        });

        // Kitchen Role
        await CreateRoleIfNotExistsAsync("Kitchen", new[]
        {
            SmartRestaurantPermissions.Kitchen.Default,
            SmartRestaurantPermissions.Kitchen.UpdateStatus
        });

        // Cashier Role
        await CreateRoleIfNotExistsAsync("Cashier", new[]
        {
            SmartRestaurantPermissions.Payments.Default,
            SmartRestaurantPermissions.Orders.Default,
            SmartRestaurantPermissions.Tables.Default
        });
    }

    private async Task CreateRoleIfNotExistsAsync(string name, string[] permissions)
    {
        var existingRole = await _roleRepository.FindByNormalizedNameAsync(name.ToUpperInvariant());
        
        if (existingRole == null)
        {
            var role = new IdentityRole(
                id: _guidGenerator.Create(),
                name: name,
                tenantId: null
            );

            await _roleRepository.InsertAsync(role);

            // Grant permissions to the role
            foreach (var permission in permissions)
            {
                try
                {
                    await _permissionManager.SetAsync(permission, RolePermissionValueProvider.ProviderName, name, true);
                }
                catch
                {
                    // Permission might not exist yet, skip it
                }
            }
        }
    }
}