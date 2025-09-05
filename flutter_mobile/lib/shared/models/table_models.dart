import 'package:json_annotation/json_annotation.dart';

part 'table_models.g.dart';

enum TableStatus {
  @JsonValue('available')
  available,
  @JsonValue('occupied')
  occupied,
  @JsonValue('reserved')
  reserved,
  @JsonValue('cleaning')
  cleaning,
}

@JsonSerializable()
class TableModel {
  final String id;
  final String tableNumber;
  final int capacity;
  final TableStatus status;
  final String layoutSectionId;
  final String? currentOrderId;
  final DateTime? occupiedSince;

  const TableModel({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.status,
    required this.layoutSectionId,
    this.currentOrderId,
    this.occupiedSince,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) =>
      _$TableModelFromJson(json);

  Map<String, dynamic> toJson() => _$TableModelToJson(this);

  TableModel copyWith({
    String? id,
    String? tableNumber,
    int? capacity,
    TableStatus? status,
    String? layoutSectionId,
    String? currentOrderId,
    DateTime? occupiedSince,
  }) {
    return TableModel(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      layoutSectionId: layoutSectionId ?? this.layoutSectionId,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      occupiedSince: occupiedSince ?? this.occupiedSince,
    );
  }

  String get statusDisplayName {
    switch (status) {
      case TableStatus.available:
        return 'Trống';
      case TableStatus.occupied:
        return 'Có khách';
      case TableStatus.reserved:
        return 'Đã đặt';
      case TableStatus.cleaning:
        return 'Đang dọn';
    }
  }

  String get capacityDisplayName => '$capacity người';

  bool get isSelectable =>
      status == TableStatus.available || status == TableStatus.reserved;
}