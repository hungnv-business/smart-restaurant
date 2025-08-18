import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String _baseUrl = 'https://localhost:44346';
  static const String _tokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  late Dio _dio;
  final FlutterSecureStorage _secureStorage;
  late SharedPreferences _prefs;

  ApiClient({FlutterSecureStorage? secureStorage}) 
      : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(milliseconds: 30000),
      receiveTimeout: const Duration(milliseconds: 30000),
      sendTimeout: const Duration(milliseconds: 30000),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Request interceptor for adding JWT token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // Log request for debugging
        _logRequest(options);
        
        handler.next(options);
      },
      
      onResponse: (response, handler) {
        // Log response for debugging
        _logResponse(response);
        handler.next(response);
      },
      
      onError: (error, handler) async {
        // Log error for debugging
        _logError(error);
        
        // Handle 401 Unauthorized - try to refresh token
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the original request
            final options = error.requestOptions;
            final token = await getToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            
            try {
              final response = await _dio.request(
                options.path,
                data: options.data,
                queryParameters: options.queryParameters,
                options: Options(
                  method: options.method,
                  headers: options.headers,
                ),
              );
              handler.resolve(response);
              return;
            } catch (retryError) {
              // If retry fails, proceed with original error
            }
          }
        }
        
        handler.next(error);
      },
    ));
  }

  // Authentication methods
  Future<Response<Map<String, dynamic>>> login(String username, String password) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/connect/token',
        data: {
          'grant_type': 'password',
          'username': username,
          'password': password,
          'client_id': 'flutter_mobile',
          'client_secret': '1q2w3e*',
          'scope': 'SmartRestaurant offline_access',
        },
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.data != null) {
        final accessToken = response.data!['access_token'] as String?;
        final refreshToken = response.data!['refresh_token'] as String?;
        
        if (accessToken != null) {
          await saveToken(accessToken);
        }
        if (refreshToken != null) {
          await saveRefreshToken(refreshToken);
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  // Token management
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post<Map<String, dynamic>>(
        '/connect/token',
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': 'flutter_mobile',
          'client_secret': '1q2w3e*',
        },
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.data != null) {
        final accessToken = response.data!['access_token'] as String?;
        final newRefreshToken = response.data!['refresh_token'] as String?;
        
        if (accessToken != null) {
          await saveToken(accessToken);
        }
        if (newRefreshToken != null) {
          await saveRefreshToken(newRefreshToken);
        }
        
        return true;
      }
    } catch (e) {
      // Refresh failed, clear tokens
      await logout();
    }
    
    return false;
  }

  // Generic API methods
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Logging methods for debugging
  void _logRequest(RequestOptions options) {
    print('🚀 REQUEST: ${options.method} ${options.baseUrl}${options.path}');
    print('📤 Headers: ${options.headers}');
    if (options.data != null) {
      print('📦 Data: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      print('🔍 Query: ${options.queryParameters}');
    }
  }

  void _logResponse(Response response) {
    print('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
    if (response.data != null) {
      print('📥 Data: ${response.data}');
    }
  }

  void _logError(DioException error) {
    print('❌ ERROR: ${error.requestOptions.method} ${error.requestOptions.path}');
    print('🔥 Status: ${error.response?.statusCode}');
    print('💥 Message: ${error.message}');
    if (error.response?.data != null) {
      print('📄 Error Data: ${error.response!.data}');
    }
  }

  // Check authentication status
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  // Get current user info (placeholder for ABP user info endpoint)
  Future<Response<Map<String, dynamic>>?> getCurrentUser() async {
    try {
      if (!await isAuthenticated()) {
        return null;
      }
      
      return await get<Map<String, dynamic>>('/api/app/current-user');
    } catch (e) {
      return null;
    }
  }
}