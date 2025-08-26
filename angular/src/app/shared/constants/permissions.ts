/* Permission Constants for SmartRestaurant Application */

export const PERMISSIONS = {
  // ABP Identity - User Management
  USERS: {
    DEFAULT: 'AbpIdentity.Users',
    CREATE: 'AbpIdentity.Users.Create',
    UPDATE: 'AbpIdentity.Users.Update',
    DELETE: 'AbpIdentity.Users.Delete',
  },

  // ABP Identity - Role Management
  ROLES: {
    DEFAULT: 'AbpIdentity.Roles',
    CREATE: 'AbpIdentity.Roles.Create',
    UPDATE: 'AbpIdentity.Roles.Update',
    DELETE: 'AbpIdentity.Roles.Delete',
  },

  // SmartRestaurant specific permissions (matching C# structure exactly)
  RESTAURANT: {
    // Dashboard
    DASHBOARD: 'SmartRestaurant.Dashboard',

    // Orders
    ORDERS: 'SmartRestaurant.Orders',

    // Menu
    MENU: {
      DEFAULT: 'SmartRestaurant.Menu',
      CATEGORIES: {
        DEFAULT: 'SmartRestaurant.MenuCategories',
        CREATE: 'SmartRestaurant.MenuCategories.Create',
        EDIT: 'SmartRestaurant.MenuCategories.Edit',
        DELETE: 'SmartRestaurant.MenuCategories.Delete',
      },
      ITEMS: 'SmartRestaurant.Menu.Items',
    },

    // Tables (parent permission)
    TABLES: {
      DEFAULT: 'SmartRestaurant.Tables',

      // Layout Sections
      LAYOUT_SECTION: {
        DEFAULT: 'SmartRestaurant.LayoutSection',
        CREATE: 'SmartRestaurant.LayoutSection.Create',
        EDIT: 'SmartRestaurant.LayoutSection.Edit',
        DELETE: 'SmartRestaurant.LayoutSection.Delete',
      },

      // Tables
      TABLE: {
        DEFAULT: 'SmartRestaurant.Table',
        CREATE: 'SmartRestaurant.Table.Create',
        EDIT: 'SmartRestaurant.Table.Edit',
        DELETE: 'SmartRestaurant.Table.Delete',
      },
    },

    // Kitchen
    KITCHEN: {
      DEFAULT: 'SmartRestaurant.Kitchen',
      UPDATE_STATUS: 'SmartRestaurant.Kitchen.UpdateStatus',
    },

    // Payments
    PAYMENTS: 'SmartRestaurant.Payments',

    // Reports
    REPORTS: {
      DEFAULT: 'SmartRestaurant.Reports',
      REVENUE: 'SmartRestaurant.Reports.Revenue',
      POPULAR: 'SmartRestaurant.Reports.Popular',
      STAFF: 'SmartRestaurant.Reports.Staff',
    },

    // Settings
    SETTINGS: {
      DEFAULT: 'SmartRestaurant.Settings',
      PRINTERS: 'SmartRestaurant.Settings.Printers',
    },

    // Inventory
    INVENTORY: 'SmartRestaurant.Inventory',

    // Customers
    CUSTOMERS: 'SmartRestaurant.Customers',

    // Payroll
    PAYROLL: {
      DEFAULT: 'SmartRestaurant.Payroll',
      SALARY: 'SmartRestaurant.Payroll.Salary',
    },

    // Delivery
    DELIVERY: {
      DEFAULT: 'SmartRestaurant.Delivery',
      TAKEAWAY: 'SmartRestaurant.Delivery.Takeaway',
    },
  },
} as const;

// Type helper for IntelliSense
export type PermissionKey =
  | (typeof PERMISSIONS.USERS)[keyof typeof PERMISSIONS.USERS]
  | (typeof PERMISSIONS.ROLES)[keyof typeof PERMISSIONS.ROLES]
  | (typeof PERMISSIONS.RESTAURANT)[keyof typeof PERMISSIONS.RESTAURANT];
