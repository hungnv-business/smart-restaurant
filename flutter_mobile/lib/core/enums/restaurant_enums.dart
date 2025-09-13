/// Trạng thái bàn (sync với backend TableStatus enum)
enum TableStatus {
  available,    // Bàn có sẵn, sẵn sàng phục vụ khách hàng (0)
  occupied,     // Bàn đang được sử dụng bởi khách hàng (1)  
  reserved,     // Bàn đã được đặt trước (2)
}

/// Trạng thái đơn hàng (sync với backend OrderStatus enum)
enum OrderStatus {
  active,       // Đang hoạt động - Đơn hàng đang được phục vụ (0)
  paid,         // Đã thanh toán - Khách hàng đã ăn xong và thanh toán (1)
}

/// Trạng thái từng món trong đơn hàng (sync với backend OrderItemStatus enum)
enum OrderItemStatus {
  pending,      // Chờ chuẩn bị (Nhân viên) (0)
  preparing,    // Đang chuẩn bị (Bếp) (1)
  ready,        // Đã hoàn thành (Bếp) (2)
  served,       // Đã phục vụ (Nhân viên) (3)
  canceled,     // Đã Huỷ (Nhân viên) (4)
}

/// Loại đơn hàng (sync với backend OrderType enum)
enum OrderType {
  dineIn,       // Ăn tại chỗ - Khách hàng ăn tại nhà hàng (0)
  takeaway,     // Mang về - Khách hàng đặt món mang về (1)
  delivery,     // Giao hàng - Nhà hàng giao món đến địa chỉ khách hàng (2)
}

/// Phương thức thanh toán (sync với backend PaymentMethod enum)
enum PaymentMethod {
  transfer,     // Chuyển khoản QR (0)
  cash,         // Tiền mặt (1)
  debt,         // Nợ (2)
}

/// Extension để hiển thị trạng thái bàn bằng tiếng Việt
extension TableStatusExtension on TableStatus {
  String get displayName {
    switch (this) {
      case TableStatus.available:
        return 'Có sẵn';
      case TableStatus.occupied:
        return 'Đang sử dụng';
      case TableStatus.reserved:
        return 'Đã đặt trước';
    }
  }

  /// Màu sắc tương ứng với trạng thái
  int get colorValue {
    switch (this) {
      case TableStatus.available:
        return 0xFF4CAF50; // Green
      case TableStatus.occupied:
        return 0xFFF44336; // Red
      case TableStatus.reserved:
        return 0xFFFF9800; // Orange
    }
  }
}

/// Extension để hiển thị trạng thái đơn hàng bằng tiếng Việt
extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.active:
        return 'Đang hoạt động';
      case OrderStatus.paid:
        return 'Đã thanh toán';
    }
  }

  int get colorValue {
    switch (this) {
      case OrderStatus.active:
        return 0xFF2196F3; // Blue
      case OrderStatus.paid:
        return 0xFF4CAF50; // Green
    }
  }
}

/// Extension để hiển thị trạng thái món ăn bằng tiếng Việt
extension OrderItemStatusExtension on OrderItemStatus {
  String get displayName {
    switch (this) {
      case OrderItemStatus.pending:
        return 'Chờ chuẩn bị';
      case OrderItemStatus.preparing:
        return 'Đang chuẩn bị';
      case OrderItemStatus.ready:
        return 'Đã hoàn thành';
      case OrderItemStatus.served:
        return 'Đã phục vụ';
      case OrderItemStatus.canceled:
        return 'Đã Huỷ';
    }
  }

  int get colorValue {
    switch (this) {
      case OrderItemStatus.pending:
        return 0xFF9E9E9E; // Grey
      case OrderItemStatus.preparing:
        return 0xFFFF9800; // Orange
      case OrderItemStatus.ready:
        return 0xFF4CAF50; // Green
      case OrderItemStatus.served:
        return 0xFF2196F3; // Blue
      case OrderItemStatus.canceled:
        return 0xFFF44336; // Red
    }
  }
}

/// Extension để hiển thị loại đơn hàng bằng tiếng Việt
extension OrderTypeExtension on OrderType {
  String get displayName {
    switch (this) {
      case OrderType.dineIn:
        return 'Ăn tại chỗ';
      case OrderType.takeaway:
        return 'Mang về';
      case OrderType.delivery:
        return 'Giao hàng';
    }
  }

  int get colorValue {
    switch (this) {
      case OrderType.dineIn:
        return 0xFF4CAF50; // Green
      case OrderType.takeaway:
        return 0xFFFF9800; // Orange
      case OrderType.delivery:
        return 0xFF2196F3; // Blue
    }
  }
}

/// Extension để hiển thị phương thức thanh toán bằng tiếng Việt
extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.transfer:
        return 'Chuyển khoản QR';
      case PaymentMethod.cash:
        return 'Tiền mặt';
      case PaymentMethod.debt:
        return 'Nợ';
    }
  }

  int get colorValue {
    switch (this) {
      case PaymentMethod.transfer:
        return 0xFFFF9800; // Orange
      case PaymentMethod.cash:
        return 0xFF4CAF50; // Green
      case PaymentMethod.debt:
        return 0xFFF44336; // Red
    }
  }
}