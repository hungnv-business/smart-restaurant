class MenuItem {
  final String id;
  final String name;
  final String? description;
  final double price;
  final bool isAvailable;
  final String? imageUrl;
  final String categoryId;

  MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.isAvailable,
    this.imageUrl,
    required this.categoryId,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      isAvailable: json['isAvailable'] as bool,
      imageUrl: json['imageUrl'] as String?,
      categoryId: json['categoryId'] as String,
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
    };
  }
}

class MenuCategory {
  final String id;
  final String name;
  final String? description;
  final int displayOrder;

  MenuCategory({
    required this.id,
    required this.name,
    this.description,
    required this.displayOrder,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      displayOrder: json['displayOrder'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'displayOrder': displayOrder,
    };
  }
}