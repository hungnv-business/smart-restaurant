import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mobile/features/orders/services/order_service.dart';
import 'package:flutter_mobile/features/orders/models/order_models.dart';
import 'package:flutter_mobile/features/menu/models/menu_models.dart';
import 'package:flutter_mobile/features/tables/models/table_models.dart';

void main() {
  group('OrderService Tests', () {
    late OrderService orderService;

    setUp(() {
      orderService = OrderService();
    });

    tearDown(() {
      orderService.dispose();
    });

    group('Order Management', () {
      test('should initialize with empty order', () {
        expect(orderService.hasItems, false);
        expect(orderService.orderItems, isEmpty);
        expect(orderService.totalItemCount, 0);
        expect(orderService.subtotal, 0.0);
        expect(orderService.total, 0.0);
      });

      test('should add item to order', () {
        final menuItem = MenuItem(
          id: 'test-1',
          name: 'Phở Bò',
          description: 'Phở bò truyền thống',
          price: 65000,
          isAvailable: true,
          categoryId: 'pho',
        );

        orderService.addItem(menuItem);

        expect(orderService.hasItems, true);
        expect(orderService.orderItems.length, 1);
        expect(orderService.totalItemCount, 1);
        expect(orderService.orderItems.first.menuItemName, 'Phở Bò');
        expect(orderService.orderItems.first.quantity, 1);
        expect(orderService.subtotal, 65000.0);
      });

      test('should add multiple quantities of same item', () {
        final menuItem = MenuItem(
          id: 'test-1',
          name: 'Phở Bò',
          description: 'Phở bò truyền thống',
          price: 65000,
          isAvailable: true,
          categoryId: 'pho',
        );

        orderService.addItem(menuItem, quantity: 2);

        expect(orderService.orderItems.length, 1);
        expect(orderService.totalItemCount, 2);
        expect(orderService.orderItems.first.quantity, 2);
        expect(orderService.subtotal, 130000.0);
      });

      test('should combine same items with same notes', () {
        final menuItem = MenuItem(
          id: 'test-1',
          name: 'Phở Bò',
          description: 'Phở bò truyền thống',
          price: 65000,
          isAvailable: true,
          categoryId: 'pho',
        );

        orderService.addItem(menuItem, notes: 'Ít muối');
        orderService.addItem(menuItem, notes: 'Ít muối');

        expect(orderService.orderItems.length, 1);
        expect(orderService.orderItems.first.quantity, 2);
        expect(orderService.orderItems.first.notes, 'Ít muối');
      });

      test('should create separate items for different notes', () {
        final menuItem = MenuItem(
          id: 'test-1',
          name: 'Phở Bò',
          description: 'Phở bò truyền thống',
          price: 65000,
          isAvailable: true,
          categoryId: 'pho',
        );

        orderService.addItem(menuItem, notes: 'Ít muối');
        orderService.addItem(menuItem, notes: 'Không cay');

        expect(orderService.orderItems.length, 2);
        expect(orderService.orderItems[0].notes, 'Ít muối');
        expect(orderService.orderItems[1].notes, 'Không cay');
      });

      test('should update item quantity', () {
        final menuItem = MenuItem(
          id: 'test-1',
          name: 'Phở Bò',
          description: 'Phở bò truyền thống',
          price: 65000,
          isAvailable: true,
          categoryId: 'pho',
        );

        orderService.addItem(menuItem);
        orderService.updateItemQuantity(0, 3);

        expect(orderService.orderItems.first.quantity, 3);
        expect(orderService.totalItemCount, 3);
        expect(orderService.subtotal, 195000.0);
      });

      test('should remove item when quantity set to 0', () {
        final menuItem = MenuItem(
          id: 'test-1',
          name: 'Phở Bò',
          description: 'Phở bò truyền thống',
          price: 65000,
          isAvailable: true,
          categoryId: 'pho',
        );

        orderService.addItem(menuItem);
        orderService.updateItemQuantity(0, 0);

        expect(orderService.hasItems, false);
        expect(orderService.orderItems, isEmpty);
      });

      test('should remove item by index', () {
        final menuItem = MenuItem(
          id: 'test-1',
          name: 'Phở Bò',
          description: 'Phở bò truyền thống',
          price: 65000,
          isAvailable: true,
          categoryId: 'pho',
        );

        orderService.addItem(menuItem);
        orderService.removeItem(0);

        expect(orderService.hasItems, false);
        expect(orderService.orderItems, isEmpty);
      });

      test('should update item notes', () {
        final menuItem = MenuItem(
          id: 'test-1',
          name: 'Phở Bò',
          description: 'Phở bò truyền thống',
          price: 65000,
          isAvailable: true,
          categoryId: 'pho',
        );

        orderService.addItem(menuItem);
        orderService.updateItemNotes(0, 'Thêm hành tây');

        expect(orderService.orderItems.first.notes, 'Thêm hành tây');
      });
    });

    group('Order Calculation', () {
      test('should calculate VAT correctly', () {
        final menuItem = MenuItem(
          id: 'test-1',
          name: 'Phở Bò',
          description: 'Phở bò truyền thống',
          price: 100000,
          isAvailable: true,
          categoryId: 'pho',
        );

        orderService.addItem(menuItem);

        expect(orderService.subtotal, 100000.0);
        expect(orderService.vatAmount, 10000.0); // 10% VAT
        expect(orderService.total, 110000.0);
      });

      test('should calculate total for multiple items', () {
        final menuItem1 = MenuItem(
          id: 'test-1',
          name: 'Phở Bò',
          description: 'Phở bò truyền thống',
          price: 65000,
          isAvailable: true,
          categoryId: 'pho',
        );

        final menuItem2 = MenuItem(
          id: 'test-2',
          name: 'Cơm Tấm',
          description: 'Cơm tấm sườn nướng',
          price: 55000,
          isAvailable: true,
          categoryId: 'com',
        );

        orderService.addItem(menuItem1, quantity: 2);
        orderService.addItem(menuItem2, quantity: 1);

        expect(orderService.subtotal, 185000.0); // (65000 * 2) + (55000 * 1)
        expect(orderService.vatAmount, 18500.0); // 10% VAT
        expect(orderService.total, 203500.0);
        expect(orderService.totalItemCount, 3);
      });
    });

    group('Table Selection', () {
      test('should set selected table', () {
        final table = RestaurantTable(
          id: 'table-1',
          tableNumber: 'T01',
          capacity: 4,
          layoutSectionId: 'main-floor',
          status: TableStatus.available,
        );

        orderService.setSelectedTable(table);

        expect(orderService.selectedTable, table);
        expect(orderService.selectedTable?.tableNumber, 'T01');
      });

      test('should set order type', () {
        orderService.setOrderType(OrderType.takeaway);

        expect(orderService.orderType, OrderType.takeaway);
      });

      test('should set customer note', () {
        orderService.setCustomerNote('Giao hàng nhanh');

        expect(orderService.customerNote, 'Giao hàng nhanh');
      });
    });

    group('Order Submission', () {
      test('should fail to submit empty order', () async {
        final success = await orderService.submitOrder();

        expect(success, false);
        expect(orderService.error, contains('ít nhất 1 món'));
      });

      test('should fail to submit dine-in order without table', () async {
        final menuItem = MenuItem(
          id: 'test-1',
          name: 'Phở Bò',
          description: 'Phở bò truyền thống',
          price: 65000,
          isAvailable: true,
          categoryId: 'pho',
        );

        orderService.addItem(menuItem);
        orderService.setOrderType(OrderType.dineIn);

        final success = await orderService.submitOrder();

        expect(success, false);
        expect(orderService.error, contains('chọn bàn'));
      });

      test('should submit takeaway order without table', () async {
        final menuItem = MenuItem(
          id: 'test-1',
          name: 'Phở Bò',
          description: 'Phở bò truyền thống',
          price: 65000,
          isAvailable: true,
          categoryId: 'pho',
        );

        orderService.addItem(menuItem);
        orderService.setOrderType(OrderType.takeaway);

        final success = await orderService.submitOrder();

        expect(success, true);
        expect(orderService.error, isNull);
        expect(orderService.hasItems, false); // Order should be cleared after submission
      });

      test('should submit complete dine-in order', () async {
        final menuItem = MenuItem(
          id: 'test-1',
          name: 'Phở Bò',
          description: 'Phở bò truyền thống',
          price: 65000,
          isAvailable: true,
          categoryId: 'pho',
        );

        final table = RestaurantTable(
          id: 'table-1',
          tableNumber: 'T01',
          capacity: 4,
          layoutSectionId: 'main-floor',
          status: TableStatus.available,
        );

        orderService.addItem(menuItem);
        orderService.setSelectedTable(table);
        orderService.setOrderType(OrderType.dineIn);
        orderService.setCustomerNote('Phục vụ nhanh');

        final success = await orderService.submitOrder();

        expect(success, true);
        expect(orderService.error, isNull);
        expect(orderService.hasItems, false); // Order should be cleared after submission
      });
    });

    group('Helper Methods', () {
      test('should find item by ID', () {
        final menuItem = MenuItem(
          id: 'test-1',
          name: 'Phở Bò',
          description: 'Phở bò truyền thống',
          price: 65000,
          isAvailable: true,
          categoryId: 'pho',
        );

        orderService.addItem(menuItem);
        final orderItem = orderService.orderItems.first;
        
        final foundItem = orderService.getItemById(orderItem.id);
        expect(foundItem, isNotNull);
        expect(foundItem?.menuItemName, 'Phở Bò');
      });

      test('should get items by menu item ID', () {
        final menuItem = MenuItem(
          id: 'test-1',
          name: 'Phở Bò',
          description: 'Phở bò truyền thống',
          price: 65000,
          isAvailable: true,
          categoryId: 'pho',
        );

        orderService.addItem(menuItem, notes: 'Ít muối');
        orderService.addItem(menuItem, notes: 'Không cay');

        final items = orderService.getItemsByMenuItemId('test-1');
        expect(items.length, 2);
        expect(items[0].notes, 'Ít muối');
        expect(items[1].notes, 'Không cay');
      });

      test('should clear order', () {
        final menuItem = MenuItem(
          id: 'test-1',
          name: 'Phở Bò',
          description: 'Phở bò truyền thống',
          price: 65000,
          isAvailable: true,
          categoryId: 'pho',
        );

        final table = RestaurantTable(
          id: 'table-1',
          tableNumber: 'T01',
          capacity: 4,
          layoutSectionId: 'main-floor',
          status: TableStatus.available,
        );

        orderService.addItem(menuItem);
        orderService.setSelectedTable(table);
        orderService.setCustomerNote('Test note');
        
        orderService.clearOrder();

        expect(orderService.hasItems, false);
        expect(orderService.selectedTable, isNull);
        expect(orderService.customerNote, isEmpty);
        expect(orderService.orderType, OrderType.dineIn);
      });
    });
  });
}