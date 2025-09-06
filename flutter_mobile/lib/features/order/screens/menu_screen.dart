import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/enums/restaurant_enums.dart';
import '../../../core/models/table_models.dart';
import '../../../core/models/menu_models.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../../core/services/order_service.dart';
import '../widgets/menu_item_card.dart';

/// Màn hình Menu món ăn cho bàn đã chọn
class MenuScreen extends StatefulWidget {
  final TableModel selectedTable;

  const MenuScreen({
    Key? key,
    required this.selectedTable,
  }) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final OrderService _orderService = OrderService(accessToken: null);
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  
  List<MenuCategory> _categories = [];
  List<MenuItem> _menuItems = [];
  bool _isLoadingCategories = true;
  bool _isLoadingMenuItems = false;
  String? _categoriesError;
  String? _menuItemsError;
  
  int _selectedCategoryIndex = 0;
  int _cartItemCount = 0;
  bool _onlyAvailable = true; // State cho checkbox
  String _searchQuery = ''; // Search query

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _debounceSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadMenuItems();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _debounceSearch();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _orderService.getActiveMenuCategories();
      setState(() {
        _categories = [
          const MenuCategory(id: 'all', displayName: 'Tất cả'),
          ...categories,
        ];
        _isLoadingCategories = false;
        _categoriesError = null;
      });
      
      // Load menu items sau khi load categories thành công
      await _loadMenuItems();
    } catch (e) {
      // Sử dụng fallback categories nếu API lỗi
      setState(() {
        _categories = _orderService.getFallbackCategories();
        _isLoadingCategories = false;
        _categoriesError = 'Không thể tải danh mục từ server. Sử dụng danh mục mặc định.';
      });
    }
  }

  Future<void> _loadMenuItems() async {
    try {
      setState(() {
        _isLoadingMenuItems = true;
        _menuItemsError = null;
      });
      
      // Xác định categoryId dựa trên selected index
      String? categoryId;
      if (_selectedCategoryIndex > 0 && _selectedCategoryIndex < _categories.length) {
        final selectedCategory = _categories[_selectedCategoryIndex];
        // Nếu không phải "Tất cả", sử dụng categoryId
        if (selectedCategory.id != 'all') {
          categoryId = selectedCategory.id;
        }
      }
      
      final filter = GetMenuItemsForOrder(
        categoryId: categoryId,
        onlyAvailable: _onlyAvailable,
        nameFilter: _searchQuery.isEmpty ? null : _searchQuery,
      );
      
      final menuItems = await _orderService.getMenuItemsForOrder(filter);
      setState(() {
        _menuItems = menuItems;
        _isLoadingMenuItems = false;
      });
    } catch (e) {
      setState(() {
        _menuItems = [];
        _isLoadingMenuItems = false;
        _menuItemsError = 'Không thể tải danh sách món ăn: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Menu - ${widget.selectedTable.name}',
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Color(widget.selectedTable.status.colorValue),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              widget.selectedTable.status.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header với tìm kiếm
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                // Thanh tìm kiếm với nút refresh
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm món ăn...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Nút refresh cạnh search
                    IconButton(
                      onPressed: _refreshMenu,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Cập nhật menu',
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Danh mục
                _isLoadingCategories
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          if (_categoriesError != null)
                            Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning, size: 16, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _categoriesError!,
                                      style: const TextStyle(fontSize: 12, color: Colors.orange),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(
                            height: 40,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _categories.length,
                              itemBuilder: (context, index) {
                                final isSelected = index == _selectedCategoryIndex;
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(_categories[index].displayName),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedCategoryIndex = index;
                                      });
                                      _loadMenuItems(); // Load lại món ăn khi chọn category
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          // Checkbox món khả dụng
                          Row(
                            children: [
                              Checkbox(
                                value: _onlyAvailable,
                                onChanged: (value) {
                                  setState(() {
                                    _onlyAvailable = value ?? true;
                                  });
                                  _loadMenuItems(); // Load lại món ăn khi thay đổi filter
                                },
                              ),
                              const Text('Chỉ hiển thị món khả dụng'),
                              const Spacer(),
                              if (_isLoadingMenuItems)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                            ],
                          ),
                        ],
                      ),
              ],
            ),
          ),
          
          // Danh sách món ăn
          Expanded(
            child: _buildMenuItemsList(),
          ),
        ],
      ),
      
      // Floating action button - chỉ giỏ hàng
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildMenuItemsList() {
    if (_isLoadingMenuItems) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_menuItemsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_menuItemsError!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMenuItems,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    
    if (_menuItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Không có món ăn nào'),
          ],
        ),
      );
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive breakpoints like Bootstrap
        int crossAxisCount;
        double childAspectRatio;
        
        if (constraints.maxWidth < 600) {
          // Mobile: 2 columns - vừa phải cho description 2 dòng
          crossAxisCount = 2;
          childAspectRatio = 0.85;
        } else if (constraints.maxWidth < 900) {
          // Tablet: 3 columns
          crossAxisCount = 3;
          childAspectRatio = 0.9;
        } else {
          // Desktop: 4 columns
          crossAxisCount = 4;
          childAspectRatio = 0.95;
        }
        
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _menuItems.length,
          itemBuilder: (context, index) {
            final menuItem = _menuItems[index];
            return MenuItemCard(
              menuItem: menuItem,
              onAddToCart: () => _onAddToCart(menuItem),
            );
          },
        );
      },
    );
  }
  
  void _onAddToCart(MenuItem menuItem) {
    setState(() {
      _cartItemCount++;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm ${menuItem.name} vào giỏ hàng cho ${widget.selectedTable.name}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget? _buildFloatingActionButtons() {
    // Chỉ hiển thị nút giỏ hàng khi có món
    if (_cartItemCount > 0) {
      return FloatingActionButton.extended(
        onPressed: () {
          _showCartBottomSheet(context);
        },
        icon: const Icon(Icons.shopping_cart),
        label: Text('Giỏ hàng ($_cartItemCount)'),
      );
    }
    return null; // Không hiển thị gì khi giỏ rỗng
  }

  void _refreshMenu() {
    _loadCategories();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã cập nhật menu')),
    );
  }

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Giỏ hàng - ${widget.selectedTable.name}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              // Cart items (Demo)
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _cartItemCount,
                  itemBuilder: (context, index) => ListTile(
                    leading: const Text('🍜', style: TextStyle(fontSize: 24)),
                    title: Text('Món ăn ${index + 1}'),
                    subtitle: const Text('85.000₫'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        const Text('1'),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Bottom actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng cộng:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${_cartItemCount * 85}.000₫',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _cartItemCount = 0;
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Xóa tất cả'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Đã gửi đơn hàng cho ${widget.selectedTable.name}'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            child: const Text('Gửi đơn'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}