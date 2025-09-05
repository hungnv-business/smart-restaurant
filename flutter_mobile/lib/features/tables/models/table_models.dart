enum TableStatus {
  available,
  occupied,
  reserved,
  cleaning;

  String get displayName {
    switch (this) {
      case TableStatus.available:
        return 'Có sẵn';
      case TableStatus.occupied:
        return 'Đang sử dụng';
      case TableStatus.reserved:
        return 'Đã đặt trước';
      case TableStatus.cleaning:
        return 'Đang dọn dẹp';
    }
  }
}

class RestaurantTable {
  final String id;
  final String tableNumber;
  final int capacity;
  final String layoutSectionId;
  final TableStatus status;
  final DateTime? lastModifiedTime;

  RestaurantTable({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.layoutSectionId,
    required this.status,
    this.lastModifiedTime,
  });

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      id: json['id'] as String,
      tableNumber: json['tableNumber'] as String,
      capacity: json['capacity'] as int,
      layoutSectionId: json['layoutSectionId'] as String,
      status: TableStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      lastModifiedTime: json['lastModifiedTime'] != null
          ? DateTime.parse(json['lastModifiedTime'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableNumber': tableNumber,
      'capacity': capacity,
      'layoutSectionId': layoutSectionId,
      'status': status.toString().split('.').last,
      'lastModifiedTime': lastModifiedTime?.toIso8601String(),
    };
  }
}