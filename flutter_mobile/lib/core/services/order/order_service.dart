import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../models/notification/notification_models.dart';
import '../../enums/restaurant_enums.dart';
import '../../models/menu/menu_models.dart';
import '../../models/order/dinein_table_models.dart';
import '../../models/order/order_details_models.dart';
import '../../models/order/ingredient_verification_models.dart';
import '../shared/http_client_service.dart';
import '../notification/signalr_service.dart';
/// Service xử lý quản lý đơn hàng và bàn trong nhà hàng
class OrderService extends ChangeNotifier {
  late Dio _dio;
  final HttpClientService _httpClientService;
  final SignalRService? _signalRService;

  List<DineInTableDto> _dineInTables = [];
  bool _isLoading = false;
  String? _lastError;
  bool _autoRefreshEnabled = true;

  OrderService({
    required String? accessToken,
    SignalRService? signalRService,
  }) : _httpClientService = HttpClientService(),
       _signalRService = signalRService {
    _dio = _httpClientService.dio;
    _setupNotificationListeners();
  }

  // Getters
  List<DineInTableDto> get dineInTables => _dineInTables;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  bool get autoRefreshEnabled => _autoRefreshEnabled;

  /// Setup notification listeners để auto-refresh data
  void _setupNotificationListeners() {
    _signalRService?.notifications.listen((notification) {
      if (_autoRefreshEnabled) {
        _handleNotificationForAutoRefresh(notification);
      }
    });
  }

  /// Xử lý notification để auto-refresh data
  void _handleNotificationForAutoRefresh(BaseNotification notification) {
    switch (notification.type) {
      case NotificationType.newOrder:
      case NotificationType.orderItemServed:
      case NotificationType.orderItemQuantityUpdated:
      case NotificationType.orderItemsAdded:
      case NotificationType.orderItemRemoved:
      case NotificationType.orderItemStatusUpdated:
      case NotificationType.other:
        // Delay 2 giây trước khi refresh để đảm bảo backend đã xử lý xong
        Future.delayed(const Duration(seconds: 2), () {
          refreshTables();
        });
        break;
    }
  }

  /// Refresh danh sách bàn (gọi lại API để lấy data mới nhất)
  void refreshTables() {
    getDineInTables();
  }

  /// Enable/disable auto-refresh từ notifications
  void setAutoRefreshEnabled(bool enabled) {
    if (_autoRefreshEnabled != enabled) {
      _autoRefreshEnabled = enabled;
      notifyListeners();
    }
  }

  /// Lấy danh sách bàn DineIn (thay thế cho getActiveTables)
  /// Endpoint: GET /api/app/order/dine-in-tables
  Future<List<DineInTableDto>> getDineInTables({
    String? tableNameFilter,
    TableStatus? statusFilter,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Build query parameters
      final Map<String, dynamic> queryParams = {};
      if (tableNameFilter != null && tableNameFilter.isNotEmpty) {
        queryParams['tableNameFilter'] = tableNameFilter;
      }
      if (statusFilter != null) {
        queryParams['statusFilter'] = statusFilter.index;
      }

      final response = await _dio.get(
        '/api/app/order/dine-in-tables',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data;

        // Handle ABP Framework response format: {"items": [...]}
        if (response.data is Map<String, dynamic> &&
            response.data.containsKey('items')) {
          data = response.data['items'] as List<dynamic>;
        } else if (response.data is List) {
          data = response.data;
        } else {
          data = [response.data];
        }

        final dineInTables = data
            .map((json) => DineInTableDto.fromJson(json))
            .toList();

        // Sắp xếp theo displayOrder
        dineInTables.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

        // Update internal state
        _dineInTables = dineInTables;

        // Notify listeners để trigger UI rebuild
        notifyListeners();

        return dineInTables;
      } else {
        throw OrderServiceException(
          message: 'Phản hồi không hợp lệ từ server khi lấy danh sách bàn',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final exception = _handleDioException(e, 'lấy danh sách bàn');
      _setError(exception.message);
      throw exception;
    } catch (e) {
      final message =
          'Lỗi không xác định khi lấy danh sách bàn: ${e.toString()}';
      _setError(message);
      throw OrderServiceException(message: message, errorCode: 'UNKNOWN_ERROR');
    } finally {
      _setLoading(false);
    }
  }

  /// Lấy chi tiết đơn hàng thống nhất (cả DineIn và Takeaway)
  /// Endpoint: GET /api/app/order/order-details/{orderId}
  Future<OrderDetailsDto> getOrderDetails(String orderId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _dio.get('/api/app/order/order-details/$orderId');

      if (response.statusCode == 200 && response.data != null) {
        final orderDetails = OrderDetailsDto.fromJson(response.data);

        return orderDetails;
      } else {
        throw OrderServiceException(
          message: 'Phản hồi không hợp lệ từ server khi lấy chi tiết đơn hàng',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final exception = _handleDioException(e, 'lấy chi tiết đơn hàng');
      _setError(exception.message);
      throw exception;
    } catch (e) {
      final message =
          'Lỗi không xác định khi lấy chi tiết đơn hàng: ${e.toString()}';
      _setError(message);
      throw OrderServiceException(message: message, errorCode: 'UNKNOWN_ERROR');
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _clearError() {
    if (_lastError != null) {
      _lastError = null;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _lastError = error;
    notifyListeners();
  }

  OrderServiceException _handleDioException(DioException e, String operation) {
    String message;
    String? errorCode;

    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      if (data is Map<String, dynamic>) {
        message = data['error']?['message'] ?? 'Lỗi từ server khi $operation';
        errorCode = data['error']?['code'];
      } else {
        message = 'Lỗi HTTP $statusCode khi $operation';
      }

      return OrderServiceException(
        message: message,
        statusCode: statusCode,
        errorCode: errorCode,
      );
    } else {
      // Network error
      message = 'Lỗi kết nối mạng khi $operation';
      return OrderServiceException(
        message: message,
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  Future<dynamic> createOrder(dynamic request) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _dio.post(
        '/api/app/order',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success with response body
        final orderResponse = response.data;
        return orderResponse;
      } else if (response.statusCode == 204) {
        // Success but no content - API chỉ trả về 204 No Content
        // Trả về null vì không có dữ liệu từ server
        return null;
      } else {
        throw OrderServiceException(
          message:
              'Phản hồi không hợp lệ từ server khi tạo đơn hàng (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final exception = _handleDioException(e, 'tạo đơn hàng');
      _setError(exception.message);
      throw exception;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addItemsToOrder(String orderId, dynamic request) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _dio.post(
        '/api/app/order/items-to-order/$orderId',
        data: request.toJson(),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return; // Void method, không trả về gì
      } else {
        throw OrderServiceException(
          message: 'Phản hồi không hợp lệ từ server khi thêm món',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final exception = _handleDioException(e, 'thêm món vào đơn hàng');
      _setError(exception.message);
      throw exception;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeOrderItem(String orderId, String orderItemId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _dio.delete(
        '/api/app/order/order-item',
        queryParameters: {'orderId': orderId, 'orderItemId': orderItemId},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
      } else {
        throw OrderServiceException(
          message: 'Phản hồi không hợp lệ từ server khi xóa món',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final exception = _handleDioException(e, 'xóa món khỏi đơn hàng');
      _setError(exception.message);
      throw exception;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateOrderItemQuantity(
    String orderId,
    String orderItemId,
    int newQuantity, {
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _dio.put(
        '/api/app/order/order-item-quantity',
        queryParameters: {'orderId': orderId, 'orderItemId': orderItemId},
        data: {
          'newQuantity': newQuantity,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return; // Void method, không trả về gì
      } else {
        throw OrderServiceException(
          message: 'Phản hồi không hợp lệ từ server khi cập nhật số lượng',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final exception = _handleDioException(e, 'cập nhật số lượng món');
      _setError(exception.message);
      throw exception;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markOrderItemServed(String orderItemId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _dio.post(
        '/api/app/order/mark-order-item-served/$orderItemId',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return; // Void method
      } else {
        throw OrderServiceException(
          message:
              'Phản hồi không hợp lệ từ server khi đánh dấu món đã phục vụ',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final exception = _handleDioException(e, 'đánh dấu món đã phục vụ');
      _setError(exception.message);
      throw exception;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> processPayment({
    required String orderId,
    required dynamic paymentMethod,
    required int customerMoney,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _dio.post(
        '/api/app/order/process-payment',
        data: {
          'orderId': orderId,
          'paymentMethod': paymentMethod.index,
          'customerMoney': customerMoney,
          'notes': notes ?? '',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return; // Void method
      } else {
        throw OrderServiceException(
          message: 'Phản hồi không hợp lệ từ server khi xử lý thanh toán',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final exception = _handleDioException(e, 'xử lý thanh toán');
      _setError(exception.message);
      throw exception;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<MenuCategory>> getActiveMenuCategories() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _dio.get('/api/app/order/active-menu-categories');

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data;

        // Handle ABP Framework response format: {"items": [...]}
        if (response.data is Map<String, dynamic> &&
            response.data.containsKey('items')) {
          data = response.data['items'] as List<dynamic>;
        } else if (response.data is List) {
          data = response.data;
        } else {
          data = [response.data];
        }

        final categories = data
            .map((json) => MenuCategory.fromJson(json))
            .toList();

        return categories;
      } else {
        throw OrderServiceException(
          message:
              'Phản hồi không hợp lệ từ server khi lấy danh sách categories',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final exception = _handleDioException(e, 'lấy danh sách categories');
      _setError(exception.message);
      throw exception;
    } catch (e) {
      final message =
          'Lỗi không xác định khi lấy danh sách categories: ${e.toString()}';
      _setError(message);
      throw OrderServiceException(message: message, errorCode: 'UNKNOWN_ERROR');
    } finally {
      _setLoading(false);
    }
  }

  /// Fallback method cho khi API lỗi
  Future<List<MenuCategory>> getFallbackCategories() async {
    try {
      return await getActiveMenuCategories();
    } catch (e) {
      // Return empty list on error for fallback
      return [];
    }
  }

  Future<List<MenuItem>> getMenuItemsForOrder(dynamic input) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _dio.get(
        '/api/app/order/menu-items-for-order',
        queryParameters: input.toQueryParams(),
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data;

        // Handle ABP Framework response format: {"items": [...]}
        if (response.data is Map<String, dynamic> &&
            response.data.containsKey('items')) {
          data = response.data['items'] as List<dynamic>;
        } else if (response.data is List) {
          data = response.data;
        } else {
          data = [response.data];
        }

        final menuItems = data.map((json) => MenuItem.fromJson(json)).toList();

        return menuItems;
      } else {
        throw OrderServiceException(
          message: 'Phản hồi không hợp lệ từ server khi lấy danh sách món ăn',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final exception = _handleDioException(e, 'lấy danh sách món ăn');
      _setError(exception.message);
      throw exception;
    } catch (e) {
      final message =
          'Lỗi không xác định khi lấy danh sách món ăn: ${e.toString()}';
      _setError(message);
      throw OrderServiceException(message: message, errorCode: 'UNKNOWN_ERROR');
    } finally {
      _setLoading(false);
    }
  }

  Future<IngredientAvailabilityResultDto> verifyIngredientsAvailability(
    VerifyIngredientsRequestDto request,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _dio.post(
        '/api/app/order/verify-ingredients-availability',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        return IngredientAvailabilityResultDto.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw OrderServiceException(
          message: 'Phản hồi không hợp lệ từ server khi kiểm tra nguyên liệu',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final exception = _handleDioException(e, 'kiểm tra nguyên liệu');
      _setError(exception.message);
      throw exception;
    } finally {
      _setLoading(false);
    }
  }

}

/// Exception class cho OrderService
class OrderServiceException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  OrderServiceException({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  @override
  String toString() => message;
}
