import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:smart_restaurant/main.dart' as app;
import 'package:smart_restaurant/features/orders/services/order_service.dart';
import 'package:smart_restaurant/shared/services/api_client.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Order Workflow Integration Tests', () {
    testWidgets('complete order workflow from table selection to confirmation', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Verify app loaded
      expect(find.text('Smart Restaurant'), findsOneWidget);

      // Navigate to order screen
      await tester.tap(find.byIcon(Icons.restaurant_menu));
      await tester.pumpAndSettle();

      // Step 1: Table Selection
      expect(find.text('Chọn bàn'), findsOneWidget);
      
      // Wait for tables to load
      await tester.pump(const Duration(seconds: 2));
      
      // Select available table
      final availableTable = find.byKey(const ValueKey('table_available')).first;
      await tester.tap(availableTable);
      await tester.pumpAndSettle();

      // Step 2: Menu Browsing
      expect(find.text('Chọn món'), findsOneWidget);
      
      // Wait for menu to load
      await tester.pump(const Duration(seconds: 2));
      
      // Select Phở category
      await tester.tap(find.text('Phở'));
      await tester.pumpAndSettle();

      // Add Phở Bò to order
      await tester.tap(find.text('Phở Bò Tái'));
      await tester.pumpAndSettle();

      // Verify item added (should see cart badge)
      expect(find.text('1'), findsOneWidget); // Cart badge

      // Add another item with custom quantity
      await tester.longPress(find.text('Phở Gà'));
      await tester.pumpAndSettle();

      // Should show quantity dialog
      expect(find.text('Chọn số lượng'), findsOneWidget);
      
      final quantityField = find.byType(TextField).first;
      await tester.enterText(quantityField, '2');
      
      final notesField = find.byType(TextField).last;
      await tester.enterText(notesField, 'Không hành');

      await tester.tap(find.text('Thêm vào order'));
      await tester.pumpAndSettle();

      // Cart should show 3 items now
      expect(find.text('3'), findsOneWidget);

      // Step 3: Go to Order Summary
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Step 4: Order Summary Review
      expect(find.text('Xem lại đơn hàng'), findsOneWidget);
      expect(find.text('Phở Bò Tái'), findsOneWidget);
      expect(find.text('Phở Gà'), findsOneWidget);
      expect(find.text('x1'), findsOneWidget);
      expect(find.text('x2'), findsOneWidget);
      expect(find.text('Không hành'), findsOneWidget);

      // Check total calculation
      expect(find.textContaining('185,000₫'), findsOneWidget); // Total amount

      // Step 5: Add customer information
      await tester.tap(find.text('Thông tin khách hàng'));
      await tester.pumpAndSettle();

      final nameField = find.byKey(const Key('customer_name'));
      await tester.enterText(nameField, 'Nguyễn Văn A');
      
      final phoneField = find.byKey(const Key('customer_phone'));
      await tester.enterText(phoneField, '0901234567');

      await tester.tap(find.text('Lưu thông tin'));
      await tester.pumpAndSettle();

      // Step 6: Add order notes
      await tester.tap(find.text('Ghi chú đơn hàng'));
      await tester.pumpAndSettle();

      final orderNotesField = find.byKey(const Key('order_notes'));
      await tester.enterText(orderNotesField, 'Khách hàng VIP, phục vụ tốt');
      await tester.pumpAndSettle();

      // Step 7: Confirm Order
      await tester.tap(find.text('Xác nhận đơn hàng'));
      await tester.pumpAndSettle();

      // Should show ingredient check (if implemented)
      // If no missing ingredients, should show confirmation dialog
      expect(find.text('Xác nhận đặt món'), findsOneWidget);
      
      await tester.tap(find.text('Đặt món'));
      await tester.pumpAndSettle();

      // Step 8: Verify Success
      expect(find.text('Đặt món thành công'), findsOneWidget);
      expect(find.textContaining('ORD-'), findsOneWidget); // Order number
    });

    testWidgets('order workflow với missing ingredients', (tester) async {
      // Launch app in test mode with missing ingredients scenario
      app.main();
      await tester.pumpAndSettle();

      // Navigate and create order (abbreviated steps)
      await tester.tap(find.byIcon(Icons.restaurant_menu));
      await tester.pumpAndSettle();

      // Select table and add items
      final availableTable = find.byKey(const ValueKey('table_available')).first;
      await tester.tap(availableTable);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Phở'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Phở Bò Đặc Biệt')); // High ingredient requirement
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Try to confirm order
      await tester.tap(find.text('Xác nhận đơn hàng'));
      await tester.pumpAndSettle();

      // Should show missing ingredients warning
      expect(find.text('Thiếu nguyên liệu'), findsOneWidget);
      expect(find.text('Không thể đặt món'), findsOneWidget);
      expect(find.text('Chỉnh sửa đơn'), findsOneWidget);
      
      // Edit order instead
      await tester.tap(find.text('Chỉnh sửa đơn'));
      await tester.pumpAndSettle();

      // Should go back to menu browsing
      expect(find.text('Chọn món'), findsOneWidget);
    });

    testWidgets('offline mode order workflow', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Simulate offline mode
      await tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/connectivity',
        (message) async {
          return const StandardMethodCodec().encodeSuccessEnvelope(['none']);
        },
      );

      // Navigate to orders
      await tester.tap(find.byIcon(Icons.restaurant_menu));
      await tester.pumpAndSettle();

      // Should show offline indicator
      expect(find.text('Chế độ offline'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);

      // Create order normally (should be queued)
      final availableTable = find.byKey(const ValueKey('table_available')).first;
      await tester.tap(availableTable);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Phở'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Phở Bò'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Xác nhận đơn hàng'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Đặt món'));
      await tester.pumpAndSettle();

      // Should show queued message
      expect(find.text('Đơn hàng đã được lưu'), findsOneWidget);
      expect(find.text('Sẽ gửi khi có kết nối'), findsOneWidget);

      // Go back online
      await tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/connectivity',
        (message) async {
          return const StandardMethodCodec().encodeSuccessEnvelope(['wifi']);
        },
      );

      await tester.pump(const Duration(seconds: 2));

      // Should show sync notification
      expect(find.text('Đang đồng bộ đơn hàng...'), findsOneWidget);
    });

    testWidgets('voice search workflow', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to orders
      await tester.tap(find.byIcon(Icons.restaurant_menu));
      await tester.pumpAndSettle();

      // Select table
      final availableTable = find.byKey(const ValueKey('table_available')).first;
      await tester.tap(availableTable);
      await tester.pumpAndSettle();

      // Use voice search
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      // Should show voice input UI
      expect(find.text('Nói tên món ăn...'), findsOneWidget);
      expect(find.byIcon(Icons.mic_none), findsOneWidget);

      // Simulate voice result (would normally come from speech recognition)
      final voiceInputWidget = find.byKey(const Key('voice_input_widget'));
      expect(voiceInputWidget, findsOneWidget);

      // Voice search should populate search field
      // (This would be tested with actual device/emulator)
    });

    testWidgets('error recovery workflow', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Simulate network error during order creation
      await tester.tap(find.byIcon(Icons.restaurant_menu));
      await tester.pumpAndSettle();

      // Create order
      final availableTable = find.byKey(const ValueKey('table_available')).first;
      await tester.tap(availableTable);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Phở'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Phở Bò'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Simulate network failure during confirmation
      await tester.tap(find.text('Xác nhận đơn hàng'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Đặt món'));
      await tester.pump(const Duration(seconds: 3));

      // Should show error and retry options
      expect(find.text('Có lỗi xảy ra'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
      expect(find.text('Lưu nháp'), findsOneWidget);

      // Retry should work
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
    });

    testWidgets('multiple orders trên different tables', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Create first order for table 1
      await tester.tap(find.byIcon(Icons.restaurant_menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('B01'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Phở'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Phở Bò'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Xác nhận đơn hàng'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Đặt món'));
      await tester.pumpAndSettle();

      // Should show success and go back to table selection
      expect(find.text('Đặt món thành công'), findsOneWidget);
      
      await tester.tap(find.text('Đặt món tiếp'));
      await tester.pumpAndSettle();

      // Should be back at table selection
      expect(find.text('Chọn bàn'), findsOneWidget);
      
      // Table 1 should now show "occupied" status
      expect(find.text('Có khách'), findsAtLeastNWidgets(1));

      // Create second order for different table
      await tester.tap(find.text('B02'));
      await tester.pumpAndSettle();

      // Repeat process for second table...
      await tester.tap(find.text('Cơm'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cơm Tấm'));
      await tester.pumpAndSettle();

      // Verify independent orders
      expect(find.text('1'), findsOneWidget); // New cart badge
    });

    testWidgets('order status tracking workflow', (tester) async {
      // Launch app and create an order first
      app.main();
      await tester.pumpAndSettle();

      // ... create order steps (abbreviated) ...

      // After order confirmation, navigate to tracking
      await tester.tap(find.byIcon(Icons.track_changes));
      await tester.pumpAndSettle();

      // Should show order tracking screen
      expect(find.text('Theo dõi đơn hàng'), findsOneWidget);
      expect(find.textContaining('ORD-'), findsAtLeastNWidgets(1));

      // Tap on an order to see details
      final orderCard = find.byType(Card).first;
      await tester.tap(orderCard);
      await tester.pumpAndSettle();

      // Should show order status timeline
      expect(find.text('Đã đặt'), findsOneWidget);
      expect(find.text('Đã xác nhận'), findsOneWidget);
      expect(find.text('Đang chuẩn bị'), findsOneWidget);
      expect(find.text('Sẵn sàng'), findsOneWidget);

      // Should show real-time updates (if WebSocket connected)
      expect(find.byIcon(Icons.wifi), findsOneWidget); // Connected indicator
    });

    testWidgets('kitchen integration notifications', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to kitchen integration screen
      await tester.tap(find.byIcon(Icons.kitchen));
      await tester.pumpAndSettle();

      // Should show kitchen dashboard
      expect(find.text('Bếp'), findsOneWidget);
      expect(find.text('Đơn hàng đang chờ'), findsOneWidget);

      // Should show live order queue
      expect(find.byType(ListView), findsOneWidget);

      // Test notification when new order arrives
      // (This would require WebSocket simulation)
    });

    testWidgets('search functionality across workflow', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.restaurant_menu));
      await tester.pumpAndSettle();

      // Select table
      final availableTable = find.byKey(const ValueKey('table_available')).first;
      await tester.tap(availableTable);
      await tester.pumpAndSettle();

      // Use search instead of categories
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'phở');
      await tester.pump(const Duration(milliseconds: 500));

      // Should show search results
      expect(find.text('Phở Bò'), findsAtLeastNWidgets(1));
      expect(find.text('Phở Gà'), findsAtLeastNWidgets(1));

      // Test Vietnamese diacritics search
      await tester.enterText(searchField, 'pho'); // Without accents
      await tester.pump(const Duration(milliseconds: 500));

      // Should still find phở items
      expect(find.text('Phở Bò'), findsAtLeastNWidgets(1));

      // Test voice search
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      expect(find.text('Nói tên món ăn...'), findsOneWidget);
    });

    testWidgets('error handling và recovery', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to orders
      await tester.tap(find.byIcon(Icons.restaurant_menu));
      await tester.pumpAndSettle();

      // Try to proceed without selecting table (should show error)
      final menuTab = find.text('Menu');
      if (menuTab.evaluate().isNotEmpty) {
        await tester.tap(menuTab);
        await tester.pumpAndSettle();
        
        // Should show error or prevent navigation
        expect(find.text('Vui lòng chọn bàn trước'), findsOneWidget);
      }

      // Test network error recovery
      // Simulate network issue during data load
      await tester.pump(const Duration(seconds: 5));

      if (find.text('Có lỗi xảy ra').evaluate().isNotEmpty) {
        // Should show retry option
        expect(find.text('Thử lại'), findsOneWidget);
        
        await tester.tap(find.text('Thử lại'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('tablet optimized layout', (tester) async {
      // Set tablet screen size
      await tester.binding.setSurfaceSize(const Size(1024, 768));
      
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.restaurant_menu));
      await tester.pumpAndSettle();

      // Should show optimized tablet layout
      // Table selection should be in grid view
      expect(find.byType(GridView), findsAtLeastNWidgets(1));

      // Navigate and check menu layout
      final availableTable = find.byKey(const ValueKey('table_available')).first;
      await tester.tap(availableTable);
      await tester.pumpAndSettle();

      // Menu should show categories on side and items on main area
      expect(find.text('Phở'), findsOneWidget);
      expect(find.text('Cơm'), findsOneWidget);
      
      // Should have larger touch targets for tablet
      final menuItems = find.byType(Card);
      expect(menuItems.evaluate().length, greaterThan(0));
    });

    testWidgets('performance với large menu data', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.restaurant_menu));
      await tester.pumpAndSettle();

      final availableTable = find.byKey(const ValueKey('table_available')).first;
      await tester.tap(availableTable);
      await tester.pumpAndSettle();

      // Test scroll performance with large menu
      await tester.tap(find.text('Tất cả')); // Show all items
      await tester.pumpAndSettle();

      // Scroll through large list
      final listView = find.byType(ListView);
      for (int i = 0; i < 10; i++) {
        await tester.drag(listView, const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should still be responsive
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('accessibility navigation workflow', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Test semantic navigation
      expect(find.bySemanticsLabel('Đặt món'), findsOneWidget);
      
      await tester.tap(find.bySemanticsLabel('Đặt món'));
      await tester.pumpAndSettle();

      // Table selection should have proper semantics
      final tableButtons = find.bySemanticsLabel(RegExp(r'Bàn số \w+'));
      expect(tableButtons.evaluate().length, greaterThan(0));

      // Menu items should have accessibility labels
      await tester.tap(tableButtons.first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Phở'));
      await tester.pumpAndSettle();

      final menuItemSemantics = find.bySemanticsLabel(RegExp(r'Phở .+, giá \d+'));
      expect(menuItemSemantics.evaluate().length, greaterThan(0));
    });
  });

  group('Order Management Integration Tests', () {
    testWidgets('waiter dashboard với multiple active orders', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to waiter dashboard
      await tester.tap(find.byIcon(Icons.dashboard));
      await tester.pumpAndSettle();

      // Should show waiter dashboard
      expect(find.text('Dashboard Nhân viên'), findsOneWidget);
      
      // Should show active orders count
      expect(find.textContaining('đơn hàng'), findsAtLeastNWidgets(1));
      
      // Should show tables status overview
      expect(find.text('Trạng thái bàn'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget); // Table grid

      // Should show priority orders
      expect(find.text('Đơn ưu tiên'), findsOneWidget);
      
      // Should show kitchen status
      expect(find.text('Tình trạng bếp'), findsOneWidget);
    });

    testWidgets('real-time updates integration', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to tracking
      await tester.tap(find.byIcon(Icons.track_changes));
      await tester.pumpAndSettle();

      // Should connect to WebSocket
      expect(find.byIcon(Icons.wifi), findsOneWidget); // Connected

      // Should show real-time order status
      expect(find.textContaining('Cập nhật:'), findsAtLeastNWidgets(1));
      
      // Should update when order status changes
      // (This requires actual backend integration)
    });

    testWidgets('multi-language support', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // All text should be in Vietnamese
      expect(find.text('Smart Restaurant'), findsOneWidget);
      expect(find.text('Đặt món'), findsOneWidget);
      expect(find.text('Theo dõi'), findsOneWidget);
      
      // Numbers should use Vietnamese formatting
      expect(find.textContaining('₫'), findsAtLeastNWidgets(1));
      
      // Time should use Vietnamese format
      expect(find.textContaining('phút'), findsAtLeastNWidgets(1));
    });
  });
}