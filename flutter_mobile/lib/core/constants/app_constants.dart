import 'package:flutter/foundation.dart';

/// Các hằng số ứng dụng Quán bia
class AppConstants {
  // Thông tin ứng dụng
  static const String appName = 'Quán bia';
  static const String appVersion = '1.0.0';
  
  // Debug mode
  static bool get isDebug => kDebugMode;
  
  // Routes
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String orderRoute = '/order';
  static const String takeawayRoute = '/takeaway';
  static const String paymentRoute = '/payment';
  
  // API endpoints
  // Thay đổi URL này thành IP của máy chạy backend
  // Ví dụ: static const String baseUrl = 'https://192.168.1.100:44346';
  // Hoặc domain name: static const String baseUrl = 'https://your-backend-domain.com';
  static const String baseUrl = 'https://localhost:44346'; // TODO: Update this URL
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  
  // Vietnamese strings
  static const String vietnameseTitle = 'Quán bia Việt Nam';
  static const String orderTabTitle = 'Gọi món';
  static const String takeawayTabTitle = 'Mang về';
  static const String paymentTabTitle = 'Thanh toán';
}