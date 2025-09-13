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
        final sectionsCount = _groupedTables.length;
        
        if (sectionsCount == 0) {
          return const SizedBox.shrink();
        }
        
        // Responsive padding
        final horizontalPadding = screenWidth > 400 ? 20.0 : 16.0;
        final verticalPadding = screenWidth > 400 ? 12.0 : 8.0;
        
        // Tính toán để fit 3 cột trên iPhone 15 Pro Max
        final availableWidth = screenWidth - (horizontalPadding * 2);
        final columnSpacing = screenWidth > 400 ? 12.0 : 8.0; // Giảm spacing
        
        // Tính column width để fit 3 cột
        double columnWidth;
        if (sectionsCount <= 3 && sectionsCount > 0) {
          final totalSpacing = (sectionsCount - 1) * columnSpacing;
          columnWidth = (availableWidth - totalSpacing) / sectionsCount;
          
          // Đảm bảo min width hợp lý cho 3 cột trên iPhone
          final minWidth = screenWidth > 428 ? 120.0 : 105.0; // Giảm min width
          columnWidth = columnWidth.clamp(minWidth, 140.0); // Max width 140
        } else {
          // Với > 3 sections, sử dụng scroll
          columnWidth = screenWidth > 428 ? 130 : 115;
        }
        
        final needsScroll = sectionsCount > 3 || 
            (sectionsCount > 0 && (columnWidth * sectionsCount + (sectionsCount - 1) * columnSpacing) > availableWidth);
        
        final content = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _groupedTables.entries.toList().asMap().entries.map((mapEntry) {
            final index = mapEntry.key;
            final entry = mapEntry.value;
            final isLast = index == _groupedTables.length - 1;
            
            return Container(
              width: columnWidth,
              margin: EdgeInsets.only(right: isLast ? 0 : columnSpacing),
              child: SectionColumn(
                sectionName: entry.key,
                tables: entry.value,
                onTableUpdated: _loadTables,
                isCompact: true, // Thêm flag để compact layout
              ),
            );
          }).toList(),
        );
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
          child: needsScroll 
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: content,
              )
            : content,
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