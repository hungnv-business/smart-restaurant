using SmartRestaurant.Localization;
using Volo.Abp.Authorization.Permissions;
using Volo.Abp.Localization;

namespace SmartRestaurant.Permissions;

public class SmartRestaurantPermissionDefinitionProvider : PermissionDefinitionProvider
{
    public override void Define(IPermissionDefinitionContext context)
    {
        var myGroup = context.AddGroup(SmartRestaurantPermissions.GroupName);
        //Define your own permissions here. Example:
        //myGroup.AddPermission(SmartRestaurantPermissions.MyPermission1, L("Permission:MyPermission1"));
    }

    private static LocalizableString L(string name)
    {
        return LocalizableString.Create<SmartRestaurantResource>(name);
    }
}
