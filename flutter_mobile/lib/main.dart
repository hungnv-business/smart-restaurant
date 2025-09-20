import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/auth/auth_service.dart';
import 'core/services/order/order_service.dart';
import 'core/services/order/shared_order_service.dart';
import 'core/services/notification/signalr_service.dart';
import 'core/services/notification/notification_service.dart';
import 'core/widgets/auth_wrapper.dart';

/// Entry point của ứng dụng Quán bia Mobile
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        // Auth Service
        ChangeNotifierProvider(create: (_) => AuthService()),
        
        // Notification Service
        ChangeNotifierProvider(create: (_) => NotificationService()),
        
        // SignalR Service (depends on AuthService)
        ChangeNotifierProxyProvider<AuthService, SignalRService>(
          create: (context) => SignalRService(authService: context.read<AuthService>()),
          update: (_, auth, previous) => previous ?? SignalRService(authService: auth),
        ),
        
        // Order Service (depends on AuthService, SignalRService, NotificationService)
        ChangeNotifierProxyProvider3<AuthService, SignalRService, NotificationService, OrderService>(
          create: (context) => OrderService(
            accessToken: context.read<AuthService>().accessToken,
            signalRService: context.read<SignalRService>(),
            notificationService: context.read<NotificationService>(),
          ),
          update: (_, auth, signalR, notification, previous) {
            // Reuse existing OrderService if possible, only create new if null
            if (previous != null) {
              return previous;
            }
            return OrderService(
              accessToken: auth.accessToken,
              signalRService: signalR,
              notificationService: notification,
            );
          },
        ),
        
        // Shared Order Service (depends on OrderService)
        ChangeNotifierProxyProvider<OrderService, SharedOrderService>(
          create: (context) => SharedOrderService(orderService: context.read<OrderService>()),
          update: (_, orderService, previous) => previous ?? SharedOrderService(orderService: orderService),
        ),
      ],
      child: const QuanBiaApp(),
    ),
  );
}

/// Ứng dụng mobile Quán bia cho nhân viên
/// 
/// Chức năng chính:
/// - Gọi món từ thực đơn với hình ảnh và mô tả chi tiết
/// - Quản lý đơn hàng mang về
/// - Thanh toán và xử lý hóa đơn
/// - Theo dõi trạng thái đơn hàng real-time
/// 
/// Tối ưu hóa cho tablet nhà hàng với responsive design
class QuanBiaApp extends StatelessWidget {
  /// Constructor với key tùy chọn
  const QuanBiaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}
