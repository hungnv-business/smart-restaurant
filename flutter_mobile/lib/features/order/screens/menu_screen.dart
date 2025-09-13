import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/enums/restaurant_enums.dart';
import '../../../core/models/table_models.dart';
import '../../../core/models/menu_models.dart';
import '../../../core/models/order_request_models.dart';
import '../../../core/models/ingredient_verification_models.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../../../core/services/order_service.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/cart_dialog.dart';
import '../widgets/ingredient_verification_dialog.dart';

/// Màn hình Menu món ăn cho bàn đã chọn
class MenuScreen extends StatefulWidget {
  final ActiveTableDto selectedTable;
  final bool hasActiveOrder;
  final String? currentOrderId;

  const MenuScreen({
    Key? key,
    required this.selectedTable,
    this.hasActiveOrder = false,
    this.currentOrderId,
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
  bool _onlyAvailable = true; // State cho checkbox
  String _searchQuery = ''; // Search query
  
  // Danh sách món trong giỏ hàng với thông tin đầy đủ
  List<MenuItem> _cartItems = [];
  List<int> _cartItemQuantities = [];
  
  // Getter để lấy số lượng item trong giỏ hàng
  int get _cartItemCount => _cartItems.length;

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
        title: 'Menu - ${widget.selectedTable.tableNumber}',
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
          // Mobile: 2 columns - tăng chiều cao để đủ chỗ cho content
          crossAxisCount = 2;
          childAspectRatio = 0.9;
        } else if (constraints.maxWidth < 900) {
          // Tablet: 3 columns
          crossAxisCount = 3;
          childAspectRatio = 1.0;
        } else {
          // Desktop: 4 columns
          crossAxisCount = 4;
          childAspectRatio = 1.05;
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
            // Tìm số lượng hiện tại của món trong giỏ hàng
            int currentQuantity = 0;
            int cartIndex = _cartItems.indexWhere((item) => item.id == menuItem.id);
            if (cartIndex != -1) {
              currentQuantity = _cartItemQuantities[cartIndex];
            }
            
            return MenuItemCard(
              menuItem: menuItem,
              quantity: currentQuantity,
              onAddToCart: () => _onAddToCart(menuItem),
              onIncreaseQuantity: () => _onIncreaseQuantity(menuItem),
              onDecreaseQuantity: () => _onDecreaseQuantity(menuItem),
            );
          },
        );
      },
    );
  }
  
  void _onAddToCart(MenuItem menuItem) {
    setState(() {
      // Kiểm tra xem món đã có trong giỏ hàng chưa
      int existingIndex = _cartItems.indexWhere((item) => item.id == menuItem.id);
      
      if (existingIndex != -1) {
        // Món đã có, tăng số lượng
        _cartItemQuantities[existingIndex]++;
      } else {
        // Món chưa có, thêm mới
        _cartItems.add(menuItem);
        _cartItemQuantities.add(1);
      }
    });
  }

  void _onIncreaseQuantity(MenuItem menuItem) {
    setState(() {
      int existingIndex = _cartItems.indexWhere((item) => item.id == menuItem.id);
      
      if (existingIndex != -1) {
        // Món đã có, tăng số lượng
        _cartItemQuantities[existingIndex]++;
      } else {
        // Món chưa có, thêm mới với số lượng 1
        _cartItems.add(menuItem);
        _cartItemQuantities.add(1);
      }
    });
  }

  void _onDecreaseQuantity(MenuItem menuItem) {
    setState(() {
      int existingIndex = _cartItems.indexWhere((item) => item.id == menuItem.id);
      
      if (existingIndex != -1) {
        if (_cartItemQuantities[existingIndex] > 1) {
          // Giảm số lượng
          _cartItemQuantities[existingIndex]--;
        } else {
          // Xóa món nếu số lượng = 1
          _cartItems.removeAt(existingIndex);
          _cartItemQuantities.removeAt(existingIndex);
        }
      }
    });
  }

  void _increaseQuantity(int index) {
    if (index >= 0 && index < _cartItemQuantities.length) {
      setState(() {
        _cartItemQuantities[index]++;
      });
    }
  }

  void _decreaseQuantity(int index) {
    if (index >= 0 && index < _cartItemQuantities.length) {
      setState(() {
        if (_cartItemQuantities[index] > 1) {
          _cartItemQuantities[index]--;
        } else {
          // Xóa món nếu số lượng = 0
          _cartItems.removeAt(index);
          _cartItemQuantities.removeAt(index);
        }
      });
    }
  }

  int _calculateTotal() {
    int total = 0;
    for (int i = 0; i < _cartItems.length; i++) {
      total += _cartItems[i].price * _cartItemQuantities[i];
    }
    return total;
  }

  /// Gửi đơn hàng lên API (tạo mới hoặc thêm món)
  Future<void> _submitOrder() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giỏ hàng trống, không thể gửi đơn hàng'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Tạo order items từ cart để verify ingredients
      final verificationItems = <OrderItemRequest>[];
      for (int i = 0; i < _cartItems.length; i++) {
        final menuItem = _cartItems[i];
        final quantity = _cartItemQuantities[i];
        
        verificationItems.add(OrderItemRequest(
          menuItemId: menuItem.id,
          menuItemName: menuItem.name,
          quantity: quantity,
        ));
      }

      // Bước 1: Verify ingredients availability
      final verificationRequest = VerifyIngredientsRequest(
        items: verificationItems,
      );

      final verificationResult = await _orderService.verifyIngredientsAvailability(verificationRequest);

      // Bước 2: Hiển thị dialog verification result
      bool? userConfirmed;
      if (mounted) {
        userConfirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => IngredientVerificationDialog(
            verificationResult: verificationResult,
          ),
        );
      }

      // Nếu user cancel hoặc không confirm thì dừng
      if (userConfirmed != true) {
        return;
      }

      // Bước 3: Proceed với order creation/addition
      final orderItems = <CreateOrderItemRequest>[];
      for (int i = 0; i < _cartItems.length; i++) {
        final menuItem = _cartItems[i];
        final quantity = _cartItemQuantities[i];
        
        orderItems.add(CreateOrderItemRequest.fromMenuItem(
          menuItemId: menuItem.id,
          menuItemName: menuItem.name,
          quantity: quantity,
          unitPrice: menuItem.price,
        ));
      }

      if (widget.hasActiveOrder) {
        // THÊM MÓN VÀO ORDER HIỆN CÓ
        if (widget.currentOrderId == null) {
          throw Exception('Không tìm thấy orderId của bàn ${widget.selectedTable.tableNumber}');
        }
        
        final addItemsRequest = AddItemsToOrderRequest(
          items: orderItems,
          additionalNotes: 'Gọi thêm từ mobile app',
        );
        
        await _orderService.addItemsToOrder(widget.currentOrderId!, addItemsRequest);
        
        // Hiển thị thông báo thành công
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Đã thêm món vào đơn hàng cho ${widget.selectedTable.tableNumber}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // TẠO ĐƠNAHAÀNG MỚI  
        final orderRequest = CreateOrderRequest(
          tableId: widget.selectedTable.id,
          orderType: OrderRequestType.dineIn,
          orderItems: orderItems,
          notes: null,
        );

        final response = await _orderService.createOrder(orderRequest);
        
        // Hiển thị thông báo thành công
        if (mounted) {
          String message;
          if (response != null) {
            // API trả về response với orderNumber
            message = '✅ Đã tạo đơn hàng #${response.orderNumber} cho ${widget.selectedTable.tableNumber}';
          } else {
            // API chỉ trả về 204 No Content
            message = '✅ Đã tạo đơn hàng thành công cho ${widget.selectedTable.tableNumber}';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }

      // Clear cart sau khi thành công  
      setState(() {
        _cartItems.clear();
        _cartItemQuantities.clear();
      });

      // Navigate back về TableDetailScreen với result = true
      if (mounted) {
        Navigator.of(context).pop(true); // Trả về true để báo hiệu có thay đổi
      }

    } catch (e) {
      // Hiển thị thông báo lỗi
      if (mounted) {
        final action = widget.hasActiveOrder ? 'thêm món' : 'tạo đơn hàng';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi $action: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Thử lại',
              onPressed: () => _submitOrder(),
            ),
          ),
        );
      }
    }
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
    showDialog(
      context: context,
      builder: (context) => CartDialog(
        selectedTable: widget.selectedTable,
        cartItems: _cartItems,
        cartItemQuantities: _cartItemQuantities,
        onIncreaseQuantity: _increaseQuantity,
        onDecreaseQuantity: _decreaseQuantity,
        onClearCart: () {
          setState(() {
            _cartItems.clear();
            _cartItemQuantities.clear();
          });
        },
        onSubmitOrder: () => _submitOrder(),
        hasActiveOrder: widget.hasActiveOrder,
      ),
    );
  }
}