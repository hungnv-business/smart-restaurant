import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:smart_restaurant/features/orders/widgets/table_selection_widget.dart';
import 'package:smart_restaurant/features/orders/services/order_service.dart';
import 'package:smart_restaurant/features/orders/models/order_models.dart';
import 'package:smart_restaurant/shared/services/api_client.dart';
import 'package:smart_restaurant/shared/models/table_models.dart';

import 'table_selection_widget_test.mocks.dart';

@GenerateMocks([OrderService, ApiClient])
void main() {
  group('TableSelectionWidget Tests', () {
    late MockOrderService mockOrderService;
    late MockApiClient mockApiClient;
    late List<TableModel> testTables;

    setUp(() {
      mockOrderService = MockOrderService();
      mockApiClient = MockApiClient();
      
      testTables = [
        TableModel(
          id: '1',
          tableNumber: 'B01',
          capacity: 4,
          status: TableStatus.available,
          layoutSectionId: 'section1',
        ),
        TableModel(
          id: '2', 
          tableNumber: 'B02',
          capacity: 6,
          status: TableStatus.occupied,
          layoutSectionId: 'section1',
        ),
        TableModel(
          id: '3',
          tableNumber: 'B03', 
          capacity: 2,
          status: TableStatus.reserved,
          layoutSectionId: 'section2',
        ),
      ];

      when(mockApiClient.getTables()).thenAnswer((_) async => testTables);
    });

    Widget createWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<OrderService>.value(
          value: mockOrderService,
          child: const TableSelectionWidget(),
        ),
      );
    }

    testWidgets('hiển thị danh sách bàn khi load thành công', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump(); // Trigger rebuild after setState

      // Assert
      expect(find.text('B01'), findsOneWidget);
      expect(find.text('B02'), findsOneWidget);
      expect(find.text('B03'), findsOneWidget);
      expect(find.text('4 người'), findsOneWidget);
      expect(find.text('6 người'), findsOneWidget);
      expect(find.text('2 người'), findsOneWidget);
    });

    testWidgets('hiển thị trạng thái bàn đúng màu sắc', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Assert - Check container colors for different statuses
      final availableTable = find.byKey(const Key('table_card_1'));
      final occupiedTable = find.byKey(const Key('table_card_2'));
      final reservedTable = find.byKey(const Key('table_card_3'));
      
      expect(availableTable, findsOneWidget);
      expect(occupiedTable, findsOneWidget);
      expect(reservedTable, findsOneWidget);

      // Verify status indicators
      expect(find.text('Trống'), findsOneWidget);
      expect(find.text('Có khách'), findsOneWidget);
      expect(find.text('Đã đặt'), findsOneWidget);
    });

    testWidgets('chỉ cho phép chọn bàn trống hoặc đã đặt', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);
      bool tableSelected = false;
      String selectedTableId = '';

      final widget = MaterialApp(
        home: ChangeNotifierProvider<OrderService>.value(
          value: mockOrderService,
          child: TableSelectionWidget(
            onTableSelected: (tableId) {
              tableSelected = true;
              selectedTableId = tableId;
            },
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.pump();

      // Tap available table (should work)
      await tester.tap(find.byKey(const Key('table_card_1')));
      await tester.pump();

      // Assert
      expect(tableSelected, isTrue);
      expect(selectedTableId, equals('1'));

      // Reset
      tableSelected = false;
      selectedTableId = '';

      // Try tapping occupied table (should not work)
      await tester.tap(find.byKey(const Key('table_card_2')));
      await tester.pump();

      expect(tableSelected, isFalse);
      expect(selectedTableId, isEmpty);
    });

    testWidgets('hiển thị thông báo khi không có bàn trống', (tester) async {
      // Arrange - All tables occupied
      final occupiedTables = testTables.map((table) => 
        table.copyWith(status: TableStatus.occupied)
      ).toList();
      
      when(mockApiClient.getTables()).thenAnswer((_) async => occupiedTables);
      when(mockOrderService.apiClient).thenReturn(mockApiClient);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Assert
      expect(find.text('Tất cả bàn đang được sử dụng'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('hiển thị loading indicator khi đang tải', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);
      when(mockApiClient.getTables()).thenAnswer((_) => 
        Future.delayed(const Duration(seconds: 2), () => testTables)
      );

      // Act
      await tester.pumpWidget(createWidget());

      // Assert - Should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Đang tải danh sách bàn...'), findsOneWidget);

      // Wait for data
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Should show tables
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('B01'), findsOneWidget);
    });

    testWidgets('hiển thị thông báo lỗi khi load thất bại', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);
      when(mockApiClient.getTables()).thenThrow(Exception('Network error'));

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Assert
      expect(find.text('Có lỗi xảy ra khi tải danh sách bàn'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
    });

    testWidgets('có thể refresh danh sách bàn', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);
      when(mockApiClient.getTables()).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Verify error state
      expect(find.text('Có lỗi xảy ra khi tải danh sách bàn'), findsOneWidget);

      // Arrange for successful retry
      when(mockApiClient.getTables()).thenAnswer((_) async => testTables);

      // Act - Tap retry button
      await tester.tap(find.text('Thử lại'));
      await tester.pump();

      // Assert - Should show tables now
      expect(find.text('B01'), findsOneWidget);
      expect(find.text('Có lỗi xảy ra khi tải danh sách bàn'), findsNothing);
    });

    testWidgets('filter bàn theo layout section', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);

      // Act
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Initially shows all tables
      expect(find.text('B01'), findsOneWidget);
      expect(find.text('B02'), findsOneWidget);  
      expect(find.text('B03'), findsOneWidget);

      // Find and tap section filter
      final sectionFilter = find.byKey(const Key('section_filter'));
      expect(sectionFilter, findsOneWidget);
      
      await tester.tap(sectionFilter);
      await tester.pump();

      // Select section1
      await tester.tap(find.text('Khu vực 1'));
      await tester.pump();

      // Should only show section1 tables  
      expect(find.text('B01'), findsOneWidget);
      expect(find.text('B02'), findsOneWidget);
      expect(find.text('B03'), findsNothing);
    });

    testWidgets('responsive layout cho tablet và điện thoại', (tester) async {
      // Arrange
      when(mockOrderService.apiClient).thenReturn(mockApiClient);

      // Test tablet layout
      await tester.binding.setSurfaceSize(const Size(1024, 768));
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Should show grid layout for tablet
      final gridView = find.byType(GridView);
      expect(gridView, findsOneWidget);

      // Test phone layout
      await tester.binding.setSurfaceSize(const Size(375, 667));
      await tester.pump();

      // Should still work on phone
      expect(find.text('B01'), findsOneWidget);
    });
  });
}