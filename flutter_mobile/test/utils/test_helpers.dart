import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Test utilities for SmartRestaurant Mobile App

class TestHelpers {
  static const testScreenSize = Size(768, 1024); // Tablet size for testing

  /// Create a test app wrapper with providers and screen util
  static Widget createTestApp({
    required Widget child,
    List<Override>? providerOverrides,
    NavigatorObserver? navigatorObserver,
  }) {
    return ProviderScope(
      overrides: providerOverrides ?? [],
      child: ScreenUtilInit(
        designSize: testScreenSize,
        minTextAdapt: true,
        builder: (context, widget) => MaterialApp(
          home: child,
          navigatorObservers: navigatorObserver != null ? [navigatorObserver] : [],
          locale: const Locale('vi', 'VN'),
          supportedLocales: const [
            Locale('vi', 'VN'),
            Locale('en', 'US'),
          ],
        ),
      ),
    );
  }

  /// Create a test widget with basic material app wrapper
  static Widget createTestWidget({
    required Widget child,
    List<Override>? providerOverrides,
  }) {
    return ProviderScope(
      overrides: providerOverrides ?? [],
      child: MaterialApp(
        home: Scaffold(body: child),
        locale: const Locale('vi', 'VN'),
      ),
    );
  }

  /// Pump a widget with test app wrapper
  static Future<void> pumpTestApp(
    WidgetTester tester, {
    required Widget child,
    List<Override>? providerOverrides,
    NavigatorObserver? navigatorObserver,
  }) async {
    await tester.pumpWidget(
      createTestApp(
        child: child,
        providerOverrides: providerOverrides,
        navigatorObserver: navigatorObserver,
      ),
    );
  }

  /// Common Vietnamese text constants for testing
  static const vietnameseTexts = {
    'appName': 'SmartRestaurant',
    'loading': 'Đang tải...',
    'login': 'Đăng nhập',
    'logout': 'Đăng xuất',
    'orders': 'Gọi món',
    'reservations': 'Đặt bàn',
    'takeaway': 'Mang về',
    'save': 'Lưu',
    'cancel': 'Hủy',
    'confirm': 'Xác nhận',
    'error': 'Lỗi',
    'success': 'Thành công',
  };

  /// Mock Vietnamese data for testing
  static const mockVietnameseData = {
    'customerNames': ['Nguyễn Văn An', 'Trần Thị Bình', 'Lê Minh Cường', 'Phạm Thị Dung'],
    'phoneNumbers': ['0901234567', '0902345678', '0903456789', '0904567890'],
    'dishNames': ['Phở Bò', 'Cơm Tấm', 'Bún Chả', 'Bánh Mì'],
    'currencies': ['50.000đ', '75.000đ', '125.000đ', '200.000đ'],
    'dates': ['18/08/2025', '19/08/2025', '20/08/2025', '21/08/2025'],
    'times': ['14:30', '15:00', '16:30', '17:45'],
  };

  /// Wait for animations to complete
  static Future<void> waitForAnimations(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  /// Find widget by Vietnamese text
  static Finder findByVietnameseText(String text) {
    return find.text(text);
  }

  /// Find widget by Vietnamese text containing
  static Finder findByVietnameseTextContaining(String text) {
    return find.textContaining(text);
  }

  /// Verify Vietnamese currency format
  static bool isValidVietnameseCurrency(String text) {
    // Check for Vietnamese currency format: "1.234.567đ"
    final regex = RegExp(r'^\d{1,3}(\.\d{3})*đ$');
    return regex.hasMatch(text);
  }

  /// Verify Vietnamese date format
  static bool isValidVietnameseDate(String text) {
    // Check for Vietnamese date format: "dd/MM/yyyy"
    final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    return regex.hasMatch(text);
  }

  /// Verify Vietnamese time format
  static bool isValidVietnameseTime(String text) {
    // Check for Vietnamese time format: "HH:mm"
    final regex = RegExp(r'^\d{2}:\d{2}$');
    return regex.hasMatch(text);
  }

  /// Verify Vietnamese phone format
  static bool isValidVietnamesePhone(String text) {
    // Check for Vietnamese phone format: "090 123 4567"
    final regex = RegExp(r'^0\d{2} \d{3} \d{4}$');
    return regex.hasMatch(text);
  }

  /// Enter text in a text field
  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump();
    await tester.enterText(finder, text);
    await tester.pump();
  }

  /// Tap and wait
  static Future<void> tapAndWait(
    WidgetTester tester,
    Finder finder, {
    Duration? delay,
  }) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump(delay ?? const Duration(milliseconds: 300));
  }

  /// Scroll to find a widget
  static Future<void> scrollToFind(
    WidgetTester tester,
    Finder scrollableFinder,
    Finder targetFinder, {
    double delta = -200.0,
  }) async {
    while (!any(targetFinder) && tester.binding.hasScheduledFrame) {
      await tester.drag(scrollableFinder, Offset(0, delta));
      await tester.pump();
    }
  }

  /// Check if finder exists
  static bool any(Finder finder) {
    try {
      finder.evaluate();
      return finder.hasFound;
    } catch (e) {
      return false;
    }
  }

  /// Mock network delay
  static Future<void> mockNetworkDelay([Duration? delay]) async {
    await Future.delayed(delay ?? const Duration(milliseconds: 500));
  }

  /// Generate mock order data
  static Map<String, dynamic> generateMockOrder(int id) {
    return {
      'id': id.toString(),
      'orderNumber': 'ĐH${id.toString().padLeft(3, '0')}',
      'customerName': mockVietnameseData['customerNames']![id % 4],
      'phoneNumber': mockVietnameseData['phoneNumbers']![id % 4],
      'total': (50000 + (id * 25000)),
      'status': ['Đang chờ', 'Đã xác nhận', 'Đang chuẩn bị', 'Sẵn sàng'][id % 4],
      'tableNumber': id + 1,
      'orderDate': DateTime.now().subtract(Duration(hours: id)),
    };
  }

  /// Generate mock reservation data
  static Map<String, dynamic> generateMockReservation(int id) {
    return {
      'id': id.toString(),
      'customerName': mockVietnameseData['customerNames']![id % 4],
      'phoneNumber': mockVietnameseData['phoneNumbers']![id % 4],
      'guestCount': 2 + (id % 4),
      'tableNumber': 10 + id,
      'reservationDate': DateTime.now().add(Duration(days: id)),
      'reservationTime': '19:${(id * 15 % 60).toString().padLeft(2, '0')}',
      'status': 'Đã xác nhận',
    };
  }

  /// Generate mock takeaway data
  static Map<String, dynamic> generateMockTakeaway(int id) {
    return {
      'id': id.toString(),
      'orderNumber': 'MW${id.toString().padLeft(3, '0')}',
      'customerPhone': mockVietnameseData['phoneNumbers']![id % 4],
      'total': (75000 + (id * 15000)),
      'status': ['Đang chuẩn bị', 'Sẵn sàng', 'Hoàn thành'][id % 3],
      'pickupTime': '${15 + id}:${(id * 10 % 60).toString().padLeft(2, '0')}',
      'orderDate': DateTime.now().subtract(Duration(minutes: id * 30)),
    };
  }

  /// Create mock user data
  static Map<String, dynamic> createMockUser({
    String? id,
    String? name,
    String? role,
  }) {
    return {
      'id': id ?? '1',
      'userName': 'test_user',
      'email': 'test@restaurant.vn',
      'name': name ?? 'Nguyễn',
      'surname': 'Văn Test',
      'phoneNumber': '0901234567',
      'isActive': true,
      'roles': [role ?? 'Waitstaff'],
    };
  }

  /// Assert Vietnamese text formatting
  static void expectVietnameseFormat({
    required WidgetTester tester,
    String? currency,
    String? date,
    String? time,
    String? phone,
  }) {
    if (currency != null) {
      expect(isValidVietnameseCurrency(currency), isTrue,
          reason: 'Invalid Vietnamese currency format: $currency');
    }
    
    if (date != null) {
      expect(isValidVietnameseDate(date), isTrue,
          reason: 'Invalid Vietnamese date format: $date');
    }
    
    if (time != null) {
      expect(isValidVietnameseTime(time), isTrue,
          reason: 'Invalid Vietnamese time format: $time');
    }
    
    if (phone != null) {
      expect(isValidVietnamesePhone(phone), isTrue,
          reason: 'Invalid Vietnamese phone format: $phone');
    }
  }
}