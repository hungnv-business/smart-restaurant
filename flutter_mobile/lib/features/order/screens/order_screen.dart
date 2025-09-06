import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/enums/restaurant_enums.dart';
import '../../../core/models/table_models.dart';
import '../../../core/services/order_service.dart';
import '../../../core/services/auth_service.dart';
import '../widgets/table_screen_header.dart';
import '../widgets/table_filters.dart';
import '../widgets/section_column.dart';
import '../widgets/empty_state_widget.dart';

/// Màn hình Gọi món - Hiển thị danh sách bàn
class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<ActiveTableDto> _allTables = [];
  String _searchQuery = '';
  TableStatus? _selectedStatusFilter;
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTables();
    });
  }

  Future<void> _loadTables() async {
    try {
      final orderService = Provider.of<OrderService>(context, listen: false);
      
      // Gọi API với filters
      final tables = await orderService.getActiveTables(
        tableNameFilter: _searchQuery.isEmpty ? null : _searchQuery,
        statusFilter: _selectedStatusFilter,
      );
      setState(() {
        _allTables = tables;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải danh sách bàn: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Thử lại',
              onPressed: _loadTables,
            ),
          ),
        );
      }
    }
  }

  void _debounceSearch() {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      _loadTables();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _debounceSearch();
  }

  void _onStatusFilterChanged(TableStatus? status) {
    setState(() {
      _selectedStatusFilter = status;
    });
    _loadTables();
  }

  /// Group bàn theo section
  Map<String, List<ActiveTableDto>> get _groupedTables {
    final Map<String, List<ActiveTableDto>> grouped = {};
    
    for (final table in _allTables) {
      final sectionName = table.layoutSectionName ?? 'Không có khu vực';
      if (!grouped.containsKey(sectionName)) {
        grouped[sectionName] = [];
      }
      grouped[sectionName]!.add(table);
    }
    
    // Sắp xếp bàn trong mỗi section theo displayOrder
    for (final section in grouped.values) {
      section.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    }
    
    return grouped;
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const TableScreenHeader(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TableFilters(
              searchQuery: _searchQuery,
              selectedStatusFilter: _selectedStatusFilter,
              onSearchChanged: _onSearchChanged,
              onStatusFilterChanged: _onStatusFilterChanged,
            ),
          ),
          Expanded(child: _buildTableContent()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshTables,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildTableContent() {
    return Consumer<OrderService>(
      builder: (context, orderService, child) {
        if (orderService.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_allTables.isEmpty) {
          return const EmptyStateWidget(hasNoTables: true);
        }

        return _buildTableGrid();
      },
    );
  }

  Widget _buildTableGrid() {

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final availableWidth = screenWidth - 32; // Trừ padding 16 mỗi bên
        final sectionsCount = _groupedTables.length;
        
        // Tính width cho mỗi cột dựa trên số lượng sections
        double columnWidth = 200; // Default width
        if (sectionsCount > 0) {
          final totalSpacing = (sectionsCount - 1) * 12; // Spacing giữa các cột
          final maxColumnWidth = (availableWidth - totalSpacing) / sectionsCount;
          columnWidth = maxColumnWidth > 150 ? maxColumnWidth : 200; // Min width 150
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _groupedTables.entries.toList().asMap().entries.map((mapEntry) {
                final index = mapEntry.key;
                final entry = mapEntry.value;
                final isLast = index == _groupedTables.length - 1;
                
                return Container(
                  width: columnWidth,
                  margin: EdgeInsets.only(right: isLast ? 0 : 12),
                  child: SectionColumn(
                    sectionName: entry.key,
                    tables: entry.value,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _refreshTables() {
    _loadTables();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã cập nhật danh sách bàn')),
    );
  }
}