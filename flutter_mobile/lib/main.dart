import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'shared/services/router_service.dart';
import 'shared/constants/vietnamese_constants.dart';

/// Entry point của ứng dụng Smart Restaurant Mobile
/// 
/// Khởi tạo ProviderScope cho state management và chạy ứng dụng chính
void main() {
  runApp(const ProviderScope(child: SmartRestaurantApp()));
}

/// Ứng dụng mobile Smart Restaurant cho khách hàng nhà hàng
/// 
/// Chức năng chính:
/// - Đặt bàn trực tuyến với lựa chọn thời gian và số người
/// - Gọi món từ thực đơn với hình ảnh và mô tả chi tiết
/// - Đặt món mang về với thời gian nhận hàng
/// - Thanh toán trực tuyến an toàn
/// - Theo dõi trạng thái đơn hàng real-time
/// 
/// Tối ưu hóa cho tablet nhà hàng với responsive design
class SmartRestaurantApp extends StatelessWidget {
  /// Constructor với key tùy chọn
  const SmartRestaurantApp({Key? key}) : super(key: key);

  /// Xây dựng giao diện ứng dụng với theme và routing
  /// 
  /// Cấu hình responsive design cho các thiết bị khác nhau
  /// Áp dụng theme nhà hàng với màu sắc và typography phù hợp
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Kích thước thiết kế chuẩn cho tablet nhà hàng (768x1024)
      designSize: const Size(768, 1024),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp.router(
        title: VietnameseConstants.appName,
        debugShowCheckedModeBanner: false,
        
        // Cấu hình routing với GoRouter
        routerConfig: RouterService.router,
        
        // Theme tùy chỉnh cho nhà hàng
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          
          // Font hỗ trợ tốt tiếng Việt có dấu
          fontFamily: 'Inter',
          
          // Theme cho App Bar (thanh tiêu đề)
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            elevation: 2,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          
          // Theme cho các nút bấm
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              textStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              textStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Theme cho các trường nhập liệu
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
          
          // Theme cho card (thẻ hiển thị thông tin)
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            color: Colors.white,
          ),
          
          // Theme cho thanh điều hướng dưới
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.blue[600],
            unselectedItemColor: Colors.grey[600],
            selectedLabelStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
            elevation: 8,
          ),
        ),
        
        // Sử dụng locale tiếng Anh cho Material widgets, text tiếng Việt được hard-code
        locale: const Locale('en', 'US'),
      ),
    );
  }
}
