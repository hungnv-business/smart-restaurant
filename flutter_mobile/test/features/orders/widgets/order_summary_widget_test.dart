import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:smart_restaurant/features/orders/widgets/order_summary_widget.dart';
import 'package:smart_restaurant/features/orders/services/order_service.dart';
import 'package:smart_restaurant/features/orders/models/order_models.dart';
import 'package:smart_restaurant/shared/services/api_client.dart';

import 'order_summary_widget_test.mocks.dart';

@GenerateMocks([OrderService, ApiClient])
void main() {
  group('OrderSummaryWidget Tests', () {
    late MockOrderService mockOrderService;
    late MockApiClient mockApiClient;
    late List<OrderItemModel> testOrderItems;

    setUp(() {
      mockOrderService = MockOrderService();
      mockApiClient = MockApiClient();

      testOrderItems = [
        OrderItemModel(
          id: '1',
          menuItemId: '1', 
          menuItemName: 'Phở Bò Tái',
          unitPrice: 65000,
          quantity: 2,
          notes: 'Ít muối',
          status: OrderItemStatus.pending,
        ),
        OrderItemModel(
          id: '2',
          menuItemId: '2',
          menuItemName: 'Cơm Tấm Sườn', 
          unitPrice: 55000,
          quantity: 1,
          notes: '',
          status: OrderItemStatus.pending,
        ),
      ];

      when(mockOrderService.items).thenReturn(testOrderItems);
      when(mockOrderService.totalAmount).thenReturn(185000); // (65000*2) + 55000
      when(mockOrderService.totalQuantity).thenReturn(3);
    });

    Widget createWidget({
      String? tableId,
      VoidCallback? onConfirmOrder,
      VoidCallback? onEditOrder,
    }) {
      return MaterialApp(
        home: ChangeNotifierProvider<OrderService>.value(
          value: mockOrderService,
          child: OrderSummaryWidget(
            tableId: tableId ?? 'table-1',
            onConfirmOrder: onConfirmOrder ?? () {},
            onEditOrder: onEditOrder ?? () {},
          ),
        ),
      );
    }

    testWidgets('hiển thị danh sách món trong order', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Assert
      expect(find.text('Phở Bò Tái'), findsOneWidget);
      expect(find.text('Cơm Tấm Sườn'), findsOneWidget);
      expect(find.text('x2'), findsOneWidget);
      expect(find.text('x1'), findsOneWidget);
      expect(find.text('Ít muối'), findsOneWidget);
      expect(find.text('130,000₫'), findsOneWidget); // 65000*2
      expect(find.text('55,000₫'), findsOneWidget);
    });

    testWidgets('hiển thị tổng tiền đúng', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Assert
      expect(find.text('Tổng tiền'), findsOneWidget);
      expect(find.text('185,000₫'), findsOneWidget);
      expect(find.text('Tổng số món: 3'), findsOneWidget);
    });

    testWidgets('có thể xóa món khỏi order', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Find delete button for first item
      final deleteButton = find.byKey(const Key('delete_item_1'));
      await tester.tap(deleteButton);
      await tester.pump();

      // Assert - Should call removeItem
      verify(mockOrderService.removeItem('1')).called(1);
    });

    testWidgets('có thể chỉnh sửa số lượng món', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Tap quantity to edit
      await tester.tap(find.text('x2'));
      await tester.pump();

      // Should show quantity edit dialog
      expect(find.text('Chỉnh sửa số lượng'), findsOneWidget);
      
      final quantityField = find.byType(TextField);
      await tester.enterText(quantityField, '3');
      
      await tester.tap(find.text('Cập nhật'));
      await tester.pump();

      // Assert - Should call updateQuantity
      verify(mockOrderService.updateItemQuantity('1', 3)).called(1);
    });

    testWidgets('có thể chỉnh sửa ghi chú món', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Tap notes to edit
      await tester.tap(find.text('Ít muối'));
      await tester.pump();

      // Should show notes edit dialog
      expect(find.text('Chỉnh sửa ghi chú'), findsOneWidget);
      
      final notesField = find.byType(TextField);
      await tester.enterText(notesField, 'Không muối, nhiều hành');
      
      await tester.tap(find.text('Cập nhật'));
      await tester.pump();

      // Assert - Should call updateNotes
      verify(mockOrderService.updateItemNotes('1', 'Không muối, nhiều hành')).called(1);
    });

    testWidgets('hiển thị thông báo khi order trống', (tester) async {
      // Arrange - Empty order
      when(mockOrderService.items).thenReturn([]);
      when(mockOrderService.totalAmount).thenReturn(0);
      when(mockOrderService.totalQuantity).thenReturn(0);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Assert
      expect(find.text('Đơn hàng trống'), findsOneWidget);
      expect(find.text('Chưa có món nào được chọn'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('kiểm tra nguyên liệu trước khi confirm', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);
      when(mockApiClient.checkIngredientAvailability(any))
        .thenAnswer((_) async => [
          MissingIngredientModel(
            ingredientName: 'Thịt bò',
            requiredQuantity: 300,
            currentStock: 150,
            missingQuantity: 150,
            isOptional: false,
          ),
        ]);

      bool confirmCalled = false;
      final widget = createWidget(
        onConfirmOrder: () {
          confirmCalled = true;
        },
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pump();

      // Tap confirm button
      await tester.tap(find.text('Xác nhận đơn hàng'));
      await tester.pump();

      // Assert - Should show missing ingredients warning
      expect(find.text('Thiếu nguyên liệu'), findsOneWidget);
      expect(find.text('Thịt bò'), findsOneWidget);
      expect(find.text('Thiếu: 150g'), findsOneWidget);
      expect(find.text('Tiếp tục đặt món'), findsOneWidget);
      expect(find.text('Chỉnh sửa đơn'), findsOneWidget);

      // Confirm should not be called yet
      expect(confirmCalled, isFalse);
    });

    testWidgets('có thể tiếp tục order với nguyên liệu thiếu optional', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);
      when(mockApiClient.checkIngredientAvailability(any))
        .thenAnswer((_) async => [
          MissingIngredientModel(
            ingredientName: 'Rau thơm',
            requiredQuantity: 50,
            currentStock: 0,
            missingQuantity: 50,
            isOptional: true, // Optional ingredient
          ),
        ]);

      bool confirmCalled = false;
      final widget = createWidget(
        onConfirmOrder: () {
          confirmCalled = true;
        },
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pump();

      await tester.tap(find.text('Xác nhận đơn hàng'));
      await tester.pump();

      // Should show warning but allow continue
      expect(find.text('Một số nguyên liệu không có'), findsOneWidget);
      expect(find.text('(không bắt buộc)'), findsOneWidget);
      
      // Continue with order
      await tester.tap(find.text('Tiếp tục đặt món'));
      await tester.pump();

      // Assert - Should proceed with confirmation
      expect(confirmCalled, isTrue);
    });

    testWidgets('không cho phép order khi thiếu nguyên liệu bắt buộc', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);
      when(mockApiClient.checkIngredientAvailability(any))
        .thenAnswer((_) async => [
          MissingIngredientModel(
            ingredientName: 'Thịt bò',
            requiredQuantity: 300,
            currentStock: 0,
            missingQuantity: 300,
            isOptional: false, // Critical ingredient
          ),
        ]);

      bool confirmCalled = false;
      final widget = createWidget(
        onConfirmOrder: () {
          confirmCalled = true;
        },
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pump();

      await tester.tap(find.text('Xác nhận đơn hàng'));
      await tester.pump();

      // Assert - Should show blocking warning
      expect(find.text('Không thể đặt món'), findsOneWidget);
      expect(find.text('Thiếu nguyên liệu bắt buộc'), findsOneWidget);
      expect(find.text('Tiếp tục đặt món'), findsNothing); // No continue button
      expect(find.text('Chỉnh sửa đơn'), findsOneWidget);

      // Should not allow confirmation
      expect(confirmCalled, isFalse);
    });

    testWidgets('hiển thị estimated time và priority', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);
      when(mockApiClient.getEstimatedCookingTime(any))
        .thenAnswer((_) async => const Duration(minutes: 25));

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Assert
      expect(find.text('Thời gian ước tính'), findsOneWidget);
      expect(find.text('~25 phút'), findsOneWidget);
      
      // Priority selector should be visible
      expect(find.text('Ưu tiên'), findsOneWidget);
      expect(find.text('Bình thường'), findsOneWidget);
    });

    testWidgets('có thể chọn priority cho order', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Tap priority selector
      await tester.tap(find.text('Bình thường'));
      await tester.pump();

      // Should show priority options
      expect(find.text('Thấp'), findsOneWidget);
      expect(find.text('Bình thường'), findsWidgets);
      expect(find.text('Cao'), findsOneWidget);
      expect(find.text('Khẩn cấp'), findsOneWidget);

      // Select high priority
      await tester.tap(find.text('Cao'));
      await tester.pump();

      // Should update display
      expect(find.text('Cao'), findsOneWidget);
    });

    testWidgets('split payment options hoạt động', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Tap payment method
      final paymentButton = find.text('Tiền mặt');
      await tester.tap(paymentButton);
      await tester.pump();

      // Should show payment options
      expect(find.text('Chọn phương thức thanh toán'), findsOneWidget);
      expect(find.text('Tiền mặt'), findsWidgets);
      expect(find.text('Thẻ ngân hàng'), findsOneWidget);
      expect(find.text('Chuyển khoản'), findsOneWidget);
      expect(find.text('Chia tách hóa đơn'), findsOneWidget);

      // Select split payment
      await tester.tap(find.text('Chia tách hóa đơn'));
      await tester.pump();

      // Should show split options
      expect(find.text('Chia đều theo số người'), findsOneWidget);
      expect(find.text('Chia theo món'), findsOneWidget);
    });

    testWidgets('có thể thêm discount cho order', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Tap discount button
      final discountButton = find.byIcon(Icons.local_offer);
      await tester.tap(discountButton);
      await tester.pump();

      // Should show discount options
      expect(find.text('Áp dụng giảm giá'), findsOneWidget);
      expect(find.text('Phần trăm (%)'), findsOneWidget);
      expect(find.text('Số tiền cố định'), findsOneWidget);

      // Enter discount percentage
      await tester.tap(find.text('Phần trăm (%)'));
      await tester.pump();

      final discountField = find.byType(TextField);
      await tester.enterText(discountField, '10');
      
      await tester.tap(find.text('Áp dụng'));
      await tester.pump();

      // Should update total amount
      verify(mockOrderService.applyDiscount(0.1)).called(1);
    });

    testWidgets('customer info form validation hoạt động', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Tap customer info section
      final customerButton = find.text('Thông tin khách hàng');
      await tester.tap(customerButton);
      await tester.pump();

      // Should show customer form
      expect(find.text('Tên khách hàng'), findsOneWidget);
      expect(find.text('Số điện thoại'), findsOneWidget);
      expect(find.text('Ghi chú đặc biệt'), findsOneWidget);

      // Enter invalid phone
      final phoneField = find.byKey(const Key('customer_phone'));
      await tester.enterText(phoneField, '123');
      
      await tester.tap(find.text('Lưu thông tin'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Số điện thoại không hợp lệ'), findsOneWidget);
    });

    testWidgets('hiển thị order summary breakdown chi tiết', (tester) async {
      // Arrange
      when(mockOrderService.subtotal).thenReturn(185000);
      when(mockOrderService.taxAmount).thenReturn(18500); // 10% VAT
      when(mockOrderService.serviceCharge).thenReturn(9250); // 5% service
      when(mockOrderService.discount).thenReturn(10000);
      when(mockOrderService.totalAmount).thenReturn(202750);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Tap to expand breakdown
      final expandButton = find.byIcon(Icons.expand_more);
      await tester.tap(expandButton);
      await tester.pump();

      // Assert - Should show detailed breakdown
      expect(find.text('Tạm tính'), findsOneWidget);
      expect(find.text('185,000₫'), findsOneWidget);
      expect(find.text('Thuế VAT (10%)'), findsOneWidget);
      expect(find.text('18,500₫'), findsOneWidget);
      expect(find.text('Phí phục vụ (5%)'), findsOneWidget);
      expect(find.text('9,250₫'), findsOneWidget);
      expect(find.text('Giảm giá'), findsOneWidget);
      expect(find.text('-10,000₫'), findsOneWidget);
      expect(find.text('Tổng cộng'), findsOneWidget);
      expect(find.text('202,750₫'), findsOneWidget);
    });

    testWidgets('confirmation dialog hiển thị thông tin đầy đủ', (tester) async {
      // Arrange
      bool confirmCalled = false;
      when(mockOrderService.apiClient).thenReturn(mockApiClient);
      when(mockApiClient.checkIngredientAvailability(any))
        .thenAnswer((_) async => []); // No missing ingredients

      final widget = createWidget(
        tableId: 'table-5',
        onConfirmOrder: () {
          confirmCalled = true;
        },
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pump();

      await tester.tap(find.text('Xác nhận đơn hàng'));
      await tester.pump();

      // Should show confirmation dialog
      expect(find.text('Xác nhận đơn hàng'), findsAtLeastNWidgets(1));
      expect(find.text('Bàn: table-5'), findsOneWidget);
      expect(find.text('Tổng tiền: 185,000₫'), findsOneWidget);
      expect(find.text('Số món: 3'), findsOneWidget);

      // Confirm order
      await tester.tap(find.text('Đặt món').last);
      await tester.pump();

      // Assert
      expect(confirmCalled, isTrue);
    });

    testWidgets('hiển thị loading khi đang xử lý order', (tester) async {
      // Arrange
      when(mockOrderService.isProcessing).thenReturn(true);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Assert - Confirm button should be disabled with loading
      final confirmButton = find.text('Đang xử lý...');
      expect(confirmButton, findsOneWidget);
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('print preview hoạt động đúng', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Tap print preview
      final printButton = find.byIcon(Icons.print);
      await tester.tap(printButton);
      await tester.pump();

      // Should show print preview
      expect(find.text('Xem trước hóa đơn'), findsOneWidget);
      expect(find.text('Smart Restaurant'), findsOneWidget);
      expect(find.text('Bàn: table-1'), findsOneWidget);
      
      // Should show order items in print format
      expect(find.textContaining('2x Phở Bò Tái'), findsOneWidget);
      expect(find.textContaining('1x Cơm Tấm Sườn'), findsOneWidget);
    });

    testWidgets('save draft hoạt động khi order chưa confirm', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Long press to show context menu
      await tester.longPress(find.text('Xác nhận đơn hàng'));
      await tester.pump();

      // Should show draft options
      expect(find.text('Lưu nháp'), findsOneWidget);
      expect(find.text('Khôi phục nháp'), findsOneWidget);

      // Save draft
      await tester.tap(find.text('Lưu nháp'));
      await tester.pump();

      // Should call save draft
      verify(mockOrderService.saveDraft()).called(1);
    });

    testWidgets('estimated delivery time hiển thị đúng', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);
      when(mockApiClient.getEstimatedCookingTime(any))
        .thenAnswer((_) async => const Duration(minutes: 30));

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Assert
      expect(find.text('Thời gian chuẩn bị'), findsOneWidget);
      expect(find.text('~30 phút'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('special requests section hoạt động', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Tap special requests
      final specialRequestsButton = find.text('Yêu cầu đặc biệt');
      await tester.tap(specialRequestsButton);
      await tester.pump();

      // Should show special requests form
      expect(find.text('Ghi chú cho bếp'), findsOneWidget);
      expect(find.text('Allergy warnings'), findsOneWidget);
      expect(find.text('Serving preferences'), findsOneWidget);

      // Add kitchen notes
      final notesField = find.byKey(const Key('kitchen_notes'));
      await tester.enterText(notesField, 'Làm nhanh giúp, khách vội');
      
      await tester.tap(find.text('Lưu yêu cầu'));
      await tester.pump();

      // Should update order with special requests
      verify(mockOrderService.updateSpecialRequests(any)).called(1);
    });

    testWidgets('quick actions shortcuts hoạt động', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Should have quick action buttons
      expect(find.byIcon(Icons.add_circle), findsOneWidget); // Add more items
      expect(find.byIcon(Icons.edit), findsOneWidget); // Edit order
      expect(find.byIcon(Icons.copy), findsOneWidget); // Duplicate order
      expect(find.byIcon(Icons.delete), findsOneWidget); // Clear order

      // Test clear order
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      // Should show confirmation
      expect(find.text('Xóa toàn bộ đơn hàng?'), findsOneWidget);
      
      await tester.tap(find.text('Xóa'));
      await tester.pump();

      verify(mockOrderService.clearOrder()).called(1);
    });

    testWidgets('accessibility labels đầy đủ', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Check semantic labels for order items
      final firstItem = find.byKey(const Key('order_item_1'));
      expect(tester.getSemantics(firstItem).label,
        contains('Phở Bò Tái, số lượng 2, giá 130,000 đồng'));

      // Check confirm button semantics
      final confirmButton = find.text('Xác nhận đơn hàng');
      expect(tester.getSemantics(confirmButton).label,
        contains('Xác nhận đơn hàng với tổng tiền 185,000 đồng'));
    });

    testWidgets('swipe to delete món hoạt động', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Swipe first item to delete
      final firstItem = find.byKey(const Key('order_item_1'));
      await tester.drag(firstItem, const Offset(-300, 0));
      await tester.pump();

      // Should show delete action
      expect(find.byIcon(Icons.delete), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      // Should remove item
      verify(mockOrderService.removeItem('1')).called(1);
    });

    testWidgets('order notes cho toàn bộ order', (tester) async {
      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Tap order notes section
      final notesButton = find.text('Ghi chú đơn hàng');
      await tester.tap(notesButton);
      await tester.pump();

      // Should show notes input
      final notesField = find.byKey(const Key('order_notes'));
      await tester.enterText(notesField, 'Khách hàng VIP, chăm sóc đặc biệt');
      
      // Auto-save after typing
      await tester.pump(const Duration(milliseconds: 1000));

      // Should save notes
      verify(mockOrderService.updateOrderNotes('Khách hàng VIP, chăm sóc đặc biệt')).called(1);
    });
  });
}