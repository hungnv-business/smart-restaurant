import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../interceptors/auth_interceptor.dart';
import 'auth_service.dart';

/// Singleton HTTP client service với auth interceptor
class HttpClientService {
  static HttpClientService? _instance;
  late Dio _dio;
  AuthService? _authService;

  HttpClientService._internal() {
    _dio = Dio();
    _setupDio();
  }

  factory HttpClientService() {
    return _instance ??= HttpClientService._internal();
  }

  /// Setup Dio với base configuration
  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  /// Initialize với AuthService reference
  void initialize(AuthService authService) {
    _authService = authService;
    
    // Clear existing interceptors
    _dio.interceptors.clear();
    
    // Add auth interceptor
    _dio.interceptors.add(
      AuthInterceptor(
        authService: authService,
        dio: _dio,
      ),
    );

    // Add logging interceptor trong debug mode
    if (AppConstants.isDebug) {
      _dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ));
    }
  }

  /// Get Dio instance
  Dio get dio => _dio;

  /// Dispose resources
  void dispose() {
    _dio.close();
    _instance = null;
  }
}