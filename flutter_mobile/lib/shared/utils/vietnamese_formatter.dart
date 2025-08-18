import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Vietnamese formatting utilities for dates, times, and currency
/// All formatting follows Vietnamese conventions as specified in the requirements
class VietnameseFormatter {
  // Private constructors to prevent instantiation
  VietnameseFormatter._();

  static bool _initialized = false;
  
  // Initialize date formatting if needed
  static Future<void> _ensureInitialized() async {
    if (!_initialized) {
      try {
        await initializeDateFormatting('vi_VN');
        _initialized = true;
      } catch (e) {
        // Fallback to default locale if Vietnamese locale is not available
        await initializeDateFormatting();
        _initialized = true;
      }
    }
  }

  // Date formatters following Vietnamese convention (dd/MM/yyyy)
  static DateFormat get _dateFormatter {
    return DateFormat('dd/MM/yyyy');
  }
  
  static DateFormat get _timeFormatter {
    return DateFormat('HH:mm');
  }
  
  static DateFormat get _dateTimeFormatter {
    return DateFormat('dd/MM/yyyy HH:mm:ss');
  }
  
  static DateFormat get _shortDateTimeFormatter {
    return DateFormat('dd/MM/yyyy HH:mm');
  }

  // Number formatters for Vietnamese currency
  static NumberFormat get _currencyFormatter {
    return NumberFormat('#,###');
  }
  
  static NumberFormat get _numberFormatter {
    return NumberFormat('#,###');
  }

  /// Format date as dd/MM/yyyy (e.g., 18/08/2025)
  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  /// Format time as HH:mm (e.g., 14:30)
  static String formatTime(DateTime dateTime) {
    return _timeFormatter.format(dateTime);
  }

  /// Format date and time as dd/MM/yyyy HH:mm:ss (e.g., 18/08/2025 14:30:00)
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormatter.format(dateTime);
  }

  /// Format date and time as dd/MM/yyyy HH:mm (e.g., 18/08/2025 14:30)
  static String formatShortDateTime(DateTime dateTime) {
    return _shortDateTimeFormatter.format(dateTime);
  }

  /// Parse Vietnamese date format (dd/MM/yyyy) to DateTime
  static DateTime? parseDate(String dateString) {
    try {
      return _dateFormatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parse Vietnamese datetime format (dd/MM/yyyy HH:mm:ss) to DateTime
  static DateTime? parseDateTime(String dateTimeString) {
    try {
      return _dateTimeFormatter.parse(dateTimeString);
    } catch (e) {
      try {
        return _shortDateTimeFormatter.parse(dateTimeString);
      } catch (e) {
        return null;
      }
    }
  }

  /// Format currency amount in Vietnamese Dong
  /// Examples: 
  /// - 1234567 -> "1.234.567đ"
  /// - 50000 -> "50.000đ"
  /// - 0 -> "0đ"
  static String formatCurrency(num amount) {
    if (amount == 0) {
      return '0đ';
    }
    return '${_currencyFormatter.format(amount)}đ';
  }

  /// Format currency with decimal places if needed
  /// Examples:
  /// - 1234567.50 -> "1.234.567,50đ"
  /// - 50000.00 -> "50.000đ"
  static String formatCurrencyWithDecimals(double amount) {
    if (amount == amount.roundToDouble()) {
      // No decimal places needed
      return formatCurrency(amount.round());
    }
    
    final wholePart = amount.floor();
    final decimalPart = ((amount - wholePart) * 100).round();
    
    return '${_currencyFormatter.format(wholePart)},${decimalPart.toString().padLeft(2, '0')}đ';
  }

  /// Format number with thousand separators (e.g., 1.234.567)
  static String formatNumber(num number) {
    return _numberFormatter.format(number);
  }

  /// Parse Vietnamese currency string to number
  /// Examples:
  /// - "1.234.567đ" -> 1234567
  /// - "50.000đ" -> 50000
  static double? parseCurrency(String currencyString) {
    try {
      // Remove currency symbol and spaces
      String cleanString = currencyString
          .replaceAll('đ', '')
          .replaceAll(' ', '')
          .trim();
      
      // Handle decimal separator
      if (cleanString.contains(',')) {
        final parts = cleanString.split(',');
        if (parts.length == 2) {
          final wholePart = parts[0].replaceAll('.', '');
          final decimalPart = parts[1];
          return double.parse('$wholePart.$decimalPart');
        }
      }
      
      // Remove thousand separators and parse
      cleanString = cleanString.replaceAll('.', '');
      return double.parse(cleanString);
    } catch (e) {
      return null;
    }
  }

  /// Format relative time in Vietnamese
  /// Examples:
  /// - "Vừa xong" (just now)
  /// - "5 phút trước" (5 minutes ago)
  /// - "2 giờ trước" (2 hours ago)
  /// - "1 ngày trước" (1 day ago)
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes phút trước';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours giờ trước';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ngày trước';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks tuần trước';
    } else {
      return formatDate(dateTime);
    }
  }

  /// Format Vietnamese day of week
  /// Examples: "Thứ Hai", "Thứ Ba", "Chủ Nhật"
  static String formatDayOfWeek(DateTime dateTime) {
    const days = [
      'Chủ Nhật',   // Sunday
      'Thứ Hai',    // Monday
      'Thứ Ba',     // Tuesday
      'Thứ Tư',     // Wednesday
      'Thứ Năm',    // Thursday
      'Thứ Sáu',    // Friday
      'Thứ Bảy',    // Saturday
    ];
    
    return days[dateTime.weekday % 7];
  }

  /// Format Vietnamese month name
  /// Examples: "Tháng 1", "Tháng 12"
  static String formatMonth(DateTime dateTime) {
    return 'Tháng ${dateTime.month}';
  }

  /// Format full Vietnamese date with day of week
  /// Example: "Thứ Hai, 18/08/2025"
  static String formatFullDate(DateTime dateTime) {
    return '${formatDayOfWeek(dateTime)}, ${formatDate(dateTime)}';
  }

  /// Format time range in Vietnamese
  /// Example: "14:30 - 16:00"
  static String formatTimeRange(DateTime startTime, DateTime endTime) {
    return '${formatTime(startTime)} - ${formatTime(endTime)}';
  }

  /// Check if a date is today
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
           dateTime.month == now.month &&
           dateTime.day == now.day;
  }

  /// Check if a date is tomorrow
  static bool isTomorrow(DateTime dateTime) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dateTime.year == tomorrow.year &&
           dateTime.month == tomorrow.month &&
           dateTime.day == tomorrow.day;
  }

  /// Check if a date is yesterday
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
           dateTime.month == yesterday.month &&
           dateTime.day == yesterday.day;
  }

  /// Format smart date (shows "Hôm nay", "Ngày mai", etc. when appropriate)
  static String formatSmartDate(DateTime dateTime) {
    if (isToday(dateTime)) {
      return 'Hôm nay';
    } else if (isTomorrow(dateTime)) {
      return 'Ngày mai';
    } else if (isYesterday(dateTime)) {
      return 'Hôm qua';
    } else {
      return formatDate(dateTime);
    }
  }

  /// Format smart datetime (combines smart date with time)
  /// Example: "Hôm nay 14:30", "18/08/2025 14:30"
  static String formatSmartDateTime(DateTime dateTime) {
    if (isToday(dateTime)) {
      return 'Hôm nay ${formatTime(dateTime)}';
    } else if (isTomorrow(dateTime)) {
      return 'Ngày mai ${formatTime(dateTime)}';
    } else if (isYesterday(dateTime)) {
      return 'Hôm qua ${formatTime(dateTime)}';
    } else {
      return formatShortDateTime(dateTime);
    }
  }

  /// Validate Vietnamese phone number format
  /// Examples: "0901234567", "+84901234567", "84901234567"
  static bool isValidVietnamesePhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Check various Vietnamese phone formats
    final regexPatterns = [
      r'^0[3-9]\d{8}$',        // 0x xxxxxxxx (10 digits, starting with 0)
      r'^84[3-9]\d{8}$',       // 84x xxxxxxxx (11 digits, starting with 84)
      r'^\+84[3-9]\d{8}$',     // +84x xxxxxxxx (12 digits, starting with +84)
    ];
    
    for (final pattern in regexPatterns) {
      if (RegExp(pattern).hasMatch(cleanPhone)) {
        return true;
      }
    }
    
    return false;
  }

  /// Format Vietnamese phone number for display
  /// Example: "0901234567" -> "090 123 4567"
  static String formatPhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    if (cleanPhone.length == 10 && cleanPhone.startsWith('0')) {
      return '${cleanPhone.substring(0, 3)} ${cleanPhone.substring(3, 6)} ${cleanPhone.substring(6)}';
    } else if (cleanPhone.length == 11 && cleanPhone.startsWith('84')) {
      return '+84 ${cleanPhone.substring(2, 5)} ${cleanPhone.substring(5, 8)} ${cleanPhone.substring(8)}';
    }
    
    return phone; // Return original if format not recognized
  }
}