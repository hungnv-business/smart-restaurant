using Volo.Abp.Reflection;

namespace SmartRestaurant.Permissions;

public static class SmartRestaurantPermissions
{
    public const string GroupName = "SmartRestaurant";

    public static class Dashboard
    {
        public const string Default = GroupName + ".Dashboard";
    }

    public static class Orders
    {
        public const string Default = GroupName + ".Orders";
    }

    public static class Menu
    {
        public const string Default = GroupName + ".Menu";
        public const string Categories = Default + ".Categories";
        public const string Items = Default + ".Items";
    }

    public static class Tables
    {
        public const string Default = GroupName + ".Tables";

        public static class LayoutSection
        {
            public const string Default = GroupName + ".LayoutSection";
            public const string Create = Default + ".Create";
            public const string Edit = Default + ".Edit";
            public const string Delete = Default + ".Delete";
        }

        public static class Table
        {
            public const string Default = GroupName + ".Table";
            public const string Create = Default + ".Create";
            public const string Edit = Default + ".Edit";
            public const string Delete = Default + ".Delete";
            public const string AssignTableToSection = Default + ".AssignTableToSection";
            public const string EditTableOrder = Default + ".EditTableOrder";
        }
    }

    public static class Kitchen
    {
        public const string Default = GroupName + ".Kitchen";
        public const string UpdateStatus = Default + ".UpdateStatus";
    }

    public static class Payments
    {
        public const string Default = GroupName + ".Payments";
    }

    public static class Reports
    {
        public const string Default = GroupName + ".Reports";
        public const string Revenue = Default + ".Revenue";
        public const string Popular = Default + ".Popular";
        public const string Staff = Default + ".Staff";
    }

    public static class Settings
    {
        public const string Default = GroupName + ".Settings";
        public const string Printers = Default + ".Printers";
    }

    public static class Inventory
    {
        public const string Default = GroupName + ".Inventory";
    }

    public static class Customers
    {
        public const string Default = GroupName + ".Customers";
    }

    public static class Payroll
    {
        public const string Default = GroupName + ".Payroll";
        public const string Salary = Default + ".Salary";
    }

    public static class Delivery
    {
        public const string Default = GroupName + ".Delivery";
        public const string Takeaway = Default + ".Takeaway";
    }

    public static string[] GetAll()
    {
        return ReflectionHelper.GetPublicConstantsRecursively(typeof(SmartRestaurantPermissions));
    }
}
