import 'package:flutter/material.dart';

/// Widget hiển thị trạng thái rỗng khi không có bàn nào
class EmptyStateWidget extends StatelessWidget {
  final bool hasNoTables;
  
  const EmptyStateWidget({
    super.key,
    required this.hasNoTables,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.table_restaurant_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            hasNoTables 
                ? 'Không có bàn nào'
                : 'Không tìm thấy bàn phù hợp',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasNoTables
                ? 'Vui lòng kiểm tra kết nối và thử lại'
                : 'Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}