import 'package:flutter/material.dart';
import '../../../shared/utils/price_formatter.dart';

/// Widget hiển thị thông tin một món trong đơn hàng
class OrderItemCard extends StatelessWidget {
  final String itemName;
  final int quantity;
  final int unitPrice;
  final String status;
  final Color? statusColor;
  final String? totalPrice;
  final String? specialRequest;
  final bool hasMissingIngredients;
  final String? missingIngredientsMessage; // Thêm field cho displayMessage
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;
  final VoidCallback? onServe; // Callback cho nút phục vụ

  const OrderItemCard({
    Key? key,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.status,
    this.statusColor,
    this.totalPrice,
    this.specialRequest,
    this.hasMissingIngredients = false,
    this.missingIngredientsMessage,
    this.onEdit,
    this.onRemove,
    this.onServe,
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
      margin: EdgeInsets.zero, // Bỏ margin vì đã có trong ListView
      elevation: 1, // Giảm elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Giảm border radius
        side: BorderSide(
          color: hasMissingIngredients 
              ? Colors.orange 
              : Colors.transparent,
          width: hasMissingIngredients ? 1.5 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12), // Giảm padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content row
            Row(
              children: [
                // Món ăn info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên món
                      Text(
                        itemName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      
                      // Số lượng và status inline
                      Row(
                        children: [
                          Text(
                            'SL: $quantity',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Status compact
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColors[status]?.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: statusColors[status] ?? Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Warning thiếu nguyên liệu
                      if (hasMissingIngredients) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.warning,
                              size: 14,
                              color: Colors.orange[700],
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                missingIngredientsMessage?.isNotEmpty == true
                                    ? '${missingIngredientsMessage!}'
                                    : 'Thiếu nguyên liệu',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      // Ghi chú nếu có (compact)
                      if (specialRequest != null && specialRequest!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          specialRequest!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.amber[800],
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Giá và actions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      PriceFormatter.format(unitPrice * quantity),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    
                    // Action buttons compact
                    if (status == 'Chờ chuẩn bị') ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: onEdit,
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.edit,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: onRemove,
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.delete,
                                size: 16,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    // Nút Phục vụ khi món đã sẵn sàng
                    if (status == 'Đã hoàn thành' && onServe != null) ...[
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: onServe,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Phục vụ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}