import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../../models/user_model.dart';

// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthService(apiClient);
});

// Authentication state provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthStateNotifier(authService);
});

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<LoginResult> login(String username, String password) async {
    try {
      final response = await _apiClient.login(username, password);
      
      if (response.statusCode == 200 && response.data != null) {
        // Try to get user info after successful login
        final userResponse = await _apiClient.getCurrentUser();
        UserModel? user;
        
        if (userResponse?.data != null) {
          user = UserModel.fromJson(userResponse!.data!);
        }
        
        return LoginResult(
          success: true,
          user: user,
          message: 'Đăng nhập thành công',
        );
      } else {
        return LoginResult(
          success: false,
          message: 'Đăng nhập thất bại',
        );
      }
    } on DioException catch (e) {
      String message = 'Đăng nhập thất bại';
      
      if (e.response?.statusCode == 400) {
        message = 'Tên đăng nhập hoặc mật khẩu không đúng';
      } else if (e.response?.statusCode == 401) {
        message = 'Tài khoản không có quyền truy cập';
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        message = 'Kết nối bị timeout. Vui lòng thử lại';
      } else if (e.type == DioExceptionType.connectionError) {
        message = 'Không thể kết nối đến server';
      }
      
      return LoginResult(
        success: false,
        message: message,
      );
    } catch (e) {
      return LoginResult(
        success: false,
        message: 'Đã xảy ra lỗi không mong muốn',
      );
    }
  }

  Future<void> logout() async {
    await _apiClient.logout();
  }

  Future<bool> isAuthenticated() async {
    return await _apiClient.isAuthenticated();
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _apiClient.getCurrentUser();
      if (response?.data != null) {
        return UserModel.fromJson(response!.data!);
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
    return null;
  }

  Future<String?> getToken() async {
    return await _apiClient.getToken();
  }
}

class LoginResult {
  final bool success;
  final String message;
  final UserModel? user;

  LoginResult({
    required this.success,
    required this.message,
    this.user,
  });
}

// Authentication state classes
class AuthState {
  final bool isAuthenticated;
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      if (isAuthenticated) {
        final user = await _authService.getCurrentUser();
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          user: null,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        user: null,
        isLoading: false,
        error: 'Lỗi kiểm tra trạng thái đăng nhập',
      );
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _authService.login(username, password);
    
    if (result.success) {
      state = state.copyWith(
        isAuthenticated: true,
        user: result.user,
        isLoading: false,
      );
      return true;
    } else {
      state = state.copyWith(
        isAuthenticated: false,
        user: null,
        isLoading: false,
        error: result.message,
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    await _authService.logout();
    
    state = state.copyWith(
      isAuthenticated: false,
      user: null,
      isLoading: false,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}