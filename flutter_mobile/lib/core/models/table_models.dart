import '../enums/restaurant_enums.dart';
import 'ingredient_verification_models.dart';

/// DTO cho bàn active trong danh sách bàn (đơn giản để hiển thị danh sách)
class ActiveTableDto {
  final String id;
  final String tableNumber;
  final int displayOrder;
  final TableStatus status;
  final String statusDisplay;
  final String? layoutSectionId;
  final String? layoutSectionName;
  final bool hasActiveOrders;
  final String orderStatusDisplay; // "Có đơn hàng", "Món chờ phục vụ"
  final int pendingItemsCount;
  final int readyItemsCount; // Số món đã sẵn sàng phục vụ

  ActiveTableDto({
    required this.id,
    required this.tableNumber,
    required this.displayOrder,
    required this.status,
    required this.statusDisplay,
    this.layoutSectionId,
    this.layoutSectionName,
    required this.hasActiveOrders,
    required this.orderStatusDisplay,
    required this.pendingItemsCount,
    required this.readyItemsCount,
  });

  factory ActiveTableDto.fromJson(Map<String, dynamic> json) {
    return ActiveTableDto(
      id: json['id'] ?? '',
      tableNumber: json['tableNumber'] ?? '',
      displayOrder: json['displayOrder'] ?? 0,
      status: EnumParser.parseTableStatus(json['status']),
      statusDisplay: json['statusDisplay'] ?? '',
      layoutSectionId: json['layoutSectionId'],
      layoutSectionName: json['layoutSectionName'],
      hasActiveOrders: json['hasActiveOrders'] ?? false,
      orderStatusDisplay: json['orderStatusDisplay'] ?? AppTexts.emptyTable,
      pendingItemsCount: json['pendingItemsCount'] ?? 0,
      readyItemsCount: json['readyItemsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableNumber': tableNumber,
      'displayOrder': displayOrder,
      'status': status.index,
      'statusDisplay': statusDisplay,
      'layoutSectionId': layoutSectionId,
      'layoutSectionName': layoutSectionName,
      'hasActiveOrders': hasActiveOrders,
      'orderStatusDisplay': orderStatusDisplay,
      'pendingItemsCount': pendingItemsCount,
      'readyItemsCount': readyItemsCount,
    };
  }


  ActiveTableDto copyWith({
    String? id,
    String? tableNumber,
    int? displayOrder,
    TableStatus? status,
    String? statusDisplay,
    String? layoutSectionId,
    String? layoutSectionName,
    bool? hasActiveOrders,
    String? orderStatusDisplay,
    int? pendingItemsCount,
    int? readyItemsCount,
  }) {
    return ActiveTableDto(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      displayOrder: displayOrder ?? this.displayOrder,
      status: status ?? this.status,
      statusDisplay: statusDisplay ?? this.statusDisplay,
      layoutSectionId: layoutSectionId ?? this.layoutSectionId,
      layoutSectionName: layoutSectionName ?? this.layoutSectionName,
      hasActiveOrders: hasActiveOrders ?? this.hasActiveOrders,
      orderStatusDisplay: orderStatusDisplay ?? this.orderStatusDisplay,
      pendingItemsCount: pendingItemsCount ?? this.pendingItemsCount,
      readyItemsCount: readyItemsCount ?? this.readyItemsCount,
    );
  }
}

/// DTO cho chi tiết bàn với đầy đủ thông tin đơn hàng (dùng khi click vào bàn)
class TableDetailDto {
  final String id;
  final String tableNumber;
  final String layoutSectionName;
  final TableStatus status;
  final String statusDisplay;
  final String? orderId; // ID của order đang active (nếu có)
  final TableOrderSummaryDto? orderSummary;
  final List<TableOrderItemDto> orderItems;

  TableDetailDto({
    required this.id,
    required this.tableNumber,
    required this.layoutSectionName,
    required this.status,
    required this.statusDisplay,
    this.orderId,
    this.orderSummary,
    required this.orderItems,
  });

  factory TableDetailDto.fromJson(Map<String, dynamic> json) {
    return TableDetailDto(
      id: json['id'] ?? '',
      tableNumber: json['tableNumber'] ?? '',
      layoutSectionName: json['layoutSectionName'] ?? '',
      status: EnumParser.parseTableStatus(json['status']),
      statusDisplay: json['statusDisplay'] ?? '',
      orderId: json['orderId'], // ID của order đang active
      orderSummary: json['orderSummary'] != null
          ? TableOrderSummaryDto.fromJson(json['orderSummary'])
          : null,
      orderItems: json['orderItems'] != null
          ? (json['orderItems'] as List)
              .map((item) => TableOrderItemDto.fromJson(item))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableNumber': tableNumber,
      'layoutSectionName': layoutSectionName,
      'status': status.index,
      'statusDisplay': statusDisplay,
      'orderId': orderId,
      'orderSummary': orderSummary?.toJson(),
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
    };
  }
}

/// DTO tổng quan đơn hàng của bàn
class TableOrderSummaryDto {
  final int totalItemsCount;
  final int pendingServeCount;
  final int totalAmount;

  TableOrderSummaryDto({
    required this.totalItemsCount,
    required this.pendingServeCount,
    required this.totalAmount,
  });

  factory TableOrderSummaryDto.fromJson(Map<String, dynamic> json) {
    return TableOrderSummaryDto(
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

/// DTO món ăn trong đơn hàng của bàn
class TableOrderItemDto {
  final String id;
  final String menuItemName;
  final int quantity;
  final int unitPrice;
  final int totalPrice;
  final OrderItemStatus status;
  final bool canEdit;
  final bool canDelete;
  final String? specialRequest;
  final bool hasMissingIngredients;
  final List<MissingIngredientDto> missingIngredients;
  final bool requiresCooking;

  TableOrderItemDto({
    required this.id,
    required this.menuItemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.status,
    required this.canEdit,
    required this.canDelete,
    this.specialRequest,
    this.hasMissingIngredients = false,
    this.missingIngredients = const [],
    this.requiresCooking = true,
  });

  factory TableOrderItemDto.fromJson(Map<String, dynamic> json) {
    return TableOrderItemDto(
      id: json['id'] ?? '',
      menuItemName: json['menuItemName'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toInt(),
      totalPrice: (json['totalPrice'] ?? 0).toInt(),
      status: EnumParser.parseOrderItemStatus(json['status']),
      canEdit: json['canEdit'] ?? false,
      canDelete: json['canDelete'] ?? false,
      specialRequest: json['specialRequest'],
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
      'canEdit': canEdit,
      'canDelete': canDelete,
      'specialRequest': specialRequest,
      'hasMissingIngredients': hasMissingIngredients,
      'missingIngredients': missingIngredients.map((item) => item.toJson()).toList(),
      'requiresCooking': requiresCooking,
    };
  }

}

