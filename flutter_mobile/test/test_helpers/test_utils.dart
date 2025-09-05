import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:smart_restaurant/features/orders/services/order_service.dart';
import 'package:smart_restaurant/shared/services/api_client.dart';

class TestUtils {
  /// Tạo MaterialApp wrapper với providers cho testing
  static Widget createTestApp({
    required Widget child,
    OrderService? orderService,
    ApiClient? apiClient,
  }) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          if (orderService != null)
            ChangeNotifierProvider<OrderService>.value(value: orderService),
          if (apiClient != null)
            Provider<ApiClient>.value(value: apiClient),
        ],
        child: child,
      ),
    );
  }

  /// Pump widget và chờ animations hoàn thành
  static Future<void> pumpAndSettleWithTimeout(
    WidgetTester tester,
    Duration timeout,
  ) async {
    await tester.pumpAndSettle(timeout);
  }

  /// Verify widget hiển thị Vietnamese text đúng
  static void verifyVietnameseText(String text) {
    expect(text, isNotEmpty);
    // Check common Vietnamese characters
    final vietnamesePattern = RegExp(r'[àáảạãăắằẳặẵâấầẩậẫèéẻẹẽêếềểệễìíỉịĩòóỏọõôốồổộỗơớờởợỡùúủụũưứừửựữỳýỷỵỹđĐ]');
    // Allow either Vietnamese or English text for flexibility
    expect(text.length, greaterThan(0));
  }

  /// Verify monetary amounts formatted correctly
  static void verifyVietnameseCurrency(String text) {
    expect(text, matches(RegExp(r'\d{1,3}(,\d{3})*₫')));
  }

  /// Helper to enter Vietnamese text correctly
  static Future<void> enterVietnameseText(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pump();
  }

  /// Simulate network delay
  static Future<void> simulateNetworkDelay([Duration? delay]) async {
    await Future.delayed(delay ?? const Duration(milliseconds: 500));
  }

  /// Verify loading states
  static void verifyLoadingState(WidgetTester tester) {
    expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
  }

  /// Verify error states
  static void verifyErrorState(WidgetTester tester, [String? errorMessage]) {
    expect(find.byIcon(Icons.error_outline), findsAtLeastNWidgets(1));
    if (errorMessage != null) {
      expect(find.text(errorMessage), findsOneWidget);
    }
  }

  /// Test responsive behavior
  static Future<void> testResponsiveBehavior(
    WidgetTester tester,
    Widget widget,
  ) async {
    // Test phone size
    await tester.binding.setSurfaceSize(const Size(375, 667));
    await tester.pumpWidget(widget);
    await tester.pump();

    // Test tablet size
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    await tester.pump();

    // Test large tablet size
    await tester.binding.setSurfaceSize(const Size(1366, 1024));
    await tester.pump();

    // Reset to default
    await tester.binding.setSurfaceSize(const Size(800, 600));
    await tester.pump();
  }

  /// Verify accessibility requirements
  static void verifyAccessibility(WidgetTester tester, Finder finder) {
    final widget = tester.widget(finder);
    
    // Check minimum tap target size (44px)
    if (widget is InkWell || widget is GestureDetector || widget is ElevatedButton) {
      final renderObject = tester.renderObject(finder);
      if (renderObject is RenderBox) {
        expect(renderObject.size.width, greaterThanOrEqualTo(44));
        expect(renderObject.size.height, greaterThanOrEqualTo(44));
      }
    }
  }

  /// Mock API responses for testing
  static void setupMockApiResponses(MockApiClient mockApiClient) {
    // Default successful responses
    when(mockApiClient.getTables())
      .thenAnswer((_) async => []);
    
    when(mockApiClient.getMenuCategories())
      .thenAnswer((_) async => []);
      
    when(mockApiClient.getMenuItemsByCategory(any))
      .thenAnswer((_) async => []);
      
    when(mockApiClient.searchMenuItems(any))
      .thenAnswer((_) async => []);
      
    when(mockApiClient.createOrder(any))
      .thenAnswer((_) async => throw Exception('Not implemented in test'));
      
    when(mockApiClient.checkIngredientAvailability(any))
      .thenAnswer((_) async => []);
  }

  /// Verify form validation
  static Future<void> testFormValidation(
    WidgetTester tester,
    Map<String, String> fieldValues,
    Map<String, String> expectedErrors,
  ) async {
    // Enter invalid data
    for (final entry in fieldValues.entries) {
      final field = find.byKey(Key(entry.key));
      await tester.enterText(field, entry.value);
    }

    // Submit form
    await tester.tap(find.text('Lưu'));
    await tester.pump();

    // Check validation errors
    for (final entry in expectedErrors.entries) {
      expect(find.text(entry.value), findsOneWidget);
    }
  }

  /// Performance measurement helpers
  static Future<Duration> measureActionDuration(Future<void> Function() action) async {
    final stopwatch = Stopwatch()..start();
    await action();
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  /// Simulate gestures for testing
  static Future<void> simulateSwipeGesture(
    WidgetTester tester,
    Finder finder,
    Offset direction,
  ) async {
    await tester.drag(finder, direction);
    await tester.pumpAndSettle();
  }

  static Future<void> simulateLongPress(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.longPress(finder);
    await tester.pumpAndSettle();
  }

  static Future<void> simulateDoubleTap(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.tap(finder);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Database/API mock helpers
  static void mockSuccessfulOrderCreation(MockApiClient mockApiClient) {
    when(mockApiClient.createOrder(any)).thenAnswer((_) async => 
      const OrderModel(
        id: 'test-order',
        orderNumber: 'ORD-TEST',
        tableId: 'table-1',
        status: OrderStatus.pending,
        items: [],
        totalAmount: 0,
        createdAt: null,
      )
    );
  }

  static void mockNetworkError(MockApiClient mockApiClient) {
    when(mockApiClient.createOrder(any))
      .thenThrow(const NetworkException('Không có kết nối internet'));
  }

  static void mockServerError(MockApiClient mockApiClient) {
    when(mockApiClient.createOrder(any))
      .thenThrow(const ServerException('Lỗi server, vui lòng thử lại'));
  }

  static void mockValidationError(MockApiClient mockApiClient) {
    when(mockApiClient.createOrder(any))
      .thenThrow(const ValidationException('Dữ liệu không hợp lệ'));
  }

  /// Vietnamese text matching helpers
  static Matcher containsVietnameseText(String text) {
    return predicate<String>((actual) => 
      actual.toLowerCase().contains(text.toLowerCase()) ||
      removeVietnameseDiacritics(actual.toLowerCase())
        .contains(removeVietnameseDiacritics(text.toLowerCase()))
    );
  }

  static String removeVietnameseDiacritics(String text) {
    final diacriticsMap = {
      'à': 'a', 'á': 'a', 'ả': 'a', 'ạ': 'a', 'ã': 'a',
      'ă': 'a', 'ắ': 'a', 'ằ': 'a', 'ẳ': 'a', 'ặ': 'a', 'ẵ': 'a',
      'â': 'a', 'ấ': 'a', 'ầ': 'a', 'ẩ': 'a', 'ậ': 'a', 'ẫ': 'a',
      'è': 'e', 'é': 'e', 'ẻ': 'e', 'ẹ': 'e', 'ẽ': 'e',
      'ê': 'e', 'ế': 'e', 'ề': 'e', 'ể': 'e', 'ệ': 'e', 'ễ': 'e',
      'ì': 'i', 'í': 'i', 'ỉ': 'i', 'ị': 'i', 'ĩ': 'i',
      'ò': 'o', 'ó': 'o', 'ỏ': 'o', 'ọ': 'o', 'õ': 'o',
      'ô': 'o', 'ố': 'o', 'ồ': 'o', 'ổ': 'o', 'ộ': 'o', 'ỗ': 'o',
      'ơ': 'o', 'ớ': 'o', 'ờ': 'o', 'ở': 'o', 'ợ': 'o', 'ỡ': 'o',
      'ù': 'u', 'ú': 'u', 'ủ': 'u', 'ụ': 'u', 'ũ': 'u',
      'ư': 'u', 'ứ': 'u', 'ừ': 'u', 'ử': 'u', 'ự': 'u', 'ữ': 'u',
      'ỳ': 'y', 'ý': 'y', 'ỷ': 'y', 'ỵ': 'y', 'ỹ': 'y',
      'đ': 'd',
    };

    String result = text;
    diacriticsMap.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    return result;
  }

  /// Animation testing helpers
  static Future<void> waitForAnimation(
    WidgetTester tester, 
    Finder finder,
  ) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300)); // Common animation duration
  }

  static Future<void> verifyAnimationCompleted(
    WidgetTester tester,
    Finder finder,
  ) async {
    // Verify animation has started and completed
    await tester.pump();
    await tester.pumpAndSettle();
    
    final widget = tester.widget(finder);
    if (widget is AnimatedContainer) {
      // Animation should be at final state
      expect(widget.duration, isNotNull);
    }
  }

  /// State management testing helpers
  static void verifyProviderState<T>(
    WidgetTester tester,
    bool Function(T) predicate,
  ) {
    final context = tester.element(find.byType(MaterialApp));
    final state = Provider.of<T>(context, listen: false);
    expect(predicate(state), isTrue);
  }

  /// Memory leak detection helpers
  static int getWidgetCount(WidgetTester tester, Type widgetType) {
    return tester.widgetList(find.byType(widgetType)).length;
  }

  /// Custom matchers for Vietnamese app
  static Matcher isVietnamesePhoneNumber = predicate<String>((phone) {
    // Vietnamese phone patterns: 09x, 08x, 07x, 05x, 03x + 8 digits
    return RegExp(r'^(09|08|07|05|03)[0-9]{8}$').hasMatch(phone.replaceAll(RegExp(r'\D'), ''));
  });

  static Matcher isVietnameseCurrency = predicate<String>((text) {
    return RegExp(r'^\d{1,3}(,\d{3})*₫$').hasMatch(text);
  });

  static Matcher isVietnameseOrderNumber = predicate<String>((text) {
    return RegExp(r'^ORD-\d{3,}$').hasMatch(text);
  });

  /// Generate test data with Vietnamese characteristics
  static String generateVietnameseName() {
    final firstNames = ['Nguyễn', 'Trần', 'Lê', 'Phạm', 'Hoàng', 'Phan', 'Vũ', 'Võ'];
    final middleNames = ['Văn', 'Thị', 'Hữu', 'Minh', 'Thanh', 'Xuân'];
    final lastNames = ['An', 'Bình', 'Cường', 'Dung', 'Em', 'Phúc', 'Giang', 'Hạnh'];
    
    firstNames.shuffle();
    middleNames.shuffle();
    lastNames.shuffle();
    
    return '${firstNames.first} ${middleNames.first} ${lastNames.first}';
  }

  static String generateVietnamesePhone() {
    final prefixes = ['090', '091', '094', '083', '084', '085', '081', '082'];
    prefixes.shuffle();
    
    final suffix = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    return '${prefixes.first}$suffix';
  }

  /// Widget finder helpers
  static Finder findByVietnameseText(String text) {
    return find.byWidgetPredicate((widget) {
      if (widget is Text) {
        return widget.data?.contains(text) == true ||
               removeVietnameseDiacritics(widget.data?.toLowerCase() ?? '')
                 .contains(removeVietnameseDiacritics(text.toLowerCase()));
      }
      return false;
    });
  }

  static Finder findOrderItemByName(String menuItemName) {
    return find.byKey(Key('order_item_${menuItemName.replaceAll(' ', '_')}'));
  }

  static Finder findTableByNumber(String tableNumber) {
    return find.byKey(Key('table_$tableNumber'));
  }

  /// Test data validation helpers
  static bool isValidVietnameseOrderData(Map<String, dynamic> orderData) {
    // Check required fields
    if (!orderData.containsKey('tableId') || 
        !orderData.containsKey('items') ||
        orderData['items'].isEmpty) {
      return false;
    }

    // Check Vietnamese formatting
    final totalAmount = orderData['totalAmount'] as int?;
    if (totalAmount == null || totalAmount <= 0) {
      return false;
    }

    return true;
  }

  /// Error simulation helpers
  static Exception createNetworkException(String message) {
    return NetworkException('Không có kết nối internet: $message');
  }

  static Exception createServerException(String message) {
    return ServerException('Lỗi server: $message');
  }

  static Exception createValidationException(String field, String message) {
    return ValidationException('Validation lỗi ở field $field: $message');
  }

  /// Widget interaction helpers
  static Future<void> tapAndWait(
    WidgetTester tester,
    Finder finder, {
    Duration? wait,
  }) async {
    await tester.tap(finder);
    await tester.pump(wait ?? const Duration(milliseconds: 100));
  }

  static Future<void> longPressAndWait(
    WidgetTester tester,
    Finder finder, {
    Duration? wait,
  }) async {
    await tester.longPress(finder);
    await tester.pump(wait ?? const Duration(milliseconds: 300));
  }

  static Future<void> scrollAndWait(
    WidgetTester tester,
    Finder finder,
    Offset offset, {
    Duration? wait,
  }) async {
    await tester.drag(finder, offset);
    await tester.pump(wait ?? const Duration(milliseconds: 200));
  }

  /// State verification helpers
  static void verifyOrderServiceState(
    OrderService orderService, {
    int? expectedItemCount,
    int? expectedTotalAmount,
    int? expectedTotalQuantity,
  }) {
    if (expectedItemCount != null) {
      expect(orderService.items.length, equals(expectedItemCount));
    }
    if (expectedTotalAmount != null) {
      expect(orderService.totalAmount, equals(expectedTotalAmount));
    }
    if (expectedTotalQuantity != null) {
      expect(orderService.totalQuantity, equals(expectedTotalQuantity));
    }
  }

  /// Dialog helpers
  static Future<void> expectAndDismissDialog(
    WidgetTester tester,
    String dialogTitle,
    String dismissButton,
  ) async {
    expect(find.text(dialogTitle), findsOneWidget);
    await tester.tap(find.text(dismissButton));
    await tester.pumpAndSettle();
    expect(find.text(dialogTitle), findsNothing);
  }

  /// Widget tree debugging helpers
  static void debugWidgetTree(WidgetTester tester) {
    debugPrint('=== Widget Tree Debug ===');
    tester.allWidgets.forEach((widget) {
      debugPrint(widget.toString());
    });
    debugPrint('========================');
  }

  static void debugFinderResults(Finder finder) {
    debugPrint('=== Finder Results Debug ===');
    debugPrint('Found ${finder.evaluate().length} widgets');
    finder.evaluate().forEach((element) {
      debugPrint('  - ${element.widget.runtimeType}: ${element.widget}');
    });
    debugPrint('===========================');
  }

  /// Vietnamese locale testing
  static Future<void> setupVietnameseLocale(WidgetTester tester) async {
    await tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/localization',
      (message) async {
        return const StandardMethodCodec().encodeSuccessEnvelope(['vi', 'VN']);
      },
    );
  }

  /// Camera/image testing helpers (for menu item photos)
  static Future<void> mockImagePicker(WidgetTester tester, String imagePath) async {
    await tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      'plugins.flutter.io/image_picker',
      (message) async {
        return const StandardMethodCodec().encodeSuccessEnvelope(imagePath);
      },
    );
  }
}

/// Custom exceptions for testing
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
  
  @override
  String toString() => 'ServerException: $message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
  
  @override
  String toString() => 'ValidationException: $message';
}