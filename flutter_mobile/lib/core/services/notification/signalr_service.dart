import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../../constants/app_constants.dart';
import '../../models/notification/notification_models.dart';
import '../../enums/restaurant_enums.dart';
import '../auth/auth_service.dart';

/// Service để kết nối với SignalR KitchenHub và nhận real-time notifications
class SignalRService extends ChangeNotifier {
  HubConnection? _hubConnection;
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  String? _lastError;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;
  static const Duration reconnectDelay = Duration(seconds: 5);

  final StreamController<BaseNotification> _notificationController =
      StreamController<BaseNotification>.broadcast();

  final AuthService _authService;

  SignalRService({required AuthService authService}) : _authService = authService {
    _authService.addListener(_onAuthStateChanged);
    
    // Kiểm tra ngay auth state hiện tại
    if (_authService.isLoggedIn) {
      // Delay một chút để đảm bảo constructor hoàn tất
      Future.delayed(Duration(milliseconds: 100), () {
        connect();
      });
    }
  }

  // Getters
  ConnectionStatus get connectionStatus => _connectionStatus;
  String? get lastError => _lastError;
  Stream<BaseNotification> get notifications => _notificationController.stream;
  bool get isConnected => _connectionStatus == ConnectionStatus.connected;

  /// Khởi tạo kết nối SignalR
  Future<void> connect() async {
    if (_connectionStatus == ConnectionStatus.connected ||
        _connectionStatus == ConnectionStatus.connecting) {
      return;
    }

    final accessToken = _authService.accessToken;
    if (accessToken == null) {
      _setError('Không có access token để kết nối SignalR');
      return;
    }

    try {
      _setConnectionStatus(ConnectionStatus.connecting);
      _clearError();

      final hubUrl = '${AppConstants.baseUrl}/signalr-hubs/kitchen';

      _hubConnection = HubConnectionBuilder()
          .withUrl('$hubUrl?access_token=$accessToken')
          .withAutomaticReconnect()
          .build();

      _setupEventHandlers();

      await _hubConnection!.start();
      _setConnectionStatus(ConnectionStatus.connected);
      _reconnectAttempts = 0;

      // Join Kitchen group để nhận notifications
      await _joinKitchenGroup();
      
    } catch (e) {
      
      String errorMessage = 'Lỗi kết nối SignalR';
      if (e.toString().contains('Failed host lookup')) {
        errorMessage = 'Không thể kết nối tới server. Kiểm tra URL và mạng.';
      } else if (e.toString().contains('Connection refused')) {
        errorMessage = 'Server từ chối kết nối. Kiểm tra server đã chạy chưa.';
      } else if (e.toString().contains('Unauthorized')) {
        errorMessage = 'Không có quyền truy cập. Kiểm tra token.';
      } else {
        errorMessage = 'Lỗi kết nối: $e';
      }
      
      _setError(errorMessage);
      _setConnectionStatus(ConnectionStatus.error);
      
      // Schedule reconnect if not manually disconnected
      if (_reconnectAttempts < maxReconnectAttempts) {
        _scheduleReconnect();
      }
    }
  }

  /// Ngắt kết nối SignalR
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;

    if (_hubConnection != null) {
      try {
        await _hubConnection!.stop();
      } catch (e) {
      }
    }

    _setConnectionStatus(ConnectionStatus.disconnected);
    _clearError();
  }

  /// Join Kitchen group để nhận thông báo
  Future<void> _joinKitchenGroup() async {
    if (_hubConnection == null || !isConnected) {
      return;
    }

    try {
      await _hubConnection!.invoke('JoinKitchenGroup');
    } catch (e) {
    }
  }

  /// Setup event handlers cho các loại notification
  void _setupEventHandlers() {
    if (_hubConnection == null) return;

    // Đơn hàng mới
    _hubConnection!.on('NewOrderReceived', (arguments) {
      _handleNewOrderReceived(arguments);
    });

    // Món đã phục vụ
    _hubConnection!.on('OrderItemServed', (arguments) {
      _handleOrderItemServed(arguments);
    });

    // Cập nhật số lượng món
    _hubConnection!.on('OrderItemQuantityUpdated', (arguments) {
      _handleOrderItemQuantityUpdated(arguments);
    });

    // Cập nhật trạng thái món ăn từ kitchen
    _hubConnection!.on('OrderItemStatusUpdated', (arguments) {
      _handleOrderItemStatusUpdated(arguments);
    });

    // Thêm món mới
    _hubConnection!.on('OrderItemsAdded', (arguments) {
      _handleOrderItemsAdded(arguments);
    });

    // Xóa món
    _hubConnection!.on('OrderItemRemoved', (arguments) {
      _handleOrderItemRemoved(arguments);
    });

    // Connection events
    _hubConnection!.onclose(({Exception? error}) {
      _setConnectionStatus(ConnectionStatus.disconnected);
      if (error != null) {
        _setError('Kết nối bị ngắt: $error');
        _scheduleReconnect();
      }
    });

    _hubConnection!.onreconnecting(({Exception? error}) {
      _setConnectionStatus(ConnectionStatus.reconnecting);
    });

    _hubConnection!.onreconnected(({String? connectionId}) {
      _setConnectionStatus(ConnectionStatus.connected);
      _reconnectAttempts = 0;
      _clearError();
      
      // Rejoin Kitchen group after reconnect
      _joinKitchenGroup();
    });
  }

  /// Xử lý notification đơn hàng mới
  void _handleNewOrderReceived(List<Object?>? arguments) {
    try {
      if (arguments == null || arguments.isEmpty) return;
      
      final data = arguments[0] as Map<String, dynamic>;

      final notification = NewOrderNotification(
        orderId: data['Order']?['Id'] ?? '',
        orderNumber: data['Order']?['OrderNumber'] ?? '',
        tableName: data['Order']?['TableName'] ?? '',
        tableId: data['Order']?['TableId'],
        notifiedAt: DateTime.tryParse(data['NotifiedAt'] ?? '') ?? DateTime.now(),
        message: data['Message'] ?? 'Có đơn hàng mới',
      );

      _notificationController.add(notification);
    } catch (e) {
    }
  }

  /// Xử lý notification món đã phục vụ
  void _handleOrderItemServed(List<Object?>? arguments) {
    try {
      if (arguments == null || arguments.isEmpty) {
        return;
      }
      
      final data = arguments[0] as Map<String, dynamic>;

      final notification = OrderItemServedNotification(
        orderId: data['OrderId'] ?? '',
        orderNumber: data['OrderNumber'] ?? '',
        menuItemName: data['MenuItemName'] ?? '',
        quantity: data['Quantity'] ?? 0,
        tableName: data['TableName'] ?? '',
        tableId: data['TableId'],
        notifiedAt: DateTime.tryParse(data['ServedAt'] ?? '') ?? DateTime.now(),
        message: data['Message'] ?? 'Món đã được phục vụ',
      );

      _notificationController.add(notification);
    } catch (e) {
    }
  }

  /// Xử lý notification cập nhật số lượng
  void _handleOrderItemQuantityUpdated(List<Object?>? arguments) {
    try {
      if (arguments == null || arguments.isEmpty) return;
      
      final data = arguments[0] as Map<String, dynamic>;

      final notification = OrderItemQuantityUpdatedNotification(
        orderItemId: data['OrderItemId'] ?? '',
        tableName: data['TableName'] ?? '',
        menuItemName: data['MenuItemName'] ?? '',
        newQuantity: data['NewQuantity'] ?? 0,
        notifiedAt: DateTime.tryParse(data['UpdatedAt'] ?? '') ?? DateTime.now(),
        message: data['Message'] ?? 'Số lượng món đã được cập nhật',
      );

      _notificationController.add(notification);
    } catch (e) {
    }
  }

  /// Xử lý notification cập nhật trạng thái món ăn từ kitchen
  void _handleOrderItemStatusUpdated(List<Object?>? arguments) {
    try {
      if (arguments == null || arguments.isEmpty) {
        return;
      }
      
      final data = arguments[0] as Map<String, dynamic>;

      // Tạo OrderItemStatusUpdatedNotification
      final notification = OrderItemStatusUpdatedNotification(
        orderItemId: data['OrderItemId'] ?? '',
        menuItemName: data['MenuItemName'] ?? '',
        tableName: data['TableName'] ?? '',
        newStatus: data['NewStatus'] ?? 0,
        statusDisplay: data['StatusDisplay'],
        notifiedAt: DateTime.tryParse(data['UpdatedAt'] ?? '') ?? DateTime.now(),
        message: data['Message'] ?? 'Trạng thái món ăn đã được cập nhật',
      );

      _notificationController.add(notification);
    } catch (e) {
    }
  }

  /// Xử lý notification thêm món
  void _handleOrderItemsAdded(List<Object?>? arguments) {
    try {
      if (arguments == null || arguments.isEmpty) return;
      
      final data = arguments[0] as Map<String, dynamic>;

      final notification = OrderItemsAddedNotification(
        tableName: data['TableName'] ?? '',
        addedItemsDetail: data['AddedItemsDetail'] ?? '',
        notifiedAt: DateTime.tryParse(data['AddedAt'] ?? '') ?? DateTime.now(),
        message: data['Message'] ?? 'Đã thêm món mới',
      );

      _notificationController.add(notification);
    } catch (e) {
    }
  }

  /// Xử lý notification xóa món
  void _handleOrderItemRemoved(List<Object?>? arguments) {
    try {
      if (arguments == null || arguments.isEmpty) return;
      
      final data = arguments[0] as Map<String, dynamic>;

      final notification = OrderItemRemovedNotification(
        orderItemId: data['OrderItemId'] ?? '',
        tableName: data['TableName'] ?? '',
        menuItemName: data['MenuItemName'] ?? '',
        quantity: data['Quantity'] ?? 0,
        notifiedAt: DateTime.tryParse(data['RemovedAt'] ?? '') ?? DateTime.now(),
        message: data['Message'] ?? 'Món đã được xóa',
      );

      _notificationController.add(notification);
    } catch (e) {
    }
  }

  /// Schedule reconnect after delay
  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectAttempts++;
    
    
    _reconnectTimer = Timer(reconnectDelay, () {
      if (_connectionStatus != ConnectionStatus.connected) {
        connect();
      }
    });
  }

  /// Xử lý khi auth state thay đổi
  void _onAuthStateChanged() {
    
    if (_authService.isLoggedIn) {
      // User logged in, connect to SignalR
      connect();
    } else {
      // User logged out, disconnect
      disconnect();
    }
  }

  /// Set connection status và notify listeners
  void _setConnectionStatus(ConnectionStatus status) {
    if (_connectionStatus != status) {
      _connectionStatus = status;
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

  /// TEST METHOD: Simulate notification để test auto-refresh
  void simulateStatusUpdateNotification() {
    
    final testData = {
      'OrderItemId': '12345-test',
      'NewStatus': 2, // Ready status  
      'UpdatedAt': DateTime.now().toIso8601String(),
      'Message': 'Test notification - Món ăn đã sẵn sàng'
    };
    
    _handleOrderItemStatusUpdated([testData]);
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthStateChanged);
    _reconnectTimer?.cancel();
    disconnect();
    _notificationController.close();
    super.dispose();
  }
}