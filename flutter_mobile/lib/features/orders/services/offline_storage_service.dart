import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_models.dart';

class OfflineStorageService extends ChangeNotifier {
  static const String _pendingOrdersKey = 'pending_orders';
  static const String _orderDraftsKey = 'order_drafts';
  static const String _offlineModeKey = 'offline_mode_enabled';
  
  bool _isOfflineMode = false;
  final List<Order> _pendingOrders = [];
  final List<OrderDraft> _orderDrafts = [];
  
  bool get isOfflineMode => _isOfflineMode;
  int get pendingOrdersCount => _pendingOrders.length;
  List<Order> get pendingOrders => List.unmodifiable(_pendingOrders);

  OfflineStorageService() {
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load offline mode state
      _isOfflineMode = prefs.getBool(_offlineModeKey) ?? false;
      
      // Load pending orders
      final pendingOrdersJson = prefs.getString(_pendingOrdersKey);
      if (pendingOrdersJson != null) {
        final List<dynamic> ordersList = jsonDecode(pendingOrdersJson);
        _pendingOrders.clear();
        _pendingOrders.addAll(
          ordersList.map((json) => Order.fromJson(json as Map<String, dynamic>)),
        );
      }
      
      // Load order drafts
      final draftsJson = prefs.getString(_orderDraftsKey);
      if (draftsJson != null) {
        final List<dynamic> draftsList = jsonDecode(draftsJson);
        _orderDrafts.clear();
        _orderDrafts.addAll(
          draftsList.map((json) => OrderDraft.fromJson(json as Map<String, dynamic>)),
        );
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading offline data: $e');
    }
  }

  Future<void> enableOfflineMode() async {
    _isOfflineMode = true;
    await _saveOfflineModeState();
    notifyListeners();
  }

  Future<void> disableOfflineMode() async {
    _isOfflineMode = false;
    await _saveOfflineModeState();
    notifyListeners();
  }

  Future<void> _saveOfflineModeState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_offlineModeKey, _isOfflineMode);
    } catch (e) {
      debugPrint('Error saving offline mode state: $e');
    }
  }

  Future<bool> saveOrderOffline(Order order) async {
    try {
      _pendingOrders.add(order);
      await _savePendingOrders();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error saving order offline: $e');
      return false;
    }
  }

  Future<bool> saveDraft(OrderDraft draft) async {
    try {
      final existingIndex = _orderDrafts.indexWhere((d) => d.id == draft.id);
      if (existingIndex != -1) {
        _orderDrafts[existingIndex] = draft;
      } else {
        _orderDrafts.add(draft);
      }
      
      await _saveDrafts();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error saving draft: $e');
      return false;
    }
  }

  Future<bool> deleteDraft(String draftId) async {
    try {
      _orderDrafts.removeWhere((draft) => draft.id == draftId);
      await _saveDrafts();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting draft: $e');
      return false;
    }
  }

  Future<List<OrderDraft>> getDrafts() async {
    return List.from(_orderDrafts);
  }

  Future<OrderDraft?> getDraft(String draftId) async {
    try {
      return _orderDrafts.firstWhere((draft) => draft.id == draftId);
    } catch (e) {
      return null;
    }
  }

  Future<List<Order>> getPendingOrders() async {
    return List.from(_pendingOrders);
  }

  Future<int> syncPendingData() async {
    if (_pendingOrders.isEmpty) return 0;

    int syncedCount = 0;
    final ordersToSync = List<Order>.from(_pendingOrders);

    for (final order in ordersToSync) {
      try {
        // Simulate API call to sync order
        await Future.delayed(const Duration(milliseconds: 500));
        
        // In real app, send order to backend API
        debugPrint('Syncing order: ${order.orderNumber}');
        
        // Remove from pending list if successful
        _pendingOrders.remove(order);
        syncedCount++;
        
      } catch (e) {
        debugPrint('Failed to sync order ${order.orderNumber}: $e');
        // Keep order in pending list for retry
      }
    }

    if (syncedCount > 0) {
      await _savePendingOrders();
      notifyListeners();
    }

    return syncedCount;
  }

  Future<void> _savePendingOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = jsonEncode(
        _pendingOrders.map((order) => order.toJson()).toList(),
      );
      await prefs.setString(_pendingOrdersKey, ordersJson);
    } catch (e) {
      debugPrint('Error saving pending orders: $e');
    }
  }

  Future<void> _saveDrafts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftsJson = jsonEncode(
        _orderDrafts.map((draft) => draft.toJson()).toList(),
      );
      await prefs.setString(_orderDraftsKey, draftsJson);
    } catch (e) {
      debugPrint('Error saving drafts: $e');
    }
  }

  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingOrdersKey);
      await prefs.remove(_orderDraftsKey);
      
      _pendingOrders.clear();
      _orderDrafts.clear();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing offline data: $e');
    }
  }
}

class OrderDraft {
  final String id;
  final String? tableId;
  final OrderType orderType;
  final List<OrderItem> items;
  final String customerNote;
  final DateTime lastModifiedTime;

  const OrderDraft({
    required this.id,
    this.tableId,
    required this.orderType,
    required this.items,
    required this.customerNote,
    required this.lastModifiedTime,
  });

  factory OrderDraft.fromOrder({
    required String? tableId,
    required OrderType orderType,
    required List<OrderItem> items,
    required String customerNote,
  }) {
    return OrderDraft(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tableId: tableId,
      orderType: orderType,
      items: items,
      customerNote: customerNote,
      lastModifiedTime: DateTime.now(),
    );
  }

  factory OrderDraft.fromJson(Map<String, dynamic> json) {
    return OrderDraft(
      id: json['id'] as String,
      tableId: json['tableId'] as String?,
      orderType: OrderType.values.firstWhere(
        (e) => e.toString().split('.').last == json['orderType'],
      ),
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      customerNote: json['customerNote'] as String,
      lastModifiedTime: DateTime.parse(json['lastModifiedTime'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableId': tableId,
      'orderType': orderType.toString().split('.').last,
      'items': items.map((item) => item.toJson()).toList(),
      'customerNote': customerNote,
      'lastModifiedTime': lastModifiedTime.toIso8601String(),
    };
  }

  Order toOrder() {
    return Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      orderNumber: _generateOrderNumber(),
      orderType: orderType,
      tableId: tableId,
      status: OrderStatus.pending,
      totalAmount: items.fold(0.0, (sum, item) => sum + item.totalPrice),
      notes: customerNote.isEmpty ? null : customerNote,
      items: items,
      creationTime: DateTime.now(),
    );
  }

  String _generateOrderNumber() {
    final now = DateTime.now();
    return 'OFF${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }

  OrderDraft copyWith({
    String? id,
    String? tableId,
    OrderType? orderType,
    List<OrderItem>? items,
    String? customerNote,
    DateTime? lastModifiedTime,
  }) {
    return OrderDraft(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      orderType: orderType ?? this.orderType,
      items: items ?? this.items,
      customerNote: customerNote ?? this.customerNote,
      lastModifiedTime: lastModifiedTime ?? this.lastModifiedTime,
    );
  }

  @override
  String toString() {
    return 'OrderDraft(id: $id, tableId: $tableId, orderType: $orderType, itemCount: ${items.length}, lastModified: $lastModifiedTime)';
  }
}