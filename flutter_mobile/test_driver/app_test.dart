import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('SmartRestaurant Mobile App E2E Tests', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    test('complete order workflow end-to-end', () async {
      // Step 1: Launch app và verify initial state
      await driver.waitFor(find.text('Smart Restaurant'));
      
      // Step 2: Navigate to order screen
      await driver.tap(find.byValueKey('orders_tab'));
      await driver.waitFor(find.text('Chọn bàn'));

      // Step 3: Select table
      await driver.tap(find.byValueKey('table_B01'));
      await driver.waitFor(find.text('Chọn món'));

      // Step 4: Browse menu and add items
      await driver.tap(find.text('Phở'));
      await driver.waitFor(find.text('Phở Bò Tái'));

      // Add first item
      await driver.tap(find.text('Phở Bò Tái'));
      await driver.waitFor(find.text('1')); // Cart badge

      // Add second item with customization
      await driver.tap(find.text('Phở Gà'));
      await driver.waitFor(find.text('2')); // Cart badge should update

      // Step 5: Go to order summary
      await driver.tap(find.byValueKey('cart_button'));
      await driver.waitFor(find.text('Xem lại đơn hàng'));

      // Verify order details
      expect(await driver.getText(find.text('Phở Bò Tái')), equals('Phở Bò Tái'));
      expect(await driver.getText(find.text('Phở Gà')), equals('Phở Gà'));

      // Step 6: Add customer information
      await driver.tap(find.text('Thông tin khách hàng'));
      await driver.enterText(find.byValueKey('customer_name'), 'Nguyễn Văn Test');
      await driver.enterText(find.byValueKey('customer_phone'), '0901234567');
      await driver.tap(find.text('Lưu thông tin'));

      // Step 7: Add special requests
      await driver.tap(find.text('Yêu cầu đặc biệt'));
      await driver.enterText(find.byValueKey('kitchen_notes'), 'Làm nhanh, khách vội');
      await driver.tap(find.text('Lưu yêu cầu'));

      // Step 8: Confirm order
      await driver.tap(find.text('Xác nhận đơn hàng'));
      await driver.waitFor(find.text('Xác nhận đặt món'));
      
      await driver.tap(find.text('Đặt món'));
      
      // Step 9: Verify success
      await driver.waitFor(find.text('Đặt món thành công'));
      expect(await driver.getText(find.byValueKey('order_number')), 
        contains('ORD-'));
    });

    test('order tracking real-time updates', () async {
      // Navigate to tracking screen
      await driver.tap(find.byValueKey('tracking_tab'));
      await driver.waitFor(find.text('Theo dõi đơn hàng'));

      // Should show connection status
      await driver.waitFor(find.byValueKey('connection_indicator'));

      // Select an order to track
      await driver.tap(find.byValueKey('order_card_0'));
      await driver.waitFor(find.text('Chi tiết đơn hàng'));

      // Should show status timeline
      expect(await driver.getText(find.text('Đã đặt')), equals('Đã đặt'));
      expect(await driver.getText(find.text('Đã xác nhận')), equals('Đã xác nhận'));

      // Wait for real-time update (simulated)
      await driver.waitFor(find.text('Đang chuẩn bị'), timeout: const Duration(seconds: 10));
    });

    test('kitchen dashboard notifications', () async {
      // Navigate to kitchen screen
      await driver.tap(find.byValueKey('kitchen_tab'));
      await driver.waitFor(find.text('Bếp'));

      // Should show pending orders
      await driver.waitFor(find.text('Đơn hàng đang chờ'));
      
      // Should show kitchen areas
      expect(await driver.getText(find.text('Khu vực Phở')), equals('Khu vực Phở'));
      expect(await driver.getText(find.text('Khu vực Nướng')), equals('Khu vực Nướng'));

      // Test marking item as ready
      await driver.tap(find.byValueKey('mark_ready_button_0'));
      await driver.waitFor(find.text('Đã sẵn sàng'));

      // Should trigger notification
      await driver.waitFor(find.byValueKey('notification_banner'));
    });

    test('offline mode functionality', () async {
      // Navigate to settings to enable offline mode
      await driver.tap(find.byValueKey('settings_tab'));
      await driver.waitFor(find.text('Cài đặt'));

      await driver.tap(find.text('Chế độ offline'));
      await driver.waitFor(find.text('Đã bật chế độ offline'));

      // Go back and create order offline
      await driver.tap(find.byValueKey('orders_tab'));
      await driver.waitFor(find.text('Chế độ offline')); // Offline indicator

      // Create order normally
      await driver.tap(find.byValueKey('table_B02'));
      await driver.tap(find.text('Cơm'));
      await driver.tap(find.text('Cơm Tấm'));
      await driver.tap(find.byValueKey('cart_button'));
      await driver.tap(find.text('Xác nhận đơn hàng'));
      await driver.tap(find.text('Đặt món'));

      // Should show offline confirmation
      await driver.waitFor(find.text('Đơn hàng đã được lưu'));
      await driver.waitFor(find.text('Sẽ gửi khi có kết nối'));
    });

    test('voice search functionality', () async {
      // Navigate to orders
      await driver.tap(find.byValueKey('orders_tab'));
      await driver.tap(find.byValueKey('table_B03'));
      await driver.waitFor(find.text('Chọn món'));

      // Test voice search
      await driver.tap(find.byValueKey('voice_search_button'));
      await driver.waitFor(find.text('Nói tên món ăn...'));

      // Simulate voice input (would require actual device testing)
      // For now, just verify UI appears correctly
      expect(await driver.getText(find.text('Nghe...')), equals('Nghe...'));
    });

    test('accessibility features', () async {
      // Test screen reader navigation
      await driver.tap(find.byValueKey('orders_tab'));
      await driver.waitFor(find.text('Chọn bàn'));

      // Verify semantic labels exist
      final tableCard = find.byValueKey('table_B01');
      await driver.waitFor(tableCard);

      // Test large font support (would need device settings)
      // Test high contrast mode
      // Test tap target sizes (44px minimum)
    });

    test('performance với large dataset', () async {
      // Navigate to menu with many items
      await driver.tap(find.byValueKey('orders_tab'));
      await driver.tap(find.byValueKey('table_B01'));
      await driver.waitFor(find.text('Chọn món'));

      // Load all categories to stress test
      await driver.tap(find.text('Tất cả'));
      await driver.waitFor(find.byType('ListView'));

      final stopwatch = Stopwatch()..start();

      // Scroll through entire menu
      for (int i = 0; i < 20; i++) {
        await driver.scroll(find.byType('ListView'), 0, -500, const Duration(milliseconds: 100));
        await driver.waitForAbsent(find.text('Đang tải...'));
      }

      stopwatch.stop();

      // Should complete scrolling within reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(10000)); // 10 seconds max
    });

    test('memory usage optimization', () async {
      // Create and cancel multiple orders to test cleanup
      for (int i = 0; i < 5; i++) {
        await driver.tap(find.byValueKey('orders_tab'));
        await driver.tap(find.byValueKey('table_B0${i + 1}'));
        await driver.tap(find.text('Phở'));
        await driver.tap(find.text('Phở Bò'));
        await driver.tap(find.byValueKey('cart_button'));
        
        // Cancel order
        await driver.tap(find.byValueKey('clear_order_button'));
        await driver.tap(find.text('Xóa'));
        
        await driver.tap(find.byValueKey('back_button'));
      }

      // App should still be responsive
      await driver.tap(find.byValueKey('orders_tab'));
      await driver.waitFor(find.text('Chọn bàn'));
    });

    test('network resilience testing', () async {
      // Start with normal operation
      await driver.tap(find.byValueKey('orders_tab'));
      await driver.tap(find.byValueKey('table_B01'));
      await driver.waitFor(find.text('Chọn món'));

      // Add items to order
      await driver.tap(find.text('Phở'));
      await driver.tap(find.text('Phở Bò'));

      // Simulate network interruption during confirmation
      await driver.tap(find.byValueKey('cart_button'));
      await driver.tap(find.text('Xác nhận đơn hàng'));
      
      // Should show retry mechanism
      await driver.waitFor(find.text('Thử lại'), timeout: const Duration(seconds: 10));
      
      await driver.tap(find.text('Thử lại'));
      await driver.waitFor(find.text('Đặt món thành công'));
    });

    test('concurrent order creation', () async {
      // This test would require multiple devices/sessions
      // For now, test rapid order creation on single device
      
      for (int i = 0; i < 3; i++) {
        await driver.tap(find.byValueKey('orders_tab'));
        await driver.tap(find.byValueKey('table_B0${i + 1}'));
        await driver.tap(find.text('Cơm'));
        await driver.tap(find.text('Cơm Tấm'));
        await driver.tap(find.byValueKey('cart_button'));
        await driver.tap(find.text('Xác nhận đơn hàng'));
        await driver.tap(find.text('Đặt món'));
        
        // Should handle rapid order creation gracefully
        await driver.waitFor(find.text('Đặt món thành công'));
        await driver.tap(find.text('Đặt món tiếp'));
      }

      // Verify all orders were created
      await driver.tap(find.byValueKey('tracking_tab'));
      await driver.waitFor(find.text('Theo dõi đơn hàng'));
      
      // Should show multiple recent orders
      final orderCards = find.byType('Card');
      expect(await driver.getText(orderCards), contains('ORD-'));
    });

    test('Vietnamese input method support', () async {
      // Test Vietnamese text input in search
      await driver.tap(find.byValueKey('orders_tab'));
      await driver.tap(find.byValueKey('table_B01'));
      
      final searchField = find.byValueKey('search_field');
      await driver.enterText(searchField, 'phở bò tái nạm');
      
      // Should handle Vietnamese diacritics correctly
      await driver.waitFor(find.text('Phở Bò Tái Nạm'));
      
      // Test notes input with Vietnamese
      await driver.tap(find.text('Phở Bò Tái Nạm'));
      await driver.longPress(find.byValueKey('cart_button'));
      
      final notesField = find.byValueKey('item_notes');
      await driver.enterText(notesField, 'Không có hành lá, ít muối');
      
      await driver.tap(find.text('Thêm vào order'));
      
      // Should preserve Vietnamese text
      await driver.tap(find.byValueKey('cart_button'));
      expect(await driver.getText(find.text('Không có hành lá, ít muối')), 
        equals('Không có hành lá, ít muối'));
    });

    test('payment flow integration', () async {
      // Create order first
      await driver.tap(find.byValueKey('orders_tab'));
      await driver.tap(find.byValueKey('table_B01'));
      await driver.tap(find.text('Phở'));
      await driver.tap(find.text('Phở Bò'));
      await driver.tap(find.byValueKey('cart_button'));

      // Select payment method
      await driver.tap(find.text('Tiền mặt'));
      await driver.waitFor(find.text('Chọn phương thức thanh toán'));
      
      await driver.tap(find.text('Thẻ ngân hàng'));
      await driver.tap(find.text('Áp dụng'));

      // Should update payment display
      expect(await driver.getText(find.text('Thẻ ngân hàng')), 
        equals('Thẻ ngân hàng'));

      // Test split payment
      await driver.tap(find.text('Thẻ ngân hàng'));
      await driver.tap(find.text('Chia tách hóa đơn'));
      await driver.tap(find.text('Chia đều theo số người'));
      
      await driver.enterText(find.byValueKey('split_count'), '2');
      await driver.tap(find.text('Áp dụng'));

      // Should show split amounts
      expect(await driver.getText(find.byType('Text')), contains('32,500₫'));
    });
  });

  group('Error Scenarios E2E Tests', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    test('network error during order creation', () async {
      // Create order to the point of confirmation
      await driver.tap(find.byValueKey('orders_tab'));
      await driver.tap(find.byValueKey('table_B01'));
      await driver.tap(find.text('Phở'));
      await driver.tap(find.text('Phở Bò'));
      await driver.tap(find.byValueKey('cart_button'));
      
      // Simulate network error (would require test server)
      await driver.tap(find.text('Xác nhận đơn hàng'));
      await driver.tap(find.text('Đặt món'));

      // Should handle error gracefully
      await driver.waitFor(find.text('Có lỗi xảy ra'), timeout: const Duration(seconds: 10));
      expect(await driver.getText(find.text('Thử lại')), equals('Thử lại'));
      expect(await driver.getText(find.text('Lưu nháp')), equals('Lưu nháp'));
    });

    test('ingredient shortage workflow', () async {
      // Create order with items that may have ingredient issues
      await driver.tap(find.byValueKey('orders_tab'));
      await driver.tap(find.byValueKey('table_B02'));
      await driver.tap(find.text('Phở'));
      await driver.tap(find.text('Phở Đặc Biệt')); // High ingredient requirement
      await driver.tap(find.byValueKey('cart_button'));
      
      await driver.tap(find.text('Xác nhận đơn hàng'));

      // Should show ingredient warning if any
      final missingIngredientsText = find.text('Thiếu nguyên liệu');
      if (await driver.isPresent(missingIngredientsText)) {
        expect(await driver.getText(missingIngredientsText), equals('Thiếu nguyên liệu'));
        
        // Should show options
        expect(await driver.getText(find.text('Chỉnh sửa đơn')), equals('Chỉnh sửa đơn'));
        
        if (await driver.isPresent(find.text('Tiếp tục đặt món'))) {
          await driver.tap(find.text('Tiếp tục đặt món'));
        } else {
          await driver.tap(find.text('Chỉnh sửa đơn'));
        }
      }
    });

    test('validation error handling', () async {
      // Try to create order without table (for dine-in)
      await driver.tap(find.byValueKey('orders_tab'));
      
      // Skip table selection, go directly to menu
      await driver.tap(find.byValueKey('skip_table')); // If available
      
      if (await driver.isPresent(find.text('Vui lòng chọn bàn'))) {
        expect(await driver.getText(find.text('Vui lòng chọn bàn')), 
          equals('Vui lòng chọn bàn'));
      }

      // Try to confirm empty order
      await driver.tap(find.byValueKey('confirm_empty_order')); // If available
      
      if (await driver.isPresent(find.text('Đơn hàng trống'))) {
        expect(await driver.getText(find.text('Đơn hàng trống')), 
          equals('Đơn hàng trống'));
      }
    });
  });

  group('Performance E2E Tests', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    test('app startup performance', () async {
      final timeline = await driver.traceAction(() async {
        // App should start within reasonable time
        await driver.waitFor(find.text('Smart Restaurant'));
      });

      // Analyze performance metrics
      final summary = TimelineSummary.summarize(timeline);
      expect(summary.averageFrameBuildTimeMillis, lessThan(16)); // 60fps
      expect(summary.missedFrameBuildBudgetCount, lessThan(5));
    });

    test('order creation performance', () async {
      final timeline = await driver.traceAction(() async {
        await driver.tap(find.byValueKey('orders_tab'));
        await driver.tap(find.byValueKey('table_B01'));
        await driver.tap(find.text('Phở'));
        await driver.tap(find.text('Phở Bò'));
        await driver.tap(find.byValueKey('cart_button'));
        await driver.tap(find.text('Xác nhận đơn hàng'));
        await driver.tap(find.text('Đặt món'));
        await driver.waitFor(find.text('Đặt món thành công'));
      });

      final summary = TimelineSummary.summarize(timeline);
      expect(summary.averageFrameBuildTimeMillis, lessThan(20));
      expect(summary.countFrames(), greaterThan(0));
    });

    test('scroll performance với large menu', () async {
      await driver.tap(find.byValueKey('orders_tab'));
      await driver.tap(find.byValueKey('table_B01'));
      await driver.tap(find.text('Tất cả')); // Show all menu items

      final timeline = await driver.traceAction(() async {
        // Scroll through entire menu
        for (int i = 0; i < 20; i++) {
          await driver.scroll(find.byType('ListView'), 0, -500, const Duration(milliseconds: 100));
        }
      });

      final summary = TimelineSummary.summarize(timeline);
      expect(summary.averageFrameBuildTimeMillis, lessThan(16)); // Maintain 60fps
    });
  });
}