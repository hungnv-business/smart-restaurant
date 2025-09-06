import 'package:dio/dio.dart';
import '../services/auth_service.dart';

/// Interceptor tự động refresh token khi gặp lỗi 401 Unauthorized
class AuthInterceptor extends Interceptor {
  final AuthService authService;
  final Dio dio;

  AuthInterceptor({
    required this.authService,
    required this.dio,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Thêm authorization header nếu có token
    if (authService.accessToken != null && !options.path.contains('/connect/token')) {
      options.headers['Authorization'] = 'Bearer ${authService.accessToken}';
    }
    
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Kiểm tra lỗi 401 và thử refresh token
    if (err.response?.statusCode == 401 && 
        !err.requestOptions.path.contains('/connect/token')) {
      
      try {
        print('🔄 AuthInterceptor: Token expired, attempting refresh...');
        
        // Thử refresh token
        await authService.refreshToken();
        
        // Retry request với token mới
        final requestOptions = err.requestOptions;
        requestOptions.headers['Authorization'] = 'Bearer ${authService.accessToken}';
        
        final response = await dio.fetch(requestOptions);
        
        print('✅ AuthInterceptor: Request retried successfully');
        handler.resolve(response);
        return;
        
      } catch (refreshError) {
        print('❌ AuthInterceptor: Token refresh failed: $refreshError');
        
        // Nếu refresh thất bại, logout user
        await authService.logout();
        
        // Trả về lỗi gốc
        handler.next(err);
        return;
      }
    }
    
    super.onError(err, handler);
  }
}