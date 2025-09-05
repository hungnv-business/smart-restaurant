import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:smart_restaurant/features/orders/widgets/menu_browsing_widget.dart';
import 'package:smart_restaurant/features/orders/services/order_service.dart';
import 'package:smart_restaurant/shared/services/api_client.dart';
import 'package:smart_restaurant/shared/models/menu_models.dart';

import 'menu_browsing_widget_test.mocks.dart';

@GenerateMocks([OrderService, ApiClient])
void main() {
  group('MenuBrowsingWidget Tests', () {
    late MockOrderService mockOrderService;
    late MockApiClient mockApiClient;
    late List<MenuCategoryModel> testCategories;
    late List<MenuItemModel> testMenuItems;

    setUp(() {
      mockOrderService = MockOrderService();
      mockApiClient = MockApiClient();

      testCategories = [
        MenuCategoryModel(
          id: '1',
          name: 'Phở',
          description: 'Các loại phở truyền thống',
          sortOrder: 1,
          isActive: true,
        ),
        MenuCategoryModel(
          id: '2',
          name: 'Cơm',
          description: 'Các món cơm đa dạng',
          sortOrder: 2,
          isActive: true,
        ),
        MenuCategoryModel(
          id: '3',
          name: 'Nước uống',
          description: 'Đồ uống giải khát',
          sortOrder: 3,
          isActive: true,
        ),
      ];

      testMenuItems = [
        MenuItemModel(
          id: '1',
          name: 'Phở Bò Tái',
          description: 'Phở bò tái thơm ngon',
          price: 65000,
          categoryId: '1',
          isAvailable: true,
          imageUrl: null,
        ),
        MenuItemModel(
          id: '2',
          name: 'Phở Gà',
          description: 'Phở gà nước trong',
          price: 60000,
          categoryId: '1',
          isAvailable: true,
          imageUrl: null,
        ),
        MenuItemModel(
          id: '3',
          name: 'Cơm Tấm Sườn',
          description: 'Cơm tấm sườn nướng',
          price: 55000,
          categoryId: '2',
          isAvailable: false, // Out of stock
          imageUrl: null,
        ),
      ];

      when(mockApiClient.getMenuCategories()).thenAnswer((_) async => testCategories);
      when(mockApiClient.getMenuItemsByCategory('1')).thenAnswer((_) async => 
        testMenuItems.where((item) => item.categoryId == '1').toList()
      );
      when(mockApiClient.getMenuItemsByCategory('2')).thenAnswer((_) async => 
        testMenuItems.where((item) => item.categoryId == '2').toList()
      );
      when(mockApiClient.searchMenuItems('phở')).thenAnswer((_) async => 
        testMenuItems.where((item) => 
          item.name.toLowerCase().contains('phở')).toList()
      );
    });

    Widget createWidget({VoidCallback? onItemAdded}) {
      return MaterialApp(
        home: ChangeNotifierProvider<OrderService>.value(
          value: mockOrderService,
          child: MenuBrowsingWidget(
            onItemAdded: onItemAdded ?? () {},
          ),
        ),
      );
    }

    testWidgets('hiển thị danh mục menu khi load thành công', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Assert - Should show category tabs
      expect(find.text('Phở'), findsOneWidget);
      expect(find.text('Cơm'), findsOneWidget);
      expect(find.text('Nước uống'), findsOneWidget);
    });

    testWidgets('hiển thị món ăn khi chọn danh mục', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();
      
      // Tap Phở category
      await tester.tap(find.text('Phở'));
      await tester.pump();

      // Assert - Should show Phở items
      expect(find.text('Phở Bò Tái'), findsOneWidget);
      expect(find.text('Phở Gà'), findsOneWidget);
      expect(find.text('65,000₫'), findsOneWidget);
      expect(find.text('60,000₫'), findsOneWidget);
    });

    testWidgets('tìm kiếm món ăn hoạt động đúng', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Enter search query
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      
      await tester.enterText(searchField, 'phở');
      await tester.pump(const Duration(milliseconds: 500)); // Debounce delay

      // Assert - Should show search results
      expect(find.text('Phở Bò Tái'), findsOneWidget);
      expect(find.text('Phở Gà'), findsOneWidget);
      expect(find.text('Cơm Tấm Sườn'), findsNothing);
    });

    testWidgets('hiển thị placeholder khi tìm kiếm không có kết quả', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);
      when(mockApiClient.searchMenuItems('xyz')).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump(const Duration(milliseconds: 500));

      // Assert
      expect(find.text('Không tìm thấy món ăn nào'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('hiển thị trạng thái "hết hàng" cho món không có sẵn', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();
      
      // Select Cơm category to see unavailable item
      await tester.tap(find.text('Cơm'));
      await tester.pump();

      // Assert
      expect(find.text('Cơm Tấm Sườn'), findsOneWidget);
      expect(find.text('Hết hàng'), findsOneWidget);
      
      // Check that item card is grayed out
      final itemCard = find.byKey(const Key('menu_item_3'));
      expect(itemCard, findsOneWidget);
    });

    testWidgets('thêm món vào order khi tap', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);
      bool itemAdded = false;
      MenuItemModel? addedItem;

      final widget = MaterialApp(
        home: ChangeNotifierProvider<OrderService>.value(
          value: mockOrderService,
          child: MenuBrowsingWidget(
            onItemAdded: () {
              itemAdded = true;
            },
          ),
        ),
      );

      // Mock addItem method
      when(mockOrderService.addItem(any)).thenAnswer((invocation) async {
        addedItem = invocation.positionalArguments[0] as MenuItemModel;
      });

      // Act
      await tester.pumpWidget(widget);
      await tester.pump();
      
      await tester.tap(find.text('Phở'));
      await tester.pump();
      
      await tester.tap(find.text('Phở Bò Tái'));
      await tester.pump();

      // Assert
      expect(itemAdded, isTrue);
      verify(mockOrderService.addItem(any)).called(1);
    });

    testWidgets('không thể thêm món hết hàng', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);
      bool itemAdded = false;

      final widget = MaterialApp(
        home: ChangeNotifierProvider<OrderService>.value(
          value: mockOrderService,
          child: MenuBrowsingWidget(
            onItemAdded: () {
              itemAdded = true;
            },
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pump();
      
      await tester.tap(find.text('Cơm'));
      await tester.pump();
      
      // Try to tap unavailable item
      await tester.tap(find.text('Cơm Tấm Sườn'));
      await tester.pump();

      // Assert - Should not add item
      expect(itemAdded, isFalse);
      verifyNever(mockOrderService.addItem(any));
    });

    testWidgets('hiển thị số lượng món trong order badge', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);
      when(mockOrderService.items).thenReturn([
        OrderItemModel(
          id: '1',
          menuItemId: '1',
          menuItemName: 'Phở Bò',
          unitPrice: 65000,
          quantity: 2,
          notes: '',
          status: OrderItemStatus.pending,
        ),
      ]);
      when(mockOrderService.totalQuantity).thenReturn(2);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Assert - Should show cart badge
      expect(find.text('2'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    });

    testWidgets('voice search hoạt động đúng', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Find and tap voice search button
      final voiceButton = find.byIcon(Icons.mic);
      expect(voiceButton, findsOneWidget);
      
      await tester.tap(voiceButton);
      await tester.pump();

      // Assert - Should show voice input UI
      expect(find.text('Nói tên món ăn...'), findsOneWidget);
      expect(find.byIcon(Icons.mic_none), findsOneWidget);
    });

    testWidgets('filter theo giá hoạt động đúng', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();
      
      // Open price filter
      final filterButton = find.byIcon(Icons.filter_list);
      await tester.tap(filterButton);
      await tester.pump();

      // Set price range
      await tester.tap(find.text('50,000₫ - 100,000₫'));
      await tester.pump();

      await tester.tap(find.text('Áp dụng'));
      await tester.pump();

      // All items should be visible as they're in range
      await tester.tap(find.text('Phở'));
      await tester.pump();
      
      expect(find.text('Phở Bò Tái'), findsOneWidget);
      expect(find.text('Phở Gà'), findsOneWidget);
    });

    testWidgets('hiển thị loading khi switch giữa các category', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);
      when(mockApiClient.getMenuItemsByCategory('2')).thenAnswer((_) => 
        Future.delayed(const Duration(milliseconds: 500), () => 
          testMenuItems.where((item) => item.categoryId == '2').toList())
      );

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      await tester.tap(find.text('Cơm'));
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - Should show loading for that category
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for data
      await tester.pump(const Duration(milliseconds: 500));
      
      expect(find.text('Cơm Tấm Sườn'), findsOneWidget);
    });

    testWidgets('scroll loading thêm món khi cuộn đến cuối', (tester) async {
      // Arrange - Large menu list
      final largeMenuItems = List.generate(50, (index) => 
        MenuItemModel(
          id: '$index',
          name: 'Phở số $index',
          description: 'Phở ngon số $index', 
          price: 60000 + (index * 1000),
          categoryId: '1',
          isAvailable: true,
          imageUrl: null,
        )
      );

      when(mockOrderService.apiClient).thenReturn(mockApiClient);
      when(mockApiClient.getMenuItemsByCategory('1')).thenAnswer((_) async => 
        largeMenuItems.take(20).toList() // First page
      );

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();
      
      await tester.tap(find.text('Phở'));
      await tester.pump();

      // Initially shows 20 items
      expect(find.text('Phở số 0'), findsOneWidget);
      expect(find.text('Phở số 19'), findsOneWidget);
      
      // Scroll to bottom to trigger pagination
      final listView = find.byType(ListView);
      await tester.drag(listView, const Offset(0, -500));
      await tester.pump();

      // Should trigger loading more items
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hiển thị thông tin dinh dưỡng khi tap info', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();
      
      await tester.tap(find.text('Phở'));
      await tester.pump();

      // Find and tap info button on first item
      final infoButton = find.byKey(const Key('menu_item_info_1'));
      await tester.tap(infoButton);
      await tester.pump();

      // Assert - Should show nutrition info dialog
      expect(find.text('Thông tin dinh dưỡng'), findsOneWidget);
      expect(find.text('Phở Bò Tái'), findsOneWidget);
      expect(find.text('Calo'), findsOneWidget);
      expect(find.text('Protein'), findsOneWidget);
    });

    testWidgets('favorite hoạt động đúng', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();
      
      await tester.tap(find.text('Phở'));
      await tester.pump();

      // Find and tap favorite button
      final favoriteButton = find.byKey(const Key('favorite_button_1'));
      await tester.tap(favoriteButton);
      await tester.pump();

      // Assert - Should show as favorited
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      
      // Tap again to unfavorite
      await tester.tap(favoriteButton);
      await tester.pump();
      
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('quick add button thêm món nhanh', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);
      bool itemAdded = false;

      final widget = createWidget(onItemAdded: () {
        itemAdded = true;
      });

      // Act
      await tester.pumpWidget(widget);
      await tester.pump();
      
      await tester.tap(find.text('Phở'));
      await tester.pump();

      // Find and tap quick add button
      final quickAddButton = find.byKey(const Key('quick_add_1'));
      await tester.tap(quickAddButton);
      await tester.pump();

      // Assert
      expect(itemAdded, isTrue);
      verify(mockOrderService.addItem(any)).called(1);
    });

    testWidgets('custom quantity dialog hoạt động', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();
      
      await tester.tap(find.text('Phở'));
      await tester.pump();

      // Long press to open quantity dialog
      await tester.longPress(find.text('Phở Bò Tái'));
      await tester.pump();

      // Assert - Should show quantity dialog
      expect(find.text('Chọn số lượng'), findsOneWidget);
      expect(find.text('Ghi chú'), findsOneWidget);
      
      // Change quantity
      final quantityField = find.byType(TextField).first;
      await tester.enterText(quantityField, '3');
      
      // Add notes
      final notesField = find.byType(TextField).last;
      await tester.enterText(notesField, 'Ít muối');

      // Confirm
      await tester.tap(find.text('Thêm vào order'));
      await tester.pump();

      // Should call addItem with correct quantity and notes
      verify(mockOrderService.addItem(any, quantity: 3, notes: 'Ít muối')).called(1);
    });

    testWidgets('floating search suggestions hoạt động', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);
      when(mockApiClient.getSearchSuggestions('ph')).thenAnswer((_) async => [
        'Phở Bò', 'Phở Gà', 'Phở Chay'
      ]);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Enter partial search
      await tester.enterText(find.byType(TextField), 'ph');
      await tester.pump(const Duration(milliseconds: 300));

      // Assert - Should show suggestions
      expect(find.text('Phở Bò'), findsOneWidget);
      expect(find.text('Phở Gà'), findsOneWidget);
      expect(find.text('Phở Chay'), findsOneWidget);

      // Tap suggestion
      await tester.tap(find.text('Phở Bò'));
      await tester.pump();

      // Should update search field
      final searchField = find.byType(TextField);
      expect(
        (tester.widget(searchField) as TextField).controller?.text,
        equals('Phở Bò')
      );
    });

    testWidgets('grid/list view toggle hoạt động', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();
      
      await tester.tap(find.text('Phở'));
      await tester.pump();

      // Initially in grid view
      expect(find.byType(GridView), findsOneWidget);

      // Toggle to list view
      final viewToggle = find.byIcon(Icons.list);
      await tester.tap(viewToggle);
      await tester.pump();

      // Should switch to list view
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
    });

    testWidgets('pull-to-refresh hoạt động đúng', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();
      
      await tester.tap(find.text('Phở'));
      await tester.pump();

      // Pull to refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert - Should call API again
      verify(mockApiClient.getMenuItemsByCategory('1')).called(2); // Once on load, once on refresh
    });

    testWidgets('sort options hoạt động đúng', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();
      
      await tester.tap(find.text('Phở'));
      await tester.pump();

      // Open sort options
      final sortButton = find.byIcon(Icons.sort);
      await tester.tap(sortButton);
      await tester.pump();

      // Assert - Should show sort options
      expect(find.text('Sắp xếp theo'), findsOneWidget);
      expect(find.text('Tên A-Z'), findsOneWidget);
      expect(find.text('Giá thấp → cao'), findsOneWidget);
      expect(find.text('Giá cao → thấp'), findsOneWidget);
      expect(find.text('Phổ biến'), findsOneWidget);

      // Select price sort
      await tester.tap(find.text('Giá thấp → cao'));
      await tester.pump();

      // Items should be reordered by price
      final firstItemPrice = find.text('60,000₫');
      final secondItemPrice = find.text('65,000₫');
      
      // Verify order (Phở Gà 60k should come before Phở Bò Tái 65k)
      expect(firstItemPrice, findsOneWidget);
      expect(secondItemPrice, findsOneWidget);
    });

    testWidgets('accessibility support đầy đủ', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();
      
      await tester.tap(find.text('Phở'));
      await tester.pump();

      // Assert - Check semantic labels
      final menuItem = find.byKey(const Key('menu_item_1'));
      expect(tester.getSemantics(menuItem).label, 
        contains('Phở Bò Tái, 65,000 đồng'));
      
      // Check button semantics
      final addButton = find.byKey(const Key('quick_add_1'));
      expect(tester.getSemantics(addButton).label,
        equals('Thêm Phở Bò Tái vào đơn hàng'));
    });
  });
}