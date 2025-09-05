// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TableModel _$TableModelFromJson(Map<String, dynamic> json) => TableModel(
      id: json['id'] as String,
      tableNumber: json['tableNumber'] as String,
      capacity: (json['capacity'] as num).toInt(),
      status: $enumDecode(_$TableStatusEnumMap, json['status']),
      layoutSectionId: json['layoutSectionId'] as String,
      currentOrderId: json['currentOrderId'] as String?,
      occupiedSince: json['occupiedSince'] == null
          ? null
          : DateTime.parse(json['occupiedSince'] as String),
    );

Map<String, dynamic> _$TableModelToJson(TableModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tableNumber': instance.tableNumber,
      'capacity': instance.capacity,
      'status': _$TableStatusEnumMap[instance.status]!,
      'layoutSectionId': instance.layoutSectionId,
      'currentOrderId': instance.currentOrderId,
      'occupiedSince': instance.occupiedSince?.toIso8601String(),
    };

const _$TableStatusEnumMap = {
  TableStatus.available: 'available',
  TableStatus.occupied: 'occupied',
  TableStatus.reserved: 'reserved',
  TableStatus.cleaning: 'cleaning',
};
