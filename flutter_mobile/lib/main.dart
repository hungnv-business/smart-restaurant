import 'package:flutter/material.dart';
import 'core/themes/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/screens/login_screen.dart';

/// Entry point của ứng dụng Smart Restaurant Mobile
void main() {
  runApp(const SmartRestaurantApp());
}

/// Ứng dụng mobile Smart Restaurant cho nhân viên nhà hàng
/// 
/// Chức năng chính:
/// - Gọi món từ thực đơn với hình ảnh và mô tả chi tiết
/// - Quản lý đơn hàng mang về
/// - Thanh toán và xử lý hóa đơn
/// - Theo dõi trạng thái đơn hàng real-time
/// 
/// Tối ưu hóa cho tablet nhà hàng với responsive design
class SmartRestaurantApp extends StatelessWidget {
  /// Constructor với key tùy chọn
  const SmartRestaurantApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
      routes: {
        AppConstants.loginRoute: (context) => const LoginScreen(),
      },
    );
  }
}
