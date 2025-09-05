import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_state.dart';
import '../services/menu_service.dart';
import '../services/order_service.dart';
import '../widgets/voice_input_widget.dart';
import '../widgets/pull_to_refresh_widget.dart';
import '../../menu/models/menu_models.dart';

class MenuBrowsingWidget extends StatefulWidget {
  const MenuBrowsingWidget({super.key});

  @override
  State<MenuBrowsingWidget> createState() => _MenuBrowsingWidgetState();
}

class _MenuBrowsingWidgetState extends State<MenuBrowsingWidget> {
  late MenuService _menuService;
  final TextEditingController _searchController = TextEditingController();
  List<MenuItem> _filteredItems = [];
  MenuSortOption _sortOption = MenuSortOption.name;
  PriceRangeFilter _priceFilter = PriceRangeFilter.all;
  bool _showAvailableOnly = false;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _menuService = MenuService();
    _searchController.addListener(_onSearchChanged);
    _filteredItems = _menuService.menuItems;
    
    // Listen to menu updates
    _menuService.menuItemsStream.listen((items) {
      if (mounted) {
        _applyFiltersAndSort();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _menuService.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    setState(() {
      var items = _menuService.menuItems;
      
      // Apply search filter
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        items = _menuService.searchItems(query);
      } else {
        items = _menuService.menuItems;
      }
      
      // Apply availability filter
      if (_showAvailableOnly) {
        items = items.where((item) => item.isAvailable).toList();
      }
      
      // Apply price filter
      if (_priceFilter != PriceRangeFilter.all) {
        final (minPrice, maxPrice) = _priceFilter.priceRange;
        items = items.where((item) => 
            item.price >= minPrice && item.price <= maxPrice
        ).toList();
      }
      
      // Apply sorting
      switch (_sortOption) {
        case MenuSortOption.name:
          items.sort((a, b) => a.name.compareTo(b.name));
          break;
        case MenuSortOption.priceAsc:
          items.sort((a, b) => a.price.compareTo(b.price));
          break;
        case MenuSortOption.priceDesc:
          items.sort((a, b) => b.price.compareTo(a.price));
          break;
        case MenuSortOption.availability:
          items.sort((a, b) {
            if (a.isAvailable && !b.isAvailable) return -1;
            if (!a.isAvailable && b.isAvailable) return 1;
            return a.name.compareTo(b.name);
          });
          break;
      }
      
      _filteredItems = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _menuService,
      child: Consumer2<OrderWorkflowNotifier, OrderService>(
        builder: (context, notifier, orderService, child) {
          return Scaffold(
            body: SmartRefreshWrapper(
              onRefresh: () async {
                await _menuService.refreshMenu();
                _applyFiltersAndSort();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    _buildHeader(context),
                    const SizedBox(height: 16),
                    
                    // Search section
                    _buildSearchSection(context),
                    const SizedBox(height: 16),
                    
                    // Category tabs
                    _buildCategoryTabs(context),
                    const SizedBox(height: 16),
                    
                    if (_showFilters) ...[
                      _buildFiltersSection(context),
                      const SizedBox(height: 16),
                    ],
                    
                    // Results info
                    _buildResultsInfo(context),
                    const SizedBox(height: 16),
                    
                    // Menu items grid
                    Expanded(
                      child: _buildMenuItemsGrid(context, notifier),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: orderService.hasItems
                ? FloatingActionButton.extended(
                    onPressed: () => _navigateToOrderSummary(context),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.shopping_cart),
                    label: Text('Xem giỏ hàng (${orderService.totalItemCount})'),
                  )
                : null,
          );
        },
      ),
    );
  }
  
  void _navigateToOrderSummary(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OrderSummaryWidget(),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Chọn món ăn',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Consumer<MenuService>(
              builder: (context, service, child) {
                return IconButton(
                  onPressed: service.isLoading ? null : () => service.refreshMenu(),
                  icon: service.isLoading 
                    ? const SizedBox(
                        width: 20, 
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                  tooltip: 'Làm mới menu',
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Duyệt menu và thêm món vào đơn hàng',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SearchAnchor(
                searchController: _searchController,
                builder: (BuildContext context, SearchController controller) {
                  return TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm món ăn (ví dụ: phở, cơm, gà)...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          VoiceInputWidget(
                            onSpeechResult: (text) {
                              _searchController.text = text;
                              _applyFiltersAndSort();
                            },
                            hintText: 'Nói tên món ăn',
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _applyFiltersAndSort();
                              },
                              icon: const Icon(Icons.clear),
                            ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  );
                },
                suggestionsBuilder: (BuildContext context, SearchController controller) {
                  final suggestions = _menuService.getSearchSuggestions(controller.text);
                  return suggestions.map((suggestion) {
                    return ListTile(
                      leading: const Icon(Icons.search),
                      title: Text(suggestion),
                      onTap: () {
                        controller.closeView(suggestion);
                        _searchController.text = suggestion;
                        _applyFiltersAndSort();
                      },
                    );
                  }).toList();
                },
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
              icon: Icon(
                _showFilters ? Icons.filter_list_off : Icons.filter_list,
                color: _showFilters ? Theme.of(context).colorScheme.primary : null,
              ),
              tooltip: _showFilters ? 'Ẩn bộ lọc' : 'Hiện bộ lọc',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
    return Consumer<MenuService>(
      builder: (context, service, child) {
        return SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: service.categories.length,
            itemBuilder: (context, index) {
              final category = service.categories[index];
              final isSelected = service.selectedCategoryId == category.id;
              
              return Padding(
                padding: EdgeInsets.only(right: index < service.categories.length - 1 ? 8 : 0),
                child: FilterChip(
                  label: Text(category.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    service.selectCategory(category.id);
                    _applyFiltersAndSort();
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFiltersSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bộ lọc và sắp xếp',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Availability filter
            CheckboxListTile(
              title: const Text('Chỉ hiện món có sẵn'),
              value: _showAvailableOnly,
              onChanged: (value) {
                setState(() {
                  _showAvailableOnly = value ?? false;
                });
                _applyFiltersAndSort();
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            
            const SizedBox(height: 12),
            
            // Price range filter
            Text(
              'Khoảng giá:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: PriceRangeFilter.values.map((filter) {
                return FilterChip(
                  label: Text(filter.displayName),
                  selected: _priceFilter == filter,
                  onSelected: (selected) {
                    setState(() {
                      _priceFilter = filter;
                    });
                    _applyFiltersAndSort();
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Sort options
            Text(
              'Sắp xếp theo:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: MenuSortOption.values.map((option) {
                return FilterChip(
                  label: Text(option.displayName),
                  selected: _sortOption == option,
                  onSelected: (selected) {
                    setState(() {
                      _sortOption = option;
                    });
                    _applyFiltersAndSort();
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _priceFilter = PriceRangeFilter.all;
                      _sortOption = MenuSortOption.name;
                      _showAvailableOnly = false;
                      _searchController.clear();
                    });
                    _applyFiltersAndSort();
                  },
                  child: const Text('Xóa bộ lọc'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsInfo(BuildContext context) {
    final availableCount = _filteredItems.where((item) => item.isAvailable).length;
    final totalCount = _filteredItems.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Hiển thị $totalCount món • $availableCount có sẵn',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemsGrid(BuildContext context, OrderWorkflowNotifier notifier) {
    if (_filteredItems.isEmpty) {
      return _buildEmptyState(context);
    }

    return Consumer<MenuService>(
      builder: (context, service, child) {
        if (service.error != null) {
          return _buildErrorState(context, service.error!, () => service.refreshMenu());
        }

        return RefreshIndicator(
          onRefresh: () => service.refreshMenu(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              return _buildMenuItemCard(context, item, notifier);
            },
          ),
        );
      },
    );
  }

  Widget _buildMenuItemCard(
    BuildContext context,
    MenuItem item,
    OrderWorkflowNotifier notifier,
  ) {
    final isSelected = notifier.state.selectedItems.any((i) => i.id == item.id);
    final quantity = notifier.state.itemQuantities[item.id] ?? 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: item.isAvailable ? () => _showItemDetails(context, item, notifier) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Item image placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: item.isAvailable 
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.restaurant,
                  size: 32,
                  color: item.isAvailable
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Item info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item name
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: item.isAvailable 
                          ? null 
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Item description
                    if (item.description != null)
                      Text(
                        item.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: item.isAvailable 
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Price and availability
                    Row(
                      children: [
                        Text(
                          _formatPrice(item.price),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: item.isAvailable 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // Availability badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.isAvailable 
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.isAvailable ? 'Có sẵn' : 'Hết món',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: item.isAvailable ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Quantity controls
              if (item.isAvailable)
                _buildQuantityControls(context, item, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityControls(
    BuildContext context,
    MenuItem item,
    OrderWorkflowNotifier notifier,
  ) {
    final quantity = notifier.state.itemQuantities[item.id] ?? 0;
    
    if (quantity == 0) {
      return ElevatedButton.icon(
        onPressed: () => notifier.addMenuItem(item),
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Thêm'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => notifier.updateItemQuantity(item.id, quantity - 1),
          icon: const Icon(Icons.remove),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        ),
        
        Container(
          width: 32,
          alignment: Alignment.center,
          child: Text(
            quantity.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        IconButton(
          onPressed: () => notifier.updateItemQuantity(item.id, quantity + 1),
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy món ăn nào',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thử thay đổi từ khóa tìm kiếm hoặc bộ lọc',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _priceFilter = PriceRangeFilter.all;
                _sortOption = MenuSortOption.name;
                _showAvailableOnly = false;
                _searchController.clear();
              });
              _menuService.selectCategory('all');
              _applyFiltersAndSort();
            },
            child: const Text('Xóa tất cả bộ lọc'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Không thể tải menu',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(BuildContext context, MenuItem item, OrderWorkflowNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Item image placeholder
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.restaurant,
                      size: 64,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Item name and category
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.isAvailable 
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.isAvailable ? 'Có sẵn' : 'Hết món',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: item.isAvailable ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Price
                  Text(
                    _formatPrice(item.price),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  if (item.description != null) ...[
                    Text(
                      'Mô tả',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Notes input
                  Text(
                    'Ghi chú đặc biệt',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Ví dụ: Không cay, ít muối, thêm hành...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: 3,
                    onChanged: (notes) => notifier.updateItemNotes(item.id, notes),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quantity controls and add button
                  if (item.isAvailable) ...[
                    Row(
                      children: [
                        Text(
                          'Số lượng:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        _buildQuantityControls(context, item, notifier),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final orderService = context.read<OrderService>();
                          final quantity = notifier.state.itemQuantities[item.id] ?? 1;
                          final notes = notifier.state.itemNotes[item.id] ?? '';
                          
                          orderService.addItem(item, notes: notes, quantity: quantity);
                          
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã thêm ${item.name} vào đơn hàng'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Thêm vào đơn hàng'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.block),
                        label: const Text('Món này hiện không có sẵn'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.'
    )}₫';
  }
}