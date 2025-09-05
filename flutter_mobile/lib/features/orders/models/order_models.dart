import 'package:json_annotation/json_annotation.dart';

// part 'order_models.g.dart'; // Temporarily commented out for iOS build

enum OrderStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('preparing')
  preparing,
  @JsonValue('ready')
  ready,
  @JsonValue('served')
  served,
  @JsonValue('paid')
  paid,
  @JsonValue('cancelled')
  cancelled,
}

enum OrderItemStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('preparing')
  preparing,
  @JsonValue('ready')
  ready,
  @JsonValue('served')
  served,
}

enum OrderType {
  @JsonValue('dine_in')
  dineIn,
  @JsonValue('takeaway')
  takeaway,
  @JsonValue('delivery')
  delivery,
}

enum OrderPriority {
  @JsonValue('low')
  low,
  @JsonValue('normal')
  normal,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
}

enum PaymentMethod {
  @JsonValue('cash')
  cash,
  @JsonValue('card')
  card,
  @JsonValue('transfer')
  transfer,
  @JsonValue('split')
  split,
}

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

@JsonSerializable()
class OrderItemModel {
  final String id;
  final String menuItemId;
  final String menuItemName;
  final int unitPrice;
  final int quantity;
  final String notes;
  final OrderItemStatus status;
  final String? kitchenArea;

  const OrderItemModel({
    required this.id,
    required this.menuItemId,
    required this.menuItemName,
    required this.unitPrice,
    required this.quantity,
    required this.notes,
    required this.status,
    this.kitchenArea,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      OrderItemModel(
        id: json['id'] as String,
        menuItemId: json['menuItemId'] as String,
        menuItemName: json['menuItemName'] as String,
        quantity: (json['quantity'] as num).toInt(),
        unitPrice: (json['unitPrice'] as num).toDouble(),
        totalPrice: (json['totalPrice'] as num).toDouble(),
        specialRequests: json['specialRequests'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
        status: OrderItemStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'],
          orElse: () => OrderItemStatus.pending,
        ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'menuItemId': menuItemId,
        'menuItemName': menuItemName,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
        'specialRequests': specialRequests,
        'notes': notes,
        'status': status.toString().split('.').last,
      };

  OrderItemModel copyWith({
    String? id,
    String? menuItemId,
    String? menuItemName,
    int? unitPrice,
    int? quantity,
    String? notes,
    OrderItemStatus? status,
    String? kitchenArea,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      menuItemId: menuItemId ?? this.menuItemId,
      menuItemName: menuItemName ?? this.menuItemName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      kitchenArea: kitchenArea ?? this.kitchenArea,
    );
  }
}

@JsonSerializable()
class CustomerInfo {
  final String? name;
  final String? phone;
  final String? notes;

  const CustomerInfo({
    this.name,
    this.phone,
    this.notes,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) =>
      _$CustomerInfoFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerInfoToJson(this);

  CustomerInfo copyWith({
    String? name,
    String? phone,
    String? notes,
  }) {
    return CustomerInfo(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
    );
  }
}

@JsonSerializable()
class SpecialRequestsModel {
  final String kitchenNotes;
  final List<String> allergyWarnings;
  final String servingPreferences;
  final OrderPriority priority;

  const SpecialRequestsModel({
    required this.kitchenNotes,
    required this.allergyWarnings,
    required this.servingPreferences,
    required this.priority,
  });

  factory SpecialRequestsModel.fromJson(Map<String, dynamic> json) =>
      _$SpecialRequestsModelFromJson(json);

  Map<String, dynamic> toJson() => _$SpecialRequestsModelToJson(this);

  SpecialRequestsModel copyWith({
    String? kitchenNotes,
    List<String>? allergyWarnings,
    String? servingPreferences,
    OrderPriority? priority,
  }) {
    return SpecialRequestsModel(
      kitchenNotes: kitchenNotes ?? this.kitchenNotes,
      allergyWarnings: allergyWarnings ?? this.allergyWarnings,
      servingPreferences: servingPreferences ?? this.servingPreferences,
      priority: priority ?? this.priority,
    );
  }
}

@JsonSerializable()
class OrderStatusHistoryItem {
  final OrderStatus status;
  final DateTime timestamp;
  final String notes;

  const OrderStatusHistoryItem({
    required this.status,
    required this.timestamp,
    required this.notes,
  });

  factory OrderStatusHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusHistoryItemFromJson(json);

  Map<String, dynamic> toJson() => _$OrderStatusHistoryItemToJson(this);
}

@JsonSerializable()
class OrderModel {
  final String id;
  final String orderNumber;
  final String? tableId;
  final OrderStatus status;
  final List<OrderItemModel> items;
  final int totalAmount;
  final DateTime? createdAt;
  final CustomerInfo? customerInfo;
  final SpecialRequestsModel? specialRequests;
  final List<OrderStatusHistoryItem>? statusHistory;
  final OrderType? orderType;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.tableId,
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    this.customerInfo,
    this.specialRequests,
    this.statusHistory,
    this.orderType,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? tableId,
    OrderStatus? status,
    List<OrderItemModel>? items,
    int? totalAmount,
    DateTime? createdAt,
    CustomerInfo? customerInfo,
    SpecialRequestsModel? specialRequests,
    List<OrderStatusHistoryItem>? statusHistory,
    OrderType? orderType,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      tableId: tableId ?? this.tableId,
      status: status ?? this.status,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      customerInfo: customerInfo ?? this.customerInfo,
      specialRequests: specialRequests ?? this.specialRequests,
      statusHistory: statusHistory ?? this.statusHistory,
      orderType: orderType ?? this.orderType,
    );
  }
}

@JsonSerializable()
class MissingIngredientModel {
  final String ingredientName;
  final int requiredQuantity;
  final int currentStock;
  final int missingQuantity;
  final bool isOptional;

  const MissingIngredientModel({
    required this.ingredientName,
    required this.requiredQuantity,
    required this.currentStock,
    required this.missingQuantity,
    required this.isOptional,
  });

  factory MissingIngredientModel.fromJson(Map<String, dynamic> json) =>
      _$MissingIngredientModelFromJson(json);

  Map<String, dynamic> toJson() => _$MissingIngredientModelToJson(this);
}

@JsonSerializable()
class OrderStatusUpdate {
  final String orderId;
  final OrderStatus status;
  final String updatedAt;
  final String? estimatedReadyTime;
  final String? notes;

  const OrderStatusUpdate({
    required this.orderId,
    required this.status,
    required this.updatedAt,
    this.estimatedReadyTime,
    this.notes,
  });

  factory OrderStatusUpdate.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$OrderStatusUpdateToJson(this);
}

@JsonSerializable()
class OrderItemStatusUpdate {
  final String orderId;
  final String orderItemId;
  final OrderItemStatus status;
  final String? notes;
  final String? updatedBy;

  const OrderItemStatusUpdate({
    required this.orderId,
    required this.orderItemId,
    required this.status,
    this.notes,
    this.updatedBy,
  });

  factory OrderItemStatusUpdate.fromJson(Map<String, dynamic> json) =>
      _$OrderItemStatusUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemStatusUpdateToJson(this);
}

@JsonSerializable()
class KitchenNotification {
  final String orderId;
  final String message;
  final NotificationPriority priority;
  final String? kitchenArea;
  final DateTime timestamp;

  const KitchenNotification({
    required this.orderId,
    required this.message,
    required this.priority,
    this.kitchenArea,
    required this.timestamp,
  });

  factory KitchenNotification.fromJson(Map<String, dynamic> json) =>
      _$KitchenNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$KitchenNotificationToJson(this);
}

@JsonSerializable()
class PaymentResult {
  final bool success;
  final String? transactionId;
  final PaymentMethod paymentMethod;
  final int? amount;
  final DateTime? timestamp;
  final String? errorMessage;

  const PaymentResult({
    required this.success,
    this.transactionId,
    required this.paymentMethod,
    this.amount,
    this.timestamp,
    this.errorMessage,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> json) =>
      _$PaymentResultFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentResultToJson(this);
}

@JsonSerializable()
class OrderSummary {
  final List<OrderItemModel> items;
  final int subtotal;
  final int taxAmount;
  final int serviceCharge;
  final int discount;
  final int totalAmount;
  final String? notes;
  final CustomerInfo? customerInfo;

  const OrderSummary({
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.serviceCharge,
    required this.discount,
    required this.totalAmount,
    this.notes,
    this.customerInfo,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) =>
      _$OrderSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$OrderSummaryToJson(this);
}

// Exceptions for error handling
class OrderValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;

  const OrderValidationException(this.message, [this.fieldErrors]);

  @override
  String toString() => 'OrderValidationException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class ServerException implements Exception {
  final String message;

  const ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}

class ValidationException implements Exception {
  final String message;

  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

class Order {
  final String id;
  final String orderNumber;
  final OrderType orderType;
  final String? tableId;
  final OrderStatus status;
  final double totalAmount;
  final String? notes;
  final List<OrderItem> items;
  final DateTime creationTime;
  final DateTime? lastModifiedTime;

  Order({
    required this.id,
    required this.orderNumber,
    required this.orderType,
    this.tableId,
    required this.status,
    required this.totalAmount,
    this.notes,
    required this.items,
    required this.creationTime,
    this.lastModifiedTime,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      orderType: OrderType.values.firstWhere(
        (e) => e.toString().split('.').last == json['orderType'],
      ),
      tableId: json['tableId'] as String?,
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      notes: json['notes'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      creationTime: DateTime.parse(json['creationTime'] as String),
      lastModifiedTime: json['lastModifiedTime'] != null
          ? DateTime.parse(json['lastModifiedTime'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'orderType': orderType.toString().split('.').last,
      'tableId': tableId,
      'status': status.toString().split('.').last,
      'totalAmount': totalAmount,
      'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),
      'creationTime': creationTime.toIso8601String(),
      'lastModifiedTime': lastModifiedTime?.toIso8601String(),
    };
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String menuItemId;
  final String menuItemName;
  final int quantity;
  final double unitPrice;
  final String? notes;
  final OrderItemStatus status;
  final DateTime? preparationStartTime;
  final DateTime? preparationCompleteTime;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.menuItemName,
    required this.quantity,
    required this.unitPrice,
    this.notes,
    required this.status,
    this.preparationStartTime,
    this.preparationCompleteTime,
  });

  double get totalPrice => unitPrice * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      menuItemId: json['menuItemId'] as String,
      menuItemName: json['menuItemName'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      notes: json['notes'] as String?,
      status: OrderItemStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      preparationStartTime: json['preparationStartTime'] != null
          ? DateTime.parse(json['preparationStartTime'] as String)
          : null,
      preparationCompleteTime: json['preparationCompleteTime'] != null
          ? DateTime.parse(json['preparationCompleteTime'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'menuItemId': menuItemId,
      'menuItemName': menuItemName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'notes': notes,
      'status': status.toString().split('.').last,
      'preparationStartTime': preparationStartTime?.toIso8601String(),
      'preparationCompleteTime': preparationCompleteTime?.toIso8601String(),
    };
  }
}

class CreateOrderDto {
  final OrderType orderType;
  final String? tableId;
  final String? notes;
  final List<CreateOrderItemDto> items;

  CreateOrderDto({
    required this.orderType,
    this.tableId,
    this.notes,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderType': orderType.toString().split('.').last,
      'tableId': tableId,
      'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class CreateOrderItemDto {
  final String menuItemId;
  final int quantity;
  final String? notes;

  CreateOrderItemDto({
    required this.menuItemId,
    required this.quantity,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'menuItemId': menuItemId,
      'quantity': quantity,
      'notes': notes,
    };
  }
}

class UpdateOrderStatusDto {
  final OrderStatus status;
  final String? notes;

  UpdateOrderStatusDto({
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status.toString().split('.').last,
      'notes': notes,
    };
  }
}

class MissingIngredient {
  final String ingredientName;
  final String menuItemName;
  final int requiredQuantity;
  final int currentStock;
  final String unit;
  final bool isOptional;

  MissingIngredient({
    required this.ingredientName,
    required this.menuItemName,
    required this.requiredQuantity,
    required this.currentStock,
    required this.unit,
    required this.isOptional,
  });

  int get missingQuantity => requiredQuantity - currentStock;

  String get displayText =>
      '$menuItemName: thiếu $ingredientName (cần $requiredQuantity$unit)';

  String get stockDisplayText => '$ingredientName: $currentStock$unit';

  factory MissingIngredient.fromJson(Map<String, dynamic> json) {
    return MissingIngredient(
      ingredientName: json['ingredientName'] as String,
      menuItemName: json['menuItemName'] as String,
      requiredQuantity: json['requiredQuantity'] as int,
      currentStock: json['currentStock'] as int,
      unit: json['unit'] as String,
      isOptional: json['isOptional'] as bool,
    );
  }
}