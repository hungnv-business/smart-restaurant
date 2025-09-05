import 'package:json_annotation/json_annotation.dart';

part 'menu_models.g.dart';

@JsonSerializable()
class MenuCategoryModel {
  final String id;
  final String name;
  final String description;
  final int sortOrder;
  final bool isActive;

  const MenuCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.sortOrder,
    required this.isActive,
  });

  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$MenuCategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$MenuCategoryModelToJson(this);

  MenuCategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    int? sortOrder,
    bool? isActive,
  }) {
    return MenuCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }
}

@JsonSerializable()
class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final int price;
  final String categoryId;
  final bool isAvailable;
  final String? imageUrl;

  const MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.isAvailable,
    this.imageUrl,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) =>
      _$MenuItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemModelToJson(this);

  MenuItemModel copyWith({
    String? id,
    String? name,
    String? description,
    int? price,
    String? categoryId,
    bool? isAvailable,
    String? imageUrl,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}