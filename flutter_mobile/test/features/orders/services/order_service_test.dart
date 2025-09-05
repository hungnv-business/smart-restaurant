import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:smart_restaurant/features/orders/services/order_service.dart';
import 'package:smart_restaurant/features/orders/models/order_models.dart';
import 'package:smart_restaurant/shared/services/api_client.dart';
import 'package:smart_restaurant/shared/models/menu_models.dart';

import 'order_service_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  group('OrderService Tests', () {
    late OrderService orderService;
    late MockApiClient mockApiClient;
    late MenuItemModel testMenuItem;

    setUp(() {
      mockApiClient = MockApiClient();
      orderService = OrderService(apiClient: mockApiClient);
      
      testMenuItem = MenuItemModel(
        id: '1',
        name: 'Phở Bò',
        description: 'Phở bò truyền thống',
        price: 65000,
        categoryId: '1',
        isAvailable: true,
        imageUrl: null,
      );
    });

    test('addItem thêm món mới vào order', () {
      // Act
      orderService.addItem(testMenuItem);

      // Assert
      expect(orderService.items.length, equals(1));
      expect(orderService.items[0].menuItemName, equals('Phở Bò'));
      expect(orderService.items[0].quantity, equals(1));
      expect(orderService.totalAmount, equals(65000));
      expect(orderService.totalQuantity, equals(1));
    });

    test('addItem tăng quantity nếu món đã có', () {
      // Arrange
      orderService.addItem(testMenuItem);

      // Act - Add same item again
      orderService.addItem(testMenuItem);

      // Assert
      expect(orderService.items.length, equals(1));
      expect(orderService.items[0].quantity, equals(2));
      expect(orderService.totalAmount, equals(130000));
      expect(orderService.totalQuantity, equals(2));
    });

    test('addItem với custom quantity và notes', () {
      // Act
      orderService.addItem(testMenuItem, quantity: 3, notes: 'Ít muối');

      // Assert
      expect(orderService.items[0].quantity, equals(3));
      expect(orderService.items[0].notes, equals('Ít muối'));
      expect(orderService.totalAmount, equals(195000));
    });

    test('removeItem xóa món khỏi order', () {
      // Arrange
      orderService.addItem(testMenuItem);
      final itemId = orderService.items[0].id;

      // Act
      orderService.removeItem(itemId);

      // Assert
      expect(orderService.items.isEmpty, isTrue);
      expect(orderService.totalAmount, equals(0));
      expect(orderService.totalQuantity, equals(0));
    });

    test('updateItemQuantity cập nhật số lượng', () {
      // Arrange
      orderService.addItem(testMenuItem);
      final itemId = orderService.items[0].id;

      // Act
      orderService.updateItemQuantity(itemId, 5);

      // Assert
      expect(orderService.items[0].quantity, equals(5));
      expect(orderService.totalAmount, equals(325000));
      expect(orderService.totalQuantity, equals(5));
    });

    test('updateItemQuantity = 0 xóa món', () {
      // Arrange
      orderService.addItem(testMenuItem);
      final itemId = orderService.items[0].id;

      // Act
      orderService.updateItemQuantity(itemId, 0);

      // Assert
      expect(orderService.items.isEmpty, isTrue);
      expect(orderService.totalAmount, equals(0));
    });

    test('updateItemNotes cập nhật ghi chú', () {
      // Arrange
      orderService.addItem(testMenuItem);
      final itemId = orderService.items[0].id;

      // Act
      orderService.updateItemNotes(itemId, 'Không cay, thêm rau');

      // Assert
      expect(orderService.items[0].notes, equals('Không cay, thêm rau'));
    });

    test('clearOrder xóa toàn bộ order', () {
      // Arrange
      orderService.addItem(testMenuItem);
      orderService.addItem(testMenuItem);

      // Act
      orderService.clearOrder();

      // Assert
      expect(orderService.items.isEmpty, isTrue);
      expect(orderService.totalAmount, equals(0));
      expect(orderService.totalQuantity, equals(0));
    });

    test('applyDiscount áp dụng giảm giá phần trăm', () {
      // Arrange
      orderService.addItem(testMenuItem, quantity: 2); // 130000

      // Act
      orderService.applyDiscount(0.1); // 10% discount

      // Assert
      expect(orderService.discount, equals(13000));
      expect(orderService.totalAmount, equals(117000)); // 130000 - 13000
    });

    test('applyDiscountFixed áp dụng giảm giá cố định', () {
      // Arrange  
      orderService.addItem(testMenuItem, quantity: 2); // 130000

      // Act
      orderService.applyDiscountFixed(15000);

      // Assert
      expect(orderService.discount, equals(15000));
      expect(orderService.totalAmount, equals(115000)); // 130000 - 15000
    });

    test('calculateTax tính thuế VAT', () {
      // Arrange
      orderService.addItem(testMenuItem); // 65000

      // Act
      final tax = orderService.calculateTax(); // Default 10%

      // Assert
      expect(tax, equals(6500));
    });

    test('calculateServiceCharge tính phí phục vụ', () {
      // Arrange
      orderService.addItem(testMenuItem); // 65000

      // Act
      final serviceCharge = orderService.calculateServiceCharge(); // Default 5%

      // Assert
      expect(serviceCharge, equals(3250));
    });

    test('confirmOrderAsync gọi API và cập nhật trạng thái', () async {
      // Arrange
      orderService.addItem(testMenuItem);
      when(mockApiClient.checkIngredientAvailability(any))
        .thenAnswer((_) async => []);
      when(mockApiClient.createOrder(any))
        .thenAnswer((_) async => OrderModel(
          id: 'order-123',
          orderNumber: 'ORD-001',
          tableId: 'table-1',
          status: OrderStatus.pending,
          items: orderService.items,
          totalAmount: 65000,
          createdAt: DateTime.now(),
        ));

      // Act
      final result = await orderService.confirmOrderAsync('table-1');

      // Assert
      expect(result, isNotNull);
      expect(result!.orderNumber, equals('ORD-001'));
      expect(orderService.currentOrder, equals(result));
      expect(orderService.items.isEmpty, isTrue); // Should clear after confirm
    });

    test('confirmOrderAsync throws khi có missing ingredients bắt buộc', () async {
      // Arrange
      orderService.addItem(testMenuItem);
      when(mockApiClient.checkIngredientAvailability(any))
        .thenAnswer((_) async => [
          MissingIngredientModel(
            ingredientName: 'Thịt bò',
            requiredQuantity: 200,
            currentStock: 50,
            missingQuantity: 150,
            isOptional: false,
          ),
        ]);

      // Act & Assert
      expect(
        () => orderService.confirmOrderAsync('table-1'),
        throwsA(isA<OrderValidationException>()),
      );
    });

    test('saveDraft và loadDraft hoạt động đúng', () async {
      // Arrange
      orderService.addItem(testMenuItem, quantity: 2, notes: 'Test notes');
      orderService.updateOrderNotes('Draft order for testing');

      // Act - Save draft
      await orderService.saveDraft();

      // Clear current order
      orderService.clearOrder();
      expect(orderService.items.isEmpty, isTrue);

      // Load draft
      await orderService.loadDraft();

      // Assert - Should restore draft
      expect(orderService.items.length, equals(1));
      expect(orderService.items[0].quantity, equals(2));
      expect(orderService.items[0].notes, equals('Test notes'));
      expect(orderService.orderNotes, equals('Draft order for testing'));
    });

    test('updateSpecialRequests cập nhật yêu cầu đặc biệt', () {
      // Act
      orderService.updateSpecialRequests(SpecialRequestsModel(
        kitchenNotes: 'Làm nhanh',
        allergyWarnings: ['Không tôm', 'Không đậu phộng'],
        servingPreferences: 'Món nóng trước',
        priority: OrderPriority.high,
      ));

      // Assert
      expect(orderService.specialRequests?.kitchenNotes, equals('Làm nhanh'));
      expect(orderService.specialRequests?.priority, equals(OrderPriority.high));
    });

    test('listeners được notify khi order thay đổi', () {
      // Arrange
      bool notified = false;
      orderService.addListener(() {
        notified = true;
      });

      // Act
      orderService.addItem(testMenuItem);

      // Assert
      expect(notified, isTrue);
    });

    test('calculateEstimatedTime dựa trên complexity', () async {
      // Arrange
      when(mockApiClient.getEstimatedCookingTime(any))
        .thenAnswer((_) async => const Duration(minutes: 20));
      
      orderService.addItem(testMenuItem, quantity: 3);

      // Act
      final estimatedTime = await orderService.calculateEstimatedTime();

      // Assert
      expect(estimatedTime.inMinutes, equals(20));
      verify(mockApiClient.getEstimatedCookingTime(any)).called(1);
    });

    test('getOrderSummary tạo summary đầy đủ', () {
      // Arrange
      orderService.addItem(testMenuItem, quantity: 2);
      orderService.applyDiscount(0.05); // 5%
      orderService.updateOrderNotes('Test order');

      // Act
      final summary = orderService.getOrderSummary();

      // Assert
      expect(summary.items.length, equals(1));
      expect(summary.subtotal, equals(130000));
      expect(summary.discount, equals(6500)); // 5% of 130000
      expect(summary.taxAmount, equals(12350)); // 10% of (130000-6500)
      expect(summary.serviceCharge, equals(6175)); // 5% of (130000-6500)
      expect(summary.notes, equals('Test order'));
    });

    test('processPayment xử lý thanh toán', () async {
      // Arrange
      orderService.addItem(testMenuItem);
      when(mockApiClient.processPayment(any))
        .thenAnswer((_) async => PaymentResult(
          success: true,
          transactionId: 'txn-123',
          paymentMethod: PaymentMethod.cash,
        ));

      // Act
      final result = await orderService.processPayment(PaymentMethod.cash);

      // Assert
      expect(result.success, isTrue);
      expect(result.transactionId, equals('txn-123'));
      verify(mockApiClient.processPayment(any)).called(1);
    });

    test('validation ngăn chặn order trống', () {
      // Act & Assert
      expect(
        () => orderService.validateOrder(),
        throwsA(isA<OrderValidationException>()),
      );
    });

    test('validation kiểm tra table required cho dine-in', () {
      // Arrange
      orderService.addItem(testMenuItem);

      // Act & Assert - No table ID provided for dine-in
      expect(
        () => orderService.validateOrder(orderType: OrderType.dineIn),
        throwsA(isA<OrderValidationException>()),
      );
    });

    test('state persistence qua app restarts', () async {
      // Arrange
      orderService.addItem(testMenuItem, quantity: 2);

      // Act - Simulate app restart
      await orderService.persistState();
      
      final newOrderService = OrderService(apiClient: mockApiClient);
      await newOrderService.restoreState();

      // Assert - State should be restored
      expect(newOrderService.items.length, equals(1));
      expect(newOrderService.items[0].quantity, equals(2));
      expect(newOrderService.totalAmount, equals(130000));
    });
  });

  group('OrderService Error Handling', () {
    late OrderService orderService;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      orderService = OrderService(apiClient: mockApiClient);
    });

    test('network error được handle đúng cách', () async {
      // Arrange
      when(mockApiClient.createOrder(any))
        .thenThrow(NetworkException('Không có kết nối internet'));

      orderService.addItem(MenuItemModel(
        id: '1',
        name: 'Test Item',
        description: 'Test',
        price: 50000,
        categoryId: '1',
        isAvailable: true,
        imageUrl: null,
      ));

      // Act & Assert
      expect(
        () => orderService.confirmOrderAsync('table-1'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('server error được retry và handle', () async {
      // Arrange
      var callCount = 0;
      when(mockApiClient.createOrder(any)).thenAnswer((_) async {
        callCount++;
        if (callCount < 3) {
          throw ServerException('Server tạm thời không phản hồi');
        }
        return OrderModel(
          id: 'order-success',
          orderNumber: 'ORD-002',
          tableId: 'table-1',
          status: OrderStatus.pending,
          items: [],
          totalAmount: 50000,
          createdAt: DateTime.now(),
        );
      });

      orderService.addItem(MenuItemModel(
        id: '1',
        name: 'Test Item',
        description: 'Test',
        price: 50000,
        categoryId: '1',
        isAvailable: true,
        imageUrl: null,
      ));

      // Act
      final result = await orderService.confirmOrderAsync('table-1');

      // Assert - Should succeed after retries
      expect(result?.orderNumber, equals('ORD-002'));
      verify(mockApiClient.createOrder(any)).called(3);
    });

    test('validation error không retry', () async {
      // Arrange
      when(mockApiClient.createOrder(any))
        .thenThrow(ValidationException('Dữ liệu không hợp lệ'));

      orderService.addItem(MenuItemModel(
        id: '1',
        name: 'Test Item',
        description: 'Test',
        price: 50000,
        categoryId: '1',
        isAvailable: true,
        imageUrl: null,
      ));

      // Act & Assert
      expect(
        () => orderService.confirmOrderAsync('table-1'),
        throwsA(isA<ValidationException>()),
      );
      
      // Should only call once (no retry for validation errors)
      verify(mockApiClient.createOrder(any)).called(1);
    });
  });

  group('OrderService Vietnamese Currency Formatting', () {
    late OrderService orderService;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      orderService = OrderService(apiClient: mockApiClient);
    });

    test('formatCurrency định dạng tiền Việt Nam', () {
      expect(orderService.formatCurrency(65000), equals('65,000₫'));
      expect(orderService.formatCurrency(1500000), equals('1,500,000₫'));
      expect(orderService.formatCurrency(0), equals('0₫'));
    });

    test('formatQuantity hiển thị số lượng Việt Nam', () {
      expect(orderService.formatQuantity(1), equals('x1'));
      expect(orderService.formatQuantity(10), equals('x10'));
    });

    test('formatOrderNumber định dạng số order', () {
      expect(orderService.formatOrderNumber(1), equals('ORD-001'));
      expect(orderService.formatOrderNumber(99), equals('ORD-099'));
      expect(orderService.formatOrderNumber(1000), equals('ORD-1000'));
    });
  });

  group('OrderService Complex Scenarios', () {
    late OrderService orderService;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      orderService = OrderService(apiClient: mockApiClient);
    });

    test('multiple items với different customizations', () {
      // Arrange
      final pho = MenuItemModel(
        id: '1', name: 'Phở Bò', description: '', price: 65000,
        categoryId: '1', isAvailable: true, imageUrl: null,
      );
      final com = MenuItemModel(
        id: '2', name: 'Cơm Tấm', description: '', price: 55000,
        categoryId: '2', isAvailable: true, imageUrl: null,
      );

      // Act
      orderService.addItem(pho, quantity: 2, notes: 'Ít muối');
      orderService.addItem(com, quantity: 1, notes: 'Thêm nước mắm');
      orderService.applyDiscount(0.1); // 10%

      // Assert
      expect(orderService.items.length, equals(2));
      expect(orderService.subtotal, equals(185000)); // (65000*2) + 55000
      expect(orderService.discount, equals(18500)); // 10% of 185000
      expect(orderService.totalAmount, equals(166500)); // 185000 - 18500
      expect(orderService.totalQuantity, equals(3));
    });

    test('order với split payment calculation', () {
      // Arrange
      orderService.addItem(MenuItemModel(
        id: '1', name: 'Item 1', description: '', price: 100000,
        categoryId: '1', isAvailable: true, imageUrl: null,
      ));

      // Act - Split payment among 4 people
      final splitAmount = orderService.calculateSplitPayment(4);

      // Assert
      expect(splitAmount, equals(25000)); // 100000 / 4
    });

    test('order priority ảnh hưởng estimated time', () async {
      // Arrange
      when(mockApiClient.getEstimatedCookingTime(any))
        .thenAnswer((_) async => const Duration(minutes: 30));

      orderService.addItem(MenuItemModel(
        id: '1', name: 'Complex Dish', description: '', price: 100000,
        categoryId: '1', isAvailable: true, imageUrl: null,
      ));

      // Act - High priority should reduce time
      orderService.updateSpecialRequests(SpecialRequestsModel(
        priority: OrderPriority.high,
        kitchenNotes: '',
        allergyWarnings: [],
        servingPreferences: '',
      ));

      final estimatedTime = await orderService.calculateEstimatedTime();

      // Assert - High priority reduces cooking time
      expect(estimatedTime.inMinutes, lessThan(30));
    });

    test('offline mode queue orders', () {
      // Arrange
      orderService.setOfflineMode(true);
      orderService.addItem(MenuItemModel(
        id: '1', name: 'Offline Item', description: '', price: 50000,
        categoryId: '1', isAvailable: true, imageUrl: null,
      ));

      // Act
      orderService.confirmOrderAsync('table-1');

      // Assert - Should queue order instead of sending immediately
      expect(orderService.queuedOrders.length, equals(1));
      expect(orderService.queuedOrders[0].tableId, equals('table-1'));
    });

    test('sync queued orders khi online', () async {
      // Arrange
      orderService.setOfflineMode(true);
      orderService.addItem(MenuItemModel(
        id: '1', name: 'Queued Item', description: '', price: 50000,
        categoryId: '1', isAvailable: true, imageUrl: null,
      ));
      
      orderService.confirmOrderAsync('table-1'); // Queued
      expect(orderService.queuedOrders.length, equals(1));

      when(mockApiClient.createOrder(any))
        .thenAnswer((_) async => OrderModel(
          id: 'synced-order',
          orderNumber: 'ORD-SYNC',
          tableId: 'table-1',
          status: OrderStatus.confirmed,
          items: [],
          totalAmount: 50000,
          createdAt: DateTime.now(),
        ));

      // Act - Go back online
      orderService.setOfflineMode(false);
      await orderService.syncQueuedOrders();

      // Assert - Queue should be synced
      expect(orderService.queuedOrders.isEmpty, isTrue);
      verify(mockApiClient.createOrder(any)).called(1);
    });
  });
}