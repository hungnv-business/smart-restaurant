// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseNotification _$BaseNotificationFromJson(Map<String, dynamic> json) =>
    BaseNotification(
      notifiedAt: DateTime.parse(json['notifiedAt'] as String),
      message: json['message'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$BaseNotificationToJson(BaseNotification instance) =>
    <String, dynamic>{
      'notifiedAt': instance.notifiedAt.toIso8601String(),
      'message': instance.message,
      'type': _$NotificationTypeEnumMap[instance.type]!,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.newOrder: 'newOrder',
  NotificationType.orderItemServed: 'orderItemServed',
  NotificationType.orderItemQuantityUpdated: 'orderItemQuantityUpdated',
  NotificationType.orderItemsAdded: 'orderItemsAdded',
  NotificationType.orderItemRemoved: 'orderItemRemoved',
  NotificationType.other: 'other',
};

NewOrderNotification _$NewOrderNotificationFromJson(
        Map<String, dynamic> json) =>
    NewOrderNotification(
      orderId: json['orderId'] as String,
      orderNumber: json['orderNumber'] as String,
      tableName: json['tableName'] as String,
      tableId: json['tableId'] as String?,
      notifiedAt: DateTime.parse(json['notifiedAt'] as String),
      message: json['message'] as String,
    );

Map<String, dynamic> _$NewOrderNotificationToJson(
        NewOrderNotification instance) =>
    <String, dynamic>{
      'notifiedAt': instance.notifiedAt.toIso8601String(),
      'message': instance.message,
      'orderId': instance.orderId,
      'orderNumber': instance.orderNumber,
      'tableName': instance.tableName,
      'tableId': instance.tableId,
    };

OrderItemServedNotification _$OrderItemServedNotificationFromJson(
        Map<String, dynamic> json) =>
    OrderItemServedNotification(
      orderId: json['orderId'] as String,
      orderNumber: json['orderNumber'] as String,
      menuItemName: json['menuItemName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      tableName: json['tableName'] as String,
      tableId: json['tableId'] as String?,
      notifiedAt: DateTime.parse(json['notifiedAt'] as String),
      message: json['message'] as String,
    );

Map<String, dynamic> _$OrderItemServedNotificationToJson(
        OrderItemServedNotification instance) =>
    <String, dynamic>{
      'notifiedAt': instance.notifiedAt.toIso8601String(),
      'message': instance.message,
      'orderId': instance.orderId,
      'orderNumber': instance.orderNumber,
      'menuItemName': instance.menuItemName,
      'quantity': instance.quantity,
      'tableName': instance.tableName,
      'tableId': instance.tableId,
    };

OrderItemQuantityUpdatedNotification
    _$OrderItemQuantityUpdatedNotificationFromJson(Map<String, dynamic> json) =>
        OrderItemQuantityUpdatedNotification(
          orderItemId: json['orderItemId'] as String,
          tableName: json['tableName'] as String,
          menuItemName: json['menuItemName'] as String,
          newQuantity: (json['newQuantity'] as num).toInt(),
          notifiedAt: DateTime.parse(json['notifiedAt'] as String),
          message: json['message'] as String,
        );

Map<String, dynamic> _$OrderItemQuantityUpdatedNotificationToJson(
        OrderItemQuantityUpdatedNotification instance) =>
    <String, dynamic>{
      'notifiedAt': instance.notifiedAt.toIso8601String(),
      'message': instance.message,
      'orderItemId': instance.orderItemId,
      'tableName': instance.tableName,
      'menuItemName': instance.menuItemName,
      'newQuantity': instance.newQuantity,
    };

OrderItemsAddedNotification _$OrderItemsAddedNotificationFromJson(
        Map<String, dynamic> json) =>
    OrderItemsAddedNotification(
      tableName: json['tableName'] as String,
      addedItemsDetail: json['addedItemsDetail'] as String,
      notifiedAt: DateTime.parse(json['notifiedAt'] as String),
      message: json['message'] as String,
    );

Map<String, dynamic> _$OrderItemsAddedNotificationToJson(
        OrderItemsAddedNotification instance) =>
    <String, dynamic>{
      'notifiedAt': instance.notifiedAt.toIso8601String(),
      'message': instance.message,
      'tableName': instance.tableName,
      'addedItemsDetail': instance.addedItemsDetail,
    };

OrderItemRemovedNotification _$OrderItemRemovedNotificationFromJson(
        Map<String, dynamic> json) =>
    OrderItemRemovedNotification(
      orderItemId: json['orderItemId'] as String,
      tableName: json['tableName'] as String,
      menuItemName: json['menuItemName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      notifiedAt: DateTime.parse(json['notifiedAt'] as String),
      message: json['message'] as String,
    );

Map<String, dynamic> _$OrderItemRemovedNotificationToJson(
        OrderItemRemovedNotification instance) =>
    <String, dynamic>{
      'notifiedAt': instance.notifiedAt.toIso8601String(),
      'message': instance.message,
      'orderItemId': instance.orderItemId,
      'tableName': instance.tableName,
      'menuItemName': instance.menuItemName,
      'quantity': instance.quantity,
    };
