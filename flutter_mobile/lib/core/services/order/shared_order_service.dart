import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../enums/restaurant_enums.dart';
import '../../models/order/order_request_models.dart';
import '../../models/order/order_details_models.dart';
import '../../models/order/dinein_table_models.dart';
import '../../models/order/takeaway_models.dart';
import 'order_service.dart';
import '../shared/http_client_service.dart';

/// Shared service để xử lý cả dine-in và takeaway orders
/// Tái sử dụng logic chung, chỉ khác tableId (null cho takeaway)
class SharedOrderService extends ChangeNotifier {
  final OrderService _orderService;
  final HttpClientService _httpClientService;
  late Dio _dio;
  
  // State cho takeaway orders
  List<TakeawayOrderDto> _takeawayOrders = [];
  bool _isLoadingTakeaway = false;
  String? _lastTakeawayError;

  SharedOrderService({required OrderService orderService}) 
      : _orderService = orderService,
        _httpClientService = HttpClientService() {
    _dio = _httpClientService.dio;
  }

  // Getters
  List<TakeawayOrderDto> get takeawayOrders => _takeawayOrders;
  bool get isLoadingTakeaway => _isLoadingTakeaway;
  String? get lastTakeawayError => _lastTakeawayError;

  // Delegate dine-in operations to OrderService
  List<DineInTableDto> get dineInTables => _orderService.dineInTables;
  bool get isLoadingTables => _orderService.isLoading;
  String? get lastTablesError => _orderService.lastError;

  /// Tạo order cho cả dine-in và takeaway
  /// orderType: OrderType.dineIn hoặc OrderType.takeaway
  /// tableId: required cho dine-in, null cho takeaway
  Future<String?> createOrder({
    required OrderType orderType,
    String? tableId,
    required List<CreateOrderItemDto> orderItems,
    String? notes,
    String? customerName,
    String? customerPhone,
  }) async {
    // Validate parameters
    if (orderType == OrderType.dineIn && tableId == null) {
      throw ArgumentError('tableId là bắt buộc cho đơn ăn tại chỗ');
    }
    if (orderType == OrderType.takeaway && (customerName == null || customerPhone == null)) {
      throw ArgumentError('customerName và customerPhone là bắt buộc cho đơn mang về');
    }

    final request = CreateOrderDto(
      orderType: orderType,
      tableId: tableId, // null cho takeaway
      orderItems: orderItems,
      notes: notes,
      customerName: customerName, // thêm cho takeaway
      customerPhone: customerPhone, // thêm cho takeaway
    );

    return await _orderService.createOrder(request);
  }

  /// Load takeaway orders từ API sử dụng method mới
  Future<void> loadTakeawayOrders({
    TakeawayStatus? statusFilter,
  }) async {
    try {
      _setLoadingTakeaway(true);
      _clearTakeawayError();

      // Sử dụng API getTakeawayOrders với endpoint chuẩn
      final Map<String, dynamic> queryParams = {};
      if (statusFilter != null) {
        queryParams['statusFilter'] = statusFilter.index;
      }

      final response = await _dio.get(
        '/api/app/order/takeaway-orders',
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
            
        _takeawayOrders = data
            .map((json) => TakeawayOrderDto.fromJson(json))
            .toList();
      } else {
        throw Exception('Phản hồi không hợp lệ từ server khi lấy danh sách đơn takeaway');
      }

      notifyListeners();
    } catch (e) {
      // Fallback to mock data on error
      _takeawayOrders = _getMockTakeawayOrders();
      
      // Apply filter local
      if (statusFilter != null) {
        _takeawayOrders = _takeawayOrders
            .where((order) => order.status == statusFilter)
            .toList();
      }
      
      notifyListeners();
      _setTakeawayError('Không thể tải đơn mang về từ server, hiển thị dữ liệu mẫu');
    } finally {
      _setLoadingTakeaway(false);
    }
  }

  /// Cập nhật trạng thái đơn takeaway
  Future<void> updateTakeawayOrderStatus({
    required String orderId,
    required TakeawayStatus newStatus,
  }) async {
    try {
      _setLoadingTakeaway(true);
      _clearTakeawayError();

      // Gọi API cập nhật trạng thái
      final response = await _dio.put(
        '/api/app/order/takeaway-status',
        queryParameters: {
          'orderId': orderId,
          'status': newStatus.index,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Update local state khi API thành công
        final orderIndex = _takeawayOrders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          _takeawayOrders[orderIndex] = _takeawayOrders[orderIndex].copyWith(status: newStatus);
          notifyListeners();
        }
      } else {
        throw Exception('API call failed with status: ${response.statusCode}');
      }
    } catch (e) {
      _setTakeawayError('Lỗi khi cập nhật trạng thái: ${e.toString()}');
      rethrow;
    } finally {
      _setLoadingTakeaway(false);
    }
  }

  /// Get filtered takeaway orders
  List<TakeawayOrderDto> getFilteredTakeawayOrders(TakeawayStatus? filter) {
    if (filter == null) return _takeawayOrders;
    return _takeawayOrders.where((order) => order.status == filter).toList();
  }


  /// Load DineIn tables sử dụng API mới
  Future<List<DineInTableDto>> loadDineInTables({
    String? tableNameFilter,
    TableStatus? statusFilter,
  }) async {
    return await _orderService.getDineInTables(
      tableNameFilter: tableNameFilter,
      statusFilter: statusFilter,
    );
  }


  /// Lấy chi tiết đơn hàng thống nhất (thay thế getTableDetails và getTakeawayOrderDetails)
  Future<OrderDetailsDto> getOrderDetails(String orderId) async {
    return await _orderService.getOrderDetails(orderId);
  }


  /// Private helper methods
  void _setLoadingTakeaway(bool loading) {
    if (_isLoadingTakeaway != loading) {
      _isLoadingTakeaway = loading;
      notifyListeners();
    }
  }

  void _setTakeawayError(String? error) {
    _lastTakeawayError = error;
    notifyListeners();
  }

  void _clearTakeawayError() {
    if (_lastTakeawayError != null) {
      _lastTakeawayError = null;
      notifyListeners();
    }
  }

  /// Mock data cho takeaway orders
  List<TakeawayOrderDto> _getMockTakeawayOrders() {
    return [
      TakeawayOrderDto(
        id: 'TW001',
        orderNumber: 'ORD-MOCK-001',
        customerName: 'Nguyễn Văn A',
        customerPhone: '0901234567',
        itemNames: ['Phở Bò Tái', 'Cà phê sữa đá'],
        itemCount: 2,
        totalAmount: 110000,
        paymentTime: DateTime.now().add(const Duration(minutes: 45)),
        status: TakeawayStatus.preparing,
        createdTime: DateTime.now().subtract(const Duration(minutes: 15)),
        statusDisplay: 'Đang chuẩn bị',
        notes: '',
      ),
      TakeawayOrderDto(
        id: 'TW002',
        orderNumber: 'ORD-MOCK-002',
        customerName: 'Trần Thị B',
        customerPhone: '0987654321',
        itemNames: ['Cơm tấm', 'Nước mía'],
        itemCount: 2,
        totalAmount: 80000,
        paymentTime: DateTime.now().add(const Duration(hours: 1)),
        status: TakeawayStatus.ready,
        createdTime: DateTime.now().subtract(const Duration(minutes: 30)),
        statusDisplay: 'Sẵn sàng',
        notes: 'Không cần đậu',
      ),
      TakeawayOrderDto(
        id: 'TW003',
        orderNumber: 'ORD-MOCK-003',
        customerName: 'Lê Văn C',
        customerPhone: '0912345678',
        itemNames: ['Bánh mì thịt nướng', 'Bánh flan'],
        itemCount: 2,
        totalAmount: 70000,
        paymentTime: DateTime.now().add(const Duration(hours: 1, minutes: 15)),
        status: TakeawayStatus.delivered,
        createdTime: DateTime.now().subtract(const Duration(minutes: 45)),
        statusDisplay: 'Đã giao',
        notes: '',
      ),
    ];
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}

