/// Models cho Order Requests - tương ứng với backend DTOs
/// Dùng để gửi request tạo đơn hàng lên API

/// Enum loại đơn hàng tương ứng với backend OrderType
enum OrderRequestType {
  /// Ăn tại chỗ - Khách hàng ăn tại nhà hàng
  dineIn(0, 'Ăn tại chỗ'),
  
  /// Mang về - Khách hàng đặt món mang về  
  takeaway(1, 'Mang về'),
  
  /// Giao hàng - Nhà hàng giao món đến địa chỉ khách hàng
  delivery(2, 'Giao hàng');

  const OrderRequestType(this.value, this.displayName);
  
  final int value;
  final String displayName;
  
  /// Convert từ int về OrderRequestType
  static OrderRequestType fromValue(int value) {
    return OrderRequestType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OrderRequestType.dineIn,
    );
  }
}

/// DTO cho việc tạo OrderItem trong đơn hàng
/// Tương ứng với CreateOrderItemDto.cs
class CreateOrderItemRequest {
  /// ID của món ăn từ menu
  final String menuItemId;
  
  /// Tên món ăn 
  final String menuItemName;
  
  /// Số lượng món được đặt
  final int quantity;
  
  /// Giá đơn vị 
  final int unitPrice;
  
  /// Ghi chú riêng cho món này (ví dụ: "Không cay", "Thêm hành")
  final String? notes;

  const CreateOrderItemRequest({
    required this.menuItemId,
    required this.menuItemName,
    required this.quantity,
    required this.unitPrice,
    this.notes,
  });

  /// Convert sang JSON để gửi lên API
  Map<String, dynamic> toJson() {
    return {
      'menuItemId': menuItemId,
      'menuItemName': menuItemName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }

  /// Tạo từ MenuItem và quantity
  factory CreateOrderItemRequest.fromMenuItem({
    required String menuItemId,
    required String menuItemName, 
    required int quantity,
    required int unitPrice,
    String? notes,
  }) {
    return CreateOrderItemRequest(
      menuItemId: menuItemId,
      menuItemName: menuItemName,
      quantity: quantity,
      unitPrice: unitPrice,
      notes: notes,
    );
  }
}

/// DTO cho việc tạo đơn hàng mới  
/// Tương ứng với CreateOrderDto.cs
class CreateOrderRequest {
  /// ID của bàn (bắt buộc cho DineIn, nullable cho Takeaway/Delivery)
  final String? tableId;
  
  /// Loại đơn hàng - mặc định là ăn tại chỗ
  final OrderRequestType orderType;
  
  /// Ghi chú chung của khách hàng hoặc nhân viên
  final String? notes;
  
  /// Danh sách món được đặt (tối thiểu 1 món)
  final List<CreateOrderItemRequest> orderItems;

  const CreateOrderRequest({
    this.tableId,
    this.orderType = OrderRequestType.dineIn,
    this.notes,
    required this.orderItems,
  });

  /// Convert sang JSON để gửi lên API
  Map<String, dynamic> toJson() {
    return {
      if (tableId != null && tableId!.isNotEmpty) 'tableId': tableId,
      'orderType': orderType.value,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
    };
  }

  /// Validate business rules (tương tự backend)
  List<String> validate() {
    final errors = <String>[];
    
    // Validate DineIn requires table
    if (orderType == OrderRequestType.dineIn && (tableId == null || tableId!.isEmpty)) {
      errors.add('Đơn hàng ăn tại chỗ phải có bàn');
    }
    
    // Validate OrderItems not empty  
    if (orderItems.isEmpty) {
      errors.add('Đơn hàng phải có ít nhất một món');
    }
    
    // Validate each OrderItem
    for (int i = 0; i < orderItems.length; i++) {
      final item = orderItems[i];
      
      if (item.quantity <= 0) {
        errors.add('Số lượng món thứ ${i + 1} phải lớn hơn 0');
      }
      
      if (item.unitPrice < 0) {
        errors.add('Giá món thứ ${i + 1} không được âm');
      }
      
      if (item.menuItemName.isEmpty) {
        errors.add('Tên món thứ ${i + 1} không được rỗng');
      }
    }
    
    return errors;
  }

  /// Check if order is valid
  bool get isValid => validate().isEmpty;

  /// Tính tổng tiền đơn hàng
  int get totalAmount {
    return orderItems.fold<int>(
      0, 
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );
  }
}

/// Response từ API sau khi tạo đơn hàng thành công
class CreateOrderResponse {
  final String orderId;
  final String orderNumber;
  final DateTime createdAt;
  final int totalAmount;

  const CreateOrderResponse({
    required this.orderId,
    required this.orderNumber,
    required this.createdAt,
    required this.totalAmount,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      orderId: json['id'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      totalAmount: json['totalAmount'] != null 
          ? (json['totalAmount'] as num).toInt()
          : 0,
    );
  }
}