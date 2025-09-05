import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../menu/models/menu_models.dart';

class MenuService extends ChangeNotifier {
  final List<MenuCategory> _categories = [];
  final List<MenuItem> _menuItems = [];
  final StreamController<List<MenuItem>> _menuItemsController = 
      StreamController<List<MenuItem>>.broadcast();
  
  bool _isLoading = false;
  String? _error;
  String _selectedCategoryId = '';

  List<MenuCategory> get categories => List.unmodifiable(_categories);
  List<MenuItem> get menuItems => List.unmodifiable(_menuItems);
  Stream<List<MenuItem>> get menuItemsStream => _menuItemsController.stream;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategoryId => _selectedCategoryId;

  MenuService() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Mock categories
    _categories.addAll([
      MenuCategory(
        id: 'all',
        name: 'Tất cả',
        description: 'Tất cả món ăn',
        displayOrder: 0,
      ),
      MenuCategory(
        id: 'pho',
        name: 'Phở',
        description: 'Các loại phở truyền thống',
        displayOrder: 1,
      ),
      MenuCategory(
        id: 'com',
        name: 'Cơm',
        description: 'Cơm các loại',
        displayOrder: 2,
      ),
      MenuCategory(
        id: 'bun',
        name: 'Bún',
        description: 'Bún và miến',
        displayOrder: 3,
      ),
      MenuCategory(
        id: 'drinks',
        name: 'Đồ uống',
        description: 'Nước uống các loại',
        displayOrder: 4,
      ),
      MenuCategory(
        id: 'dessert',
        name: 'Tráng miệng',
        description: 'Món tráng miệng',
        displayOrder: 5,
      ),
    ]);

    // Mock menu items
    _menuItems.addAll([
      // Phở
      MenuItem(
        id: 'pho-bo-tai',
        name: 'Phở Bò Tái',
        description: 'Phở bò với thịt bò tái tươi ngon, nước dùng trong',
        price: 65000,
        isAvailable: true,
        imageUrl: 'https://example.com/pho-bo-tai.jpg',
        categoryId: 'pho',
      ),
      MenuItem(
        id: 'pho-bo-chin',
        name: 'Phở Bò Chín',
        description: 'Phở bò với thịt bò chín mềm, đậm đà hương vị',
        price: 70000,
        isAvailable: true,
        categoryId: 'pho',
      ),
      MenuItem(
        id: 'pho-ga',
        name: 'Phở Gà',
        description: 'Phở gà thơm ngon với thịt gà tươi',
        price: 60000,
        isAvailable: false, // Hết món
        categoryId: 'pho',
      ),
      MenuItem(
        id: 'pho-tom',
        name: 'Phở Tôm',
        description: 'Phở tôm tươi với nước dùng ngọt thanh',
        price: 80000,
        isAvailable: true,
        categoryId: 'pho',
      ),

      // Cơm
      MenuItem(
        id: 'com-tam',
        name: 'Cơm Tấm',
        description: 'Cơm tấm sườn nướng, trứng ốp la, bì chả',
        price: 55000,
        isAvailable: true,
        categoryId: 'com',
      ),
      MenuItem(
        id: 'com-ga-nuong',
        name: 'Cơm Gà Nướng',
        description: 'Cơm gà nướng mật ong thơm ngon',
        price: 65000,
        isAvailable: true,
        categoryId: 'com',
      ),
      MenuItem(
        id: 'com-bo-luc-lac',
        name: 'Cơm Bò Lúc Lắc',
        description: 'Cơm với bò lúc lắc kèm rau củ',
        price: 75000,
        isAvailable: true,
        categoryId: 'com',
      ),

      // Bún
      MenuItem(
        id: 'bun-bo-hue',
        name: 'Bún Bò Huế',
        description: 'Bún bò Huế cay nồng đúng vị xứ Huế',
        price: 70000,
        isAvailable: true,
        categoryId: 'bun',
      ),
      MenuItem(
        id: 'bun-cha-ca',
        name: 'Bún Chả Cá',
        description: 'Bún chả cá Lã Vọng với thì là thơm',
        price: 75000,
        isAvailable: true,
        categoryId: 'bun',
      ),
      MenuItem(
        id: 'bun-rieu',
        name: 'Bún Riêu',
        description: 'Bún riêu cua đồng ngọt thanh',
        price: 65000,
        isAvailable: false,
        categoryId: 'bun',
      ),

      // Đồ uống
      MenuItem(
        id: 'ca-phe-den',
        name: 'Cà Phê Đen',
        description: 'Cà phê đen đậm đà phong cách Việt Nam',
        price: 25000,
        isAvailable: true,
        categoryId: 'drinks',
      ),
      MenuItem(
        id: 'ca-phe-sua',
        name: 'Cà Phê Sữa',
        description: 'Cà phê sữa đá truyền thống',
        price: 30000,
        isAvailable: true,
        categoryId: 'drinks',
      ),
      MenuItem(
        id: 'tra-da',
        name: 'Trà Đá',
        description: 'Trà đá mát lạnh',
        price: 15000,
        isAvailable: true,
        categoryId: 'drinks',
      ),
      MenuItem(
        id: 'nuoc-cam',
        name: 'Nước Cam Tươi',
        description: 'Nước cam vắt tươi ngon',
        price: 35000,
        isAvailable: true,
        categoryId: 'drinks',
      ),

      // Tráng miệng
      MenuItem(
        id: 'che-ba-mau',
        name: 'Chè Ba Màu',
        description: 'Chè ba màu với đậu xanh, đậu đỏ, thạch',
        price: 30000,
        isAvailable: true,
        categoryId: 'dessert',
      ),
      MenuItem(
        id: 'banh-flan',
        name: 'Bánh Flan',
        description: 'Bánh flan mềm mịn với caramel',
        price: 25000,
        isAvailable: true,
        categoryId: 'dessert',
      ),
    ]);

    _selectedCategoryId = 'all';
    _menuItemsController.add(_getFilteredItems());
  }

  Future<void> refreshMenu() async {
    _setLoading(true);
    _setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate some availability changes
      _simulateAvailabilityChanges();
      
      _menuItemsController.add(_getFilteredItems());
      notifyListeners();
    } catch (e) {
      _setError('Không thể tải menu: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _simulateAvailabilityChanges() {
    // Randomly change some item availability for demo
    for (int i = 0; i < _menuItems.length; i++) {
      if (DateTime.now().millisecondsSinceEpoch % (i + 5) == 0) {
        final updatedItem = MenuItem(
          id: _menuItems[i].id,
          name: _menuItems[i].name,
          description: _menuItems[i].description,
          price: _menuItems[i].price,
          isAvailable: !_menuItems[i].isAvailable,
          imageUrl: _menuItems[i].imageUrl,
          categoryId: _menuItems[i].categoryId,
        );
        _menuItems[i] = updatedItem;
      }
    }
  }

  void selectCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    _menuItemsController.add(_getFilteredItems());
    notifyListeners();
  }

  List<MenuItem> _getFilteredItems() {
    if (_selectedCategoryId == 'all' || _selectedCategoryId.isEmpty) {
      return _menuItems;
    }
    return _menuItems.where((item) => item.categoryId == _selectedCategoryId).toList();
  }

  List<MenuItem> searchItems(String query) {
    if (query.trim().isEmpty) return _getFilteredItems();
    
    final lowerQuery = query.trim().toLowerCase();
    return _getFilteredItems().where((item) {
      return item.name.toLowerCase().contains(lowerQuery) ||
             (item.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  List<MenuItem> getAvailableItems() {
    return _getFilteredItems().where((item) => item.isAvailable).toList();
  }

  List<MenuItem> getItemsByPriceRange(double minPrice, double maxPrice) {
    return _getFilteredItems().where((item) =>
        item.price >= minPrice && item.price <= maxPrice
    ).toList();
  }

  MenuItem? getItemById(String id) {
    try {
      return _menuItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  MenuCategory? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Auto-complete suggestions
  List<String> getSearchSuggestions(String query) {
    if (query.trim().isEmpty) return [];
    
    final lowerQuery = query.trim().toLowerCase();
    final suggestions = <String>{};
    
    for (final item in _menuItems) {
      // Add item name if matches
      if (item.name.toLowerCase().contains(lowerQuery)) {
        suggestions.add(item.name);
      }
      
      // Add partial matches
      final words = item.name.toLowerCase().split(' ');
      for (final word in words) {
        if (word.startsWith(lowerQuery)) {
          suggestions.add(item.name);
          break;
        }
      }
    }
    
    return suggestions.take(5).toList();
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
    _menuItemsController.close();
    super.dispose();
  }
}

enum MenuSortOption {
  name,
  priceAsc,
  priceDesc,
  availability;

  String get displayName {
    switch (this) {
      case MenuSortOption.name:
        return 'Tên món';
      case MenuSortOption.priceAsc:
        return 'Giá tăng dần';
      case MenuSortOption.priceDesc:
        return 'Giá giảm dần';
      case MenuSortOption.availability:
        return 'Có sẵn trước';
    }
  }
}

enum PriceRangeFilter {
  all,
  under50k,
  from50to100k,
  over100k;

  String get displayName {
    switch (this) {
      case PriceRangeFilter.all:
        return 'Tất cả';
      case PriceRangeFilter.under50k:
        return 'Dưới 50.000₫';
      case PriceRangeFilter.from50to100k:
        return '50.000₫ - 100.000₫';
      case PriceRangeFilter.over100k:
        return 'Trên 100.000₫';
    }
  }

  (double, double) get priceRange {
    switch (this) {
      case PriceRangeFilter.all:
        return (0, double.infinity);
      case PriceRangeFilter.under50k:
        return (0, 50000);
      case PriceRangeFilter.from50to100k:
        return (50000, 100000);
      case PriceRangeFilter.over100k:
        return (100000, double.infinity);
    }
  }
}