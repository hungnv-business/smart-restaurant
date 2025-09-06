import 'package:flutter/material.dart';

/// Widget hiển thị thông tin một món trong đơn hàng
class OrderItemCard extends StatelessWidget {
  final String itemName;
  final int quantity;
  final int unitPrice;
  final String status;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  const OrderItemCard({
    Key? key,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.status,
    this.onEdit,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColors = {
      'Chờ chuẩn bị': Colors.grey,
      'Đang chuẩn bị': Colors.orange,
      'Đã hoàn thành': Colors.green,
      'Đã phục vụ': Colors.blue,
      'Đã Huỷ': Colors.red,
    };

    final statusIcons = {
      'Chờ chuẩn bị': Icons.pending,
      'Đang chuẩn bị': Icons.restaurant,
      'Đã hoàn thành': Icons.check_circle,
      'Đã phục vụ': Icons.done_all,
      'Đã Huỷ': Icons.cancel,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Món ăn info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Số lượng: $quantity',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Giá
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${unitPrice * quantity}đ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${unitPrice}đ/món',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Status và actions
            Row(
              children: [
                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColors[status]?.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: statusColors[status] ?? Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcons[status] ?? Icons.help,
                        size: 14,
                        color: statusColors[status] ?? Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColors[status] ?? Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Action buttons (chỉ hiển thị với những món chưa phục vụ)
                if (status == 'Chờ chuẩn bị') ...[
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 20),
                    tooltip: 'Sửa món',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete, size: 20),
                    color: Colors.red,
                    tooltip: 'Xóa món',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}