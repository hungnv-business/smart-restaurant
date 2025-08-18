// Route constants for SmartRestaurant Mobile App
// English route names with Vietnamese UI labels

class RouteConstants {
  // Root routes
  static const String root = '/';
  static const String login = '/login';
  static const String splash = '/splash';

  // Main feature routes (3 core restaurant staff features)
  static const String orders = '/orders';
  static const String reservations = '/reservations';
  static const String takeaway = '/takeaway';

  // Sub-routes for Orders feature
  static const String ordersNew = '/orders/new';
  static const String ordersEdit = '/orders/edit';
  static const String ordersDetail = '/orders/detail';

  // Sub-routes for Reservations feature
  static const String reservationsNew = '/reservations/new';
  static const String reservationsEdit = '/reservations/edit';
  static const String reservationsDetail = '/reservations/detail';

  // Sub-routes for Takeaway feature
  static const String takeawayNew = '/takeaway/new';
  static const String takeawayEdit = '/takeaway/edit';
  static const String takeawayDetail = '/takeaway/detail';

  // Error and utility routes
  static const String notFound = '/404';
  static const String error = '/error';

  // Navigation item data structure
  static const List<Map<String, dynamic>> mainNavItems = [
    {
      'route': orders,
      'labelVi': 'Gọi món',
      'icon': 'restaurant',
      'description': 'Dine-in ordering for customers eating at tables'
    },
    {
      'route': reservations,
      'labelVi': 'Đặt bàn',
      'icon': 'event_seat',
      'description': 'Table reservations and bookings management'
    },
    {
      'route': takeaway,
      'labelVi': 'Mang về',
      'icon': 'takeout_dining',
      'description': 'Takeaway orders for customers taking food away'
    },
  ];
}