import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_state.dart';
import '../services/table_service.dart';
import '../services/order_service.dart';
import '../../tables/models/table_models.dart';

class TableSelectionWidget extends StatefulWidget {
  const TableSelectionWidget({super.key});

  @override
  State<TableSelectionWidget> createState() => _TableSelectionWidgetState();
}

class _TableSelectionWidgetState extends State<TableSelectionWidget> {
  late TableService _tableService;
  final TextEditingController _searchController = TextEditingController();
  TableFilterOption _statusFilter = TableFilterOption.all;
  CapacityFilter _capacityFilter = CapacityFilter.all;
  List<RestaurantTable> _filteredTables = [];
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tableService = TableService();
    _searchController.addListener(_onSearchChanged);
    _filteredTables = _tableService.tables;
    
    // Listen to table updates
    _tableService.tablesStream.listen((tables) {
      if (mounted) {
        _applyFilters();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tableService.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      var tables = _tableService.tables;
      
      // Apply search filter
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        tables = _tableService.searchTables(query);
      }
      
      // Apply status filter
      if (_statusFilter.status != null) {
        tables = tables.where((table) => table.status == _statusFilter.status).toList();
      }
      
      // Apply capacity filter
      if (_capacityFilter != CapacityFilter.all) {
        final (minCap, maxCap) = _capacityFilter.capacityRange;
        tables = tables.where((table) => 
            table.capacity >= minCap && table.capacity <= maxCap
        ).toList();
      }
      
      _filteredTables = tables;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _tableService,
      child: Consumer<OrderWorkflowNotifier>(
        builder: (context, notifier, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                _buildHeader(context),
                const SizedBox(height: 16),
                
                // Search and filters section
                _buildSearchSection(context),
                const SizedBox(height: 16),
                
                if (_showFilters) ...[
                  _buildFiltersSection(context),
                  const SizedBox(height: 16),
                ],
                
                // Table legend
                _buildTableLegend(context),
                const SizedBox(height: 16),
                
                // Status bar
                _buildStatusBar(context),
                const SizedBox(height: 16),
                
                // Table grid
                Expanded(
                  child: _buildTableGrid(context, notifier),
                ),
              ],
            ),
          );
        },
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
                'Chọn bàn để phục vụ',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Consumer<TableService>(
              builder: (context, service, child) {
                return IconButton(
                  onPressed: service.isLoading ? null : () => service.refreshTables(),
                  icon: service.isLoading 
                    ? const SizedBox(
                        width: 20, 
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                  tooltip: 'Làm mới danh sách bàn',
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Vui lòng chọn một bàn trống để bắt đầu tạo đơn hàng',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm bàn (ví dụ: T01, 4 chỗ)...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
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
              'Bộ lọc',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Status filter
            Text(
              'Trạng thái:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: TableFilterOption.values.map((option) {
                return FilterChip(
                  label: Text(option.displayName),
                  selected: _statusFilter == option,
                  onSelected: (selected) {
                    setState(() {
                      _statusFilter = option;
                    });
                    _applyFilters();
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Capacity filter
            Text(
              'Sức chứa:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: CapacityFilter.values.map((filter) {
                return FilterChip(
                  label: Text(filter.displayName),
                  selected: _capacityFilter == filter,
                  onSelected: (selected) {
                    setState(() {
                      _capacityFilter = filter;
                    });
                    _applyFilters();
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
                      _statusFilter = TableFilterOption.all;
                      _capacityFilter = CapacityFilter.all;
                      _searchController.clear();
                    });
                    _applyFilters();
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

  Widget _buildTableLegend(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem(
          context, 
          'Có sẵn', 
          Colors.green, 
          Icons.restaurant_menu,
        ),
        _buildLegendItem(
          context, 
          'Đang sử dụng', 
          Colors.red, 
          Icons.people,
        ),
        _buildLegendItem(
          context, 
          'Đã đặt trước', 
          Colors.orange, 
          Icons.schedule,
        ),
        _buildLegendItem(
          context, 
          'Đang dọn dẹp', 
          Colors.blue, 
          Icons.cleaning_services,
        ),
      ],
    );
  }

  Widget _buildStatusBar(BuildContext context) {
    final availableCount = _filteredTables.where((t) => t.status == TableStatus.available).length;
    final occupiedCount = _filteredTables.where((t) => t.status == TableStatus.occupied).length;
    final totalCount = _filteredTables.length;

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
              'Hiển thị $totalCount bàn • $availableCount có sẵn • $occupiedCount đang sử dụng',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    IconData icon,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 8, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildTableGrid(BuildContext context, OrderWorkflowNotifier notifier) {
    if (_filteredTables.isEmpty) {
      return _buildEmptyState(context);
    }

    return Consumer<TableService>(
      builder: (context, service, child) {
        if (service.error != null) {
          return _buildErrorState(context, service.error!, () => service.refreshTables());
        }

        return RefreshIndicator(
          onRefresh: () => service.refreshTables(),
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _filteredTables.length,
            itemBuilder: (context, index) {
              final table = _filteredTables[index];
              return _buildTableCard(context, table, notifier);
            },
          ),
        );
      },
    );
  }

  Widget _buildTableCard(
    BuildContext context,
    RestaurantTable table,
    OrderWorkflowNotifier notifier,
  ) {
    final isSelected = notifier.state.selectedTable?.id == table.id;
    final canSelect = table.status == TableStatus.available;

    return Material(
      elevation: isSelected ? 4 : 1,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: canSelect 
          ? () => _onTableSelected(context, table, notifier)
          : () => _onUnavailableTableTapped(context, table),
        onLongPress: () => _showTableDetails(context, table),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _getTableBackgroundColor(context, table.status, isSelected),
            border: Border.all(
              color: _getTableBorderColor(context, table.status, isSelected),
              width: isSelected ? 3 : 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Table icon with status indicator
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          _getTableIcon(table.status),
                          size: 36,
                          color: _getTableIconColor(context, table.status, isSelected),
                        ),
                        if (isSelected)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.check,
                                size: 8,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Table number
                    Text(
                      table.tableNumber,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getTableTextColor(context, table.status, isSelected),
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Capacity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person,
                          size: 14,
                          color: _getTableTextColor(context, table.status, isSelected),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${table.capacity} chỗ',
                          style: TextStyle(
                            fontSize: 12,
                            color: _getTableTextColor(context, table.status, isSelected),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTableStatusColor(context, table.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        table.status.displayName,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getTableStatusColor(context, table.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Loading overlay
              Consumer<TableService>(
                builder: (context, service, child) {
                  if (service.isLoading) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
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
            'Không tìm thấy bàn nào',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _statusFilter = TableFilterOption.all;
                _capacityFilter = CapacityFilter.all;
                _searchController.clear();
              });
              _applyFilters();
            },
            child: const Text('Xóa bộ lọc'),
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
            'Không thể tải danh sách bàn',
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

  void _onTableSelected(
    BuildContext context,
    RestaurantTable table,
    OrderWorkflowNotifier notifier,
  ) async {
    // Show confirmation if table is being selected
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận chọn bàn ${table.tableNumber}'),
        content: Text(
          'Bạn có chắc chắn muốn chọn bàn ${table.tableNumber} (${table.capacity} chỗ) để tạo đơn hàng?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Chọn bàn'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Reserve table through service
      final success = await _tableService.reserveTable(table.id);
      if (success) {
        notifier.selectTable(table);
        
        // Also update OrderService
        final orderService = context.read<OrderService>();
        orderService.setSelectedTable(table);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã chọn bàn ${table.tableNumber}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  void _onUnavailableTableTapped(BuildContext context, RestaurantTable table) {
    String message;
    IconData icon;
    Color color;

    switch (table.status) {
      case TableStatus.occupied:
        message = 'Bàn ${table.tableNumber} đang được sử dụng';
        icon = Icons.people;
        color = Colors.red;
        break;
      case TableStatus.reserved:
        message = 'Bàn ${table.tableNumber} đã được đặt trước';
        icon = Icons.schedule;
        color = Colors.orange;
        break;
      case TableStatus.cleaning:
        message = 'Bàn ${table.tableNumber} đang được dọn dẹp';
        icon = Icons.cleaning_services;
        color = Colors.blue;
        break;
      default:
        return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
      ),
    );
  }

  void _showTableDetails(BuildContext context, RestaurantTable table) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getTableIcon(table.status),
                  size: 32,
                  color: _getTableStatusColor(context, table.status),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bàn ${table.tableNumber}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        table.status.displayName,
                        style: TextStyle(
                          color: _getTableStatusColor(context, table.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow(context, 'Sức chứa', '${table.capacity} khách'),
            _buildDetailRow(context, 'Khu vực', _getLayoutSectionName(table.layoutSectionId)),
            if (table.lastModifiedTime != null)
              _buildDetailRow(
                context, 
                'Cập nhật lần cuối', 
                _formatDateTime(table.lastModifiedTime!),
              ),
            const SizedBox(height: 24),
            if (table.status == TableStatus.available)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _onTableSelected(context, table, context.read<OrderWorkflowNotifier>());
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Chọn bàn này'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLayoutSectionName(String sectionId) {
    switch (sectionId) {
      case 'main-floor':
        return 'Tầng chính';
      case 'vip-section':
        return 'Khu VIP';
      case 'terrace':
        return 'Sân thượng';
      case 'private-room':
        return 'Phòng riêng';
      default:
        return 'Khu vực khác';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Color _getTableBackgroundColor(
    BuildContext context,
    TableStatus status,
    bool isSelected,
  ) {
    if (isSelected) {
      return Theme.of(context).colorScheme.primaryContainer;
    }

    switch (status) {
      case TableStatus.available:
        return Colors.green.withOpacity(0.1);
      case TableStatus.occupied:
        return Colors.red.withOpacity(0.1);
      case TableStatus.reserved:
        return Colors.orange.withOpacity(0.1);
      case TableStatus.cleaning:
        return Colors.blue.withOpacity(0.1);
    }
  }

  Color _getTableBorderColor(
    BuildContext context,
    TableStatus status,
    bool isSelected,
  ) {
    if (isSelected) {
      return Theme.of(context).colorScheme.primary;
    }

    switch (status) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.red;
      case TableStatus.reserved:
        return Colors.orange;
      case TableStatus.cleaning:
        return Colors.blue;
    }
  }

  IconData _getTableIcon(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Icons.restaurant_menu;
      case TableStatus.occupied:
        return Icons.people;
      case TableStatus.reserved:
        return Icons.schedule;
      case TableStatus.cleaning:
        return Icons.cleaning_services;
    }
  }

  Color _getTableIconColor(
    BuildContext context,
    TableStatus status,
    bool isSelected,
  ) {
    if (isSelected) {
      return Theme.of(context).colorScheme.onPrimaryContainer;
    }

    switch (status) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.red;
      case TableStatus.reserved:
        return Colors.orange;
      case TableStatus.cleaning:
        return Colors.blue;
    }
  }

  Color _getTableTextColor(
    BuildContext context,
    TableStatus status,
    bool isSelected,
  ) {
    if (isSelected) {
      return Theme.of(context).colorScheme.onPrimaryContainer;
    }

    return Theme.of(context).colorScheme.onSurface;
  }

  Color _getTableStatusColor(BuildContext context, TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.red;
      case TableStatus.reserved:
        return Colors.orange;
      case TableStatus.cleaning:
        return Colors.blue;
    }
  }
}