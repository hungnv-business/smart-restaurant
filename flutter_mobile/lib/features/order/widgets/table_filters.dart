import 'package:flutter/material.dart';
import '../../../core/enums/restaurant_enums.dart';

/// Widget chứa thanh tìm kiếm và các filter chips
class TableFilters extends StatelessWidget {
  final String searchQuery;
  final TableStatus? selectedStatusFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<TableStatus?> onStatusFilterChanged;
  
  const TableFilters({
    super.key,
    required this.searchQuery,
    required this.selectedStatusFilter,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchField(),
        const SizedBox(height: 16),
        _buildStatusFilters(),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Tìm kiếm bàn...',
        prefixIcon: Icon(Icons.search),
      ),
      onChanged: onSearchChanged,
    );
  }

  Widget _buildStatusFilters() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(
            label: 'Tất cả',
            isSelected: selectedStatusFilter == null,
            onSelected: (selected) {
              onStatusFilterChanged(null);
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: TableStatus.available.displayName,
            isSelected: selectedStatusFilter == TableStatus.available,
            onSelected: (selected) {
              onStatusFilterChanged(selected ? TableStatus.available : null);
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: TableStatus.occupied.displayName,
            isSelected: selectedStatusFilter == TableStatus.occupied,
            onSelected: (selected) {
              onStatusFilterChanged(selected ? TableStatus.occupied : null);
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: TableStatus.reserved.displayName,
            isSelected: selectedStatusFilter == TableStatus.reserved,
            onSelected: (selected) {
              onStatusFilterChanged(selected ? TableStatus.reserved : null);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
    );
  }
}