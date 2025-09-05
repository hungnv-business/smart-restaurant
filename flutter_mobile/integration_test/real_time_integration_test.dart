import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:smart_restaurant/main.dart' as app;
import 'package:smart_restaurant/features/orders/services/order_tracking_service.dart';
import 'package:smart_restaurant/features/orders/models/order_models.dart';
import 'dart:convert';
import 'dart:async';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Real-time Integration Tests', () {
    late OrderTrackingService trackingService;
    late WebSocketChannel mockWebSocket;

    setUp(() async {
      trackingService = OrderTrackingService();
    });

    tearDown(() async {
      await trackingService.dispose();
      await mockWebSocket.sink.close();
    });

    testWidgets('WebSocket connection và order status updates', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Setup WebSocket mock để simulate server messages
      await tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/websocket',
        (ByteData? message) async {
          // Mock WebSocket connection success
          return const StandardMethodCodec().encodeSuccessEnvelope(true);
        },
      );

      // Navigate to order tracking
      await tester.tap(find.byIcon(Icons.track_changes));
      await tester.pumpAndSettle();

      // Should connect to WebSocket
      expect(find.byIcon(Icons.wifi), findsOneWidget); // Connected indicator

      // Simulate incoming order status update
      final testUpdate = OrderStatusUpdate(
        orderId: 'test-order-123',
        status: OrderStatus.preparing,
        updatedAt: DateTime.now().toIso8601String(),
        notes: 'Đầu bếp đã nhận đơn',
      );

      // Simulate WebSocket message
      trackingService.handleIncomingMessage({
        'type': 'order_status_update',
        'data': testUpdate.toJson(),
      });

      await tester.pump();

      // Should show updated status
      expect(find.text('Đang chuẩn bị'), findsOneWidget);
      expect(find.text('Đầu bếp đã nhận đơn'), findsOneWidget);
    });

    testWidgets('Kitchen notifications real-time flow', (tester) async {
      // Launch app và navigate to kitchen screen
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.kitchen));
      await tester.pumpAndSettle();

      // Should show kitchen dashboard
      expect(find.text('Bếp'), findsOneWidget);

      // Simulate kitchen notification
      final kitchenNotification = KitchenNotification(
        orderId: 'kitchen-test-456',
        message: 'Bàn 5: Phở Bò x2 - Ít muối, không hành',
        priority: NotificationPriority.high,
        kitchenArea: 'pho_station',
        timestamp: DateTime.now(),
      );

      trackingService.handleIncomingMessage({
        'type': 'kitchen_notification',
        'data': kitchenNotification.toJson(),
      });

      await tester.pump();

      // Should show notification
      expect(find.text('Bàn 5: Phở Bò x2'), findsOneWidget);
      expect(find.text('Ít muối, không hành'), findsOneWidget);
      expect(find.byIcon(Icons.priority_high), findsOneWidget);
    });

    testWidgets('Auto-reconnection khi mất kết nối', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.track_changes));
      await tester.pumpAndSettle();

      // Initially connected
      expect(find.byIcon(Icons.wifi), findsOneWidget);

      // Simulate connection loss
      await tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/websocket',
        (ByteData? message) async {
          throw PlatformException(code: 'WEBSOCKET_ERROR', message: 'Connection lost');
        },
      );

      // Trigger connection check
      trackingService.simulateConnectionLoss();
      await tester.pump();

      // Should show disconnected state
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('Mất kết nối'), findsOneWidget);
      expect(find.text('Đang kết nối lại...'), findsOneWidget);

      // Simulate successful reconnection
      await tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/websocket',
        (ByteData? message) async {
          return const StandardMethodCodec().encodeSuccessEnvelope(true);
        },
      );

      // Wait for auto-reconnection
      await tester.pump(const Duration(seconds: 3));

      // Should be connected again
      expect(find.byIcon(Icons.wifi), findsOneWidget);
      expect(find.text('Đã kết nối'), findsOneWidget);
    });

    testWidgets('Multiple order updates trong cùng session', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.track_changes));
      await tester.pumpAndSettle();

      // Simulate multiple rapid updates
      final updates = [
        OrderStatusUpdate(
          orderId: 'multi-order-1',
          status: OrderStatus.confirmed,
          updatedAt: DateTime.now().toIso8601String(),
          notes: 'Order 1 confirmed',
        ),
        OrderStatusUpdate(
          orderId: 'multi-order-2',
          status: OrderStatus.preparing,
          updatedAt: DateTime.now().add(const Duration(seconds: 1)).toIso8601String(),
          notes: 'Order 2 preparing',
        ),
        OrderStatusUpdate(
          orderId: 'multi-order-3',
          status: OrderStatus.ready,
          updatedAt: DateTime.now().add(const Duration(seconds: 2)).toIso8601String(),
          notes: 'Order 3 ready',
        ),
      ];

      // Send updates rapidly
      for (final update in updates) {
        trackingService.handleIncomingMessage({
          'type': 'order_status_update',
          'data': update.toJson(),
        });
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pump();

      // Should handle all updates correctly
      expect(find.text('Order 1 confirmed'), findsOneWidget);
      expect(find.text('Order 2 preparing'), findsOneWidget);
      expect(find.text('Order 3 ready'), findsOneWidget);
    });

    testWidgets('Ingredient alerts real-time integration', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to management dashboard (if exists)
      await tester.tap(find.byIcon(Icons.dashboard));
      await tester.pumpAndSettle();

      // Simulate ingredient low stock alert
      trackingService.handleIncomingMessage({
        'type': 'ingredient_alert',
        'data': {
          'ingredientName': 'Thịt bò',
          'currentStock': 2,
          'minimumStock': 5,
          'unit': 'kg',
          'severity': 'high',
          'message': 'Thịt bò sắp hết, cần nhập thêm ngay',
        }
      });

      await tester.pump();

      // Should show ingredient alert
      expect(find.text('Cảnh báo nguyên liệu'), findsOneWidget);
      expect(find.text('Thịt bò sắp hết'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('Real-time order queue management', (tester) async {
      // Launch app và navigate to kitchen
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.kitchen));
      await tester.pumpAndSettle();

      // Simulate new order arriving
      trackingService.handleIncomingMessage({
        'type': 'new_order',
        'data': {
          'orderId': 'queue-order-789',
          'tableNumber': 'B07',
          'items': [
            {
              'menuItemName': 'Phở Bò Viên',
              'quantity': 1,
              'notes': 'Không hành'
            },
            {
              'menuItemName': 'Trà Đá',
              'quantity': 2,
              'notes': ''
            }
          ],
          'priority': 'normal',
          'estimatedTime': 20,
        }
      });

      await tester.pump();

      // Should add to kitchen queue
      expect(find.text('B07'), findsOneWidget);
      expect(find.text('Phở Bò Viên'), findsOneWidget);
      expect(find.text('Trà Đá x2'), findsOneWidget);
      expect(find.text('~20 phút'), findsOneWidget);

      // Mark item as ready
      await tester.tap(find.byKey(const ValueKey('mark_ready_pho_bo_vien')));
      await tester.pump();

      // Should update order status
      expect(find.text('Sẵn sàng'), findsOneWidget);
    });

    testWidgets('Vietnamese voice command integration', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.restaurant_menu));
      await tester.pumpAndSettle();

      // Select table
      final availableTable = find.byKey(const ValueKey('table_available')).first;
      await tester.tap(availableTable);
      await tester.pumpAndSettle();

      // Use voice search
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      // Simulate speech recognition result
      await tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'plugins.flutter.io/speech_to_text',
        (ByteData? message) async {
          return const StandardMethodCodec().encodeSuccessEnvelope({
            'recognizedWords': 'hai phở bò tái',
            'confidence': 0.95,
            'finalResult': true,
          });
        },
      );

      await tester.pump(const Duration(seconds: 2));

      // Should parse Vietnamese voice command
      // "hai phở bò tái" = 2 Phở Bò Tái
      expect(find.text('Phở Bò Tái'), findsOneWidget);
      
      // Should auto-add to cart with quantity 2
      expect(find.text('2'), findsOneWidget); // Cart badge
    });

    testWidgets('Offline queue sync khi reconnect', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Set offline mode
      await tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/connectivity',
        (ByteData? message) async {
          return const StandardMethodCodec().encodeSuccessEnvelope(['none']);
        },
      );

      await tester.tap(find.byIcon(Icons.restaurant_menu));
      await tester.pumpAndSettle();

      // Create order offline
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

      // Should be queued offline
      expect(find.text('Đơn hàng đã được lưu'), findsOneWidget);
      expect(find.text('Sẽ gửi khi có kết nối'), findsOneWidget);

      // Go online
      await tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/connectivity',
        (ByteData? message) async {
          return const StandardMethodCodec().encodeSuccessEnvelope(['wifi']);
        },
      );

      await tester.pump(const Duration(seconds: 2));

      // Should sync queued orders
      expect(find.text('Đang đồng bộ...'), findsOneWidget);
      
      await tester.pump(const Duration(seconds: 3));
      
      expect(find.text('Đồng bộ thành công'), findsOneWidget);
    });

    testWidgets('Concurrent operations không conflict', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Simulate multiple concurrent operations
      final futures = <Future>[];

      // Operation 1: Create order
      futures.add(Future(() async {
        await tester.tap(find.byIcon(Icons.restaurant_menu));
        await tester.pumpAndSettle();
        
        final table1 = find.byKey(const ValueKey('table_B01'));
        await tester.tap(table1);
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Phở Bò'));
        await tester.pumpAndSettle();
      }));

      // Operation 2: Check order status
      futures.add(Future(() async {
        await tester.tap(find.byIcon(Icons.track_changes));
        await tester.pumpAndSettle();
        
        // Should load existing orders
        expect(find.byType(ListView), findsOneWidget);
      }));

      // Operation 3: Receive real-time updates
      futures.add(Future(() async {
        final statusUpdate = OrderStatusUpdate(
          orderId: 'concurrent-test',
          status: OrderStatus.ready,
          updatedAt: DateTime.now().toIso8601String(),
          notes: 'Concurrent update test',
        );

        trackingService.handleIncomingMessage({
          'type': 'order_status_update',
          'data': statusUpdate.toJson(),
        });

        await tester.pump();
      }));

      // Wait for all operations
      await Future.wait(futures);

      // App should remain stable
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Performance với high frequency updates', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.track_changes));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Send 100 rapid updates
      for (int i = 0; i < 100; i++) {
        final update = OrderStatusUpdate(
          orderId: 'perf-test-$i',
          status: OrderStatus.values[i % OrderStatus.values.length],
          updatedAt: DateTime.now().add(Duration(milliseconds: i)).toIso8601String(),
          notes: 'Performance test update $i',
        );

        trackingService.handleIncomingMessage({
          'type': 'order_status_update',
          'data': update.toJson(),
        });

        if (i % 10 == 0) {
          await tester.pump(const Duration(milliseconds: 1));
        }
      }

      stopwatch.stop();

      // Should process quickly without blocking UI
      expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // Under 5 seconds
      expect(find.byType(ListView), findsOneWidget); // UI still responsive
    });

    testWidgets('WebSocket message ordering với timestamps', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.track_changes));
      await tester.pumpAndSettle();

      final baseTime = DateTime.now();

      // Send out-of-order messages
      final newerUpdate = OrderStatusUpdate(
        orderId: 'ordering-test',
        status: OrderStatus.ready,
        updatedAt: baseTime.add(const Duration(minutes: 5)).toIso8601String(),
        notes: 'Newer update',
      );

      final olderUpdate = OrderStatusUpdate(
        orderId: 'ordering-test',
        status: OrderStatus.preparing,
        updatedAt: baseTime.toIso8601String(),
        notes: 'Older update',
      );

      // Send newer first
      trackingService.handleIncomingMessage({
        'type': 'order_status_update',
        'data': newerUpdate.toJson(),
      });

      await tester.pump();

      // Should show newer status
      expect(find.text('Sẵn sàng'), findsOneWidget);
      expect(find.text('Newer update'), findsOneWidget);

      // Send older update
      trackingService.handleIncomingMessage({
        'type': 'order_status_update', 
        'data': olderUpdate.toJson(),
      });

      await tester.pump();

      // Should ignore older update
      expect(find.text('Sẵn sàng'), findsOneWidget); // Still newer status
      expect(find.text('Newer update'), findsOneWidget);
      expect(find.text('Older update'), findsNothing);
    });

    testWidgets('Error handling cho malformed WebSocket messages', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.track_changes));
      await tester.pumpAndSettle();

      var errorHandled = false;
      
      // Listen for errors
      trackingService.errors.listen((error) {
        errorHandled = true;
      });

      // Send malformed messages
      trackingService.handleIncomingMessage({'invalid': 'structure'});
      trackingService.handleIncomingMessage('not-json');
      trackingService.handleIncomingMessage(null);

      await tester.pump();

      // Should handle errors gracefully
      expect(errorHandled, isTrue);
      expect(find.byIcon(Icons.wifi), findsOneWidget); // Still connected
    });

    testWidgets('Vietnamese text trong real-time messages', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.track_changes));
      await tester.pumpAndSettle();

      // Send Vietnamese messages
      final vietnameseUpdate = OrderStatusUpdate(
        orderId: 'vietnamese-test',
        status: OrderStatus.preparing,
        updatedAt: DateTime.now().toIso8601String(),
        notes: 'Đầu bếp đang nấu phở bò tái nạm với rau thơm và hành lá',
      );

      trackingService.handleIncomingMessage({
        'type': 'order_status_update',
        'data': vietnameseUpdate.toJson(),
      });

      await tester.pump();

      // Should display Vietnamese correctly
      expect(find.text('Đầu bếp đang nấu phở bò tái nạm'), findsOneWidget);
      expect(find.text('với rau thơm và hành lá'), findsOneWidget);
    });

    testWidgets('Table management real-time sync', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.restaurant_menu));
      await tester.pumpAndSettle();

      // Should show table grid
      expect(find.byType(GridView), findsOneWidget);

      // Simulate table status change from another device
      trackingService.handleIncomingMessage({
        'type': 'table_status_update',
        'data': {
          'tableId': 'table-b05',
          'tableNumber': 'B05',
          'status': 'occupied',
          'occupiedSince': DateTime.now().toIso8601String(),
          'currentOrderId': 'order-from-other-device',
        }
      });

      await tester.pump();

      // Table B05 should show as occupied
      final tableB05 = find.text('B05');
      expect(tableB05, findsOneWidget);
      expect(find.text('Có khách'), findsOneWidget);
    });

    testWidgets('Kitchen area coordination real-time', (tester) async {
      // Launch app và go to kitchen
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.kitchen));
      await tester.pumpAndSettle();

      // Simulate orders for different kitchen areas
      final notifications = [
        {
          'type': 'kitchen_notification',
          'data': {
            'orderId': 'area-test-1',
            'message': 'Bàn 3: Phở Bò x1',
            'kitchenArea': 'pho_station',
            'priority': 'normal',
            'timestamp': DateTime.now().toIso8601String(),
          }
        },
        {
          'type': 'kitchen_notification',
          'data': {
            'orderId': 'area-test-2',
            'message': 'Bàn 7: Sườn Nướng x2',
            'kitchenArea': 'grill_station',
            'priority': 'high',
            'timestamp': DateTime.now().toIso8601String(),
          }
        },
      ];

      for (final notification in notifications) {
        trackingService.handleIncomingMessage(notification);
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should show orders organized by kitchen area
      expect(find.text('Khu vực Phở'), findsOneWidget);
      expect(find.text('Khu vực Nướng'), findsOneWidget);
      expect(find.text('Phở Bò x1'), findsOneWidget);
      expect(find.text('Sướn Nướng x2'), findsOneWidget);

      // High priority should be highlighted
      expect(find.byIcon(Icons.priority_high), findsOneWidget);
    });

    testWidgets('Connection statistics tracking', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.track_changes));
      await tester.pumpAndSettle();

      // Send some messages để generate stats
      for (int i = 0; i < 10; i++) {
        trackingService.handleIncomingMessage({
          'type': 'ping',
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      await tester.pump();

      // Tap to view connection stats (if available)
      if (find.byIcon(Icons.info).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.info));
        await tester.pump();

        // Should show connection statistics
        expect(find.textContaining('tin nhắn'), findsAtLeastNWidgets(1));
        expect(find.textContaining('kết nối'), findsAtLeastNWidgets(1));
      }
    });

    testWidgets('Real-time notification preferences', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Go to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Configure notification preferences
      await tester.tap(find.text('Thông báo'));
      await tester.pumpAndSettle();

      // Turn on sound notifications
      final soundToggle = find.byKey(const ValueKey('sound_notifications'));
      await tester.tap(soundToggle);
      await tester.pump();

      // Turn on vibration
      final vibrationToggle = find.byKey(const ValueKey('vibration_notifications'));
      await tester.tap(vibrationToggle);
      await tester.pump();

      // Go back to tracking
      await tester.tap(find.byIcon(Icons.track_changes));
      await tester.pumpAndSettle();

      // Simulate urgent notification
      trackingService.handleIncomingMessage({
        'type': 'urgent_notification',
        'data': {
          'message': 'Đơn hàng khẩn cấp cần xử lý ngay',
          'priority': 'urgent',
          'orderId': 'urgent-test',
        }
      });

      await tester.pump();

      // Should show notification with sound/vibration indicators
      expect(find.text('KHẨN CẤP'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
      expect(find.byIcon(Icons.vibration), findsOneWidget);
    });
  });

  group('Network Resilience Tests', () {
    testWidgets('Graceful degradation khi WebSocket unavailable', (tester) async {
      // Launch app với WebSocket không available
      await tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/websocket',
        (ByteData? message) async {
          throw PlatformException(code: 'UNAVAILABLE', message: 'WebSocket not available');
        },
      );

      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.track_changes));
      await tester.pumpAndSettle();

      // Should show fallback mode
      expect(find.text('Chế độ thường'), findsOneWidget);
      expect(find.text('Cập nhật thủ công'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);

      // Manual refresh should still work
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Should refresh data via REST API
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Retry mechanism cho failed connections', (tester) async {
      var connectionAttempts = 0;
      
      await tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/websocket',
        (ByteData? message) async {
          connectionAttempts++;
          
          if (connectionAttempts < 3) {
            throw PlatformException(code: 'CONNECTION_FAILED', message: 'Connection failed');
          }
          
          return const StandardMethodCodec().encodeSuccessEnvelope(true);
        },
      );

      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.track_changes));
      await tester.pumpAndSettle();

      // Should show retry attempts
      expect(find.text('Đang thử kết nối lại...'), findsOneWidget);

      // Wait for retries
      await tester.pump(const Duration(seconds: 5));

      // Should eventually connect
      expect(find.byIcon(Icons.wifi), findsOneWidget);
    });
  });

  group('Multi-user Scenarios', () {
    testWidgets('Multiple waiters receiving different notifications', (tester) async {
      // This test simulates multiple waiter sessions
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.track_changes));
      await tester.pumpAndSettle();

      // Simulate waiter-specific notification
      trackingService.handleIncomingMessage({
        'type': 'waiter_notification',
        'data': {
          'waiterId': 'waiter-001',
          'message': 'Bàn của bạn: B05 - Món đã sẵn sàng',
          'orderId': 'waiter-order-123',
          'priority': 'normal',
        }
      });

      await tester.pump();

      // Should only show if current user is waiter-001
      if (find.text('Bàn của bạn: B05').evaluate().isNotEmpty) {
        expect(find.text('Món đã sẵn sàng'), findsOneWidget);
      }
    });

    testWidgets('Kitchen coordination giữa multiple chefs', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.kitchen));
      await tester.pumpAndSettle();

      // Simulate different chefs working on different items
      final chefUpdates = [
        {
          'type': 'chef_update',
          'data': {
            'chefId': 'chef-pho',
            'orderId': 'chef-test-1',
            'itemName': 'Phở Bò',
            'status': 'started',
            'estimatedTime': 15,
          }
        },
        {
          'type': 'chef_update',
          'data': {
            'chefId': 'chef-grill',
            'orderId': 'chef-test-2', 
            'itemName': 'Sườn Nướng',
            'status': 'ready',
            'completedTime': DateTime.now().toIso8601String(),
          }
        },
      ];

      for (final update in chefUpdates) {
        trackingService.handleIncomingMessage(update);
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should show different statuses for different items
      expect(find.text('Đang nấu'), findsOneWidget); // Phở
      expect(find.text('Hoàn thành'), findsOneWidget); // Sườn
    });
  });
}