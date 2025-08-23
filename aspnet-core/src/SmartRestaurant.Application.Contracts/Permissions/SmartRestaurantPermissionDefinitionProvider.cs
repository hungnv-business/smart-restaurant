using SmartRestaurant.Localization;
using Volo.Abp.Authorization.Permissions;
using Volo.Abp.Localization;

namespace SmartRestaurant.Permissions;

public class SmartRestaurantPermissionDefinitionProvider : PermissionDefinitionProvider
{
    public override void Define(IPermissionDefinitionContext context)
    {
        var smartRestaurantGroup = context.AddGroup(SmartRestaurantPermissions.GroupName, L("Permission:SmartRestaurant"));

        // Dashboard permissions
        smartRestaurantGroup.AddPermission(SmartRestaurantPermissions.Dashboard.Default, L("Permission:Dashboard"));

        // Order permissions
        smartRestaurantGroup.AddPermission(SmartRestaurantPermissions.Orders.Default, L("Permission:Orders"));

        // Menu permissions
        var menuPermission = smartRestaurantGroup.AddPermission(SmartRestaurantPermissions.Menu.Default, L("Permission:Menu"));
        menuPermission.AddChild(SmartRestaurantPermissions.Menu.Categories, L("Permission:Menu.Categories"));
        menuPermission.AddChild(SmartRestaurantPermissions.Menu.Items, L("Permission:Menu.Items"));

        // Table Management permissions
        var tablesPermission = smartRestaurantGroup.AddPermission(SmartRestaurantPermissions.Tables.Default, L("Permission:Tables"));

        // Layout Section permissions
        var layoutSectionPermission = tablesPermission.AddChild(SmartRestaurantPermissions.Tables.LayoutSection.Default, L("Permission:Tables.LayoutSection"));
        layoutSectionPermission.AddChild(SmartRestaurantPermissions.Tables.LayoutSection.Create, L("Permission:Tables.LayoutSection.Create"));
        layoutSectionPermission.AddChild(SmartRestaurantPermissions.Tables.LayoutSection.Edit, L("Permission:Tables.LayoutSection.Edit"));
        layoutSectionPermission.AddChild(SmartRestaurantPermissions.Tables.LayoutSection.Delete, L("Permission:Tables.LayoutSection.Delete"));

        // Table permissions
        var tablePermission = tablesPermission.AddChild(SmartRestaurantPermissions.Tables.Table.Default, L("Permission:Tables.Table"));
        tablePermission.AddChild(SmartRestaurantPermissions.Tables.Table.Create, L("Permission:Tables.Table.Create"));
        tablePermission.AddChild(SmartRestaurantPermissions.Tables.Table.Edit, L("Permission:Tables.Table.Edit"));
        tablePermission.AddChild(SmartRestaurantPermissions.Tables.Table.Delete, L("Permission:Tables.Table.Delete"));
        tablePermission.AddChild(SmartRestaurantPermissions.Tables.Table.AssignTableToSection, L("Permission:Tables.Table.AssignTableToSection"));
        tablePermission.AddChild(SmartRestaurantPermissions.Tables.Table.EditTableOrder, L("Permission:Tables.Table.EditTableOrder"));

        // Kitchen permissions
        var kitchenPermission = smartRestaurantGroup.AddPermission(SmartRestaurantPermissions.Kitchen.Default, L("Permission:Kitchen"));
        kitchenPermission.AddChild(SmartRestaurantPermissions.Kitchen.UpdateStatus, L("Permission:Kitchen.UpdateStatus"));

        // Payment permissions
        smartRestaurantGroup.AddPermission(SmartRestaurantPermissions.Payments.Default, L("Permission:Payments"));

        // Reports permissions
        var reportsPermission = smartRestaurantGroup.AddPermission(SmartRestaurantPermissions.Reports.Default, L("Permission:Reports"));
        reportsPermission.AddChild(SmartRestaurantPermissions.Reports.Revenue, L("Permission:Reports.Revenue"));
        reportsPermission.AddChild(SmartRestaurantPermissions.Reports.Popular, L("Permission:Reports.Popular"));
        reportsPermission.AddChild(SmartRestaurantPermissions.Reports.Staff, L("Permission:Reports.Staff"));

        // Settings permissions
        var settingsPermission = smartRestaurantGroup.AddPermission(SmartRestaurantPermissions.Settings.Default, L("Permission:Settings"));
        settingsPermission.AddChild(SmartRestaurantPermissions.Settings.Printers, L("Permission:Settings.Printers"));

        // Inventory permissions
        smartRestaurantGroup.AddPermission(SmartRestaurantPermissions.Inventory.Default, L("Permission:Inventory"));

        // Customer permissions
        smartRestaurantGroup.AddPermission(SmartRestaurantPermissions.Customers.Default, L("Permission:Customers"));

        // Payroll & HR permissions
        var payrollPermission = smartRestaurantGroup.AddPermission(SmartRestaurantPermissions.Payroll.Default, L("Permission:Payroll"));
        payrollPermission.AddChild(SmartRestaurantPermissions.Payroll.Salary, L("Permission:Payroll.Salary"));

        // Delivery & Takeaway permissions
        var deliveryPermission = smartRestaurantGroup.AddPermission(SmartRestaurantPermissions.Delivery.Default, L("Permission:Delivery"));
        deliveryPermission.AddChild(SmartRestaurantPermissions.Delivery.Takeaway, L("Permission:Delivery.Takeaway"));
    }

    private static LocalizableString L(string name)
    {
        return LocalizableString.Create<SmartRestaurantResource>(name);
    }
}
