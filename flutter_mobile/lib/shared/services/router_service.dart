import 'package:go_router/go_router.dart';
import '../constants/route_constants.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/reservations/reservations_screen.dart';
import '../../features/takeaway/takeaway_screen.dart';
import '../widgets/main_scaffold.dart';
import '../widgets/splash_screen.dart';
import '../widgets/login_screen.dart';
import '../widgets/not_found_screen.dart';

class RouterService {
  static final GoRouter router = GoRouter(
    initialLocation: RouteConstants.splash,
    routes: [
      // Splash screen
      GoRoute(
        path: RouteConstants.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Login screen
      GoRoute(
        path: RouteConstants.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Main application with shell route for bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          // Orders feature (Gọi món ăn ở quán)
          GoRoute(
            path: RouteConstants.orders,
            name: 'orders',
            builder: (context, state) => const OrdersScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'orders-new',
                builder: (context, state) => const OrdersScreen(mode: 'new'),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'orders-edit',
                builder: (context, state) => OrdersScreen(
                  mode: 'edit',
                  orderId: state.pathParameters['id'],
                ),
              ),
              GoRoute(
                path: 'detail/:id',
                name: 'orders-detail',
                builder: (context, state) => OrdersScreen(
                  mode: 'detail',
                  orderId: state.pathParameters['id'],
                ),
              ),
            ],
          ),

          // Reservations feature (Đặt bàn)
          GoRoute(
            path: RouteConstants.reservations,
            name: 'reservations',
            builder: (context, state) => const ReservationsScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'reservations-new',
                builder: (context, state) => const ReservationsScreen(mode: 'new'),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'reservations-edit',
                builder: (context, state) => ReservationsScreen(
                  mode: 'edit',
                  reservationId: state.pathParameters['id'],
                ),
              ),
              GoRoute(
                path: 'detail/:id',
                name: 'reservations-detail',
                builder: (context, state) => ReservationsScreen(
                  mode: 'detail',
                  reservationId: state.pathParameters['id'],
                ),
              ),
            ],
          ),

          // Takeaway feature (Gọi đồ mang về)
          GoRoute(
            path: RouteConstants.takeaway,
            name: 'takeaway',
            builder: (context, state) => const TakeawayScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'takeaway-new',
                builder: (context, state) => const TakeawayScreen(mode: 'new'),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'takeaway-edit',
                builder: (context, state) => TakeawayScreen(
                  mode: 'edit',
                  orderId: state.pathParameters['id'],
                ),
              ),
              GoRoute(
                path: 'detail/:id',
                name: 'takeaway-detail',
                builder: (context, state) => TakeawayScreen(
                  mode: 'detail',
                  orderId: state.pathParameters['id'],
                ),
              ),
            ],
          ),

          // Root redirect to orders
          GoRoute(
            path: RouteConstants.root,
            redirect: (context, state) => RouteConstants.orders,
          ),
        ],
      ),

      // Error and utility routes
      GoRoute(
        path: RouteConstants.notFound,
        name: 'not-found',
        builder: (context, state) => const NotFoundScreen(),
      ),
    ],
    
    // Error handler
    errorBuilder: (context, state) => NotFoundScreen(error: state.error),
    
    // Redirect logic for authentication
    redirect: (context, state) {
      // TODO: Implement authentication check here
      // For initial implementation, skip authentication check
      return null;
    },
  );
}