import 'dart:convert';

/// Helper để decode JWT token và extract thông tin
class JwtHelper {
  /// Decode JWT token payload (không verify signature)
  static Map<String, dynamic>? decodePayload(String token) {
    try {
      // JWT format: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode base64 payload
      String payload = parts[1];
      
      // Add padding if needed
      switch (payload.length % 4) {
        case 0:
          break;
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
        default:
          return null;
      }

      final decoded = utf8.decode(base64Url.decode(payload));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Extract user info từ JWT token payload
  static Map<String, dynamic>? extractUserInfo(String token) {
    final payload = decodePayload(token);
    if (payload == null) return null;

    return {
      'username': payload['preferred_username'] ?? payload['unique_name'] ?? '',
      'display_name': payload['given_name'] ?? payload['preferred_username'] ?? payload['unique_name'] ?? '',
      'email': payload['email'] ?? '',
      'roles': _extractRoles(payload),
      'exp': payload['exp'], // Expiration timestamp
      'iat': payload['iat'], // Issued at timestamp
    };
  }

  /// Extract roles từ JWT payload
  static List<String> _extractRoles(Map<String, dynamic> payload) {
    // ABP Framework có thể có role trong nhiều formats
    if (payload['role'] != null) {
      if (payload['role'] is List) {
        return List<String>.from(payload['role']);
      } else if (payload['role'] is String) {
        return [payload['role']];
      }
    }
    
    // Fallback cho các claim khác
    if (payload['roles'] != null && payload['roles'] is List) {
      return List<String>.from(payload['roles']);
    }
    
    return ['staff']; // Default role
  }

  /// Kiểm tra token có expired không (dựa vào exp claim)
  static bool isTokenExpiredFromJwt(String token) {
    final payload = decodePayload(token);
    if (payload == null) return true;

    final exp = payload['exp'];
    if (exp == null) return false;

    // exp là timestamp (seconds since epoch)
    final expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    final now = DateTime.now();
    
    // Add 5 minutes buffer
    final bufferTime = now.add(const Duration(minutes: 5));
    
    return bufferTime.isAfter(expirationTime);
  }
}