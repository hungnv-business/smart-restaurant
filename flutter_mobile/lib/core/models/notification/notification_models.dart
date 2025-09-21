import 'package:json_annotation/json_annotation.dart';

part 'notification_models.g.dart';

/// Enum các loại notification từ bếp
enum NotificationType {
  newOrder,
  orderItemServed,
  orderItemQuantityUpdated,
  orderItemsAdded,
  orderItemRemoved,
  orderItemStatusUpdated,
  other,
}

/// Base notification model nhận từ SignalR
@JsonSerializable()
class BaseNotification {
  final DateTime notifiedAt;
  final String message;
  final NotificationType type;

  const BaseNotification({
    required this.notifiedAt,
    required this.message,
    required this.type,
  });

  factory BaseNotification.fromJson(Map<String, dynamic> json) =>
      _$BaseNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$BaseNotificationToJson(this);
}

/// Notification cho đơn hàng mới
@JsonSerializable()
class NewOrderNotification extends BaseNotification {
  final String orderId;
  final String orderNumber;
  final String tableName;
  final String? tableId;

  const NewOrderNotification({
    required this.orderId,
    required this.orderNumber,
    required this.tableName,
    this.tableId,
    required super.notifiedAt,
    required super.message,
  }) : super(
          type: NotificationType.newOrder,
        );

  factory NewOrderNotification.fromJson(Map<String, dynamic> json) =>
      _$NewOrderNotificationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NewOrderNotificationToJson(this);
}

/// Notification cho món đã phục vụ
@JsonSerializable()
class OrderItemServedNotification extends BaseNotification {
  final String orderId;
  final String orderNumber;
  final String menuItemName;
  final int quantity;
  final String tableName;
  final String? tableId;

  const OrderItemServedNotification({
    required this.orderId,
    required this.orderNumber,
    required this.menuItemName,
    required this.quantity,
    required this.tableName,
    this.tableId,
    required super.notifiedAt,
    required super.message,
  }) : super(
          type: NotificationType.orderItemServed,
        );

  factory OrderItemServedNotification.fromJson(Map<String, dynamic> json) =>
      _$OrderItemServedNotificationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OrderItemServedNotificationToJson(this);
}

/// Notification cho cập nhật số lượng món
@JsonSerializable()
class OrderItemQuantityUpdatedNotification extends BaseNotification {
  final String orderItemId;
  final String tableName;
  final String menuItemName;
  final int newQuantity;

  const OrderItemQuantityUpdatedNotification({
    required this.orderItemId,
    required this.tableName,
    required this.menuItemName,
    required this.newQuantity,
    required super.notifiedAt,
    required super.message,
  }) : super(
          type: NotificationType.orderItemQuantityUpdated,
        );

  factory OrderItemQuantityUpdatedNotification.fromJson(
          Map<String, dynamic> json) =>
      _$OrderItemQuantityUpdatedNotificationFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$OrderItemQuantityUpdatedNotificationToJson(this);
}

/// Notification cho thêm món mới
@JsonSerializable()
class OrderItemsAddedNotification extends BaseNotification {
  final String tableName;
  final String addedItemsDetail;

  const OrderItemsAddedNotification({
    required this.tableName,
    required this.addedItemsDetail,
    required super.notifiedAt,
    required super.message,
  }) : super(
          type: NotificationType.orderItemsAdded,
        );

  factory OrderItemsAddedNotification.fromJson(Map<String, dynamic> json) =>
      _$OrderItemsAddedNotificationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OrderItemsAddedNotificationToJson(this);
}

/// Notification cho xóa món
@JsonSerializable()
class OrderItemRemovedNotification extends BaseNotification {
  final String orderItemId;
  final String tableName;
  final String menuItemName;
  final int quantity;

  const OrderItemRemovedNotification({
    required this.orderItemId,
    required this.tableName,
    required this.menuItemName,
    required this.quantity,
    required super.notifiedAt,
    required super.message,
  }) : super(
          type: NotificationType.orderItemRemoved,
        );

  factory OrderItemRemovedNotification.fromJson(Map<String, dynamic> json) =>
      _$OrderItemRemovedNotificationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OrderItemRemovedNotificationToJson(this);
}

/// Notification khi trạng thái món ăn được cập nhật từ kitchen (Preparing/Ready)
// @JsonSerializable()
class OrderItemStatusUpdatedNotification extends BaseNotification {
  final String orderItemId;
  final String menuItemName;
  final String tableName;
  final int newStatus; // OrderItemStatus enum value
  final String? statusDisplay;

  const OrderItemStatusUpdatedNotification({
    required this.orderItemId,
    required this.menuItemName,
    required this.tableName,
    required this.newStatus,
    this.statusDisplay,
    required super.notifiedAt,
    required super.message,
  }) : super(
          type: NotificationType.orderItemStatusUpdated,
        );

  factory OrderItemStatusUpdatedNotification.fromJson(Map<String, dynamic> json) {
    return OrderItemStatusUpdatedNotification(
      orderItemId: json['orderItemId'] ?? '',
      menuItemName: json['menuItemName'] ?? '',
      tableName: json['tableName'] ?? '',
      newStatus: json['newStatus'] ?? 0,
      statusDisplay: json['statusDisplay'],
      notifiedAt: DateTime.tryParse(json['notifiedAt'] ?? '') ?? DateTime.now(),
      message: json['message'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'orderItemId': orderItemId,
      'menuItemName': menuItemName,
      'tableName': tableName,
      'newStatus': newStatus,
      'statusDisplay': statusDisplay,
      'notifiedAt': notifiedAt.toIso8601String(),
      'message': message,
    };
  }
}

/// Model cho notification hiển thị trong app
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  /// Tạo AppNotification từ BaseNotification
  static AppNotification fromBaseNotification(BaseNotification notification) {
    String title = 'Thông báo từ bếp';
    String id = DateTime.now().millisecondsSinceEpoch.toString();

    switch (notification.type) {
      case NotificationType.newOrder:
        title = 'Đơn hàng mới';
        if (notification is NewOrderNotification) {
          id = notification.orderId;
        }
        break;
      case NotificationType.orderItemServed:
        title = 'Món đã phục vụ';
        break;
      case NotificationType.orderItemQuantityUpdated:
        title = 'Cập nhật số lượng';
        break;
      case NotificationType.orderItemsAdded:
        title = 'Thêm món mới';
        break;
      case NotificationType.orderItemRemoved:
        title = 'Xóa món';
        break;
      case NotificationType.orderItemStatusUpdated:
        title = 'Cập nhật trạng thái món';
        break;
      case NotificationType.other:
        title = 'Thông báo';
        break;
    }

    return AppNotification(
      id: id,
      title: title,
      body: notification.message,
      type: notification.type,
      timestamp: notification.notifiedAt,
      data: notification.toJson(),
    );
  }
}

/// Connection status cho SignalR - extension đã được định nghĩa trong restaurant_enums.dart