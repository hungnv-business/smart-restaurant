/// Models cho Order Requests - tương ứng với backend DTOs
/// Dùng để gửi request tạo đơn hàng lên API

import '../enums/restaurant_enums.dart';

/// DTO cho việc tạo OrderItem trong đơn hàng
/// Tương ứng với CreateOrderItemDto.cs
class CreateOrderItemDto {
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

  const CreateOrderItemDto({
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
  factory CreateOrderItemDto.fromMenuItem({
    required String menuItemId,
    required String menuItemName, 
    required int quantity,
    required int unitPrice,
    String? notes,
  }) {
    return CreateOrderItemDto(
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
class CreateOrderDto {
  /// ID của bàn (bắt buộc cho DineIn, nullable cho Takeaway/Delivery)
  final String? tableId;
  
  /// Loại đơn hàng - mặc định là ăn tại chỗ
  final OrderType orderType;
  
  /// Ghi chú chung của khách hàng hoặc nhân viên
  final String? notes;

  /// Tên khách hàng (bắt buộc cho Takeaway/Delivery)
  final String? customerName;

  /// Số điện thoại khách hàng (bắt buộc cho Takeaway/Delivery)
  final String? customerPhone;
  
  /// Danh sách món được đặt (tối thiểu 1 món)
  final List<CreateOrderItemDto> orderItems;

  const CreateOrderDto({
    this.tableId,
    this.orderType = OrderType.dineIn,
    this.notes,
    this.customerName,
    this.customerPhone,
    required this.orderItems,
  });

  /// Convert sang JSON để gửi lên API
  Map<String, dynamic> toJson() {
    return {
      if (tableId != null && tableId!.isNotEmpty) 'tableId': tableId,
      'orderType': orderType.index,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (customerName != null && customerName!.isNotEmpty) 'customerName': customerName,
      if (customerPhone != null && customerPhone!.isNotEmpty) 'customerPhone': customerPhone,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
    };
  }

  /// Validate business rules (tương tự backend)
  List<String> validate() {
    final errors = <String>[];
    
    // Validate DineIn requires table
    if (orderType == OrderType.dineIn && (tableId == null || tableId!.isEmpty)) {
      errors.add('Đơn hàng ăn tại chỗ phải có bàn');
    }

    // Validate Takeaway/Delivery requires customer info
    if (orderType == OrderType.takeaway || orderType == OrderType.delivery) {
      if (customerName == null || customerName!.trim().isEmpty) {
        errors.add('Đơn hàng mang về/giao hàng phải có tên khách hàng');
      }
      if (customerPhone == null || customerPhone!.trim().isEmpty) {
        errors.add('Đơn hàng mang về/giao hàng phải có số điện thoại khách hàng');
      }
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

/// DTO cho việc thêm món vào order hiện có
/// Tương ứng với AddItemsToOrderDto.cs
class AddItemsToOrderDto {
  /// Danh sách món muốn thêm vào order
  final List<CreateOrderItemDto> items;
  
  /// Ghi chú chung cho lần gọi thêm này
  final String? additionalNotes;

  const AddItemsToOrderDto({
    required this.items,
    this.additionalNotes,
  });

  /// Convert sang JSON để gửi lên API
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      if (additionalNotes != null && additionalNotes!.isNotEmpty) 
        'additionalNotes': additionalNotes,
    };
  }

  /// Validate business rules
  List<String> validate() {
    final errors = <String>[];
    
    if (items.isEmpty) {
      errors.add('Phải có ít nhất 1 món để thêm vào order');
    }
    
    // Validate từng món
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      
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

  /// Check if request is valid
  bool get isValid => validate().isEmpty;
}

/// Response từ API sau khi tạo đơn hàng thành công
class CreateOrderResponseDto {
  final String orderId;
  final String orderNumber;
  final DateTime createdAt;
  final int totalAmount;

  const CreateOrderResponseDto({
    required this.orderId,
    required this.orderNumber,
    required this.createdAt,
    required this.totalAmount,
  });

  factory CreateOrderResponseDto.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponseDto(
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

// Type aliases for backward compatibility
typedef OrderItemRequest = CreateOrderItemDto;
typedef CreateOrderItemRequest = CreateOrderItemDto;
typedef OrderRequestType = OrderType;