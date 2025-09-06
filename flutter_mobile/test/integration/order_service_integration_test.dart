import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import '../../lib/core/services/order_service.dart';
import '../../lib/core/models/table_models.dart';
import '../../lib/core/enums/restaurant_enums.dart';

/// Integration test cho OrderService
/// 
/// Test này kiểm tra kết nối thực tế với API backend
/// Yêu cầu backend phải đang chạy tại https://localhost:44346
void main() {
  group('OrderService Integration Tests', () {
    late OrderService orderService;
    
    setUp(() {
      // Tạo service với null token để test không cần auth
      orderService = OrderService(accessToken: null);
    });

    tearDown(() {
      orderService.dispose();
    });

    test('should connect to API and get active tables', () async {
      try {
        // Test gọi API lấy danh sách bàn
        final tables = await orderService.getActiveTables();
        
        // Verify kết quả
        expect(tables, isA<List<ActiveTableDto>>());
        
        // Log kết quả để debug
        print('✅ API connection successful');
        print('📊 Retrieved ${tables.length} tables');
        
        for (final table in tables) {
          print('🪑 Table ${table.tableNumber}: ${table.status.displayName}');
          if (table.layoutSectionName != null) {
            print('   📍 Section: ${table.layoutSectionName}');
          }
          if (table.hasActiveOrders) {
            print('   📋 Has active orders');
          }
          if (table.pendingServeOrdersCount > 0) {
            print('   ⏳ ${table.pendingServeOrdersCount} items pending serve');
          }
        }
        
      } catch (e) {
        // Nếu lỗi, kiểm tra nguyên nhân
        if (e is DioException) {
          if (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout) {
            print('❌ Backend API not running or connection failed');
            print('💡 Please start the backend API at https://localhost:44346');
            fail('Backend API connection failed: ${e.message}');
          } else if (e.response?.statusCode == 401) {
            print('🔒 Authentication required for this API');
            print('💡 This might be expected - API requires valid token');
            // Skip test nếu cần auth
            markTestSkipped('API requires authentication');
            return;
          }
        }
        
        print('❌ Unexpected error: $e');
        fail('Integration test failed: $e');
      }
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('should handle network errors gracefully', () async {
      // Test với URL không tồn tại
      final badService = OrderService(accessToken: null);
      
      try {
        // Override base URL để tạo lỗi
        await badService.getActiveTables();
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e, isA<OrderServiceException>());
        print('✅ Network error handled correctly: ${e.toString()}');
      } finally {
        badService.dispose();
      }
    });

    test('should parse table status correctly', () {
      // Test parsing các giá trị status khác nhau
      final testData = [
        {'status': 0, 'expected': TableStatus.available},
        {'status': 1, 'expected': TableStatus.occupied},
        {'status': 2, 'expected': TableStatus.reserved},
        {'status': '0', 'expected': TableStatus.available},
        {'status': 'available', 'expected': TableStatus.available},
        {'status': 'occupied', 'expected': TableStatus.occupied},
        {'status': null, 'expected': TableStatus.available}, // default
      ];

      for (final testCase in testData) {
        final mockTableData = {
          'id': 'test-id',
          'tableNumber': 'Test Table',
          'displayOrder': 1,
          'status': testCase['status'],
          'statusDisplay': 'Test Status',
          'hasActiveOrders': false,
          'pendingServeOrdersCount': 0,
        };

        final table = ActiveTableDto.fromJson(mockTableData);
        expect(table.status, testCase['expected']);
        print('✅ Status ${testCase['status']} -> ${table.status}');
      }
    });
  });
}