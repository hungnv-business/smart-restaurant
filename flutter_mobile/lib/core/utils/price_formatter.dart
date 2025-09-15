import 'package:intl/intl.dart';

/// Utility class để format giá tiền theo định dạng Việt Nam
class PriceFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  /// Format số tiền thành chuỗi với định dạng Việt Nam
  /// Ví dụ: 150000 -> "150.000 đ"
  static String format(int amount) {
    return _formatter.format(amount);
  }

  /// Format số tiền thành chuỗi với định dạng Việt Nam (double)
  /// Ví dụ: 150000.0 -> "150.000 đ"
  static String formatDouble(double amount) {
    return _formatter.format(amount.round());
  }

  /// Format số tiền thành chuỗi không có ký hiệu đơn vị
  /// Ví dụ: 150000 -> "150.000"
  static String formatWithoutSymbol(int amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(amount);
  }

  /// Parse chuỗi tiền về số nguyên
  /// Ví dụ: "150.000 đ" -> 150000
  static int? parseFromString(String priceString) {
    try {
      // Loại bỏ ký hiệu và dấu phân cách
      final cleanString = priceString
          .replaceAll('đ', '')
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .trim();
      
      return int.tryParse(cleanString);
    } catch (e) {
      return null;
    }
  }

  /// Kiểm tra xem chuỗi có phải định dạng tiền hợp lệ không
  static bool isValidPriceString(String priceString) {
    return parseFromString(priceString) != null;
  }
}