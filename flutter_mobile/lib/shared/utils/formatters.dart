import 'package:intl/intl.dart';

class VietnameseFormatter {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm', 'vi_VN');
  static final _timeFormat = DateFormat('HH:mm', 'vi_VN');
  static final _dateFormat = DateFormat('dd/MM/yyyy', 'vi_VN');

  /// Định dạng tiền tệ Việt Nam
  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Định dạng ngày giờ đầy đủ
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// Định dạng chỉ thời gian
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// Định dạng chỉ ngày
  static String formatDate(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  /// Định dạng thời gian tương đối (vd: "5 phút trước")
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return formatDate(dateTime);
    }
  }

  /// Định dạng thời gian còn lại (vd: "còn 15 phút")
  static String formatTimeRemaining(DateTime targetTime) {
    final now = DateTime.now();
    final difference = targetTime.difference(now);

    if (difference.isNegative) {
      return 'Đã quá hạn';
    }

    if (difference.inMinutes < 60) {
      return 'còn ${difference.inMinutes} phút';
    } else if (difference.inHours < 24) {
      return 'còn ${difference.inHours} giờ ${difference.inMinutes % 60} phút';
    } else {
      return 'còn ${difference.inDays} ngày';
    }
  }

  /// Định dạng số điện thoại Việt Nam
  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length == 10) {
      return '${phoneNumber.substring(0, 3)} ${phoneNumber.substring(3, 6)} ${phoneNumber.substring(6)}';
    } else if (phoneNumber.length == 11 && phoneNumber.startsWith('0')) {
      return '${phoneNumber.substring(0, 4)} ${phoneNumber.substring(4, 7)} ${phoneNumber.substring(7)}';
    }
    return phoneNumber;
  }

  /// Định dạng số lượng với đơn vị
  static String formatQuantity(int quantity, String unit) {
    return '$quantity $unit';
  }

  /// Định dạng tỷ lệ phần trăm
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// Định dạng thứ tự trong ngày (vd: "Đơn hàng thứ 15 hôm nay")
  static String formatOrderSequence(int orderCount) {
    return 'Đơn hàng thứ $orderCount hôm nay';
  }

  /// Định dạng thời gian chuẩn bị ước tính
  static String formatPreparationTime(int minutes) {
    if (minutes < 60) {
      return '$minutes phút';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours giờ';
      } else {
        return '$hours giờ $remainingMinutes phút';
      }
    }
  }

  /// Chuyển đổi chữ số thành chữ tiếng Việt (cho hóa đơn)
  static String numberToVietnameseWords(int number) {
    if (number == 0) return 'không';
    
    final units = ['', 'một', 'hai', 'ba', 'bốn', 'năm', 'sáu', 'bảy', 'tám', 'chín'];
    final tens = ['', '', 'hai mươi', 'ba mươi', 'bốn mươi', 'năm mươi', 
                  'sáu mươi', 'bảy mươi', 'tám mươi', 'chín mươi'];
    
    if (number < 10) {
      return units[number];
    } else if (number < 20) {
      if (number == 10) return 'mười';
      return 'mười ${units[number - 10]}';
    } else if (number < 100) {
      final ten = number ~/ 10;
      final unit = number % 10;
      if (unit == 0) return tens[ten];
      return '${tens[ten]} ${units[unit]}';
    }
    
    // For larger numbers, keep it simple
    return number.toString();
  }
}