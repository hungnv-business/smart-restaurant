/// Models cho Ingredient Verification API
/// Tương ứng với DTOs từ backend SmartRestaurant

/// Request model cho verify ingredients
class VerifyIngredientsRequest {
  final List<OrderItemRequest> items;

  const VerifyIngredientsRequest({
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

/// Model cho một item trong order (tương ứng CreateOrderItemDto)
class OrderItemRequest {
  final String menuItemId;
  final String menuItemName;
  final int quantity;
  final String? notes;

  const OrderItemRequest({
    required this.menuItemId,
    required this.menuItemName,
    required this.quantity,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'menuItemId': menuItemId,
      'menuItemName': menuItemName,
      'quantity': quantity,
      'notes': notes,
    };
  }
}

/// Model cho nguyên liệu thiếu
class MissingIngredient {
  final String menuItemId;
  final String menuItemName;
  final String ingredientId;
  final String ingredientName;
  final int requiredQuantity;
  final int currentStock;
  final String unit;
  final int shortageAmount;
  final String displayMessage;

  const MissingIngredient({
    required this.menuItemId,
    required this.menuItemName,
    required this.ingredientId,
    required this.ingredientName,
    required this.requiredQuantity,
    required this.currentStock,
    required this.unit,
    required this.shortageAmount,
    required this.displayMessage,
  });

  factory MissingIngredient.fromJson(Map<String, dynamic> json) {
    return MissingIngredient(
      menuItemId: json['menuItemId'] as String,
      menuItemName: json['menuItemName'] as String,
      ingredientId: json['ingredientId'] as String,
      ingredientName: json['ingredientName'] as String,
      requiredQuantity: json['requiredQuantity'] as int,
      currentStock: json['currentStock'] as int,
      unit: json['unit'] as String,
      shortageAmount: json['shortageAmount'] as int,
      displayMessage: json['displayMessage'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItemId': menuItemId,
      'menuItemName': menuItemName,
      'ingredientId': ingredientId,
      'ingredientName': ingredientName,
      'requiredQuantity': requiredQuantity,
      'currentStock': currentStock,
      'unit': unit,
      'shortageAmount': shortageAmount,
      'displayMessage': displayMessage,
    };
  }
}

/// Response model cho ingredient availability
class IngredientAvailabilityResult {
  final bool isAvailable;
  final List<MissingIngredient> missingIngredients;
  final int totalItemsCount;
  final int unavailableItemsCount;
  final String summaryMessage;
  final List<String> unavailableMenuItems;

  const IngredientAvailabilityResult({
    required this.isAvailable,
    required this.missingIngredients,
    required this.totalItemsCount,
    required this.unavailableItemsCount,
    required this.summaryMessage,
    required this.unavailableMenuItems,
  });

  factory IngredientAvailabilityResult.fromJson(Map<String, dynamic> json) {
    return IngredientAvailabilityResult(
      isAvailable: json['isAvailable'] as bool,
      missingIngredients: (json['missingIngredients'] as List<dynamic>?)
          ?.map((item) => MissingIngredient.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      totalItemsCount: json['totalItemsCount'] as int,
      unavailableItemsCount: json['unavailableItemsCount'] as int,
      summaryMessage: json['summaryMessage'] as String,
      unavailableMenuItems: (json['unavailableMenuItems'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList() ?? [],
    );
  }

  /// Có thiếu nguyên liệu nào không
  bool get hasMissingIngredients => missingIngredients.isNotEmpty;

  /// Thông điệp hiển thị ngắn gọn
  String get shortSummary {
    if (isAvailable) return "✅ Đủ nguyên liệu cho tất cả món";
    return "⚠️ Thiếu nguyên liệu cho $unavailableItemsCount/$totalItemsCount món";
  }
}