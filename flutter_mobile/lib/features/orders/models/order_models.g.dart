// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) =>
    OrderItemModel(
      id: json['id'] as String,
      menuItemId: json['menuItemId'] as String,
      menuItemName: json['menuItemName'] as String,
      unitPrice: (json['unitPrice'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      notes: json['notes'] as String,
      status: $enumDecode(_$OrderItemStatusEnumMap, json['status']),
      kitchenArea: json['kitchenArea'] as String?,
    );

Map<String, dynamic> _$OrderItemModelToJson(OrderItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'menuItemId': instance.menuItemId,
      'menuItemName': instance.menuItemName,
      'unitPrice': instance.unitPrice,
      'quantity': instance.quantity,
      'notes': instance.notes,
      'status': _$OrderItemStatusEnumMap[instance.status]!,
      'kitchenArea': instance.kitchenArea,
    };

const _$OrderItemStatusEnumMap = {
  OrderItemStatus.pending: 'pending',
  OrderItemStatus.confirmed: 'confirmed',
  OrderItemStatus.preparing: 'preparing',
  OrderItemStatus.ready: 'ready',
  OrderItemStatus.served: 'served',
};

CustomerInfo _$CustomerInfoFromJson(Map<String, dynamic> json) => CustomerInfo(
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$CustomerInfoToJson(CustomerInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phone': instance.phone,
      'notes': instance.notes,
    };

SpecialRequestsModel _$SpecialRequestsModelFromJson(
        Map<String, dynamic> json) =>
    SpecialRequestsModel(
      kitchenNotes: json['kitchenNotes'] as String,
      allergyWarnings: (json['allergyWarnings'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      servingPreferences: json['servingPreferences'] as String,
      priority: $enumDecode(_$OrderPriorityEnumMap, json['priority']),
    );

Map<String, dynamic> _$SpecialRequestsModelToJson(
        SpecialRequestsModel instance) =>
    <String, dynamic>{
      'kitchenNotes': instance.kitchenNotes,
      'allergyWarnings': instance.allergyWarnings,
      'servingPreferences': instance.servingPreferences,
      'priority': _$OrderPriorityEnumMap[instance.priority]!,
    };

const _$OrderPriorityEnumMap = {
  OrderPriority.low: 'low',
  OrderPriority.normal: 'normal',
  OrderPriority.high: 'high',
  OrderPriority.urgent: 'urgent',
};

OrderStatusHistoryItem _$OrderStatusHistoryItemFromJson(
        Map<String, dynamic> json) =>
    OrderStatusHistoryItem(
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String,
    );

Map<String, dynamic> _$OrderStatusHistoryItemToJson(
        OrderStatusHistoryItem instance) =>
    <String, dynamic>{
      'status': _$OrderStatusEnumMap[instance.status]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'notes': instance.notes,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.preparing: 'preparing',
  OrderStatus.ready: 'ready',
  OrderStatus.served: 'served',
  OrderStatus.paid: 'paid',
  OrderStatus.cancelled: 'cancelled',
};

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      tableId: json['tableId'] as String?,
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      customerInfo: json['customerInfo'] == null
          ? null
          : CustomerInfo.fromJson(json['customerInfo'] as Map<String, dynamic>),
      specialRequests: json['specialRequests'] == null
          ? null
          : SpecialRequestsModel.fromJson(
              json['specialRequests'] as Map<String, dynamic>),
      statusHistory: (json['statusHistory'] as List<dynamic>?)
          ?.map(
              (e) => OrderStatusHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      orderType: $enumDecodeNullable(_$OrderTypeEnumMap, json['orderType']),
    );

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'tableId': instance.tableId,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'items': instance.items,
      'totalAmount': instance.totalAmount,
      'createdAt': instance.createdAt?.toIso8601String(),
      'customerInfo': instance.customerInfo,
      'specialRequests': instance.specialRequests,
      'statusHistory': instance.statusHistory,
      'orderType': _$OrderTypeEnumMap[instance.orderType],
    };

const _$OrderTypeEnumMap = {
  OrderType.dineIn: 'dine_in',
  OrderType.takeaway: 'takeaway',
  OrderType.delivery: 'delivery',
};

MissingIngredientModel _$MissingIngredientModelFromJson(
        Map<String, dynamic> json) =>
    MissingIngredientModel(
      ingredientName: json['ingredientName'] as String,
      requiredQuantity: (json['requiredQuantity'] as num).toInt(),
      currentStock: (json['currentStock'] as num).toInt(),
      missingQuantity: (json['missingQuantity'] as num).toInt(),
      isOptional: json['isOptional'] as bool,
    );

Map<String, dynamic> _$MissingIngredientModelToJson(
        MissingIngredientModel instance) =>
    <String, dynamic>{
      'ingredientName': instance.ingredientName,
      'requiredQuantity': instance.requiredQuantity,
      'currentStock': instance.currentStock,
      'missingQuantity': instance.missingQuantity,
      'isOptional': instance.isOptional,
    };

OrderStatusUpdate _$OrderStatusUpdateFromJson(Map<String, dynamic> json) =>
    OrderStatusUpdate(
      orderId: json['orderId'] as String,
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      updatedAt: json['updatedAt'] as String,
      estimatedReadyTime: json['estimatedReadyTime'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$OrderStatusUpdateToJson(OrderStatusUpdate instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'updatedAt': instance.updatedAt,
      'estimatedReadyTime': instance.estimatedReadyTime,
      'notes': instance.notes,
    };

OrderItemStatusUpdate _$OrderItemStatusUpdateFromJson(
        Map<String, dynamic> json) =>
    OrderItemStatusUpdate(
      orderId: json['orderId'] as String,
      orderItemId: json['orderItemId'] as String,
      status: $enumDecode(_$OrderItemStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );

Map<String, dynamic> _$OrderItemStatusUpdateToJson(
        OrderItemStatusUpdate instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'orderItemId': instance.orderItemId,
      'status': _$OrderItemStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'updatedBy': instance.updatedBy,
    };

KitchenNotification _$KitchenNotificationFromJson(Map<String, dynamic> json) =>
    KitchenNotification(
      orderId: json['orderId'] as String,
      message: json['message'] as String,
      priority: $enumDecode(_$NotificationPriorityEnumMap, json['priority']),
      kitchenArea: json['kitchenArea'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$KitchenNotificationToJson(
        KitchenNotification instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'message': instance.message,
      'priority': _$NotificationPriorityEnumMap[instance.priority]!,
      'kitchenArea': instance.kitchenArea,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$NotificationPriorityEnumMap = {
  NotificationPriority.low: 'low',
  NotificationPriority.normal: 'normal',
  NotificationPriority.high: 'high',
  NotificationPriority.urgent: 'urgent',
};

PaymentResult _$PaymentResultFromJson(Map<String, dynamic> json) =>
    PaymentResult(
      success: json['success'] as bool,
      transactionId: json['transactionId'] as String?,
      paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['paymentMethod']),
      amount: (json['amount'] as num?)?.toInt(),
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$PaymentResultToJson(PaymentResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'transactionId': instance.transactionId,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'amount': instance.amount,
      'timestamp': instance.timestamp?.toIso8601String(),
      'errorMessage': instance.errorMessage,
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.card: 'card',
  PaymentMethod.transfer: 'transfer',
  PaymentMethod.split: 'split',
};

OrderSummary _$OrderSummaryFromJson(Map<String, dynamic> json) => OrderSummary(
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toInt(),
      taxAmount: (json['taxAmount'] as num).toInt(),
      serviceCharge: (json['serviceCharge'] as num).toInt(),
      discount: (json['discount'] as num).toInt(),
      totalAmount: (json['totalAmount'] as num).toInt(),
      notes: json['notes'] as String?,
      customerInfo: json['customerInfo'] == null
          ? null
          : CustomerInfo.fromJson(json['customerInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrderSummaryToJson(OrderSummary instance) =>
    <String, dynamic>{
      'items': instance.items,
      'subtotal': instance.subtotal,
      'taxAmount': instance.taxAmount,
      'serviceCharge': instance.serviceCharge,
      'discount': instance.discount,
      'totalAmount': instance.totalAmount,
      'notes': instance.notes,
      'customerInfo': instance.customerInfo,
    };
