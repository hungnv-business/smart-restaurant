import 'package:dio/dio.dart';
import '../models/menu_models.dart';
import '../models/table_models.dart';
import '../../features/orders/models/order_models.dart';

class ApiClient {
  final Dio _dio;
  
  ApiClient({String baseUrl = 'http://localhost:44346'}) 
    : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  // Table management
  Future<List<TableModel>> getTables() async {
    final response = await _dio.get('/api/tables');
    return (response.data as List)
        .map((json) => TableModel.fromJson(json))
        .toList();
  }

  // Menu management
  Future<List<MenuCategoryModel>> getMenuCategories() async {
    final response = await _dio.get('/api/menu/categories');
    return (response.data as List)
        .map((json) => MenuCategoryModel.fromJson(json))
        .toList();
  }

  Future<List<MenuItemModel>> getMenuItemsByCategory(String categoryId) async {
    final response = await _dio.get('/api/menu/items/category/$categoryId');
    return (response.data as List)
        .map((json) => MenuItemModel.fromJson(json))
        .toList();
  }

  Future<List<MenuItemModel>> searchMenuItems(String query) async {
    final response = await _dio.get('/api/menu/items/search', 
      queryParameters: {'q': query});
    return (response.data as List)
        .map((json) => MenuItemModel.fromJson(json))
        .toList();
  }

  Future<List<String>> getSearchSuggestions(String query) async {
    final response = await _dio.get('/api/menu/search-suggestions', 
      queryParameters: {'q': query});
    return List<String>.from(response.data);
  }

  // Order management
  Future<OrderModel> createOrder(CreateOrderDto orderDto) async {
    final response = await _dio.post('/api/orders', data: orderDto.toJson());
    return OrderModel.fromJson(response.data);
  }

  Future<List<MissingIngredientModel>> checkIngredientAvailability(
    List<OrderItemModel> items
  ) async {
    final response = await _dio.post('/api/orders/check-ingredients', 
      data: {'items': items.map((item) => item.toJson()).toList()});
    return (response.data as List)
        .map((json) => MissingIngredientModel.fromJson(json))
        .toList();
  }

  Future<Duration> getEstimatedCookingTime(List<OrderItemModel> items) async {
    final response = await _dio.post('/api/orders/estimated-time',
      data: {'items': items.map((item) => item.toJson()).toList()});
    return Duration(minutes: response.data['minutes']);
  }

  Future<PaymentResult> processPayment(Map<String, dynamic> paymentData) async {
    final response = await _dio.post('/api/payments/process', data: paymentData);
    return PaymentResult.fromJson(response.data);
  }

  // Order tracking
  Future<OrderModel> getOrder(String orderId) async {
    final response = await _dio.get('/api/orders/$orderId');
    return OrderModel.fromJson(response.data);
  }

  Future<List<OrderModel>> getOrdersByTable(String tableId) async {
    final response = await _dio.get('/api/orders/table/$tableId');
    return (response.data as List)
        .map((json) => OrderModel.fromJson(json))
        .toList();
  }

  Future<List<OrderModel>> getTodayOrders() async {
    final response = await _dio.get('/api/orders/today');
    return (response.data as List)
        .map((json) => OrderModel.fromJson(json))
        .toList();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status, String? notes) async {
    await _dio.put('/api/orders/$orderId/status', data: {
      'status': status.toString().split('.').last,
      'notes': notes,
    });
  }

  Future<void> updateOrderItemStatus(String orderItemId, OrderItemStatus status, String? notes) async {
    await _dio.put('/api/order-items/$orderItemId/status', data: {
      'status': status.toString().split('.').last,
      'notes': notes,
    });
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    await _dio.post('/api/orders/$orderId/cancel', data: {
      'reason': reason,
    });
  }
}