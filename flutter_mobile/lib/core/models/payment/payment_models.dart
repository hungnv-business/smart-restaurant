library;

/// Models cho Payment API
/// Tương ứng với DTOs từ backend SmartRestaurant

/// Enum phương thức thanh toán tương ứng với backend PaymentMethod
enum PaymentMethod {
  /// Tiền mặt
  cash(0, 'Tiền mặt'),
  
  /// Chuyển khoản ngân hàng
  bankTransfer(1, 'Chuyển khoản'),
  
  /// Nợ (trả sau)
  credit(2, 'Trả sau');

  const PaymentMethod(this.value, this.displayName);
  
  final int value;
  final String displayName;
  
  /// Convert từ int về PaymentMethod
  static PaymentMethod fromValue(int value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}

/// Request DTO cho việc thanh toán
/// Tương ứng với PaymentRequestDto.cs
class PaymentRequestDto {
  /// ID đơn hàng cần thanh toán
  final String orderId;
  
  /// Phương thức thanh toán
  final PaymentMethod paymentMethod;
  
  /// Tiền khách đưa (nếu thanh toán tiền mặt)
  final int? customerMoney;
  
  /// Ghi chú thêm cho thanh toán
  final String? notes;

  const PaymentRequestDto({
    required this.orderId,
    required this.paymentMethod,
    this.customerMoney,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'paymentMethod': paymentMethod.value,
      if (customerMoney != null) 'customerMoney': customerMoney,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }

  /// Validate business rules
  List<String> validate() {
    final errors = <String>[];
    
    if (orderId.isEmpty) {
      errors.add('ID đơn hàng không được rỗng');
    }
    
    if (paymentMethod == PaymentMethod.cash && customerMoney == null) {
      errors.add('Thanh toán tiền mặt phải có số tiền khách đưa');
    }
    
    if (customerMoney != null && customerMoney! < 0) {
      errors.add('Số tiền khách đưa không được âm');
    }
    
    return errors;
  }

  bool get isValid => validate().isEmpty;
}

/// DTO để lấy thông tin đơn hàng cho việc thanh toán
/// Tương ứng với OrderForPaymentDto.cs
class OrderForPaymentDto {
  /// ID đơn hàng
  final String id;
  
  /// Số đơn hàng
  final String orderNumber;
  
  /// Loại đơn hàng
  final String orderType;
  
  /// Trạng thái đơn hàng  
  final String status;
  
  /// Tổng tiền đơn hàng
  final int totalAmount;
  
  /// Ghi chú đơn hàng
  final String? notes;
  
  /// Thời gian tạo đơn
  final DateTime creationTime;
  
  /// Thông tin bàn (nếu có)
  final String? tableInfo;
  
  /// Danh sách món ăn trong đơn
  final List<OrderItemDto> orderItems;

  const OrderForPaymentDto({
    required this.id,
    required this.orderNumber,
    required this.orderType,
    required this.status,
    required this.totalAmount,
    this.notes,
    required this.creationTime,
    this.tableInfo,
    required this.orderItems,
  });

  factory OrderForPaymentDto.fromJson(Map<String, dynamic> json) {
    return OrderForPaymentDto(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      orderType: json['orderType'] as String,
      status: json['status'] as String,
      totalAmount: (json['totalAmount'] as num).toInt(),
      notes: json['notes'] as String?,
      creationTime: DateTime.parse(json['creationTime'] as String),
      tableInfo: json['tableInfo'] as String?,
      orderItems: (json['orderItems'] as List<dynamic>?)
          ?.map((item) => OrderItemDto.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

/// Model cho món ăn trong đơn thanh toán (đơn giản hóa)
class OrderItemDto {
  final String id;
  final String menuItemName;
  final int quantity;
  final int unitPrice;
  final int totalPrice;
  final String status;

  const OrderItemDto({
    required this.id,
    required this.menuItemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.status,
  });

  factory OrderItemDto.fromJson(Map<String, dynamic> json) {
    return OrderItemDto(
      id: json['id'] as String,
      menuItemName: json['menuItemName'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toInt(),
      totalPrice: (json['totalPrice'] as num).toInt(),
      status: json['status'] as String,
    );
  }
}

/// Request DTO để cập nhật số lượng món ăn
/// Tương ứng với UpdateOrderItemQuantityDto.cs  
class UpdateOrderItemQuantityDto {
  /// Số lượng mới (phải lớn hơn 0)
  final int newQuantity;
  
  /// Ghi chú bổ sung khi thay đổi số lượng (tùy chọn)
  final String? notes;

  const UpdateOrderItemQuantityDto({
    required this.newQuantity,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'newQuantity': newQuantity,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }

  /// Validate business rules
  List<String> validate() {
    final errors = <String>[];
    
    if (newQuantity <= 0) {
      errors.add('Số lượng phải lớn hơn 0');
    }
    
    return errors;
  }

  bool get isValid => validate().isEmpty;
}