// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuCategoryModel _$MenuCategoryModelFromJson(Map<String, dynamic> json) =>
    MenuCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$MenuCategoryModelToJson(MenuCategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
    };

MenuItemModel _$MenuItemModelFromJson(Map<String, dynamic> json) =>
    MenuItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toInt(),
      categoryId: json['categoryId'] as String,
      isAvailable: json['isAvailable'] as bool,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$MenuItemModelToJson(MenuItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'categoryId': instance.categoryId,
      'isAvailable': instance.isAvailable,
      'imageUrl': instance.imageUrl,
    };
