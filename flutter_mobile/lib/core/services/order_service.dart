import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../enums/restaurant_enums.dart';
import '../models/table_models.dart';
import '../models/menu_models.dart';
import '../models/order_request_models.dart';
import 'http_client_service.dart';

/// Service xử lý quản lý đơn hàng và bàn trong nhà hàng
class OrderService extends ChangeNotifier {
  late Dio _dio;
  final HttpClientService _httpClientService;
  List<ActiveTableDto> _activeTables = [];
  bool _isLoading = false;
  String? _lastError;

  OrderService({required String? accessToken}) : _httpClientService = HttpClientService() {
    _dio = _httpClientService.dio;
  }

  // Getters
  List<ActiveTableDto> get activeTables => _activeTables;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;


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
        print('✅ OrderService: Successfully loaded ${_activeTables.length} tables');
        for (final table in _activeTables) {
          print('🪑 Table ${table.tableNumber} (${table.status.displayName}) in ${table.layoutSectionName ?? "No section"}');
        }

        return _activeTables;
      } else {
        throw OrderServiceException(
          message: 'Phản hồi không hợp lệ từ server',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ OrderService: DioException - ${e.message}');
      if (e.response != null) {
        print('📄 Response status: ${e.response!.statusCode}');
        print('📄 Response data: ${e.response!.data}');
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
    return _activeTables.where((table) => table.pendingServeOrdersCount > 0).toList();
  }

  /// Refresh danh sách bàn
  Future<void> refreshTables() async {
    await getActiveTables();
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

        print('✅ OrderService: Successfully loaded ${categories.length} menu categories');
        for (final category in categories) {
          print('🍽️ Category: ${category.displayName} (${category.id})');
        }

        return categories;
      } else {
        throw OrderServiceException(
          message: 'Phản hồi không hợp lệ từ server khi lấy danh mục',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ OrderService: DioException getting menu categories - ${e.message}');
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
  Future<CreateOrderResponse> createOrder(CreateOrderRequest request) async {
    // Validate request
    final validationErrors = request.validate();
    if (validationErrors.isNotEmpty) {
      final errorMessage = 'Đơn hàng không hợp lệ:\n${validationErrors.join('\n')}';
      throw OrderServiceException(
        message: errorMessage,
        errorCode: 'VALIDATION_ERROR',
      );
    }

    _setLoading(true);
    _clearError();

    try {
      final response = await _dio.post(
        '/api/app/order',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final orderResponse = CreateOrderResponse.fromJson(response.data);
        return orderResponse;
      } else {
        throw OrderServiceException(
          message: 'Phản hồi không hợp lệ từ server khi tạo đơn hàng',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
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

  @override
  void dispose() {
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