import '../../enums/restaurant_enums.dart';

/// DTO tối ưu cho danh sách bàn trong màn hình DineIn mobile
/// Kế thừa từ ActiveTableDto nhưng thêm thông tin tối ưu cho mobile
class DineInTableDto {
  final String id;
  final String tableNumber;
  final int displayOrder;
  final TableStatus status;
  final String statusDisplay;
  final String layoutSectionId;
  final String layoutSectionName;
  final bool hasActiveOrders;
  final String? currentOrderId;
  final String pendingItemsDisplay;
  final String readyItemsCountDisplay;
  final DateTime? orderCreatedTime;

  const DineInTableDto({
    required this.id,
    required this.tableNumber,
    required this.displayOrder,
    required this.status,
    required this.statusDisplay,
    required this.layoutSectionId,
    required this.layoutSectionName,
    required this.hasActiveOrders,
    this.currentOrderId,
    required this.pendingItemsDisplay,
    required this.readyItemsCountDisplay,
    this.orderCreatedTime,
  });

  // Backward compatibility getters
  int get pendingItemsCount {
    // Parse from display string or return 0
    final match = RegExp(r'\d+').firstMatch(pendingItemsDisplay);
    return match != null ? int.tryParse(match.group(0)!) ?? 0 : 0;
  }

  int get readyItemsCount {
    // Parse from display string or return 0
    final match = RegExp(r'\d+').firstMatch(readyItemsCountDisplay);
    return match != null ? int.tryParse(match.group(0)!) ?? 0 : 0;
  }

  factory DineInTableDto.fromJson(Map<String, dynamic> json) {
    return DineInTableDto(
      id: json['id'] ?? '',
      tableNumber: json['tableNumber'] ?? '',
      displayOrder: json['displayOrder'] ?? 0,
      status: _parseTableStatus(json['status']),
      statusDisplay: json['statusDisplay'] ?? '',
      layoutSectionId: json['layoutSectionId'] ?? '',
      layoutSectionName: json['layoutSectionName'] ?? '',
      hasActiveOrders: json['hasActiveOrders'] ?? false,
      currentOrderId: json['currentOrderId'],
      pendingItemsDisplay: json['pendingItemsDisplay'] ?? '',
      readyItemsCountDisplay: json['readyItemsCountDisplay'] ?? '',
      orderCreatedTime: json['orderCreatedTime'] != null 
          ? DateTime.parse(json['orderCreatedTime']) 
          : null,
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
      'currentOrderId': currentOrderId,
      'pendingItemsDisplay': pendingItemsDisplay,
      'readyItemsCountDisplay': readyItemsCountDisplay,
      'orderCreatedTime': orderCreatedTime?.toIso8601String(),
    };
  }

  DineInTableDto copyWith({
    String? id,
    String? tableNumber,
    int? displayOrder,
    TableStatus? status,
    String? statusDisplay,
    String? layoutSectionId,
    String? layoutSectionName,
    bool? hasActiveOrders,
    String? currentOrderId,
    String? pendingItemsDisplay,
    String? readyItemsCountDisplay,
    DateTime? orderCreatedTime,
  }) {
    return DineInTableDto(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      displayOrder: displayOrder ?? this.displayOrder,
      status: status ?? this.status,
      statusDisplay: statusDisplay ?? this.statusDisplay,
      layoutSectionId: layoutSectionId ?? this.layoutSectionId,
      layoutSectionName: layoutSectionName ?? this.layoutSectionName,
      hasActiveOrders: hasActiveOrders ?? this.hasActiveOrders,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      pendingItemsDisplay: pendingItemsDisplay ?? this.pendingItemsDisplay,
      readyItemsCountDisplay: readyItemsCountDisplay ?? this.readyItemsCountDisplay,
      orderCreatedTime: orderCreatedTime ?? this.orderCreatedTime,
    );
  }

  static TableStatus _parseTableStatus(dynamic status) {
    if (status is int) {
      if (status >= 0 && status < TableStatus.values.length) {
        return TableStatus.values[status];
      }
    }
    return TableStatus.available;
  }
}

/// DTO cho filter danh sách bàn DineIn
class GetDineInTablesDto {
  final String? tableNameFilter;
  final TableStatus? statusFilter;

  const GetDineInTablesDto({
    this.tableNameFilter,
    this.statusFilter,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {};
    
    if (tableNameFilter != null && tableNameFilter!.isNotEmpty) {
      params['tableNameFilter'] = tableNameFilter;
    }
    
    if (statusFilter != null) {
      params['statusFilter'] = statusFilter!.index;
    }
    
    return params;
  }

  factory GetDineInTablesDto.fromJson(Map<String, dynamic> json) {
    return GetDineInTablesDto(
      tableNameFilter: json['tableNameFilter'],
      statusFilter: json['statusFilter'] != null 
          ? TableStatus.values[json['statusFilter']] 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tableNameFilter': tableNameFilter,
      'statusFilter': statusFilter?.index,
    };
  }
}