import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_mobile/main.dart' as app;

/// Integration tests for SmartRestaurant Mobile App
/// Tests the complete user workflows from splash to main features
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SmartRestaurant App Integration Tests', () {
    testWidgets('complete app flow from splash to login to main navigation', 
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Should start on splash screen
      expect(find.text('SmartRestaurant'), findsOneWidget);
      expect(find.text('Đang tải...'), findsOneWidget);

      // Wait for automatic navigation to login (3 seconds)
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Should now be on login screen
      expect(find.text('Đăng nhập để tiếp tục'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));

      // Enter login credentials
      final usernameField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(usernameField, 'admin');
      await tester.pumpAndSettle();

      await tester.enterText(passwordField, '1q2w3E*');
      await tester.pumpAndSettle();

      // Tap login button
      final loginButton = find.byType(ElevatedButton);
      await tester.tap(loginButton);

      // Wait for authentication (mock delay)
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should navigate to main app with bottom navigation
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Gọi món'), findsOneWidget);
      expect(find.text('Đặt bàn'), findsOneWidget);
      expect(find.text('Mang về'), findsOneWidget);

      // Should be on orders screen by default
      expect(find.text('Quản lý Đơn hàng'), findsOneWidget);
    });

    testWidgets('navigation between main features works correctly',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate through splash and login
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Login
      await tester.enterText(find.byType(TextFormField).first, 'admin');
      await tester.enterText(find.byType(TextFormField).last, '1q2w3E*');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test navigation to reservations
      await tester.tap(find.text('Đặt bàn'));
      await tester.pumpAndSettle();
      expect(find.text('Quản lý Đặt bàn'), findsOneWidget);

      // Test navigation to takeaway
      await tester.tap(find.text('Mang về'));
      await tester.pumpAndSettle();
      expect(find.text('Quản lý Mang về'), findsOneWidget);

      // Test navigation back to orders
      await tester.tap(find.text('Gọi món'));
      await tester.pumpAndSettle();
      expect(find.text('Quản lý Đơn hàng'), findsOneWidget);
    });

    testWidgets('orders screen displays mock data correctly',
        (WidgetTester tester) async {
      // Start the app and navigate to orders
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Login
      await tester.enterText(find.byType(TextFormField).first, 'admin');
      await tester.enterText(find.byType(TextFormField).last, '1q2w3E*');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should be on orders screen with mock data
      expect(find.text('Quản lý Đơn hàng'), findsOneWidget);

      // Check for search functionality
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Tìm kiếm'), findsOneWidget);

      // Check for filter button
      expect(find.byIcon(Icons.tune), findsOneWidget);

      // Check for mock order cards
      expect(find.textContaining('Đơn hàng #'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Bàn'), findsAtLeastNWidgets(1));
      expect(find.textContaining('đ'), findsAtLeastNWidgets(1)); // Vietnamese currency

      // Check for order status
      expect(find.textContaining('Đã xác nhận'), findsAtLeastNWidgets(1));
    });

    testWidgets('reservations screen displays Vietnamese data correctly',
        (WidgetTester tester) async {
      // Start the app and navigate to reservations
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Login
      await tester.enterText(find.byType(TextFormField).first, 'admin');
      await tester.enterText(find.byType(TextFormField).last, '1q2w3E*');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to reservations
      await tester.tap(find.text('Đặt bàn'));
      await tester.pumpAndSettle();

      // Should be on reservations screen
      expect(find.text('Quản lý Đặt bàn'), findsOneWidget);

      // Check for search by customer name
      expect(find.text('Tìm theo tên khách hàng'), findsOneWidget);

      // Check for date filter button
      expect(find.byIcon(Icons.date_range), findsOneWidget);

      // Check for mock Vietnamese customer names
      expect(find.textContaining('Nguyễn'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Trần'), findsAtLeastNWidgets(1));

      // Check for Vietnamese phone numbers
      expect(find.textContaining('090'), findsAtLeastNWidgets(1));

      // Check for reservation status
      expect(find.text('Đã xác nhận'), findsAtLeastNWidgets(1));

      // Check for action buttons
      expect(find.text('Gọi'), findsAtLeastNWidgets(1));
      expect(find.text('Sửa'), findsAtLeastNWidgets(1));
    });

    testWidgets('takeaway screen displays Vietnamese order data correctly',
        (WidgetTester tester) async {
      // Start the app and navigate to takeaway
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Login
      await tester.enterText(find.byType(TextFormField).first, 'admin');
      await tester.enterText(find.byType(TextFormField).last, '1q2w3E*');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to takeaway
      await tester.tap(find.text('Mang về'));
      await tester.pumpAndSettle();

      // Should be on takeaway screen
      expect(find.text('Quản lý Mang về'), findsOneWidget);

      // Check for search by phone
      expect(find.text('Tìm theo SĐT khách hàng'), findsOneWidget);

      // Check for status filter button
      expect(find.byIcon(Icons.filter_list), findsOneWidget);

      // Check for mock takeaway orders
      expect(find.textContaining('Mang về #MW'), findsAtLeastNWidgets(1));

      // Check for Vietnamese phone numbers
      expect(find.textContaining('090'), findsAtLeastNWidgets(1));

      // Check for pickup times
      expect(find.textContaining('Lấy lúc'), findsAtLeastNWidgets(1));

      // Check for order statuses in Vietnamese
      expect(find.textContaining('Đang chuẩn bị'), findsAtLeastNWidgets(1));

      // Check for currency formatting
      expect(find.textContaining('đ'), findsAtLeastNWidgets(1));

      // Check for action buttons
      expect(find.text('Gọi'), findsAtLeastNWidgets(1));
    });

    testWidgets('user profile menu works correctly',
        (WidgetTester tester) async {
      // Start the app and navigate to main screen
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Login
      await tester.enterText(find.byType(TextFormField).first, 'admin');
      await tester.enterText(find.byType(TextFormField).last, '1q2w3E*');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should be on main screen with app bar
      expect(find.byType(AppBar), findsOneWidget);

      // Tap profile button in app bar
      final profileButton = find.byIcon(Icons.person);
      expect(profileButton, findsOneWidget);
      await tester.tap(profileButton);
      await tester.pumpAndSettle();

      // Should show bottom sheet with profile options
      expect(find.text('Thông tin tài khoản'), findsOneWidget);
      expect(find.text('Cài đặt'), findsOneWidget);
      expect(find.text('Đăng xuất'), findsOneWidget);

      // Test logout confirmation
      await tester.tap(find.text('Đăng xuất'));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Bạn có chắc chắn muốn đăng xuất?'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);
      expect(find.text('Xác nhận'), findsOneWidget);

      // Cancel logout
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      // Should still be on main screen
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('app handles Vietnamese text input correctly',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Test Vietnamese text input in login fields
      await tester.enterText(find.byType(TextFormField).first, 'người_dùng_test');
      await tester.pumpAndSettle();

      // Check if Vietnamese text is displayed correctly
      expect(find.text('người_dùng_test'), findsOneWidget);

      // Test with Vietnamese characters with diacritics
      await tester.enterText(find.byType(TextFormField).first, 'nguyễn_văn_an');
      await tester.pumpAndSettle();

      expect(find.text('nguyễn_văn_an'), findsOneWidget);
    });

    testWidgets('app displays responsive layout correctly',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Login
      await tester.enterText(find.byType(TextFormField).first, 'admin');
      await tester.enterText(find.byType(TextFormField).last, '1q2w3E*');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should have responsive layout elements
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Check if cards are displayed with proper spacing
      final cards = find.byType(Container);
      expect(cards, findsAtLeastNWidgets(3)); // Should have multiple cards

      // Check if floating action button is present for adding new items
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}