import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/order_models.dart';

class OrderTrackingService extends ChangeNotifier {
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  
  Order? _currentOrder;
  bool _isLoading = false;
  String? _error;
  bool _isConnected = false;
  String? _trackingOrderId;
  
  final Duration _reconnectInterval = const Duration(seconds: 5);
  final Duration _heartbeatInterval = const Duration(seconds: 30);

  Order? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _isConnected;

  OrderTrackingService() {
    _connectToSignalR();
  }

  Future<void> startTracking(String orderId) async {
    _trackingOrderId = orderId;
    _setLoading(true);
    _setError(null);

    try {
      // First, load order details from API
      await _loadOrderDetails(orderId);
      
      // Then subscribe to real-time updates
      await _subscribeToOrderUpdates(orderId);
      
    } catch (e) {
      _setError('Không thể bắt đầu theo dõi đơn hàng: $e');
    } finally {
      _setLoading(false);
    }
  }

  void stopTracking() {
    _trackingOrderId = null;
    _unsubscribeFromOrderUpdates();
  }

  Future<void> _loadOrderDetails(String orderId) async {
    try {
      // Simulate API call to load order
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock order data - in real app, this would come from API
      _currentOrder = _createMockOrder(orderId);
      notifyListeners();
      
    } catch (e) {
      throw Exception('Không thể tải thông tin đơn hàng: $e');
    }
  }

  Order _createMockOrder(String orderId) {
    final now = DateTime.now();
    return Order(
      id: orderId,
      orderNumber: 'DH${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}',
      orderType: OrderType.dineIn,
      tableId: 'T05',
      status: OrderStatus.preparing, // Start with preparing status
      totalAmount: 195000.0,
      notes: 'Phục vụ nhanh, khách có trẻ nhỏ',
      items: [
        OrderItem(
          id: '1',
          orderId: orderId,
          menuItemId: 'pho-bo-tai',
          menuItemName: 'Phở Bò Tái',
          unitPrice: 65000,
          quantity: 2,
          notes: 'Ít hành',
          status: OrderItemStatus.preparing,
        ),
        OrderItem(
          id: '2',
          orderId: orderId,
          menuItemId: 'com-tam',
          menuItemName: 'Cơm Tấm',
          unitPrice: 55000,
          quantity: 1,
          notes: null,
          status: OrderItemStatus.preparing,
        ),
      ],
      creationTime: now.subtract(const Duration(minutes: 10)),
    );
  }

  Future<void> _subscribeToOrderUpdates(String orderId) async {
    try {
      if (_channel != null && _isConnected) {
        final subscribeMessage = {
          'action': 'SubscribeToOrder',
          'orderId': orderId,
        };
        
        _channel!.sink.add(jsonEncode(subscribeMessage));
        debugPrint('Subscribed to order updates: $orderId');
      }
    } catch (e) {
      debugPrint('Failed to subscribe to order updates: $e');
    }
  }

  void _unsubscribeFromOrderUpdates() {
    try {
      if (_channel != null && _isConnected && _trackingOrderId != null) {
        final unsubscribeMessage = {
          'action': 'UnsubscribeFromOrder',
          'orderId': _trackingOrderId,
        };
        
        _channel!.sink.add(jsonEncode(unsubscribeMessage));
        debugPrint('Unsubscribed from order updates: $_trackingOrderId');
      }
    } catch (e) {
      debugPrint('Failed to unsubscribe from order updates: $e');
    }
  }

  void _connectToSignalR() {
    try {
      // In production, this would be wss://your-api-domain/orderStatusHub
      const wsUrl = 'ws://localhost:44346/orderStatusHub';
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;
      
      // Listen for messages
      _channel!.stream.listen(
        _handleWebSocketMessage,
        onError: _handleWebSocketError,
        onDone: _handleWebSocketDisconnect,
      );
      
      _startHeartbeat();
      debugPrint('Connected to SignalR OrderStatus hub');
      
    } catch (e) {
      _handleWebSocketError(e);
    }
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final messageType = data['type'] as String?;
      
      switch (messageType) {
        case 'OrderStatusChanged':
          _handleOrderStatusUpdate(data);
          break;
        case 'OrderItemStatusChanged':
          _handleOrderItemStatusUpdate(data);
          break;
        case 'OrderUpdated':
          _handleOrderUpdate(data);
          break;
        case 'Heartbeat':
          _handleHeartbeat();
          break;
        default:
          debugPrint('Unknown message type: $messageType');
      }
    } catch (e) {
      debugPrint('Error processing WebSocket message: $e');
    }
  }

  void _handleOrderStatusUpdate(Map<String, dynamic> data) {
    final orderId = data['orderId'] as String;
    final newStatus = data['status'] as String;
    final timestamp = data['timestamp'] as String?;
    
    if (_currentOrder?.id == orderId) {
      final status = OrderStatus.values.firstWhere(
        (s) => s.toString().split('.').last == newStatus,
      );
      
      _currentOrder = Order(
        id: _currentOrder!.id,
        orderNumber: _currentOrder!.orderNumber,
        orderType: _currentOrder!.orderType,
        tableId: _currentOrder!.tableId,
        status: status,
        totalAmount: _currentOrder!.totalAmount,
        notes: _currentOrder!.notes,
        items: _currentOrder!.items,
        creationTime: _currentOrder!.creationTime,
        lastModifiedTime: timestamp != null ? DateTime.parse(timestamp) : DateTime.now(),
      );
      
      notifyListeners();
      debugPrint('Order status updated: $orderId -> $newStatus');
    }
  }

  void _handleOrderItemStatusUpdate(Map<String, dynamic> data) {
    final orderId = data['orderId'] as String;
    final itemId = data['itemId'] as String;
    final newStatus = data['status'] as String;
    
    if (_currentOrder?.id == orderId) {
      final itemIndex = _currentOrder!.items.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        final status = OrderItemStatus.values.firstWhere(
          (s) => s.toString().split('.').last == newStatus,
        );
        
        final updatedItems = List<OrderItem>.from(_currentOrder!.items);
        final currentItem = updatedItems[itemIndex];
        
        updatedItems[itemIndex] = OrderItem(
          id: currentItem.id,
          orderId: currentItem.orderId,
          menuItemId: currentItem.menuItemId,
          menuItemName: currentItem.menuItemName,
          unitPrice: currentItem.unitPrice,
          quantity: currentItem.quantity,
          notes: currentItem.notes,
          status: status,
        );
        
        _currentOrder = Order(
          id: _currentOrder!.id,
          orderNumber: _currentOrder!.orderNumber,
          orderType: _currentOrder!.orderType,
          tableId: _currentOrder!.tableId,
          status: _currentOrder!.status,
          totalAmount: _currentOrder!.totalAmount,
          notes: _currentOrder!.notes,
          items: updatedItems,
          creationTime: _currentOrder!.creationTime,
          lastModifiedTime: DateTime.now(),
        );
        
        notifyListeners();
        debugPrint('Order item status updated: $itemId -> $newStatus');
      }
    }
  }

  void _handleOrderUpdate(Map<String, dynamic> data) {
    try {
      final orderData = data['order'] as Map<String, dynamic>;
      _currentOrder = Order.fromJson(orderData);
      notifyListeners();
      debugPrint('Full order update received');
    } catch (e) {
      debugPrint('Error handling order update: $e');
    }
  }

  void _handleHeartbeat() {
    debugPrint('Heartbeat received from server');
  }

  void _handleWebSocketError(dynamic error) {
    debugPrint('WebSocket error: $error');
    _isConnected = false;
    _setError('Mất kết nối với server');
    _scheduleReconnect();
  }

  void _handleWebSocketDisconnect() {
    debugPrint('WebSocket disconnected');
    _isConnected = false;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectInterval, () {
      if (!_isConnected) {
        debugPrint('Attempting to reconnect...');
        _connectToSignalR();
      }
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (_isConnected && _channel != null) {
        try {
          final heartbeatMessage = {
            'action': 'Heartbeat',
            'timestamp': DateTime.now().toIso8601String(),
          };
          _channel!.sink.add(jsonEncode(heartbeatMessage));
        } catch (e) {
          debugPrint('Failed to send heartbeat: $e');
        }
      }
    });
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus, String? notes) async {
    _setLoading(true);
    _setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // In real app, send to backend API
      final updateData = {
        'orderId': orderId,
        'status': newStatus.toString().split('.').last,
        'notes': notes,
        'updatedBy': 'current-user-id', // Would come from auth service
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      debugPrint('Updating order status: ${jsonEncode(updateData)}');
      
      // Update local order immediately for better UX
      if (_currentOrder?.id == orderId) {
        _currentOrder = Order(
          id: _currentOrder!.id,
          orderNumber: _currentOrder!.orderNumber,
          orderType: _currentOrder!.orderType,
          tableId: _currentOrder!.tableId,
          status: newStatus,
          totalAmount: _currentOrder!.totalAmount,
          notes: _currentOrder!.notes,
          items: _currentOrder!.items,
          creationTime: _currentOrder!.creationTime,
          lastModifiedTime: DateTime.now(),
        );
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError('Không thể cập nhật trạng thái đơn hàng: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshOrder() async {
    if (_trackingOrderId == null) return;
    
    _setLoading(true);
    _setError(null);

    try {
      await _loadOrderDetails(_trackingOrderId!);
    } catch (e) {
      _setError('Không thể tải lại thông tin đơn hàng: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _unsubscribeFromOrderUpdates();
    _channel?.sink.close();
    super.dispose();
  }
}

class OrderTrackingNotification {
  final String orderId;
  final String message;
  final OrderStatus status;
  final DateTime timestamp;
  final NotificationType type;

  const OrderTrackingNotification({
    required this.orderId,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.type,
  });

  factory OrderTrackingNotification.fromJson(Map<String, dynamic> json) {
    return OrderTrackingNotification(
      orderId: json['orderId'] as String,
      message: json['message'] as String,
      status: OrderStatus.values.firstWhere(
        (s) => s.toString().split('.').last == json['status'],
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: NotificationType.values.firstWhere(
        (t) => t.toString().split('.').last == json['type'],
      ),
    );
  }
}

enum NotificationType {
  statusUpdate,
  kitchenReady,
  customerRequest,
  systemAlert;

  String get displayName {
    switch (this) {
      case NotificationType.statusUpdate:
        return 'Cập nhật trạng thái';
      case NotificationType.kitchenReady:
        return 'Món sẵn sàng';
      case NotificationType.customerRequest:
        return 'Yêu cầu khách hàng';
      case NotificationType.systemAlert:
        return 'Thông báo hệ thống';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.statusUpdate:
        return Icons.info_outline;
      case NotificationType.kitchenReady:
        return Icons.restaurant_menu;
      case NotificationType.customerRequest:
        return Icons.person_outline;
      case NotificationType.systemAlert:
        return Icons.warning_outlined;
    }
  }
}