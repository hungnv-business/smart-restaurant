import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../enums/restaurant_enums.dart';
import '../models/order_request_models.dart';
import '../models/table_models.dart';
import '../models/takeaway_order_details_models.dart';
import 'order_service.dart';
import 'http_client_service.dart';

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
  List<ActiveTableDto> get activeTables => _orderService.activeTables;
  bool get isLoadingTables => _orderService.isLoading;
  String? get lastTablesError => _orderService.lastError;

  /// Tạo order cho cả dine-in và takeaway
  /// orderType: OrderType.dineIn hoặc OrderType.takeaway
  /// tableId: required cho dine-in, null cho takeaway
  Future<CreateOrderResponseDto?> createOrder({
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

  /// Load takeaway orders từ API
  Future<void> loadTakeawayOrders({
    TakeawayStatus? statusFilter,
    DateTime? date,
    String? searchText,
  }) async {
    try {
      _setLoadingTakeaway(true);
      _clearTakeawayError();

      // Gọi API thật thông qua GET method
      final response = await _dio.get(
        '/api/app/order/takeaway-orders',
        queryParameters: {
          if (statusFilter != null) 'statusFilter': statusFilter.index,
          'date': (date ?? DateTime.now()).toIso8601String(),
          if (searchText != null && searchText.isNotEmpty) 'searchText': searchText,
        },
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
          data = [];
        }
            
        _takeawayOrders = data
            .map((json) => TakeawayOrderDto.fromJson(json))
            .toList();

        // Sắp xếp theo thời gian tạo (mới nhất trước)
        _takeawayOrders.sort((a, b) => b.orderTime.compareTo(a.orderTime));
      } else {
        // Fallback to mock data nếu API fail
        _takeawayOrders = _getMockTakeawayOrders();
        
        // Apply filter local
        if (statusFilter != null) {
          _takeawayOrders = _takeawayOrders
              .where((order) => order.status == statusFilter)
              .toList();
        }
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

  /// Delegate table operations to OrderService
  Future<void> loadTables({
    String? tableNameFilter,
    TableStatus? statusFilter,
  }) async {
    await _orderService.getActiveTables(
      tableNameFilter: tableNameFilter,
      statusFilter: statusFilter,
    );
  }

  Future<TableDetailDto> getTableDetails(String tableId) async {
    return await _orderService.getTableDetails(tableId);
  }

  /// Lấy chi tiết takeaway order từ API
  Future<TakeawayOrderDetailsDto> getTakeawayOrderDetails(String orderId) async {
    try {
      _setLoadingTakeaway(true);
      _clearTakeawayError();

      final response = await _dio.get('/api/app/order/takeaway-order-details/$orderId');

      if (response.statusCode == 200 && response.data != null) {
        return TakeawayOrderDetailsDto.fromJson(response.data);
      } else {
        throw Exception('API call failed with status: ${response.statusCode}');
      }
    } catch (e) {
      _setTakeawayError('Lỗi khi tải chi tiết đơn hàng: ${e.toString()}');
      rethrow;
    } finally {
      _setLoadingTakeaway(false);
    }
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
        items: ['Phở Bò Tái', 'Cà phê sữa đá'],
        totalAmount: 110000,
        pickupTime: '14:30',
        status: TakeawayStatus.preparing,
        orderTime: '13:45',
        notes: '',
      ),
      TakeawayOrderDto(
        id: 'TW002',
        orderNumber: 'ORD-MOCK-002',
        customerName: 'Trần Thị B',
        customerPhone: '0987654321',
        items: ['Cơm tấm', 'Nước mía'],
        totalAmount: 80000,
        pickupTime: '15:00',
        status: TakeawayStatus.ready,
        orderTime: '14:15',
        notes: 'Không cần đậu',
      ),
      TakeawayOrderDto(
        id: 'TW003',
        orderNumber: 'ORD-MOCK-003',
        customerName: 'Lê Văn C',
        customerPhone: '0912345678',
        items: ['Bánh mì thịt nướng', 'Bánh flan'],
        totalAmount: 70000,
        pickupTime: '15:15',
        status: TakeawayStatus.delivered,
        orderTime: '14:30',
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

/// DTO cho takeaway order
class TakeawayOrderDto {
  final String id;
  final String orderNumber;
  final String customerName;
  final String customerPhone;
  final List<String> items;
  final int totalAmount;
  final String pickupTime;
  final TakeawayStatus status;
  final String orderTime;
  final String notes;

  const TakeawayOrderDto({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.totalAmount,
    required this.pickupTime,
    required this.status,
    required this.orderTime,
    required this.notes,
  });

  TakeawayOrderDto copyWith({
    String? id,
    String? orderNumber,
    String? customerName,
    String? customerPhone,
    List<String>? items,
    int? totalAmount,
    String? pickupTime,
    TakeawayStatus? status,
    String? orderTime,
    String? notes,
  }) {
    return TakeawayOrderDto(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      pickupTime: pickupTime ?? this.pickupTime,
      status: status ?? this.status,
      orderTime: orderTime ?? this.orderTime,
      notes: notes ?? this.notes,
    );
  }

  String get formattedTotal => '${totalAmount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
    (Match m) => '${m[1]}.',
  )}₫';

  factory TakeawayOrderDto.fromJson(Map<String, dynamic> json) {
    return TakeawayOrderDto(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      items: (json['itemNames'] as List<dynamic>?)?.cast<String>() ?? [],
      totalAmount: json['totalAmount'] ?? 0,
      pickupTime: json['formattedPickupTime'] ?? '',
      status: TakeawayStatus.values[json['status'] ?? 0],
      orderTime: json['formattedOrderTime'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}