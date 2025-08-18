import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mobile/shared/utils/vietnamese_formatter.dart';

void main() {
  group('VietnameseFormatter', () {
    group('Date Formatting', () {
      test('formatDate should format date as dd/MM/yyyy', () {
        final date = DateTime(2025, 8, 18, 14, 30, 45);
        expect(VietnameseFormatter.formatDate(date), '18/08/2025');
      });

      test('formatTime should format time as HH:mm', () {
        final dateTime = DateTime(2025, 8, 18, 14, 30, 45);
        expect(VietnameseFormatter.formatTime(dateTime), '14:30');
      });

      test('formatDateTime should format as dd/MM/yyyy HH:mm:ss', () {
        final dateTime = DateTime(2025, 8, 18, 14, 30, 45);
        expect(VietnameseFormatter.formatDateTime(dateTime), '18/08/2025 14:30:45');
      });

      test('formatShortDateTime should format as dd/MM/yyyy HH:mm', () {
        final dateTime = DateTime(2025, 8, 18, 14, 30, 45);
        expect(VietnameseFormatter.formatShortDateTime(dateTime), '18/08/2025 14:30');
      });

      test('parseDate should parse Vietnamese date format', () {
        final result = VietnameseFormatter.parseDate('18/08/2025');
        expect(result, isNotNull);
        expect(result!.day, 18);
        expect(result.month, 8);
        expect(result.year, 2025);
      });

      test('parseDate should return null for invalid format', () {
        final result = VietnameseFormatter.parseDate('2025-08-18');
        expect(result, isNull);
      });

      test('parseDateTime should parse Vietnamese datetime format', () {
        final result = VietnameseFormatter.parseDateTime('18/08/2025 14:30:45');
        expect(result, isNotNull);
        expect(result!.day, 18);
        expect(result.month, 8);
        expect(result.year, 2025);
        expect(result.hour, 14);
        expect(result.minute, 30);
        expect(result.second, 45);
      });
    });

    group('Currency Formatting', () {
      test('formatCurrency should format Vietnamese currency correctly', () {
        expect(VietnameseFormatter.formatCurrency(0), '0đ');
        expect(VietnameseFormatter.formatCurrency(1000), '1.000đ');
        expect(VietnameseFormatter.formatCurrency(50000), '50.000đ');
        expect(VietnameseFormatter.formatCurrency(1234567), '1.234.567đ');
      });

      test('formatCurrencyWithDecimals should handle decimal places', () {
        expect(VietnameseFormatter.formatCurrencyWithDecimals(1234567.0), '1.234.567đ');
        expect(VietnameseFormatter.formatCurrencyWithDecimals(1234567.50), '1.234.567,50đ');
        expect(VietnameseFormatter.formatCurrencyWithDecimals(50000.99), '50.000,99đ');
      });

      test('formatNumber should format with thousand separators', () {
        expect(VietnameseFormatter.formatNumber(1000), '1.000');
        expect(VietnameseFormatter.formatNumber(1234567), '1.234.567');
        expect(VietnameseFormatter.formatNumber(999), '999');
      });

      test('parseCurrency should parse Vietnamese currency strings', () {
        expect(VietnameseFormatter.parseCurrency('1.234.567đ'), 1234567.0);
        expect(VietnameseFormatter.parseCurrency('50.000đ'), 50000.0);
        expect(VietnameseFormatter.parseCurrency('1.234.567,50đ'), 1234567.50);
        expect(VietnameseFormatter.parseCurrency('invalid'), isNull);
      });
    });

    group('Relative Time Formatting', () {
      test('formatRelativeTime should format recent times correctly', () {
        final now = DateTime.now();
        
        // Just now
        final justNow = now.subtract(const Duration(seconds: 30));
        expect(VietnameseFormatter.formatRelativeTime(justNow), 'Vừa xong');
        
        // Minutes ago
        final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
        expect(VietnameseFormatter.formatRelativeTime(fiveMinutesAgo), '5 phút trước');
        
        // Hours ago
        final twoHoursAgo = now.subtract(const Duration(hours: 2));
        expect(VietnameseFormatter.formatRelativeTime(twoHoursAgo), '2 giờ trước');
        
        // Days ago
        final threeDaysAgo = now.subtract(const Duration(days: 3));
        expect(VietnameseFormatter.formatRelativeTime(threeDaysAgo), '3 ngày trước');
      });
    });

    group('Day of Week Formatting', () {
      test('formatDayOfWeek should return Vietnamese day names', () {
        // Sunday = 0, Monday = 1, etc.
        final sunday = DateTime(2025, 8, 17); // Assuming this is a Sunday
        final monday = DateTime(2025, 8, 18);
        final tuesday = DateTime(2025, 8, 19);
        
        expect(VietnameseFormatter.formatDayOfWeek(sunday), contains('Chủ Nhật'));
        expect(VietnameseFormatter.formatDayOfWeek(monday), contains('Thứ'));
        expect(VietnameseFormatter.formatDayOfWeek(tuesday), contains('Thứ'));
      });
    });

    group('Phone Number Validation and Formatting', () {
      test('isValidVietnamesePhone should validate correct formats', () {
        expect(VietnameseFormatter.isValidVietnamesePhone('0901234567'), isTrue);
        expect(VietnameseFormatter.isValidVietnamesePhone('+84901234567'), isTrue);
        expect(VietnameseFormatter.isValidVietnamesePhone('84901234567'), isTrue);
        expect(VietnameseFormatter.isValidVietnamesePhone('090 123 4567'), isTrue);
        
        // Invalid formats
        expect(VietnameseFormatter.isValidVietnamesePhone('123456789'), isFalse);
        expect(VietnameseFormatter.isValidVietnamesePhone('0123456789'), isFalse);
        expect(VietnameseFormatter.isValidVietnamesePhone('invalid'), isFalse);
      });

      test('formatPhoneNumber should format Vietnamese phone numbers', () {
        expect(VietnameseFormatter.formatPhoneNumber('0901234567'), '090 123 4567');
        expect(VietnameseFormatter.formatPhoneNumber('84901234567'), '+84 090 123 4567');
        expect(VietnameseFormatter.formatPhoneNumber('invalid'), 'invalid');
      });
    });

    group('Date Helpers', () {
      test('isToday should identify today correctly', () {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day, 15, 30);
        final yesterday = now.subtract(const Duration(days: 1));
        
        expect(VietnameseFormatter.isToday(today), isTrue);
        expect(VietnameseFormatter.isToday(yesterday), isFalse);
      });

      test('isTomorrow should identify tomorrow correctly', () {
        final now = DateTime.now();
        final tomorrow = now.add(const Duration(days: 1));
        final today = DateTime(now.year, now.month, now.day);
        
        expect(VietnameseFormatter.isTomorrow(tomorrow), isTrue);
        expect(VietnameseFormatter.isTomorrow(today), isFalse);
      });

      test('isYesterday should identify yesterday correctly', () {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final today = DateTime(now.year, now.month, now.day);
        
        expect(VietnameseFormatter.isYesterday(yesterday), isTrue);
        expect(VietnameseFormatter.isYesterday(today), isFalse);
      });
    });

    group('Smart Date Formatting', () {
      test('formatSmartDate should use Vietnamese relative terms', () {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        final yesterday = today.subtract(const Duration(days: 1));
        final nextWeek = today.add(const Duration(days: 7));
        
        expect(VietnameseFormatter.formatSmartDate(today), 'Hôm nay');
        expect(VietnameseFormatter.formatSmartDate(tomorrow), 'Ngày mai');
        expect(VietnameseFormatter.formatSmartDate(yesterday), 'Hôm qua');
        expect(VietnameseFormatter.formatSmartDate(nextWeek), contains('/'));
      });

      test('formatSmartDateTime should combine smart date with time', () {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day, 14, 30);
        final tomorrow = today.add(const Duration(days: 1));
        
        expect(VietnameseFormatter.formatSmartDateTime(today), 'Hôm nay 14:30');
        expect(VietnameseFormatter.formatSmartDateTime(tomorrow), 'Ngày mai 14:30');
      });
    });

    group('Time Range Formatting', () {
      test('formatTimeRange should format time ranges correctly', () {
        final startTime = DateTime(2025, 8, 18, 14, 30);
        final endTime = DateTime(2025, 8, 18, 16, 0);
        
        expect(VietnameseFormatter.formatTimeRange(startTime, endTime), '14:30 - 16:00');
      });
    });

    group('Full Date Formatting', () {
      test('formatFullDate should include day of week', () {
        final date = DateTime(2025, 8, 18);
        final result = VietnameseFormatter.formatFullDate(date);
        
        expect(result, contains('18/08/2025'));
        expect(result, contains(','));
      });
    });
  });
}