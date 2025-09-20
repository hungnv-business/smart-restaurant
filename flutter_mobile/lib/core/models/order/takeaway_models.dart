import '../../enums/restaurant_enums.dart';

/// DTO cho takeaway orders - chỉ hiển thị thông tin cần thiết cho mobile app
class TakeawayOrderDto {
  final String id;
  final String orderNumber;
  final String customerName;
  final String customerPhone;
  final TakeawayStatus status;
  final String statusDisplay;
  final int totalAmount;
  final String notes;
  final DateTime createdTime;
  final DateTime? paymentTime;
  final List<String> itemNames;
  final int itemCount;

  const TakeawayOrderDto({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.status,
    required this.statusDisplay,
    required this.totalAmount,
    this.notes = '',
    required this.createdTime,
    this.paymentTime,
    required this.itemNames,
    required this.itemCount,
  });

  /// Format tổng tiền hiển thị
  String get formattedTotal => '${totalAmount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
    (Match m) => '${m[1]}.',
  )}₫';

  /// Thời gian tạo đơn format cho hiển thị
  String get formattedOrderTime => 
      '${createdTime.hour.toString().padLeft(2, '0')}:${createdTime.minute.toString().padLeft(2, '0')}';

  /// Backwards compatibility - thời gian đặt dạng string
  String get orderTime => formattedOrderTime;

  /// Backwards compatibility - danh sách items cũ
  List<String> get items => itemNames;

  /// Thời gian thanh toán format cho hiển thị
  String get formattedPaymentTime => paymentTime != null 
      ? '${paymentTime!.hour.toString().padLeft(2, '0')}:${paymentTime!.minute.toString().padLeft(2, '0')}'
      : '';


  factory TakeawayOrderDto.fromJson(Map<String, dynamic> json) {
    return TakeawayOrderDto(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      status: _parseTakeawayStatus(json['status']),
      statusDisplay: json['statusDisplay'] ?? '',
      totalAmount: json['totalAmount'] ?? 0,
      notes: json['notes'] ?? '',
      createdTime: json['createdTime'] != null 
          ? DateTime.parse(json['createdTime']) 
          : DateTime.now(),
      paymentTime: json['paymentTime'] != null 
          ? DateTime.parse(json['paymentTime']) 
          : null,
      itemNames: (json['itemNames'] as List<dynamic>?)?.cast<String>() ?? [],
      itemCount: json['itemCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'status': status.index,
      'statusDisplay': statusDisplay,
      'totalAmount': totalAmount,
      'notes': notes,
      'createdTime': createdTime.toIso8601String(),
      'paymentTime': paymentTime?.toIso8601String(),
      'itemNames': itemNames,
      'itemCount': itemCount,
    };
  }

  TakeawayOrderDto copyWith({
    String? id,
    String? orderNumber,
    String? customerName,
    String? customerPhone,
    TakeawayStatus? status,
    String? statusDisplay,
    int? totalAmount,
    String? notes,
    DateTime? createdTime,
    DateTime? paymentTime,
    List<String>? itemNames,
    int? itemCount,
  }) {
    return TakeawayOrderDto(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      status: status ?? this.status,
      statusDisplay: statusDisplay ?? this.statusDisplay,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      createdTime: createdTime ?? this.createdTime,
      paymentTime: paymentTime ?? this.paymentTime,
      itemNames: itemNames ?? this.itemNames,
      itemCount: itemCount ?? this.itemCount,
    );
  }

  static TakeawayStatus _parseTakeawayStatus(dynamic status) {
    if (status is int) {
      if (status >= 0 && status < TakeawayStatus.values.length) {
        return TakeawayStatus.values[status];
      }
    }
    return TakeawayStatus.preparing;
  }
}

/// DTO cho filter takeaway orders
class GetTakeawayOrdersDto {
  final TakeawayStatus? statusFilter;

  const GetTakeawayOrdersDto({
    this.statusFilter,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {};
    
    if (statusFilter != null) {
      params['statusFilter'] = statusFilter!.index;
    }
    
    return params;
  }

  factory GetTakeawayOrdersDto.fromJson(Map<String, dynamic> json) {
    return GetTakeawayOrdersDto(
      statusFilter: json['statusFilter'] != null 
          ? TakeawayStatus.values[json['statusFilter']] 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusFilter': statusFilter?.index,
    };
  }
}

