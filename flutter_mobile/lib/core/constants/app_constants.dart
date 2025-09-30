import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  
  // API endpoints - đọc từ .env file
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'https://localhost:44346';
  
  // API configuration
  static int get apiTimeout => int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;
  static bool get debugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  
  // ABP Backend Configuration
  static String get oauthClientId => dotenv.env['OAUTH_CLIENT_ID'] ?? 'flutter_mobile';
  static String get oauthClientSecret => dotenv.env['OAUTH_CLIENT_SECRET'] ?? '1q2w3e*';
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  
  // Vietnamese strings
  static const String vietnameseTitle = 'Quán bia Việt Nam';
  static const String orderTabTitle = 'Gọi món';
  static const String takeawayTabTitle = 'Mang về';
  static const String paymentTabTitle = 'Thanh toán';
}