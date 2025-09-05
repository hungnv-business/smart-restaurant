/// Models cho authentication response từ API
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final String? scope;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    this.scope,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      expiresIn: json['expires_in'] ?? 3600,
      scope: json['scope'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'scope': scope,
    };
  }
}

/// Model cho login request
class LoginRequest {
  final String username;
  final String password;
  final String grantType;
  final String clientId;
  final String scope;

  LoginRequest({
    required this.username,
    required this.password,
    this.grantType = 'password',
    this.clientId = 'SmartRestaurant_App',
    this.scope = 'offline_access SmartRestaurant',
  });

  Map<String, String> toFormData() {
    return {
      'grant_type': grantType,
      'scope': scope,
      'client_id': clientId,
      'username': username,
      'password': password,
    };
  }
}

/// Model cho user info (có thể mở rộng sau)
class UserInfo {
  final String username;
  final String? displayName;
  final List<String> roles;

  UserInfo({
    required this.username,
    this.displayName,
    this.roles = const [],
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      username: json['username'] ?? '',
      displayName: json['display_name'],
      roles: List<String>.from(json['roles'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'display_name': displayName,
      'roles': roles,
    };
  }
}

/// Exception cho authentication errors
class AuthException implements Exception {
  final String message;
  final String? errorCode;
  final int? statusCode;

  AuthException({
    required this.message,
    this.errorCode,
    this.statusCode,
  });

  @override
  String toString() {
    return 'AuthException: $message (${errorCode ?? 'Unknown'})';
  }
}