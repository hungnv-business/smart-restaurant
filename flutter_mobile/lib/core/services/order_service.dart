import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../enums/restaurant_enums.dart';
import '../models/table_models.dart';
import '../models/menu_models.dart';
import '../models/order_request_models.dart';
import '../models/ingredient_verification_models.dart';
import '../models/notification_models.dart';
import 'http_client_service.dart';
import 'signalr_service.dart';
import 'notification_service.dart';

/// Service xử lý quản lý đơn hàng và bàn trong nhà hàng
class OrderService extends ChangeNotifier {
  late Dio _dio;
  final HttpClientService _httpClientService;
  final SignalRService? _signalRService;
  final NotificationService? _notificationService;
  
  List<ActiveTableDto> _activeTables = [];
  bool _isLoading = false;
  String? _lastError;
  bool _autoRefreshEnabled = true;
  bool _isDisposed = false;

  OrderService({
    required String? accessToken, 
    SignalRService? signalRService,
    NotificationService? notificationService,
  }) : _httpClientService = HttpClientService(),
       _signalRService = signalRService,
       _notificationService = notificationService {
    _dio = _httpClientService.dio;
    _setupNotificationListeners();
  }

  // Getters
  List<ActiveTableDto> get activeTables => _activeTables;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  bool get autoRefreshEnabled => _autoRefreshEnabled;

  /// Setup notification listeners để auto-refresh data
  void _setupNotificationListeners() {
    _signalRService?.notifications.listen((notification) {
      if (_autoRefreshEnabled) {
        _handleNotificationForAutoRefresh(notification);
      }
      
      // Show notification nếu có NotificationService
      _notificationService?.showNotificationFromSignalR(notification);
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
        refreshTables();
        break;
    }
  }

  /// Enable/disable auto-refresh từ notifications
  void setAutoRefreshEnabled(bool enabled) {
    if (_autoRefreshEnabled != enabled) {
      _autoRefreshEnabled = enabled;
      notifyListeners();
    }
  }


  /// Lấy danh sách tất cả bàn active từ API
  Future<List<ActiveTableDto>> getActiveTables({
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
        '/api/app/order/active-tables',
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
            
        _activeTables = data
            .map((json) => ActiveTableDto.fromJson(json))
            .toList();

        // Sắp xếp theo displayOrder
        _activeTables.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

        // Debug logging

        // Notify listeners để trigger UI rebuild
        notifyListeners();

        return _activeTables;
      } else {
        throw OrderServiceException(
          message: 'Phản hồi không hợp lệ từ server',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      final exception = _handleDioException(e, 'lấy danh sách bàn');
      _setError(exception.message);
      throw exception;
    } catch (e) {
      final message = 'Lỗi không xác định khi lấy danh sách bàn: ${e.toString()}';
      _setError(message);
      throw OrderServiceException(
        message: message,
        errorCode: 'UNKNOWN_ERROR',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Lấy thông tin bàn theo ID
  Future<ActiveTableDto?> getTableById(String tableId) async {
    try {
      final tables = await getActiveTables();
      return tables.firstWhere(
        (table) => table.id == tableId,
        orElse: () => throw OrderServiceException(
          message: 'Không tìm thấy bàn với ID: $tableId',
          errorCode: 'TABLE_NOT_FOUND',
        ),
      );
    } catch (e) {
      if (e is OrderServiceException) rethrow;
      throw OrderServiceException(
        message: 'Lỗi khi tìm bàn: ${e.toString()}',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Lấy danh sách bàn theo trạng thái
  List<ActiveTableDto> getTablesByStatus(TableStatus status) {
    return _activeTables.where((table) => table.status == status).toList();
  }

  /// Lấy danh sách bàn theo khu vực
  List<ActiveTableDto> getTablesBySection(String? sectionId) {
    if (sectionId == null) {
      return _activeTables.where((table) => table.layoutSectionId == null).toList();
    }
    return _activeTables
        .where((table) => table.layoutSectionId == sectionId)
        .toList();
  }

  /// Lấy danh sách bàn có đơn hàng đang active
  List<ActiveTableDto> getTablesWithActiveOrders() {
    return _activeTables.where((table) => table.hasActiveOrders).toList();
  }

  /// Lấy danh sách bàn có món chờ phục vụ
  List<ActiveTableDto> getTablesWithPendingOrders() {
    return _activeTables.where((table) => table.pendingItemsCount > 0).toList();
  }

  /// Refresh danh sách bàn
  Future<void> refreshTables() async {
    if (_isDisposed) {
      return;
    }
    await getActiveTables();
  }

  /// Lấy chi tiết bàn với đầy đủ thông tin đơn hàng
  /// Endpoint: GET /api/app/order/table-details/{tableId}
  Future<TableDetailDto> getTableDetails(String tableId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _dio.get('/api/app/order/table-details/$tableId');

      if (response.statusCode == 200 && response.data != null) {
        final tableDetail = TableDetailDto.fromJson(response.data);
        
        
        return tableDetail;
      } else {
        throw OrderServiceException(
          message: 'Phản hồi không hợp lệ từ server khi lấy chi tiết bàn',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      final exception = _handleDioException(e, 'lấy chi tiết bàn');
      _setError(exception.message);
      throw exception;
    } catch (e) {
      final message = 'Lỗi không xác định khi lấy chi tiết bàn: ${e.toString()}';
      _setError(message);
      throw OrderServiceException(
        message: message,
        errorCode: 'UNKNOWN_ERROR',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Lấy danh sách categories đang hoạt động từ API
  /// Endpoint: GET /api/app/order/active-menu-categories
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
          message: 'Phản hồi không hợp lệ từ server khi lấy danh mục',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final exception = _handleDioException(e, 'lấy danh mục món ăn');
      _setError(exception.message);
      throw exception;
    } catch (e) {
      final message = 'Lỗi không xác định khi lấy danh mục món ăn: ${e.toString()}';
      _setError(message);
      throw OrderServiceException(
        message: message,
        errorCode: 'UNKNOWN_ERROR',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Lấy danh sách món ăn với filtering cho việc tạo đơn hàng
  /// Endpoint: GET /api/app/order/menu-items-for-order
  Future<List<MenuItem>> getMenuItemsForOrder(GetMenuItemsForOrder input) async {
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
            
        final menuItems = data
            .map((json) => MenuItem.fromJson(json))
            .toList();

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
      final message = 'Lỗi không xác định khi lấy danh sách món ăn: ${e.toString()}';
      _setError(message);
      throw OrderServiceException(
        message: message,
        errorCode: 'UNKNOWN_ERROR',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Fallback categories nếu API không thể gọi được
  List<MenuCategory> getFallbackCategories() {
    return const [
      MenuCategory(id: 'all', displayName: 'Tất cả'),
      MenuCategory(id: 'appetizer', displayName: 'Khai vị'),
      MenuCategory(id: 'main', displayName: 'Món chính'),
      MenuCategory(id: 'drink', displayName: 'Nước uống'),
      MenuCategory(id: 'dessert', displayName: 'Tráng miệng'),
    ];
  }

  /// Xử lý lỗi từ Dio
  OrderServiceException _handleDioException(DioException e, String operation) {
    String message = 'Lỗi kết nối khi $operation';
    String? errorCode;

    if (e.response != null) {
      final statusCode = e.response!.statusCode;

      switch (statusCode) {
        case 400:
          message = 'Yêu cầu không hợp lệ khi $operation';
          errorCode = 'BAD_REQUEST';
          break;
        case 401:
          message = 'Không có quyền truy cập để $operation';
          errorCode = 'UNAUTHORIZED';
          break;
        case 403:
          message = 'Bị cấm truy cập để $operation';
          errorCode = 'FORBIDDEN';
          break;
        case 404:
          message = 'Không tìm thấy API để $operation';
          errorCode = 'NOT_FOUND';
          break;
        case 500:
          message = 'Lỗi server khi $operation';
          errorCode = 'INTERNAL_SERVER_ERROR';
          break;
        default:
          message = 'Lỗi không xác định khi $operation (${statusCode})';
      }

      // Try to get error details from response
      if (e.response!.data != null) {
        try {
          final errorData = e.response!.data;
          if (errorData is Map) {
            if (errorData['message'] != null) {
              message = errorData['message'];
            } else if (errorData['error'] != null) {
              message = errorData['error'];
            }
          }
        } catch (_) {
          // Ignore parsing errors
        }
      }
    } else {
      // Network error
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          message = 'Timeout kết nối khi $operation - Kiểm tra mạng';
          errorCode = 'CONNECTION_TIMEOUT';
          break;
        case DioExceptionType.receiveTimeout:
          message = 'Timeout nhận dữ liệu khi $operation';
          errorCode = 'RECEIVE_TIMEOUT';
          break;
        case DioExceptionType.sendTimeout:
          message = 'Timeout gửi dữ liệu khi $operation';
          errorCode = 'SEND_TIMEOUT';
          break;
        case DioExceptionType.badCertificate:
          message = 'Lỗi SSL Certificate khi $operation';
          errorCode = 'BAD_CERTIFICATE';
          break;
        case DioExceptionType.connectionError:
          message = 'Không thể kết nối đến server khi $operation';
          errorCode = 'CONNECTION_ERROR';
          break;
        case DioExceptionType.unknown:
          message = 'Lỗi không xác định khi $operation';
          errorCode = 'UNKNOWN_ERROR';
          break;
        default:
          message = 'Lỗi mạng khi $operation';
          errorCode = 'NETWORK_ERROR';
      }
    }

    return OrderServiceException(
      message: message,
      errorCode: errorCode,
      statusCode: e.response?.statusCode,
    );
  }

  /// Set loading state và notify listeners
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Set error message
  void _setError(String? error) {
    _lastError = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    if (_lastError != null) {
      _lastError = null;
      notifyListeners();
    }
  }

  /// === ORDER CREATION METHODS ===
  
  /// Tạo đơn hàng mới
  /// Gửi request lên API POST /api/app/orders
  Future<CreateOrderResponseDto?> createOrder(CreateOrderDto request) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _dio.post(
        '/api/app/order',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success with response body
        final orderResponse = CreateOrderResponseDto.fromJson(response.data);
        return orderResponse;
      } else if (response.statusCode == 204) {
        // Success but no content - API chỉ trả về 204 No Content
        // Trả về null vì không có dữ liệu từ server
        return null;
      } else {
        throw OrderServiceException(
          message: 'Phản hồi không hợp lệ từ server khi tạo đơn hàng (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      final exception = _handleDioException(e, 'tạo đơn hàng');
      _setError(exception.message);
      throw exception;
    } catch (e) {
      final message = 'Lỗi không xác định khi tạo đơn hàng: ${e.toString()}';
      _setError(message);
      throw OrderServiceException(message: message, errorCode: 'UNKNOWN_ERROR');
    } finally {
      _setLoading(false);
    }
  }

  /// Thêm món vào order hiện có của bàn  
  /// Gửi request lên API POST /api/app/order/{orderId}/add-items
  Future<void> addItemsToOrder(String orderId, AddItemsToOrderDto request) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _dio.post(
        '/api/app/order/items-to-order/$orderId',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return; // Void method, không trả về gì
      } else {
        throw OrderServiceException(
          message: 'Phản hồi không hợp lệ từ server khi thêm món',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      final exception = _handleDioException(e, 'thêm món vào order');
      _setError(exception.message);
      throw exception;
    } catch (e) {
      final message = 'Lỗi không xác định khi thêm món vào order: ${e.toString()}';
      _setError(message);
      throw OrderServiceException(message: message, errorCode: 'UNKNOWN_ERROR');
    } finally {
      _setLoading(false);
    }
  }

  /// Xóa món ăn khỏi order
  /// Gửi request lên API DELETE /api/app/order/order-item
  Future<void> removeOrderItem(String orderId, String orderItemId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _dio.delete(
        '/api/app/order/order-item',
        queryParameters: {
          'orderId': orderId,
          'orderItemId': orderItemId,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
      } else {
        throw OrderServiceException(
          message: 'Phản hồi không hợp lệ từ server khi xóa món',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      final exception = _handleDioException(e, 'xóa món khỏi order');
      _setError(exception.message);
      throw exception;
    } catch (e) {
      final message = 'Lỗi không xác định khi xóa món khỏi order: ${e.toString()}';
      _setError(message);
      throw OrderServiceException(message: message, errorCode: 'UNKNOWN_ERROR');
    } finally {
      _setLoading(false);
    }
  }

  /// Cập nhật số lượng món trong order
  /// Gửi request lên API PUT /api/app/order/order-item-quantity
  Future<void> updateOrderItemQuantity(String orderId, String orderItemId, int newQuantity, {String? notes}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _dio.put(
        '/api/app/order/order-item-quantity',
        queryParameters: {
          'orderId': orderId,
          'orderItemId': orderItemId,
        },
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
      if (e.response != null) {
      }
      final exception = _handleDioException(e, 'cập nhật số lượng món');
      _setError(exception.message);
      throw exception;
    } catch (e) {
      final message = 'Lỗi không xác định khi cập nhật số lượng: ${e.toString()}';
      _setError(message);
      throw OrderServiceException(message: message, errorCode: 'UNKNOWN_ERROR');
    } finally {
      _setLoading(false);
    }
  }

  /// Kiểm tra tồn kho nguyên liệu cho các món trong order
  /// Endpoint: POST /api/app/order/verify-ingredients-availability
  Future<IngredientAvailabilityResultDto> verifyIngredientsAvailability(VerifyIngredientsRequestDto request) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _dio.post(
        '/api/app/order/verify-ingredients-availability',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final result = IngredientAvailabilityResultDto.fromJson(response.data);
        

        return result;
      } else {
        throw OrderServiceException(
          message: 'Phản hồi không hợp lệ từ server khi kiểm tra nguyên liệu',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      final exception = _handleDioException(e, 'kiểm tra tồn kho nguyên liệu');
      _setError(exception.message);
      throw exception;
    } catch (e) {
      final message = 'Lỗi không xác định khi kiểm tra nguyên liệu: ${e.toString()}';
      _setError(message);
      throw OrderServiceException(
        message: message,
        errorCode: 'UNKNOWN_ERROR',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Xử lý thanh toán đơn hàng
  /// Endpoint: POST /api/app/order/process-payment
  Future<void> processPayment({
    required String orderId,
    required PaymentMethod paymentMethod,
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
      if (e.response != null) {
      }
      final exception = _handleDioException(e, 'xử lý thanh toán');
      _setError(exception.message);
      throw exception;
    } catch (e) {
      final message = 'Lỗi không xác định khi xử lý thanh toán: ${e.toString()}';
      _setError(message);
      throw OrderServiceException(
        message: message,
        errorCode: 'UNKNOWN_ERROR',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Đánh dấu món đã phục vụ
  /// Endpoint: POST /api/app/order/mark-order-item-served/{orderItemId}
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
          message: 'Phản hồi không hợp lệ từ server khi đánh dấu món đã phục vụ',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      final exception = _handleDioException(e, 'đánh dấu món đã phục vụ');
      _setError(exception.message);
      throw exception;
    } catch (e) {
      final message = 'Lỗi không xác định khi đánh dấu món đã phục vụ: ${e.toString()}';
      _setError(message);
      throw OrderServiceException(message: message, errorCode: 'UNKNOWN_ERROR');
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Không close _dio ở đây vì nó được quản lý bởi HttpClientService
    super.dispose();
  }
}

/// Exception class cho Order Service
class OrderServiceException implements Exception {
  final String message;
  final String? errorCode;
  final int? statusCode;

  const OrderServiceException({
    required this.message,
    this.errorCode,
    this.statusCode,
  });

  @override
  String toString() {
    return 'OrderServiceException: $message';
  }
}