/// Utilities cho chuyển đổi số thành chữ tiếng Việt
class NumberToWordsUtils {
  /// Chuyển đổi số thành chữ tiếng Việt
  static String numberToWords(int number) {
    String result = _convertToWords(number);
    
    // Viết hoa chữ cái đầu
    if (result.isNotEmpty) {
      result = result[0].toUpperCase() + result.substring(1);
    }
    
    return result;
  }
  
  /// Helper function để chuyển đổi số thành chữ (chưa viết hoa)
  static String _convertToWords(int number) {
    if (number == 0) return 'không đồng';

    const units = [
      '',
      'một',
      'hai',
      'ba',
      'bốn',
      'năm',
      'sáu',
      'bảy',
      'tám',
      'chín',
    ];
    const tens = [
      '',
      '',
      'hai mươi',
      'ba mươi',
      'bốn mươi',
      'năm mươi',
      'sáu mươi',
      'bảy mươi',
      'tám mươi',
      'chín mươi',
    ];
    const hundreds = [
      '',
      'một trăm',
      'hai trăm',
      'ba trăm',
      'bốn trăm',
      'năm trăm',
      'sáu trăm',
      'bảy trăm',
      'tám trăm',
      'chín trăm',
    ];

    if (number < 10) {
      return '$units[number] đồng';
    }

    if (number < 100) {
      final ten = number ~/ 10;
      final unit = number % 10;
      if (ten == 1) {
        return unit == 0 ? 'mười đồng' : 'mười ${units[unit]} đồng';
      }
      if (unit == 1 && ten > 1) {
        return '${tens[ten]} một đồng';
      }
      if (unit == 5 && ten > 1) {
        return '${tens[ten]} lăm đồng';
      }
      return unit == 0
          ? '${tens[ten]} đồng'
          : '${tens[ten]} ${units[unit]} đồng';
    }

    if (number < 1000) {
      final hundred = number ~/ 100;
      final remainder = number % 100;
      String result = hundreds[hundred];
      if (remainder > 0) {
        if (remainder < 10) {
          result += ' lẻ ${units[remainder]}';
        } else {
          result += ' ${_convertToWords(remainder).replaceAll(' đồng', '')}';
        }
      }
      return '$result đồng';
    }

    if (number < 1000000) {
      final thousand = number ~/ 1000;
      final remainder = number % 1000;
      String result =
          '${_convertToWords(thousand).replaceAll(' đồng', '')} nghìn';
      if (remainder > 0) {
        if (remainder < 100) {
          result += ' lẻ ${_convertToWords(remainder).replaceAll(' đồng', '')}';
        } else {
          result += ' ${_convertToWords(remainder).replaceAll(' đồng', '')}';
        }
      }
      return '$result đồng';
    }

    // Triệu trở lên - đơn giản hóa
    if (number < 1000000000) {
      final million = number ~/ 1000000;
      final remainder = number % 1000000;
      String result =
          '${_convertToWords(million).replaceAll(' đồng', '')} triệu';
      if (remainder > 0) {
        result += ' ${_convertToWords(remainder).replaceAll(' đồng', '')}';
      }
      return '$result đồng';
    }

    return 'số quá lớn đồng';
  }

  /// Format số tiền theo kiểu Việt Nam (dấu chấm phân cách hàng nghìn)
  static String formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  /// Format số tiền kèm đơn vị VND
  static String formatCurrencyWithUnit(int amount) {
    return '$formatCurrency(amount) VND';
  }

  /// Chuyển số thành chữ không có đơn vị tiền tệ
  static String numberToWordsWithoutCurrency(int number) {
    return _convertToWords(number).replaceAll(' đồng', '');
  }
}