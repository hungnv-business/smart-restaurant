import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_models.dart';

/// Service để hiển thị local notifications và quản lý notification state
class NotificationService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<AppNotification> _notifications = [];
  bool _isInitialized = false;

  // Getters
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  bool get isInitialized => _isInitialized;

  /// Khởi tạo notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Android initialization
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions cho iOS
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _requestIOSPermissions();
      }

      // Request permissions cho Android 13+
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _requestAndroidPermissions();
      }

      _isInitialized = true;
    } catch (e) {
    }
  }

  /// Request iOS permissions
  Future<void> _requestIOSPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Request Android permissions (Android 13+)
  Future<void> _requestAndroidPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  /// Hiển thị notification từ SignalR
  Future<void> showNotificationFromSignalR(BaseNotification notification) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Tạo AppNotification và thêm vào danh sách
    final appNotification = AppNotification.fromBaseNotification(notification);
    _addNotification(appNotification);

    // Hiển thị local notification
    await _showLocalNotification(appNotification);
  }

  /// Hiển thị notification tùy chỉnh
  Future<void> showCustomNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.other,
    Map<String, dynamic>? data,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final appNotification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      timestamp: DateTime.now(),
      data: data,
    );

    _addNotification(appNotification);
    await _showLocalNotification(appNotification);
  }

  /// Hiển thị local notification
  Future<void> _showLocalNotification(AppNotification notification) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'kitchen_updates',
        'Cập nhật từ bếp',
        channelDescription: 'Thông báo cập nhật từ bếp cho nhân viên',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        notification.id.hashCode,
        notification.title,
        notification.body,
        platformChannelSpecifics,
        payload: notification.id,
      );

    } catch (e) {
    }
  }

  /// Xử lý khi user tap vào notification
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      
      // Đánh dấu notification đã đọc
      markAsRead(payload);
      
      // TODO: Navigate to appropriate screen based on notification type
      // Có thể emit event để UI component khác handle navigation
    }
  }

  /// Thêm notification vào danh sách
  void _addNotification(AppNotification notification) {
    _notifications.insert(0, notification); // Thêm vào đầu danh sách
    
    // Giới hạn số lượng notifications (tối đa 50)
    if (_notifications.length > 50) {
      _notifications.removeRange(50, _notifications.length);
    }
    
    notifyListeners();
  }

  /// Đánh dấu notification đã đọc
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  /// Đánh dấu tất cả notifications đã đọc
  void markAllAsRead() {
    bool hasChanges = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        hasChanges = true;
      }
    }
    
    if (hasChanges) {
      notifyListeners();
    }
  }

  /// Xóa notification
  void removeNotification(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications.removeAt(index);
      notifyListeners();
    }
  }

  /// Xóa tất cả notifications
  void clearAllNotifications() {
    if (_notifications.isNotEmpty) {
      _notifications.clear();
      notifyListeners();
    }
  }

  /// Xóa notifications theo loại
  void clearNotificationsByType(NotificationType type) {
    final initialLength = _notifications.length;
    _notifications.removeWhere((n) => n.type == type);
    
    if (_notifications.length != initialLength) {
      notifyListeners();
    }
  }

  /// Lấy notifications theo loại
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Hủy tất cả local notifications
  Future<void> cancelAllLocalNotifications() async {
    if (_isInitialized) {
      await _flutterLocalNotificationsPlugin.cancelAll();
    }
  }

  /// Hủy local notification theo ID
  Future<void> cancelLocalNotification(String notificationId) async {
    if (_isInitialized) {
      await _flutterLocalNotificationsPlugin.cancel(notificationId.hashCode);
    }
  }

  @override
  void dispose() {
    cancelAllLocalNotifications();
    super.dispose();
  }
}