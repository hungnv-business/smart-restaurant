import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/auth_models.dart';

/// Service xử lý authentication cho ứng dụng Quán bia
class AuthService extends ChangeNotifier {
  final Dio _dio;
  AuthResponse? _authResponse;
  UserInfo? _userInfo;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  AuthService() : _dio = Dio() {
    _setupDio();
  }

  // Getters
  AuthResponse? get authResponse => _authResponse;
  UserInfo? get userInfo => _userInfo;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get accessToken => _authResponse?.accessToken;

  /// Setup Dio với base URL và interceptors
  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
    );

    // Add auth interceptor để tự động thêm token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authResponse?.accessToken != null && 
              !options.path.contains('/connect/token')) {
            options.headers['Authorization'] = 
                'Bearer ${_authResponse!.accessToken}';
          }
          handler.next(options);
        },
      ),
    );
  }

  /// Đăng nhập với username và password
  Future<void> login(String username, String password) async {
    try {
      _setLoading(true);

      final loginRequest = LoginRequest(
        username: username,
        password: password,
      );

      final response = await _dio.post(
        '/connect/token',
        data: loginRequest.toFormData(),
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        _authResponse = AuthResponse.fromJson(response.data);
        
        // Tạo user info từ username (có thể call API khác để lấy thông tin chi tiết)
        _userInfo = UserInfo(
          username: username,
          displayName: username,
          roles: ['staff'], // Default role
        );

        _isLoggedIn = true;
      } else {
        throw AuthException(
          message: 'Phản hồi không hợp lệ từ server',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      String message = 'Lỗi kết nối';
      String? errorCode;
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        
        switch (statusCode) {
          case 400:
            message = 'Thông tin đăng nhập không hợp lệ';
            errorCode = 'INVALID_CREDENTIALS';
            break;
          case 401:
            message = 'Tên đăng nhập hoặc mật khẩu không đúng';
            errorCode = 'UNAUTHORIZED';
            break;
          case 404:
            message = 'Không tìm thấy dịch vụ xác thực';
            errorCode = 'SERVICE_NOT_FOUND';
            break;
          case 500:
            message = 'Lỗi server nội bộ';
            errorCode = 'INTERNAL_SERVER_ERROR';
            break;
          default:
            message = 'Lỗi không xác định (${statusCode})';
        }

        // Try to get error details from response
        if (e.response!.data != null) {
          try {
            final errorData = e.response!.data;
            if (errorData['error_description'] != null) {
              message = errorData['error_description'];
            } else if (errorData['error'] != null) {
              message = errorData['error'];
            }
          } catch (_) {
            // Ignore parsing errors
          }
        }
      } else {
        // Network error
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            message = 'Timeout kết nối - Kiểm tra mạng';
            errorCode = 'CONNECTION_TIMEOUT';
            break;
          case DioExceptionType.receiveTimeout:
            message = 'Timeout nhận dữ liệu';
            errorCode = 'RECEIVE_TIMEOUT';
            break;
          case DioExceptionType.sendTimeout:
            message = 'Timeout gửi dữ liệu';
            errorCode = 'SEND_TIMEOUT';
            break;
          case DioExceptionType.badCertificate:
            message = 'Lỗi SSL Certificate';
            errorCode = 'BAD_CERTIFICATE';
            break;
          case DioExceptionType.connectionError:
            message = 'Không thể kết nối đến server';
            errorCode = 'CONNECTION_ERROR';
            break;
          case DioExceptionType.unknown:
            message = 'Lỗi không xác định';
            errorCode = 'UNKNOWN_ERROR';
            break;
          default:
            message = 'Lỗi mạng';
            errorCode = 'NETWORK_ERROR';
        }
      }

      throw AuthException(
        message: message,
        errorCode: errorCode,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      
      throw AuthException(
        message: 'Lỗi không xác định: ${e.toString()}',
        errorCode: 'UNKNOWN_ERROR',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    try {
      _setLoading(true);
      
      // TODO: Call logout API if needed
      // await _dio.post('/connect/logout');
      
      _authResponse = null;
      _userInfo = null;
      _isLoggedIn = false;
      
    } catch (e) {
      // Force logout even if API call fails
      _authResponse = null;
      _userInfo = null;
      _isLoggedIn = false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh access token using refresh token
  Future<void> refreshToken() async {
    if (_authResponse?.refreshToken == null) {
      throw AuthException(message: 'Không có refresh token');
    }

    try {
      _setLoading(true);

      final response = await _dio.post(
        '/connect/token',
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': _authResponse!.refreshToken,
          'client_id': 'SmartRestaurant_App',
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        _authResponse = AuthResponse.fromJson(response.data);
        
      } else {
        throw AuthException(
          message: 'Không thể refresh token',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw AuthException(
        message: 'Lỗi khi refresh token: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Kiểm tra token có hết hạn không
  bool isTokenExpired() {
    if (_authResponse == null) return true;
    
    // TODO: Implement proper token expiration check
    // You might want to store the token creation time and compare
    return false;
  }

  /// Set loading state và notify listeners
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }
}