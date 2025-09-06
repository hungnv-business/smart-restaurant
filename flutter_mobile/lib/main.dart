import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/auth_service.dart';
import 'core/services/order_service.dart';
import 'core/widgets/auth_wrapper.dart';

/// Entry point của ứng dụng Quán bia Mobile
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, OrderService>(
          create: (_) => OrderService(accessToken: null),
          update: (_, auth, previous) => OrderService(
            accessToken: auth.accessToken,
          ),
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
