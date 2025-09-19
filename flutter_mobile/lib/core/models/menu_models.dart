/// Models cho Menu Management
/// Tương ứng với DTOs từ backend SmartRestaurant

/// Model cho danh mục món ăn (tương ứng GuidLookupItemDto)
class MenuCategory {
  final String id;
  final String displayName;

  const MenuCategory({
    required this.id,
    required this.displayName,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MenuCategory{id: $id, displayName: $displayName}';
  }
}

/// Model cho món ăn (tương ứng MenuItemDto từ backend)
class MenuItem {
  final String id;
  final String name;
  final String? description;
  final int price;
  final bool isAvailable;
  final String? imageUrl;
  final String categoryId;
  final String? categoryName;
  final int soldQuantity;
  final bool isPopular;
  final int maximumQuantityAvailable;
  final bool isOutOfStock;
  final bool hasLimitedStock;
  final bool requiresCooking;

  const MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.isAvailable,
    this.imageUrl,
    required this.categoryId,
    this.categoryName,
    this.soldQuantity = 0,
    this.isPopular = false,
    this.maximumQuantityAvailable = 0,
    this.isOutOfStock = false,
    this.hasLimitedStock = false,
    this.requiresCooking = true,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toInt(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String?,
      soldQuantity: json['soldQuantity'] as int? ?? 0,
      isPopular: json['isPopular'] as bool? ?? false,
      maximumQuantityAvailable: json['maximumQuantityAvailable'] as int? ?? 0,
      isOutOfStock: json['isOutOfStock'] as bool? ?? false,
      hasLimitedStock: json['hasLimitedStock'] as bool? ?? false,
      requiresCooking: json['requiresCooking'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'soldQuantity': soldQuantity,
      'isPopular': isPopular,
      'maximumQuantityAvailable': maximumQuantityAvailable,
      'isOutOfStock': isOutOfStock,
      'hasLimitedStock': hasLimitedStock,
      'requiresCooking': requiresCooking,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MenuItem{id: $id, name: $name, price: $price, isAvailable: $isAvailable, stock: $maximumQuantityAvailable}';
  }
  
  /// Getter để kiểm tra món có thể order được không
  bool get canOrder => isAvailable && !isOutOfStock;
  
  /// Getter để lấy stock status text
  String get stockStatusText {
    if (isOutOfStock) return 'Hết hàng';
    if (hasLimitedStock) return 'Còn ${maximumQuantityAvailable} phần';
    if (maximumQuantityAvailable == 2147483647) return 'Còn hàng'; // int.maxValue từ backend
    return 'Còn ${maximumQuantityAvailable} phần';
  }
  
  /// Getter để lấy màu stock status
  StockStatusColor get stockStatusColor {
    if (isOutOfStock) return StockStatusColor.outOfStock;
    if (hasLimitedStock) return StockStatusColor.limited;
    return StockStatusColor.available;
  }
}

/// Enum cho màu stock status
enum StockStatusColor {
  available, // Xanh lá
  limited,   // Vàng/Cam
  outOfStock // Đỏ
}

/// Model cho filter khi lấy danh sách món ăn (tương ứng GetMenuItemsForOrderDto)
class GetMenuItemsForOrder {
  final String? nameFilter;
  final String? categoryId;
  final bool onlyAvailable;

  const GetMenuItemsForOrder({
    this.nameFilter,
    this.categoryId,
    this.onlyAvailable = true,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {};
    
    if (nameFilter != null && nameFilter!.isNotEmpty) {
      params['NameFilter'] = nameFilter;
    }
    if (categoryId != null) {
      params['CategoryId'] = categoryId;
    }
    params['OnlyAvailable'] = onlyAvailable;

    return params;
  }
}

/// Response wrapper cho danh sách categories từ API
class MenuCategoriesResponse {
  final List<MenuCategory> items;

  const MenuCategoriesResponse({
    required this.items,
  });

  factory MenuCategoriesResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>?)
        ?.map((item) => MenuCategory.fromJson(item as Map<String, dynamic>))
        .toList() ?? [];
    
    return MenuCategoriesResponse(items: items);
  }
}

/// Response wrapper cho danh sách menu items từ API
class MenuItemsResponse {
  final List<MenuItem> items;

  const MenuItemsResponse({
    required this.items,
  });

  factory MenuItemsResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>?)
        ?.map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
        .toList() ?? [];
    
    return MenuItemsResponse(items: items);
  }
}