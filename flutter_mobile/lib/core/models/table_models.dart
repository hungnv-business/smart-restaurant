import '../enums/restaurant_enums.dart';

/// DTO cho bàn active trong hệ thống (sync với backend ActiveTableDto)
class ActiveTableDto {
  final String id;
  final String tableNumber;
  final int displayOrder;
  final TableStatus status;
  final String statusDisplay;
  final String? layoutSectionId;
  final String? layoutSectionName;
  final bool hasActiveOrders;
  final int pendingServeOrdersCount;

  ActiveTableDto({
    required this.id,
    required this.tableNumber,
    required this.displayOrder,
    required this.status,
    required this.statusDisplay,
    this.layoutSectionId,
    this.layoutSectionName,
    required this.hasActiveOrders,
    required this.pendingServeOrdersCount,
  });

  factory ActiveTableDto.fromJson(Map<String, dynamic> json) {
    return ActiveTableDto(
      id: json['id'] ?? '',
      tableNumber: json['tableNumber'] ?? '',
      displayOrder: json['displayOrder'] ?? 0,
      status: _parseTableStatus(json['status']),
      statusDisplay: json['statusDisplay'] ?? '',
      layoutSectionId: json['layoutSectionId'],
      layoutSectionName: json['layoutSectionName'],
      hasActiveOrders: json['hasActiveOrders'] ?? false,
      pendingServeOrdersCount: json['pendingServeOrdersCount'] ?? 0,
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
      'pendingServeOrdersCount': pendingServeOrdersCount,
    };
  }

  static TableStatus _parseTableStatus(dynamic statusValue) {
    if (statusValue == null) return TableStatus.available;
    
    // Nếu là số (enum index từ backend)
    if (statusValue is int) {
      switch (statusValue) {
        case 0:
          return TableStatus.available;
        case 1:
          return TableStatus.occupied;
        case 2:
          return TableStatus.reserved;
        default:
          return TableStatus.available;
      }
    }
    
    // Nếu là string
    if (statusValue is String) {
      switch (statusValue.toLowerCase()) {
        case 'available':
        case '0':
          return TableStatus.available;
        case 'occupied':
        case '1':
          return TableStatus.occupied;
        case 'reserved':
        case '2':
          return TableStatus.reserved;
        default:
          return TableStatus.available;
      }
    }
    
    return TableStatus.available;
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
    int? pendingServeOrdersCount,
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
      pendingServeOrdersCount: pendingServeOrdersCount ?? this.pendingServeOrdersCount,
    );
  }
}


