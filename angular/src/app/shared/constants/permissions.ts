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

  // Future SmartRestaurant specific permissions
  RESTAURANT: {
    // Orders
    ORDERS_VIEW: 'SmartRestaurant.Orders.Default',
    ORDERS_CREATE: 'SmartRestaurant.Orders.Create',
    ORDERS_UPDATE: 'SmartRestaurant.Orders.Update',
    ORDERS_DELETE: 'SmartRestaurant.Orders.Delete',

    // Menu
    MENU_VIEW: 'SmartRestaurant.Menu.Default',
    MENU_CREATE: 'SmartRestaurant.Menu.Create',
    MENU_UPDATE: 'SmartRestaurant.Menu.Update',
    MENU_DELETE: 'SmartRestaurant.Menu.Delete',

    // Kitchen
    KITCHEN_VIEW: 'SmartRestaurant.Kitchen.View',
    KITCHEN_MANAGE: 'SmartRestaurant.Kitchen.Manage',

    // Reports
    REPORTS_VIEW: 'SmartRestaurant.Reports.View',
    REPORTS_EXPORT: 'SmartRestaurant.Reports.Export',

    // Settings
    SETTINGS_VIEW: 'SmartRestaurant.Settings.View',
    SETTINGS_MANAGE: 'SmartRestaurant.Settings.Manage',
  },
} as const;

// Type helper for IntelliSense
export type PermissionKey = 
  | typeof PERMISSIONS.USERS[keyof typeof PERMISSIONS.USERS]
  | typeof PERMISSIONS.ROLES[keyof typeof PERMISSIONS.ROLES]  
  | typeof PERMISSIONS.RESTAURANT[keyof typeof PERMISSIONS.RESTAURANT];