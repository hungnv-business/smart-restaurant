import '../enums/restaurant_enums.dart';

/// DTO cho chi tiết takeaway order - tương tự TableDetailDto nhưng cho takeaway
class TakeawayOrderDetailsDto {
  final String id;
  final String orderNumber;
  final String customerName;
  final String customerPhone;
  final TakeawayStatus status;
  final int totalAmount;
  final String? notes;
  final DateTime createdTime;
  final DateTime? pickupTime;
  final TakeawayOrderSummaryDto orderSummary;
  final List<TakeawayOrderItemDto> orderItems;

  TakeawayOrderDetailsDto({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.status,
    required this.totalAmount,
    this.notes,
    required this.createdTime,
    this.pickupTime,
    required this.orderSummary,
    required this.orderItems,
  });

  factory TakeawayOrderDetailsDto.fromJson(Map<String, dynamic> json) {
    return TakeawayOrderDetailsDto(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      status: TakeawayStatus.values[json['status'] ?? 0],
      totalAmount: (json['totalAmount'] ?? 0).toInt(),
      notes: json['notes'],
      createdTime: DateTime.parse(json['createdTime'] ?? DateTime.now().toIso8601String()),
      pickupTime: json['pickupTime'] != null ? DateTime.parse(json['pickupTime']) : null,
      orderSummary: TakeawayOrderSummaryDto.fromJson(json['orderSummary'] ?? {}),
      orderItems: (json['orderItems'] as List<dynamic>?)
          ?.map((item) => TakeawayOrderItemDto.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'status': status.index,
      'totalAmount': totalAmount,
      'notes': notes,
      'createdTime': createdTime.toIso8601String(),
      'pickupTime': pickupTime?.toIso8601String(),
      'orderSummary': orderSummary.toJson(),
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
    };
  }

  String get formattedTotal => '${totalAmount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
    (Match m) => '${m[1]}.',
  )}₫';
}

/// DTO tóm tắt đơn takeaway
class TakeawayOrderSummaryDto {
  final int totalItemsCount;
  final int pendingServeCount;
  final int totalAmount;

  TakeawayOrderSummaryDto({
    required this.totalItemsCount,
    required this.pendingServeCount,
    required this.totalAmount,
  });

  factory TakeawayOrderSummaryDto.fromJson(Map<String, dynamic> json) {
    return TakeawayOrderSummaryDto(
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

/// DTO chi tiết từng món trong takeaway order
class TakeawayOrderItemDto {
  final String id;
  final String menuItemName;
  final int quantity;
  final int unitPrice;
  final int totalPrice;
  final OrderItemStatus status;
  final String? specialRequest;
  final bool canEdit;
  final bool canDelete;
  final bool hasMissingIngredients;
  final List<String> missingIngredients;
  final bool requiresCooking;

  TakeawayOrderItemDto({
    required this.id,
    required this.menuItemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.status,
    this.specialRequest,
    required this.canEdit,
    required this.canDelete,
    this.hasMissingIngredients = false,
    this.missingIngredients = const [],
    this.requiresCooking = true,
  });

  factory TakeawayOrderItemDto.fromJson(Map<String, dynamic> json) {
    return TakeawayOrderItemDto(
      id: json['id'] ?? '',
      menuItemName: json['menuItemName'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toInt(),
      totalPrice: (json['totalPrice'] ?? 0).toInt(),
      status: EnumParser.parseOrderItemStatus(json['status']),
      specialRequest: json['specialRequest'],
      canEdit: json['canEdit'] ?? false,
      canDelete: json['canDelete'] ?? false,
      hasMissingIngredients: json['hasMissingIngredients'] ?? false,
      missingIngredients: (json['missingIngredients'] as List<dynamic>?)?.cast<String>() ?? [],
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
      'missingIngredients': missingIngredients,
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