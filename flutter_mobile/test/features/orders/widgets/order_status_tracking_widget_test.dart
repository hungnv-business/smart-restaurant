import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:smart_restaurant/features/orders/widgets/order_status_tracking_widget.dart';
import 'package:smart_restaurant/features/orders/services/order_tracking_service.dart';
import 'package:smart_restaurant/features/orders/models/order_models.dart';

import 'order_status_tracking_widget_test.mocks.dart';

@GenerateMocks([OrderTrackingService])
void main() {
  group('OrderStatusTrackingWidget Tests', () {
    late MockOrderTrackingService mockTrackingService;
    late OrderModel testOrder;

    setUp(() {
      mockTrackingService = MockOrderTrackingService();
      
      testOrder = OrderModel(
        id: 'order-123',
        orderNumber: 'ORD-001',
        tableId: 'table-1',
        status: OrderStatus.preparing,
        items: [
          OrderItemModel(
            id: '1',
            menuItemId: '1',
            menuItemName: 'Phở Bò',
            unitPrice: 65000,
            quantity: 2,
            notes: '',
            status: OrderItemStatus.preparing,
          ),
        ],
        totalAmount: 130000,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      );

      when(mockTrackingService.isConnected).thenReturn(true);
      when(mockTrackingService.connectionStatus).thenReturn(ConnectionStatus.connected);
    });

    Widget createWidget() {
      return MaterialApp(
        home: OrderStatusTrackingWidget(
          order: testOrder,
          trackingService: mockTrackingService,
        ),
      );
    }

    testWidgets('hiển thị order information đúng', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Assert
      expect(find.text('ORD-001'), findsOneWidget);
      expect(find.text('Bàn: table-1'), findsOneWidget);
      expect(find.text('130,000₫'), findsOneWidget);
      expect(find.text('Đang chuẩn bị'), findsOneWidget);
    });

    testWidgets('hiển thị status timeline đúng', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Assert - Timeline steps
      expect(find.text('Đã đặt'), findsOneWidget);
      expect(find.text('Đã xác nhận'), findsOneWidget);
      expect(find.text('Đang chuẩn bị'), findsOneWidget);
      expect(find.text('Sẵn sàng'), findsOneWidget);
      expect(find.text('Đã phục vụ'), findsOneWidget);

      // Current status should be highlighted
      final currentStep = find.byKey(const Key('status_step_preparing'));
      expect(currentStep, findsOneWidget);
    });

    testWidgets('hiển thị estimated time và progress', (tester) async {
      // Arrange
      when(mockTrackingService.getEstimatedReadyTime('order-123'))
        .thenReturn(DateTime.now().add(const Duration(minutes: 20)));

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Assert
      expect(find.text('Ước tính'), findsOneWidget);
      expect(find.textContaining('20'), findsOneWidget); // 20 minutes
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('real-time updates từ WebSocket', (tester) async {
      // Arrange
      final streamController = StreamController<OrderStatusUpdate>();
      when(mockTrackingService.orderUpdates)
        .thenAnswer((_) => streamController.stream);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Simulate status update
      streamController.add(OrderStatusUpdate(
        orderId: 'order-123',
        status: OrderStatus.ready,
        updatedAt: DateTime.now().toIso8601String(),
        estimatedReadyTime: null,
        notes: 'Món đã sẵn sàng',
      ));
      await tester.pump();

      // Assert - Status should update
      expect(find.text('Sẵn sàng'), findsOneWidget);
      expect(find.text('Món đã sẵn sàng'), findsOneWidget);
    });

    testWidgets('individual item status tracking', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Should show item details
      expect(find.text('Phở Bò'), findsOneWidget);
      expect(find.text('x2'), findsOneWidget);
      
      // Item status indicator
      expect(find.byIcon(Icons.hourglass_bottom), findsOneWidget); // Preparing icon
    });

    testWidgets('kitchen area notifications', (tester) async {
      // Arrange
      final notificationController = StreamController<KitchenNotification>();
      when(mockTrackingService.kitchenNotifications)
        .thenAnswer((_) => notificationController.stream);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Simulate kitchen notification
      notificationController.add(KitchenNotification(
        orderId: 'order-123',
        message: 'Phở Bò đã hoàn thành',
        priority: NotificationPriority.normal,
        kitchenArea: 'pho_station',
        timestamp: DateTime.now(),
      ));
      await tester.pump();

      // Assert - Should show notification
      expect(find.text('Phở Bò đã hoàn thành'), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('connection status indicator', (tester) async {
      // Test connected state
      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.byIcon(Icons.wifi), findsOneWidget);
      expect(find.text('Đã kết nối'), findsOneWidget);

      // Test disconnected state
      when(mockTrackingService.isConnected).thenReturn(false);
      when(mockTrackingService.connectionStatus).thenReturn(ConnectionStatus.disconnected);

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('Mất kết nối'), findsOneWidget);
    });

    testWidgets('manual refresh hoạt động', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Pull to refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pump();

      // Assert - Should trigger refresh
      verify(mockTrackingService.requestOrderUpdate('order-123')).called(1);
    });

    testWidgets('action buttons hoạt động đúng', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Should show action buttons for current status
      if (testOrder.status == OrderStatus.preparing) {
        expect(find.text('Gọi bếp'), findsOneWidget);
        expect(find.text('Ước tính thời gian'), findsOneWidget);
      }

      // Test call kitchen button
      await tester.tap(find.text('Gọi bếp'));
      await tester.pump();

      // Should show call options
      expect(find.text('Liên hệ bếp'), findsOneWidget);
      expect(find.text('Hỏi tình trạng món'), findsOneWidget);
      expect(find.text('Yêu cầu ưu tiên'), findsOneWidget);
    });

    testWidgets('order history và timeline', (tester) async {
      // Arrange - Order with history
      final orderWithHistory = testOrder.copyWith(
        statusHistory: [
          OrderStatusHistoryItem(
            status: OrderStatus.pending,
            timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
            notes: 'Đơn hàng được tạo',
          ),
          OrderStatusHistoryItem(
            status: OrderStatus.confirmed,
            timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
            notes: 'Đã xác nhận, chuyển xuống bếp',
          ),
          OrderStatusHistoryItem(
            status: OrderStatus.preparing,
            timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
            notes: 'Đang chuẩn bị món ăn',
          ),
        ],
      );

      final widget = MaterialApp(
        home: OrderStatusTrackingWidget(
          order: orderWithHistory,
          trackingService: mockTrackingService,
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pump();

      // Tap to expand history
      await tester.tap(find.text('Xem lịch sử'));
      await tester.pump();

      // Assert - Should show timeline
      expect(find.text('Đơn hàng được tạo'), findsOneWidget);
      expect(find.text('Đã xác nhận, chuyển xuống bếp'), findsOneWidget);
      expect(find.text('Đang chuẩn bị món ăn'), findsOneWidget);

      // Timestamps should be formatted in Vietnamese
      expect(find.textContaining('phút trước'), findsAtLeastNWidgets(1));
    });

    testWidgets('priority indicator hiển thị đúng', (tester) async {
      // Arrange - High priority order
      final priorityOrder = testOrder.copyWith(
        specialRequests: SpecialRequestsModel(
          priority: OrderPriority.high,
          kitchenNotes: 'Khách VIP',
          allergyWarnings: [],
          servingPreferences: '',
        ),
      );

      final widget = MaterialApp(
        home: OrderStatusTrackingWidget(
          order: priorityOrder,
          trackingService: mockTrackingService,
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pump();

      // Assert
      expect(find.text('Ưu tiên cao'), findsOneWidget);
      expect(find.byIcon(Icons.priority_high), findsOneWidget);
      expect(find.text('Khách VIP'), findsOneWidget);
    });

    testWidgets('estimated delivery countdown', (tester) async {
      // Arrange
      final readyTime = DateTime.now().add(const Duration(minutes: 10));
      when(mockTrackingService.getEstimatedReadyTime('order-123'))
        .thenReturn(readyTime);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Should show countdown
      expect(find.textContaining('10'), findsOneWidget);
      expect(find.textContaining('phút'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Simulate time passing
      when(mockTrackingService.getEstimatedReadyTime('order-123'))
        .thenReturn(DateTime.now().add(const Duration(minutes: 5)));

      await tester.pump(const Duration(seconds: 1));

      // Should update countdown
      expect(find.textContaining('5'), findsOneWidget);
    });

    testWidgets('error handling cho connection issues', (tester) async {
      // Arrange - Connection error
      when(mockTrackingService.isConnected).thenReturn(false);
      when(mockTrackingService.connectionStatus).thenReturn(ConnectionStatus.error);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Assert
      expect(find.text('Lỗi kết nối'), findsOneWidget);
      expect(find.text('Không thể cập nhật thời gian thực'), findsOneWidget);
      expect(find.text('Thử kết nối lại'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);

      // Test reconnect button
      await tester.tap(find.text('Thử kết nối lại'));
      await tester.pump();

      verify(mockTrackingService.reconnect()).called(1);
    });

    testWidgets('order completion flow', (tester) async {
      // Arrange - Order ready to serve
      final readyOrder = testOrder.copyWith(status: OrderStatus.ready);
      
      final widget = MaterialApp(
        home: OrderStatusTrackingWidget(
          order: readyOrder,
          trackingService: mockTrackingService,
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pump();

      // Should show serve action
      expect(find.text('Phục vụ khách'), findsOneWidget);
      
      await tester.tap(find.text('Phục vụ khách'));
      await tester.pump();

      // Should show confirmation
      expect(find.text('Xác nhận phục vụ'), findsOneWidget);
      expect(find.text('Đã mang món ra bàn?'), findsOneWidget);

      await tester.tap(find.text('Đã phục vụ'));
      await tester.pump();

      // Should call complete order
      verify(mockTrackingService.markOrderServed('order-123')).called(1);
    });

    testWidgets('special dietary requirements display', (tester) async {
      // Arrange - Order with allergies
      final allergyOrder = testOrder.copyWith(
        specialRequests: SpecialRequestsModel(
          allergyWarnings: ['Không tôm', 'Không đậu phộng'],
          kitchenNotes: 'Khách dị ứng nghiêm trọng',
          priority: OrderPriority.normal,
          servingPreferences: '',
        ),
      );

      final widget = MaterialApp(
        home: OrderStatusTrackingWidget(
          order: allergyOrder,
          trackingService: mockTrackingService,
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pump();

      // Assert
      expect(find.text('Dị ứng'), findsOneWidget);
      expect(find.text('Không tôm'), findsOneWidget);
      expect(find.text('Không đậu phộng'), findsOneWidget);
      expect(find.text('Khách dị ứng nghiêm trọng'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('kitchen area progress tracking', (tester) async {
      // Arrange - Multi-station order
      final multiStationOrder = testOrder.copyWith(
        items: [
          OrderItemModel(
            id: '1',
            menuItemId: '1',
            menuItemName: 'Phở Bò',
            unitPrice: 65000,
            quantity: 1,
            notes: '',
            status: OrderItemStatus.ready,
            kitchenArea: 'pho_station',
          ),
          OrderItemModel(
            id: '2',
            menuItemId: '2', 
            menuItemName: 'Nem Nướng',
            unitPrice: 35000,
            quantity: 2,
            notes: '',
            status: OrderItemStatus.preparing,
            kitchenArea: 'grill_station',
          ),
        ],
      );

      final widget = MaterialApp(
        home: OrderStatusTrackingWidget(
          order: multiStationOrder,
          trackingService: mockTrackingService,
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pump();

      // Assert - Should show progress by kitchen area
      expect(find.text('Khu vực Phở'), findsOneWidget);
      expect(find.text('Khu vực Nướng'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget); // Phở done
      expect(find.byIcon(Icons.hourglass_bottom), findsOneWidget); // Nem preparing
    });

    testWidgets('cancel order action', (tester) async {
      // Arrange - Cancellable order
      final pendingOrder = testOrder.copyWith(status: OrderStatus.pending);
      
      final widget = MaterialApp(
        home: OrderStatusTrackingWidget(
          order: pendingOrder,
          trackingService: mockTrackingService,
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pump();

      // Should show cancel option for pending orders
      final cancelButton = find.text('Hủy đơn');
      expect(cancelButton, findsOneWidget);

      await tester.tap(cancelButton);
      await tester.pump();

      // Should show cancel confirmation
      expect(find.text('Xác nhận hủy đơn'), findsOneWidget);
      expect(find.text('Lý do hủy'), findsOneWidget);

      // Enter cancellation reason
      final reasonField = find.byType(TextField);
      await tester.enterText(reasonField, 'Khách hàng đổi ý');

      await tester.tap(find.text('Xác nhận hủy'));
      await tester.pump();

      // Should call cancel order
      verify(mockTrackingService.cancelOrder('order-123', 'Khách hàng đổi ý')).called(1);
    });

    testWidgets('order modifications cho pending orders', (tester) async {
      // Arrange - Pending order
      final pendingOrder = testOrder.copyWith(status: OrderStatus.pending);
      
      final widget = MaterialApp(
        home: OrderStatusTrackingWidget(
          order: pendingOrder,
          trackingService: mockTrackingService,
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pump();

      // Should show edit options
      expect(find.text('Chỉnh sửa'), findsOneWidget);
      
      await tester.tap(find.text('Chỉnh sửa'));
      await tester.pump();

      // Should show edit options
      expect(find.text('Thêm món'), findsOneWidget);
      expect(find.text('Xóa món'), findsOneWidget);
      expect(find.text('Sửa số lượng'), findsOneWidget);
    });

    testWidgets('animation effects cho status changes', (tester) async {
      // Arrange
      final streamController = StreamController<OrderStatusUpdate>();
      when(mockTrackingService.orderUpdates)
        .thenAnswer((_) => streamController.stream);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Trigger status change
      streamController.add(OrderStatusUpdate(
        orderId: 'order-123',
        status: OrderStatus.ready,
        updatedAt: DateTime.now().toIso8601String(),
        notes: 'Món đã sẵn sàng',
      ));

      // Should trigger animation
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));

      // Animation should complete
      expect(find.text('Sẵn sàng'), findsOneWidget);
      
      // Status change animation effects
      expect(find.byType(AnimatedContainer), findsAtLeastNWidgets(1));
    });

    testWidgets('tablet layout optimization', (tester) async {
      // Set tablet screen size
      await tester.binding.setSurfaceSize(const Size(1024, 768));

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Should show optimized tablet layout
      expect(find.byType(Row), findsAtLeastNWidgets(1)); // Side-by-side layout
      
      // Status timeline should be horizontal on tablet
      expect(find.byKey(const Key('horizontal_timeline')), findsOneWidget);
    });

    testWidgets('voice notifications hoạt động', (tester) async {
      // Arrange
      final notificationController = StreamController<KitchenNotification>();
      when(mockTrackingService.kitchenNotifications)
        .thenAnswer((_) => notificationController.stream);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Simulate high priority notification
      notificationController.add(KitchenNotification(
        orderId: 'order-123',
        message: 'Đơn hàng khẩn cấp đã sẵn sàng',
        priority: NotificationPriority.urgent,
        kitchenArea: 'all',
        timestamp: DateTime.now(),
      ));
      await tester.pump();

      // Should show urgent notification with sound/vibration indicators
      expect(find.text('KHẨN CẤP'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
      expect(find.byIcon(Icons.vibration), findsOneWidget);
    });

    testWidgets('estimated time accuracy tracking', (tester) async {
      // Arrange
      when(mockTrackingService.getEstimatedReadyTime('order-123'))
        .thenReturn(DateTime.now().add(const Duration(minutes: 15)));
      when(mockTrackingService.getEstimatedAccuracy('order-123'))
        .thenReturn(0.85); // 85% accuracy

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Assert
      expect(find.text('Độ chính xác: 85%'), findsOneWidget);
      expect(find.textContaining('15'), findsOneWidget);

      // Progress indicator should reflect accuracy
      final progressIndicator = find.byType(LinearProgressIndicator);
      expect(progressIndicator, findsOneWidget);
    });

    testWidgets('customer notification preferences', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Tap notification settings
      await tester.tap(find.byIcon(Icons.notifications_active));
      await tester.pump();

      // Should show notification options
      expect(find.text('Thông báo khách hàng'), findsOneWidget);
      expect(find.text('SMS khi món sẵn sàng'), findsOneWidget);
      expect(find.text('Gọi điện khi chậm'), findsOneWidget);

      // Toggle SMS notification
      final smsToggle = find.byKey(const Key('sms_notification_toggle'));
      await tester.tap(smsToggle);
      await tester.pump();

      verify(mockTrackingService.updateNotificationPreferences(any)).called(1);
    });

    testWidgets('accessibility screen reader support', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Check semantic labels
      final orderCard = find.byKey(const Key('order_tracking_card'));
      expect(tester.getSemantics(orderCard).label,
        contains('Đơn hàng ORD-001, đang chuẩn bị'));

      // Status timeline should have proper semantics
      final timelineStep = find.byKey(const Key('status_step_preparing'));
      expect(tester.getSemantics(timelineStep).label,
        contains('Bước hiện tại: Đang chuẩn bị'));
    });
  });
}