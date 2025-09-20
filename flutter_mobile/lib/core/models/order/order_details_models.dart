import '../../enums/restaurant_enums.dart';
import 'ingredient_verification_models.dart';

/// DTO thống nhất cho chi tiết đơn hàng (cả DineIn và Takeaway)
/// Thay thế TableDetailDto và TakeawayOrderDetailsDto riêng biệt
class OrderDetailsDto {
  final String id;
  final String orderNumber;
  final OrderType orderType;
  final OrderStatus status;
  final String statusDisplay;
  final int totalAmount;
  final String? notes;
  final DateTime createdTime;

  // =============================================================
  // Takeaway-specific fields (null for DineIn orders)
  // =============================================================
  final String? customerName;
  final String? customerPhone;
  final DateTime? paymentTime;

  // =============================================================
  // DineIn-specific fields (null for Takeaway orders)
  // =============================================================
  final String? tableNumber;
  final String? layoutSectionName;

  // =============================================================
  // Common order details
  // =============================================================
  final OrderSummaryDto orderSummary;
  final List<OrderItemDetailDto> orderItems;

  OrderDetailsDto({
    required this.id,
    required this.orderNumber,
    required this.orderType,
    required this.status,
    required this.statusDisplay,
    required this.totalAmount,
    this.notes,
    required this.createdTime,
    this.customerName,
    this.customerPhone,
    this.paymentTime,
    this.tableNumber,
    this.layoutSectionName,
    required this.orderSummary,
    required this.orderItems,
  });

  factory OrderDetailsDto.fromJson(Map<String, dynamic> json) {
    return OrderDetailsDto(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      orderType: EnumParser.parseOrderType(json['orderType']),
      status: EnumParser.parseOrderStatus(json['status']),
      statusDisplay: json['statusDisplay'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toInt(),
      notes: json['notes'],
      createdTime: DateTime.parse(json['createdTime'] ?? DateTime.now().toIso8601String()),
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      paymentTime: json['paymentTime'] != null ? DateTime.parse(json['paymentTime']) : null,
      tableNumber: json['tableNumber'],
      layoutSectionName: json['layoutSectionName'],
      orderSummary: OrderSummaryDto.fromJson(json['orderSummary'] ?? {}),
      orderItems: (json['orderItems'] as List<dynamic>?)
          ?.map((item) => OrderItemDetailDto.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'orderType': orderType.index,
      'status': status.index,
      'statusDisplay': statusDisplay,
      'totalAmount': totalAmount,
      'notes': notes,
      'createdTime': createdTime.toIso8601String(),
      'customerName': customerName,
      'customerPhone': customerPhone,
      'paymentTime': paymentTime?.toIso8601String(),
      'tableNumber': tableNumber,
      'layoutSectionName': layoutSectionName,
      'orderSummary': orderSummary.toJson(),
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
    };
  }

  String get formattedTotal => '${totalAmount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
    (Match m) => '${m[1]}.',
  )}₫';

  /// Kiểm tra xem đây có phải là DineIn order không
  bool get isDineIn => orderType == OrderType.dineIn;

  /// Kiểm tra xem đây có phải là Takeaway order không
  bool get isTakeaway => orderType == OrderType.takeaway;
}

/// DTO thống nhất cho chi tiết từng món trong đơn hàng
/// Gộp chung logic từ TableOrderItemDto và TakeawayOrderItemDto
class OrderItemDetailDto {
  final String id;
  final String menuItemName;
  final int quantity;
  final int unitPrice;
  final int totalPrice;
  final OrderItemStatus status;
  final String specialRequest;
  final bool canEdit;
  final bool canDelete;
  final bool hasMissingIngredients;
  final List<MissingIngredientDto> missingIngredients;
  final bool requiresCooking;

  OrderItemDetailDto({
    required this.id,
    required this.menuItemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.status,
    this.specialRequest = '',
    required this.canEdit,
    required this.canDelete,
    this.hasMissingIngredients = false,
    this.missingIngredients = const [],
    this.requiresCooking = true,
  });

  /// Backward compatibility getter
  String? get missingIngredientsMessage {
    if (missingIngredients.isEmpty) return null;
    return missingIngredients.map((ingredient) => ingredient.displayMessage).join(', ');
  }

  factory OrderItemDetailDto.fromJson(Map<String, dynamic> json) {
    return OrderItemDetailDto(
      id: json['id'] ?? '',
      menuItemName: json['menuItemName'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toInt(),
      totalPrice: (json['totalPrice'] ?? 0).toInt(),
      status: EnumParser.parseOrderItemStatus(json['status']),
      specialRequest: json['specialRequest'] ?? '',
      canEdit: json['canEdit'] ?? false,
      canDelete: json['canDelete'] ?? false,
      hasMissingIngredients: json['hasMissingIngredients'] ?? false,
      missingIngredients: (json['missingIngredients'] as List<dynamic>?)
          ?.map((item) => MissingIngredientDto.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      requiresCooking: json['requiresCooking'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuItemName': menuItemName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'status': status.index,
      'specialRequest': specialRequest,
      'canEdit': canEdit,
      'canDelete': canDelete,
      'hasMissingIngredients': hasMissingIngredients,
      'missingIngredients': missingIngredients.map((item) => item.toJson()).toList(),
      'requiresCooking': requiresCooking,
    };
  }

  String get formattedUnitPrice => '${unitPrice.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
    (Match m) => '${m[1]}.',
  )}₫';

  String get formattedTotalPrice => '${totalPrice.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
    (Match m) => '${m[1]}.',
  )}₫';
}

/// DTO tóm tắt đơn hàng (dùng chung cho cả DineIn và Takeaway)
class OrderSummaryDto {
  final int totalItemsCount;
  final int pendingServeCount;
  final int totalAmount;

  OrderSummaryDto({
    required this.totalItemsCount,
    required this.pendingServeCount,
    required this.totalAmount,
  });

  factory OrderSummaryDto.fromJson(Map<String, dynamic> json) {
    return OrderSummaryDto(
      totalItemsCount: json['totalItemsCount'] ?? 0,
      pendingServeCount: json['pendingServeCount'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalItemsCount': totalItemsCount,
      'pendingServeCount': pendingServeCount,
      'totalAmount': totalAmount,
    };
  }
}