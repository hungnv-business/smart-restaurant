import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../tables/models/table_models.dart';

class TableService extends ChangeNotifier {
  final List<RestaurantTable> _tables = [];
  final StreamController<List<RestaurantTable>> _tablesController = 
      StreamController<List<RestaurantTable>>.broadcast();
  
  Timer? _refreshTimer;
  bool _isLoading = false;
  String? _error;

  List<RestaurantTable> get tables => List.unmodifiable(_tables);
  Stream<List<RestaurantTable>> get tablesStream => _tablesController.stream;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TableService() {
    _initializeMockData();
    _startPeriodicRefresh();
  }

  void _initializeMockData() {
    _tables.addAll([
      RestaurantTable(
        id: '1',
        tableNumber: 'T01',
        capacity: 4,
        layoutSectionId: 'main-floor',
        status: TableStatus.available,
      ),
      RestaurantTable(
        id: '2',
        tableNumber: 'T02',
        capacity: 2,
        layoutSectionId: 'main-floor',
        status: TableStatus.occupied,
      ),
      RestaurantTable(
        id: '3',
        tableNumber: 'T03',
        capacity: 6,
        layoutSectionId: 'main-floor',
        status: TableStatus.available,
      ),
      RestaurantTable(
        id: '4',
        tableNumber: 'T04',
        capacity: 4,
        layoutSectionId: 'main-floor',
        status: TableStatus.reserved,
      ),
      RestaurantTable(
        id: '5',
        tableNumber: 'T05',
        capacity: 2,
        layoutSectionId: 'vip-section',
        status: TableStatus.cleaning,
      ),
      RestaurantTable(
        id: '6',
        tableNumber: 'T06',
        capacity: 8,
        layoutSectionId: 'vip-section',
        status: TableStatus.available,
      ),
      RestaurantTable(
        id: '7',
        tableNumber: 'T07',
        capacity: 2,
        layoutSectionId: 'terrace',
        status: TableStatus.available,
      ),
      RestaurantTable(
        id: '8',
        tableNumber: 'T08',
        capacity: 4,
        layoutSectionId: 'terrace',
        status: TableStatus.occupied,
      ),
      RestaurantTable(
        id: '9',
        tableNumber: 'T09',
        capacity: 6,
        layoutSectionId: 'private-room',
        status: TableStatus.available,
      ),
      RestaurantTable(
        id: '10',
        tableNumber: 'T10',
        capacity: 10,
        layoutSectionId: 'private-room',
        status: TableStatus.reserved,
      ),
    ]);
    _tablesController.add(_tables);
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshTableStatus();
    });
  }

  Future<void> refreshTables() async {
    _setLoading(true);
    _setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate some status changes for demo
      _simulateStatusChanges();
      
      _tablesController.add(_tables);
      notifyListeners();
    } catch (e) {
      _setError('Không thể tải danh sách bàn: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _refreshTableStatus() {
    // Simulate random status changes for demo
    _simulateStatusChanges();
    _tablesController.add(_tables);
    notifyListeners();
  }

  void _simulateStatusChanges() {
    // Randomly change some table statuses for demo
    for (int i = 0; i < _tables.length; i++) {
      if (DateTime.now().millisecondsSinceEpoch % (i + 3) == 0) {
        switch (_tables[i].status) {
          case TableStatus.occupied:
            if (DateTime.now().millisecondsSinceEpoch % 7 == 0) {
              _updateTableStatus(_tables[i].id, TableStatus.cleaning);
            }
            break;
          case TableStatus.cleaning:
            if (DateTime.now().millisecondsSinceEpoch % 5 == 0) {
              _updateTableStatus(_tables[i].id, TableStatus.available);
            }
            break;
          case TableStatus.reserved:
            if (DateTime.now().millisecondsSinceEpoch % 9 == 0) {
              _updateTableStatus(_tables[i].id, TableStatus.occupied);
            }
            break;
          default:
            // Available tables stay available for selection
            break;
        }
      }
    }
  }

  List<RestaurantTable> getTablesByStatus(TableStatus status) {
    return _tables.where((table) => table.status == status).toList();
  }

  List<RestaurantTable> getAvailableTables() {
    return getTablesByStatus(TableStatus.available);
  }

  List<RestaurantTable> searchTables(String query) {
    if (query.trim().isEmpty) return _tables;
    
    final lowerQuery = query.trim().toLowerCase();
    return _tables.where((table) {
      return table.tableNumber.toLowerCase().contains(lowerQuery) ||
             table.capacity.toString().contains(lowerQuery) ||
             table.status.displayName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<RestaurantTable> getTablesByCapacity(int minCapacity, int maxCapacity) {
    return _tables.where((table) =>
        table.capacity >= minCapacity && table.capacity <= maxCapacity
    ).toList();
  }

  RestaurantTable? getTableById(String id) {
    try {
      return _tables.firstWhere((table) => table.id == id);
    } catch (e) {
      return null;
    }
  }

  void _updateTableStatus(String tableId, TableStatus newStatus) {
    final index = _tables.indexWhere((table) => table.id == tableId);
    if (index != -1) {
      final updatedTable = RestaurantTable(
        id: _tables[index].id,
        tableNumber: _tables[index].tableNumber,
        capacity: _tables[index].capacity,
        layoutSectionId: _tables[index].layoutSectionId,
        status: newStatus,
        lastModifiedTime: DateTime.now(),
      );
      _tables[index] = updatedTable;
    }
  }

  Future<bool> reserveTable(String tableId) async {
    try {
      _setLoading(true);
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      _updateTableStatus(tableId, TableStatus.occupied);
      _tablesController.add(_tables);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Không thể đặt bàn: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tablesController.close();
    super.dispose();
  }
}

enum TableFilterOption {
  all,
  available,
  occupied,
  reserved,
  cleaning;

  String get displayName {
    switch (this) {
      case TableFilterOption.all:
        return 'Tất cả';
      case TableFilterOption.available:
        return 'Có sẵn';
      case TableFilterOption.occupied:
        return 'Đang sử dụng';
      case TableFilterOption.reserved:
        return 'Đã đặt trước';
      case TableFilterOption.cleaning:
        return 'Đang dọn dẹp';
    }
  }

  TableStatus? get status {
    switch (this) {
      case TableFilterOption.all:
        return null;
      case TableFilterOption.available:
        return TableStatus.available;
      case TableFilterOption.occupied:
        return TableStatus.occupied;
      case TableFilterOption.reserved:
        return TableStatus.reserved;
      case TableFilterOption.cleaning:
        return TableStatus.cleaning;
    }
  }
}

enum CapacityFilter {
  all,
  small,
  medium,
  large;

  String get displayName {
    switch (this) {
      case CapacityFilter.all:
        return 'Tất cả';
      case CapacityFilter.small:
        return '1-2 chỗ';
      case CapacityFilter.medium:
        return '3-4 chỗ';
      case CapacityFilter.large:
        return '5+ chỗ';
    }
  }

  (int, int) get capacityRange {
    switch (this) {
      case CapacityFilter.all:
        return (1, 20);
      case CapacityFilter.small:
        return (1, 2);
      case CapacityFilter.medium:
        return (3, 4);
      case CapacityFilter.large:
        return (5, 20);
    }
  }
}