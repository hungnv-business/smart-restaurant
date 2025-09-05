import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/order_models.dart';
import '../../menu/models/menu_models.dart';

class OrderService extends ChangeNotifier {
  final List<OrderItem> _orderItems = [];
  final StreamController<List<OrderItem>> _orderItemsController = 
      StreamController<List<OrderItem>>.broadcast();
  
  Map<String, dynamic>? _selectedTable; // RestaurantTable? _selectedTable;
  OrderType _orderType = OrderType.dineIn;
  String _customerNote = '';
  bool _isLoading = false;
  String? _error;

  List<OrderItem> get orderItems => List.unmodifiable(_orderItems);
  Stream<List<OrderItem>> get orderItemsStream => _orderItemsController.stream;
  Map<String, dynamic>? get selectedTable => _selectedTable; // RestaurantTable? get selectedTable => _selectedTable;
  OrderType get orderType => _orderType;
  String get customerNote => _customerNote;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasItems => _orderItems.isNotEmpty;

  double get subtotal {
    return _orderItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get vatAmount {
    const vatRate = 0.10; // 10% VAT
    return subtotal * vatRate;
  }

  double get total => subtotal + vatAmount;

  int get totalItemCount {
    return _orderItems.fold(0, (sum, item) => sum + item.quantity);
  }

  void setSelectedTable(Map<String, dynamic>? table) { // RestaurantTable? table
    _selectedTable = table;
    notifyListeners();
  }

  void setOrderType(OrderType type) {
    _orderType = type;
    notifyListeners();
  }

  void setCustomerNote(String note) {
    _customerNote = note;
    notifyListeners();
  }

  void addItem(MenuItem menuItem, {String? notes, int quantity = 1}) {
    final existingIndex = _orderItems.indexWhere((item) => 
        item.menuItemId == menuItem.id && item.notes == (notes ?? ''));
    
    if (existingIndex != -1) {
      updateItemQuantity(existingIndex, _orderItems[existingIndex].quantity + quantity);
    } else {
      final orderItem = OrderItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        orderId: '', // Will be set when order is created
        menuItemId: menuItem.id,
        menuItemName: menuItem.name,
        unitPrice: menuItem.price.toDouble(),
        quantity: quantity,
        notes: notes,
        status: OrderItemStatus.pending,
      );
      
      _orderItems.add(orderItem);
      _orderItemsController.add(_orderItems);
      notifyListeners();
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < _orderItems.length) {
      _orderItems.removeAt(index);
      _orderItemsController.add(_orderItems);
      notifyListeners();
    }
  }

  void updateItemQuantity(int index, int quantity) {
    if (index >= 0 && index < _orderItems.length) {
      if (quantity <= 0) {
        removeItem(index);
      } else {
        final updatedItem = OrderItem(
          id: _orderItems[index].id,
          orderId: _orderItems[index].orderId,
          menuItemId: _orderItems[index].menuItemId,
          menuItemName: _orderItems[index].menuItemName,
          unitPrice: _orderItems[index].unitPrice,
          quantity: quantity,
          notes: _orderItems[index].notes,
          status: _orderItems[index].status,
        );
        
        _orderItems[index] = updatedItem;
        _orderItemsController.add(_orderItems);
        notifyListeners();
      }
    }
  }

  void updateItemNotes(int index, String notes) {
    if (index >= 0 && index < _orderItems.length) {
      final updatedItem = OrderItem(
        id: _orderItems[index].id,
        orderId: _orderItems[index].orderId,
        menuItemId: _orderItems[index].menuItemId,
        menuItemName: _orderItems[index].menuItemName,
        unitPrice: _orderItems[index].unitPrice,
        quantity: _orderItems[index].quantity,
        notes: notes,
        status: _orderItems[index].status,
      );
      
      _orderItems[index] = updatedItem;
      _orderItemsController.add(_orderItems);
      notifyListeners();
    }
  }

  Future<bool> submitOrder() async {
    if (_orderItems.isEmpty) {
      _setError('Đơn hàng phải có ít nhất 1 món');
      return false;
    }

    if (_orderType == OrderType.dineIn && _selectedTable == null) {
      _setError('Vui lòng chọn bàn cho đơn hàng tại chỗ');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      // Simulate API call to submit order
      await Future.delayed(const Duration(seconds: 2));
      
      // Create order object
      final orderId = DateTime.now().millisecondsSinceEpoch.toString();
      final order = Order(
        id: orderId,
        orderNumber: _generateOrderNumber(),
        orderType: _orderType,
        tableId: _selectedTable?.id,
        status: OrderStatus.pending,
        totalAmount: total,
        notes: _customerNote.isEmpty ? null : _customerNote,
        items: _orderItems.map((item) => OrderItem(
          id: item.id,
          orderId: orderId,
          menuItemId: item.menuItemId,
          menuItemName: item.menuItemName,
          unitPrice: item.unitPrice,
          quantity: item.quantity,
          notes: item.notes,
          status: item.status,
        )).toList(),
        creationTime: DateTime.now(),
      );

      // In real app, send to backend API
      debugPrint('Submitting order: ${jsonEncode(order.toJson())}');
      
      // Clear order after successful submission
      clearOrder();
      
      return true;
    } catch (e) {
      _setError('Không thể gửi đơn hàng: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String _generateOrderNumber() {
    final now = DateTime.now();
    return 'DH${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.year.toString().substring(2)}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }

  void clearOrder() {
    _orderItems.clear();
    _selectedTable = null;
    _orderType = OrderType.dineIn;
    _customerNote = '';
    _orderItemsController.add(_orderItems);
    notifyListeners();
  }

  OrderItem? getItemById(String id) {
    try {
      return _orderItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  List<OrderItem> getItemsByMenuItemId(String menuItemId) {
    return _orderItems.where((item) => item.menuItemId == menuItemId).toList();
  }

  Future<void> validateOrderItems() async {
    _setLoading(true);
    _setError(null);

    try {
      // Simulate validation with menu service
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check if all items are still available
      final unavailableItems = <String>[];
      for (final item in _orderItems) {
        // In real app, check with MenuService
        // if (!menuService.isItemAvailable(item.menuItemId)) {
        //   unavailableItems.add(item.menuItemName);
        // }
      }
      
      if (unavailableItems.isNotEmpty) {
        _setError('Một số món không còn phục vụ: ${unavailableItems.join(', ')}');
      }
      
    } catch (e) {
      _setError('Không thể kiểm tra tính khả dụng của món: $e');
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
    _orderItemsController.close();
    super.dispose();
  }
}

class OrderCalculation {
  final double subtotal;
  final double vatAmount;
  final double total;
  final int totalItems;

  const OrderCalculation({
    required this.subtotal,
    required this.vatAmount,
    required this.total,
    required this.totalItems,
  });

  factory OrderCalculation.fromOrderItems(List<OrderItem> items) {
    final subtotal = items.fold(0.0, (sum, item) => sum + (item.totalPrice)); // (item.price * item.quantity)
    const vatRate = 0.10; // 10% VAT
    final vatAmount = subtotal * vatRate;
    final total = subtotal + vatAmount;
    final totalItems = items.fold(0, (sum, item) => sum + item.quantity);

    return OrderCalculation(
      subtotal: subtotal,
      vatAmount: vatAmount,
      total: total,
      totalItems: totalItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'vatAmount': vatAmount,
      'total': total,
      'totalItems': totalItems,
    };
  }
}