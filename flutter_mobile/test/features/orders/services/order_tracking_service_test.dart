import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:smart_restaurant/features/orders/services/order_tracking_service.dart';
import 'package:smart_restaurant/features/orders/models/order_models.dart';

@GenerateMocks([])
void main() {
  group('OrderTrackingService Tests', () {
    late OrderTrackingService trackingService;

    setUp(() {
      trackingService = OrderTrackingService();
    });

    tearDown(() {
      trackingService.dispose();
    });

    test('WebSocket connection establishment', () async {
      // Act
      await trackingService.connect('ws://localhost:8080/orders');

      // Assert
      expect(trackingService.isConnected, isTrue);
      expect(trackingService.connectionStatus, equals(ConnectionStatus.connected));
    });

    test('connection retry mechanism hoạt động', () async {
      // Arrange - Simulate connection failure
      var connectionAttempts = 0;

      // Act - Try to connect to invalid endpoint
      try {
        await trackingService.connect('ws://invalid-host:9999/orders');
      } catch (e) {
        // Expected to fail
      }

      // Should attempt to reconnect
      await Future.delayed(const Duration(seconds: 2));
      
      expect(trackingService.connectionStatus, equals(ConnectionStatus.reconnecting));
    });

    test('receive order status updates', () async {
      // Arrange
      OrderStatusUpdate? receivedUpdate;
      
      trackingService.orderUpdates.listen((update) {
        receivedUpdate = update;
      });

      await trackingService.connect('ws://localhost:8080/orders');

      // Simulate incoming message
      const testUpdate = OrderStatusUpdate(
        orderId: 'order-123',
        status: OrderStatus.preparing,
        updatedAt: '2024-01-15T10:30:00Z',
        estimatedReadyTime: '2024-01-15T11:00:00Z',
        notes: 'Đang chuẩn bị món ăn',
      );

      // Act - Simulate WebSocket message
      trackingService.handleIncomingMessage({
        'type': 'order_status_update',
        'data': testUpdate.toJson(),
      });

      // Assert
      expect(receivedUpdate, isNotNull);
      expect(receivedUpdate!.orderId, equals('order-123'));
      expect(receivedUpdate!.status, equals(OrderStatus.preparing));
      expect(receivedUpdate!.notes, equals('Đang chuẩn bị món ăn'));
    });

    test('heartbeat mechanism maintains connection', () async {
      // Arrange
      await trackingService.connect('ws://localhost:8080/orders');
      expect(trackingService.isConnected, isTrue);

      var heartbeatCount = 0;
      trackingService.heartbeatStream.listen((_) {
        heartbeatCount++;
      });

      // Act - Wait for heartbeats
      await Future.delayed(const Duration(seconds: 6));

      // Assert - Should have sent heartbeats
      expect(heartbeatCount, greaterThan(1));
    });

    test('connection loss detection và auto-reconnect', () async {
      // Arrange
      await trackingService.connect('ws://localhost:8080/orders');
      expect(trackingService.isConnected, isTrue);

      var connectionLost = false;
      var reconnected = false;

      trackingService.connectionStatusStream.listen((status) {
        if (status == ConnectionStatus.disconnected) {
          connectionLost = true;
        } else if (status == ConnectionStatus.connected && connectionLost) {
          reconnected = true;
        }
      });

      // Act - Simulate connection loss
      trackingService.simulateConnectionLoss();
      await Future.delayed(const Duration(seconds: 1));

      // Assert
      expect(connectionLost, isTrue);
      expect(trackingService.connectionStatus, equals(ConnectionStatus.reconnecting));

      // Wait for auto-reconnect
      await Future.delayed(const Duration(seconds: 3));
      expect(reconnected, isTrue);
    });

    test('kitchen notifications được xử lý đúng', () async {
      // Arrange
      KitchenNotification? receivedNotification;
      
      trackingService.kitchenNotifications.listen((notification) {
        receivedNotification = notification;
      });

      await trackingService.connect('ws://localhost:8080/orders');

      // Act - Simulate kitchen notification
      trackingService.handleIncomingMessage({
        'type': 'kitchen_notification',
        'data': {
          'orderId': 'order-456',
          'message': 'Món Phở Bò bàn 5 đã sẵn sàng',
          'priority': 'high',
          'timestamp': DateTime.now().toIso8601String(),
        }
      });

      // Assert
      expect(receivedNotification, isNotNull);
      expect(receivedNotification!.orderId, equals('order-456'));
      expect(receivedNotification!.message, contains('Phở Bò'));
      expect(receivedNotification!.priority, equals(NotificationPriority.high));
    });

    test('order item status updates', () async {
      // Arrange
      OrderItemStatusUpdate? receivedUpdate;
      
      trackingService.orderItemUpdates.listen((update) {
        receivedUpdate = update;
      });

      await trackingService.connect('ws://localhost:8080/orders');

      // Act
      trackingService.handleIncomingMessage({
        'type': 'order_item_status_update',
        'data': {
          'orderId': 'order-789',
          'orderItemId': 'item-123',
          'status': 'ready',
          'notes': 'Món đã hoàn thành',
          'updatedBy': 'chef-001',
        }
      });

      // Assert
      expect(receivedUpdate, isNotNull);
      expect(receivedUpdate!.orderId, equals('order-789'));
      expect(receivedUpdate!.status, equals(OrderItemStatus.ready));
    });

    test('subscribe to specific order tracking', () async {
      // Arrange
      await trackingService.connect('ws://localhost:8080/orders');
      const orderId = 'order-specific';

      // Act
      await trackingService.subscribeToOrder(orderId);

      // Assert - Should send subscription message
      expect(trackingService.subscribedOrders.contains(orderId), isTrue);
    });

    test('unsubscribe from order tracking', () async {
      // Arrange
      await trackingService.connect('ws://localhost:8080/orders');
      const orderId = 'order-unsub';
      
      await trackingService.subscribeToOrder(orderId);
      expect(trackingService.subscribedOrders.contains(orderId), isTrue);

      // Act
      await trackingService.unsubscribeFromOrder(orderId);

      // Assert
      expect(trackingService.subscribedOrders.contains(orderId), isFalse);
    });

    test('connection statistics tracking', () async {
      // Arrange
      await trackingService.connect('ws://localhost:8080/orders');

      // Act - Simulate some activity
      trackingService.handleIncomingMessage({'type': 'ping'});
      trackingService.handleIncomingMessage({'type': 'order_update', 'data': {}});
      
      await Future.delayed(const Duration(seconds: 1));

      // Assert
      final stats = trackingService.getConnectionStats();
      expect(stats.messagesReceived, greaterThanOrEqualTo(2));
      expect(stats.uptime, greaterThan(Duration.zero));
      expect(stats.lastHeartbeat, isNotNull);
    });

    test('error handling cho malformed messages', () async {
      // Arrange
      var errorCount = 0;
      trackingService.errors.listen((error) {
        errorCount++;
      });

      await trackingService.connect('ws://localhost:8080/orders');

      // Act - Send malformed message
      trackingService.handleIncomingMessage({'invalid': 'data'});
      trackingService.handleIncomingMessage('not-json');
      trackingService.handleIncomingMessage(null);

      // Assert - Should handle errors gracefully
      expect(errorCount, greaterThan(0));
      expect(trackingService.isConnected, isTrue); // Connection should remain stable
    });

    test('Vietnamese message formatting', () {
      // Act
      final message = trackingService.formatVietnameseMessage(
        OrderStatus.preparing,
        'Phở Bò',
        'B05',
      );

      // Assert
      expect(message, contains('Phở Bò'));
      expect(message, contains('bàn B05'));
      expect(message, contains('đang chuẩn bị'));
    });

    test('priority message queue', () async {
      // Arrange
      await trackingService.connect('ws://localhost:8080/orders');

      // Act - Send high priority message
      trackingService.sendPriorityMessage({
        'type': 'urgent_order',
        'orderId': 'urgent-001',
        'priority': 'high',
      });

      // Should be sent immediately despite queue
      expect(trackingService.priorityMessagesSent, greaterThan(0));
    });

    test('batch message processing', () async {
      // Arrange
      await trackingService.connect('ws://localhost:8080/orders');
      var processedCount = 0;

      trackingService.orderUpdates.listen((_) {
        processedCount++;
      });

      // Act - Send multiple messages quickly
      for (int i = 0; i < 5; i++) {
        trackingService.handleIncomingMessage({
          'type': 'order_status_update',
          'data': {
            'orderId': 'batch-$i',
            'status': 'confirmed',
            'updatedAt': DateTime.now().toIso8601String(),
          }
        });
      }

      await Future.delayed(const Duration(milliseconds: 500));

      // Assert - All messages should be processed
      expect(processedCount, equals(5));
    });

    test('cleanup resources on dispose', () async {
      // Arrange
      await trackingService.connect('ws://localhost:8080/orders');
      await trackingService.subscribeToOrder('order-cleanup');
      
      expect(trackingService.isConnected, isTrue);
      expect(trackingService.subscribedOrders.isNotEmpty, isTrue);

      // Act
      trackingService.dispose();

      // Assert
      expect(trackingService.isConnected, isFalse);
      expect(trackingService.subscribedOrders.isEmpty, isTrue);
    });
  });

  group('OrderTrackingService Vietnamese Scenarios', () {
    late OrderTrackingService trackingService;

    setUp(() {
      trackingService = OrderTrackingService();
    });

    tearDown(() {
      trackingService.dispose();
    });

    test('Vietnamese order status translations', () {
      // Test Vietnamese status mapping
      expect(trackingService.getVietnameseStatus(OrderStatus.pending), 
        equals('Chờ xác nhận'));
      expect(trackingService.getVietnameseStatus(OrderStatus.confirmed), 
        equals('Đã xác nhận'));
      expect(trackingService.getVietnameseStatus(OrderStatus.preparing), 
        equals('Đang chuẩn bị'));
      expect(trackingService.getVietnameseStatus(OrderStatus.ready), 
        equals('Sẵn sàng'));
      expect(trackingService.getVietnameseStatus(OrderStatus.served), 
        equals('Đã phục vụ'));
    });

    test('Vietnamese time formatting', () {
      final now = DateTime(2024, 1, 15, 14, 30, 0);
      final formatted = trackingService.formatVietnameseTime(now);
      
      expect(formatted, equals('14:30 - 15/01/2024'));
    });

    test('kitchen area Vietnamese notifications', () async {
      // Arrange
      var notifications = <KitchenNotification>[];
      trackingService.kitchenNotifications.listen((notification) {
        notifications.add(notification);
      });

      await trackingService.connect('ws://localhost:8080/orders');

      // Act - Simulate different kitchen areas
      trackingService.handleIncomingMessage({
        'type': 'kitchen_notification',
        'data': {
          'orderId': 'order-pho',
          'message': 'Bàn 3: Phở Bò Tái x2 - Ít muối',
          'kitchenArea': 'pho_station',
          'priority': 'normal',
          'timestamp': DateTime.now().toIso8601String(),
        }
      });

      trackingService.handleIncomingMessage({
        'type': 'kitchen_notification', 
        'data': {
          'orderId': 'order-grill',
          'message': 'Bàn 7: Cơm Tấm Sườn Nướng x1',
          'kitchenArea': 'grill_station',
          'priority': 'high',
          'timestamp': DateTime.now().toIso8601String(),
        }
      });

      // Assert
      expect(notifications.length, equals(2));
      expect(notifications[0].message, contains('Phở Bò Tái'));
      expect(notifications[1].message, contains('Cơm Tấm'));
      expect(notifications[1].priority, equals(NotificationPriority.high));
    });

    test('Vietnamese voice commands processing', () {
      // Test voice command recognition
      final commands = [
        'Bàn năm món phở bò',
        'Cập nhật đơn hàng số một hai ba',
        'Kiểm tra tình trạng bàn hai',
        'Hủy đơn hàng bàn ba',
      ];

      for (final command in commands) {
        final parsed = trackingService.parseVietnameseVoiceCommand(command);
        expect(parsed, isNotNull);
        expect(parsed!.action, isNotEmpty);
        expect(parsed.targetId, isNotEmpty);
      }
    });
  });

  group('OrderTrackingService Performance Tests', () {
    late OrderTrackingService trackingService;

    setUp(() {
      trackingService = OrderTrackingService();
    });

    tearDown(() {
      trackingService.dispose();
    });

    test('high frequency updates không block UI', () async {
      // Arrange
      await trackingService.connect('ws://localhost:8080/orders');
      
      var updateCount = 0;
      trackingService.orderUpdates.listen((_) {
        updateCount++;
      });

      final stopwatch = Stopwatch()..start();

      // Act - Send many updates quickly
      for (int i = 0; i < 100; i++) {
        trackingService.handleIncomingMessage({
          'type': 'order_status_update',
          'data': {
            'orderId': 'high-freq-$i',
            'status': 'confirmed',
            'updatedAt': DateTime.now().toIso8601String(),
          }
        });
      }

      await Future.delayed(const Duration(milliseconds: 100));
      stopwatch.stop();

      // Assert - Should process quickly
      expect(updateCount, equals(100));
      expect(stopwatch.elapsedMilliseconds, lessThan(500)); // Should be fast
    });

    test('memory usage với long-running connection', () async {
      // Arrange
      await trackingService.connect('ws://localhost:8080/orders');

      // Act - Simulate long-running session with many updates
      for (int i = 0; i < 1000; i++) {
        trackingService.handleIncomingMessage({
          'type': 'order_status_update',
          'data': {
            'orderId': 'memory-test-$i',
            'status': 'preparing',
            'updatedAt': DateTime.now().toIso8601String(),
          }
        });
      }

      // Assert - Should not accumulate excessive data
      expect(trackingService.recentUpdates.length, lessThanOrEqualTo(50)); // Should limit history
    });

    test('concurrent connections handling', () async {
      // Arrange
      final service1 = OrderTrackingService();
      final service2 = OrderTrackingService();
      final service3 = OrderTrackingService();

      // Act - Connect multiple instances
      await Future.wait([
        service1.connect('ws://localhost:8080/orders'),
        service2.connect('ws://localhost:8080/orders'),
        service3.connect('ws://localhost:8080/orders'),
      ]);

      // Assert - All should be connected
      expect(service1.isConnected, isTrue);
      expect(service2.isConnected, isTrue);
      expect(service3.isConnected, isTrue);

      // Cleanup
      service1.dispose();
      service2.dispose();
      service3.dispose();
    });

    test('message ordering với timestamps', () async {
      // Arrange
      final receivedUpdates = <OrderStatusUpdate>[];
      
      trackingService.orderUpdates.listen((update) {
        receivedUpdates.add(update);
      });

      await trackingService.connect('ws://localhost:8080/orders');

      // Act - Send updates with different timestamps
      final baseTime = DateTime.now();
      
      // Send newer message first
      trackingService.handleIncomingMessage({
        'type': 'order_status_update',
        'data': {
          'orderId': 'timing-test',
          'status': 'ready',
          'updatedAt': baseTime.add(const Duration(minutes: 2)).toIso8601String(),
        }
      });

      // Send older message
      trackingService.handleIncomingMessage({
        'type': 'order_status_update',
        'data': {
          'orderId': 'timing-test',
          'status': 'preparing',
          'updatedAt': baseTime.toIso8601String(),
        }
      });

      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Should ignore older message
      expect(receivedUpdates.length, equals(1));
      expect(receivedUpdates[0].status, equals(OrderStatus.ready));
    });
  });
}