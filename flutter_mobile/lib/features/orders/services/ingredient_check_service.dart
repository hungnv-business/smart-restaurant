import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/order_models.dart';

class IngredientCheckService extends ChangeNotifier {
  final Dio _dio = Dio();
  final Map<String, List<MissingIngredient>> _cache = {};
  Timer? _cacheCleanupTimer;
  
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  IngredientCheckService() {
    _setupCacheCleanup();
  }

  void _setupCacheCleanup() {
    _cacheCleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _cache.clear(); // Clear cache every 5 minutes for fresh data
    });
  }

  Future<List<MissingIngredient>> checkMissingIngredients(List<OrderItem> orderItems) async {
    if (orderItems.isEmpty) return [];

    // Create cache key
    final cacheKey = _createCacheKey(orderItems);
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    _setLoading(true);
    _setError(null);

    try {
      final result = await _performIngredientCheck(orderItems);
      _cache[cacheKey] = result;
      return result;
      
    } catch (e) {
      _setError('Không thể kiểm tra nguyên liệu: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<MissingIngredient>> _performIngredientCheck(List<OrderItem> orderItems) async {
    // Simulate API call - in real app, call backend endpoint
    await Future.delayed(const Duration(seconds: 2));
    
    return _simulateIngredientCheck(orderItems);
  }

  List<MissingIngredient> _simulateIngredientCheck(List<OrderItem> orderItems) {
    final missingIngredients = <MissingIngredient>[];
    
    for (final item in orderItems) {
      // Simulate different scenarios based on menu item
      if (item.menuItemName.contains('Phở')) {
        // Phở might be missing some optional ingredients
        if (DateTime.now().millisecondsSinceEpoch % 3 == 0) {
          missingIngredients.add(MissingIngredient(
            ingredientName: 'Hành lá',
            menuItemName: item.menuItemName,
            requiredQuantity: item.quantity * 10,
            currentStock: 5,
            unit: 'g',
            isOptional: true,
          ));
        }
        
        if (DateTime.now().millisecondsSinceEpoch % 7 == 0) {
          missingIngredients.add(MissingIngredient(
            ingredientName: 'Thịt bò',
            menuItemName: item.menuItemName,
            requiredQuantity: item.quantity * 150,
            currentStock: 50,
            unit: 'g',
            isOptional: false,
          ));
        }
      }
      
      if (item.menuItemName.contains('Cơm')) {
        // Rice dishes might miss some vegetables
        if (DateTime.now().millisecondsSinceEpoch % 5 == 0) {
          missingIngredients.add(MissingIngredient(
            ingredientName: 'Rau sống',
            menuItemName: item.menuItemName,
            requiredQuantity: item.quantity * 50,
            currentStock: 20,
            unit: 'g',
            isOptional: true,
          ));
        }
      }
      
      if (item.menuItemName.contains('Cà phê')) {
        // Coffee might be running low
        if (DateTime.now().millisecondsSinceEpoch % 4 == 0) {
          missingIngredients.add(MissingIngredient(
            ingredientName: 'Cà phê hạt',
            menuItemName: item.menuItemName,
            requiredQuantity: item.quantity * 20,
            currentStock: 10,
            unit: 'g',
            isOptional: false,
          ));
        }
      }
    }
    
    return missingIngredients;
  }

  String _createCacheKey(List<OrderItem> orderItems) {
    final items = orderItems.map((item) => '${item.menuItemId}:${item.quantity}').join(',');
    return 'ingredient_check_$items';
  }

  Future<bool> updateIngredientStock(String ingredientId, int newStock) async {
    _setLoading(true);
    _setError(null);

    try {
      // Simulate API call to update stock
      await Future.delayed(const Duration(seconds: 1));
      
      // In real app, call backend API
      final updateData = {
        'ingredientId': ingredientId,
        'newStock': newStock,
        'updatedBy': 'current-user-id',
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      debugPrint('Updating ingredient stock: ${jsonEncode(updateData)}');
      
      // Clear cache to force fresh check
      _cache.clear();
      
      return true;
    } catch (e) {
      _setError('Không thể cập nhật tồn kho: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<IngredientStock>> getIngredientStocks() async {
    _setLoading(true);
    _setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      return [
        IngredientStock(
          id: '1',
          name: 'Thịt bò',
          currentStock: 2500,
          minStock: 1000,
          unit: 'g',
          lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        IngredientStock(
          id: '2',
          name: 'Bánh phở',
          currentStock: 50,
          minStock: 20,
          unit: 'suất',
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        IngredientStock(
          id: '3',
          name: 'Hành lá',
          currentStock: 5,
          minStock: 50,
          unit: 'g',
          lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        IngredientStock(
          id: '4',
          name: 'Cà phê hạt',
          currentStock: 200,
          minStock: 500,
          unit: 'g',
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
      ];
    } catch (e) {
      _setError('Không thể tải danh sách nguyên liệu: $e');
      return [];
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
    _cacheCleanupTimer?.cancel();
    _dio.close();
    super.dispose();
  }
}

class IngredientStock {
  final String id;
  final String name;
  final int currentStock;
  final int minStock;
  final String unit;
  final DateTime lastUpdated;

  const IngredientStock({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.minStock,
    required this.unit,
    required this.lastUpdated,
  });

  bool get isLow => currentStock <= minStock;
  bool get isCritical => currentStock < (minStock * 0.5);
  int get stockPercentage => ((currentStock / minStock) * 100).round();

  String get statusDisplayName {
    if (isCritical) return 'Rất thấp';
    if (isLow) return 'Thấp';
    return 'Đủ';
  }

  Color get statusColor {
    if (isCritical) return Colors.red;
    if (isLow) return Colors.orange;
    return Colors.green;
  }

  factory IngredientStock.fromJson(Map<String, dynamic> json) {
    return IngredientStock(
      id: json['id'] as String,
      name: json['name'] as String,
      currentStock: json['currentStock'] as int,
      minStock: json['minStock'] as int,
      unit: json['unit'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currentStock': currentStock,
      'minStock': minStock,
      'unit': unit,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}