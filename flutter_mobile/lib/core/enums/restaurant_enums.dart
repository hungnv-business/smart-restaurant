/// Trạng thái bàn (sync với backend TableStatus enum)
enum TableStatus {
  available,    // Bàn có sẵn, sẵn sàng phục vụ khách hàng (0)
  occupied,     // Bàn đang được sử dụng bởi khách hàng (1)  
  reserved,     // Bàn đã được đặt trước (2)
}

/// Trạng thái đơn hàng (sync với backend OrderStatus enum)
enum OrderStatus {
  serving,      // Đang phục vụ - Đơn hàng đang được phục vụ (0)
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
      case OrderStatus.serving:
        return 'Đang phục vụ';
      case OrderStatus.paid:
        return 'Đã thanh toán';
    }
  }

  int get colorValue {
    switch (this) {
      case OrderStatus.serving:
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

/// Trạng thái kết nối
enum ConnectionStatus {
  disconnected,  // Ngắt kết nối
  connecting,    // Đang kết nối
  connected,     // Đã kết nối  
  reconnecting,  // Đang kết nối lại
  error,         // Lỗi kết nối
}

/// Extension để hiển thị trạng thái kết nối bằng tiếng Việt
extension ConnectionStatusExtension on ConnectionStatus {
  String get displayName {
    switch (this) {
      case ConnectionStatus.disconnected:
        return 'Ngắt kết nối';
      case ConnectionStatus.connecting:
        return 'Đang kết nối';
      case ConnectionStatus.connected:
        return 'Đã kết nối';
      case ConnectionStatus.reconnecting:
        return 'Đang kết nối lại';
      case ConnectionStatus.error:
        return 'Lỗi kết nối';
    }
  }

  int get colorValue {
    switch (this) {
      case ConnectionStatus.disconnected:
        return 0xFFF44336; // Red
      case ConnectionStatus.connecting:
        return 0xFFFF9800; // Orange
      case ConnectionStatus.connected:
        return 0xFF4CAF50; // Green
      case ConnectionStatus.reconnecting:
        return 0xFFFF9800; // Orange
      case ConnectionStatus.error:
        return 0xFFF44336; // Red
    }
  }

  bool get isConnected => this == ConnectionStatus.connected;
}

/// Trạng thái sẵn có của món ăn
enum AvailabilityStatus {
  available,    // Có sẵn
  unavailable,  // Hết hàng
}

/// Extension để hiển thị trạng thái sẵn có bằng tiếng Việt
extension AvailabilityStatusExtension on AvailabilityStatus {
  String get displayName {
    switch (this) {
      case AvailabilityStatus.available:
        return 'Có sẵn';
      case AvailabilityStatus.unavailable:
        return 'Hết hàng';
    }
  }

  int get colorValue {
    switch (this) {
      case AvailabilityStatus.available:
        return 0xFF4CAF50; // Green
      case AvailabilityStatus.unavailable:
        return 0xFFF44336; // Red
    }
  }
}

/// Trạng thái đơn takeaway
enum TakeawayStatus {
  preparing,    // Đang chuẩn bị
  ready,        // Sẵn sàng
  delivered,    // Đã giao
}

/// Extension để hiển thị trạng thái takeaway bằng tiếng Việt
extension TakeawayStatusExtension on TakeawayStatus {
  String get displayName {
    switch (this) {
      case TakeawayStatus.preparing:
        return 'Đang chuẩn bị';
      case TakeawayStatus.ready:
        return 'Sẵn sàng';
      case TakeawayStatus.delivered:
        return 'Đã giao';
    }
  }

  int get colorValue {
    switch (this) {
      case TakeawayStatus.preparing:
        return 0xFFFF9800; // Orange
      case TakeawayStatus.ready:
        return 0xFF4CAF50; // Green
      case TakeawayStatus.delivered:
        return 0xFF2196F3; // Blue
    }
  }
}

/// Helper class để parse enum từ JSON
class EnumParser {
  /// Parse TableStatus từ dynamic value (int index hoặc string)
  static TableStatus parseTableStatus(dynamic value) {
    if (value == null) return TableStatus.available;
    
    if (value is int) {
      if (value >= 0 && value < TableStatus.values.length) {
        return TableStatus.values[value];
      }
    }
    
    if (value is String) {
      // Parse từ string nếu backend gửi string thay vì index
      final intValue = int.tryParse(value);
      if (intValue != null && intValue >= 0 && intValue < TableStatus.values.length) {
        return TableStatus.values[intValue];
      }
    }
    
    return TableStatus.available; // Default fallback
  }
  
  /// Parse OrderItemStatus từ dynamic value (int index hoặc string)
  static OrderItemStatus parseOrderItemStatus(dynamic value) {
    if (value == null) return OrderItemStatus.pending;
    
    if (value is int) {
      if (value >= 0 && value < OrderItemStatus.values.length) {
        return OrderItemStatus.values[value];
      }
    }
    
    if (value is String) {
      // Parse từ string nếu backend gửi string thay vì index
      final intValue = int.tryParse(value);
      if (intValue != null && intValue >= 0 && intValue < OrderItemStatus.values.length) {
        return OrderItemStatus.values[intValue];
      }
    }
    
    return OrderItemStatus.pending; // Default fallback
  }
  
  /// Parse OrderStatus từ dynamic value
  static OrderStatus parseOrderStatus(dynamic value) {
    if (value == null) return OrderStatus.serving;
    
    if (value is int) {
      if (value >= 0 && value < OrderStatus.values.length) {
        return OrderStatus.values[value];
      }
    }
    
    if (value is String) {
      final intValue = int.tryParse(value);
      if (intValue != null && intValue >= 0 && intValue < OrderStatus.values.length) {
        return OrderStatus.values[intValue];
      }
    }
    
    return OrderStatus.serving; // Default fallback
  }

  /// Parse OrderType từ dynamic value (int index hoặc string)
  static OrderType parseOrderType(dynamic value) {
    if (value == null) return OrderType.dineIn;
    
    if (value is int) {
      if (value >= 0 && value < OrderType.values.length) {
        return OrderType.values[value];
      }
    }
    
    if (value is String) {
      final intValue = int.tryParse(value);
      if (intValue != null && intValue >= 0 && intValue < OrderType.values.length) {
        return OrderType.values[intValue];
      }
    }
    
    return OrderType.dineIn; // Default fallback
  }
}

