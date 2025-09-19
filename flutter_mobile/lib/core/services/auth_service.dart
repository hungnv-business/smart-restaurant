import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/app_constants.dart';
import '../models/auth_models.dart';
import '../utils/jwt_helper.dart';
import 'http_client_service.dart';

/// Service xử lý authentication cho ứng dụng Quán bia
class AuthService extends ChangeNotifier {
  late Dio _dio;
  final HttpClientService _httpClientService;
  AuthResponse? _authResponse;
  UserInfo? _userInfo;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  DateTime? _tokenCreationTime;

  AuthService() : _httpClientService = HttpClientService() {
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
    // Tạo riêng một Dio instance cho auth operations
    _dio = Dio();
    _dio.options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
    );
    
    // Initialize HTTP client service với auth service reference
    _httpClientService.initialize(this);
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
        _tokenCreationTime = DateTime.now();
        
        // Extract user info từ JWT access token
        final userInfoFromJwt = JwtHelper.extractUserInfo(_authResponse!.accessToken);
        
        _userInfo = UserInfo(
          username: userInfoFromJwt?['username'] ?? username,
          displayName: userInfoFromJwt?['display_name'] ?? username,
          roles: userInfoFromJwt?['roles'] ?? ['staff'],
        );

        _isLoggedIn = true;
        
        
        // Lưu authentication state vào persistent storage
        await _saveAuthState();
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
      _tokenCreationTime = null;
      
      // Xóa authentication state khỏi persistent storage
      await _clearAuthState();
      
    } catch (e) {
      // Force logout even if API call fails
      _authResponse = null;
      _userInfo = null;
      _isLoggedIn = false;
      _tokenCreationTime = null;
      await _clearAuthState();
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
        _tokenCreationTime = DateTime.now();
        
        // Update user info từ JWT token mới  
        final userInfoFromJwt = JwtHelper.extractUserInfo(_authResponse!.accessToken);
        if (userInfoFromJwt != null) {
          _userInfo = UserInfo(
            username: userInfoFromJwt['username'] ?? _userInfo?.username ?? '',
            displayName: userInfoFromJwt['display_name'] ?? _userInfo?.displayName ?? '',
            roles: userInfoFromJwt['roles'] ?? _userInfo?.roles ?? ['staff'],
          );
        }
        
        
        // Lưu lại authentication state sau khi refresh
        await _saveAuthState();
        
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
    
    // Sử dụng JWT helper để kiểm tra expiration từ token payload
    return JwtHelper.isTokenExpiredFromJwt(_authResponse!.accessToken);
  }

  /// Kiểm tra và load authentication state từ persistent storage
  Future<void> checkSavedAuthState() async {
    try {
      _setLoading(true);
      
      final prefs = await SharedPreferences.getInstance();
      final authDataJson = prefs.getString('auth_data');
      final userDataJson = prefs.getString('user_data');
      final tokenCreationTimeStr = prefs.getString('token_creation_time');
      
      if (authDataJson != null && userDataJson != null && tokenCreationTimeStr != null) {
        _authResponse = AuthResponse.fromJson(jsonDecode(authDataJson));
        _userInfo = UserInfo.fromJson(jsonDecode(userDataJson));
        _tokenCreationTime = DateTime.parse(tokenCreationTimeStr);
        _isLoggedIn = true;
        
        
        // Notify listeners để trigger SignalR connection (delayed để tránh setState during build)
        Future.microtask(() => notifyListeners());
      }
    } catch (e) {
      await _clearAuthState();
    } finally {
      _setLoading(false);
    }
  }

  /// Lưu authentication state vào persistent storage
  Future<void> _saveAuthState() async {
    if (_authResponse == null || _userInfo == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_data', jsonEncode(_authResponse!.toJson()));
      await prefs.setString('user_data', jsonEncode(_userInfo!.toJson()));
      if (_tokenCreationTime != null) {
        await prefs.setString('token_creation_time', _tokenCreationTime!.toIso8601String());
      }
      
    } catch (e) {
    }
  }

  /// Xóa authentication state khỏi persistent storage
  Future<void> _clearAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_data');
      await prefs.remove('user_data');
      await prefs.remove('token_creation_time');
      
    } catch (e) {
    }
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
    _httpClientService.dispose();
    super.dispose();
  }
}