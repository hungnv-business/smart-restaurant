import 'package:flutter/material.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../core/enums/restaurant_enums.dart';

/// Widget hiển thị thông tin một món trong đơn hàng
class OrderItemCard extends StatelessWidget {
  final String itemName;
  final int quantity;
  final int unitPrice;
  final OrderItemStatus status;
  final String? totalPrice;
  final String? specialRequest;
  final bool hasMissingIngredients;
  final String? missingIngredientsMessage; // Thêm field cho displayMessage
  final bool requiresCooking; // Món có cần nấu hay không
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;
  final VoidCallback? onServe; // Callback cho nút phục vụ

  const OrderItemCard({
    super.key,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.status,
    this.totalPrice,
    this.specialRequest,
    this.hasMissingIngredients = false,
    this.missingIngredientsMessage,
    this.requiresCooking = true,
    this.onEdit,
    this.onRemove,
    this.onServe,
  });

  /// Lấy màu cho status
  Color _getStatusColor() {
    return Color(status.colorValue);
  }

  /// Kiểm tra có thể hiển thị nút phục vụ hay không
  bool _canShowServeButton() {
    if (requiresCooking) {
      // Món cần nấu: chỉ hiển thị khi đã hoàn thành
      return status == OrderItemStatus.ready;
    } else {
      // Món không cần nấu: hiển thị luôn (trừ khi đã served)
      return status != OrderItemStatus.served;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayStatus = status.displayName;
    final statusColor = _getStatusColor();

    return Card(
      margin: EdgeInsets.zero, // Bỏ margin vì đã có trong ListView
      elevation: 1, // Giảm elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Giảm border radius
        side: BorderSide(
          color: hasMissingIngredients ? Colors.orange : Colors.transparent,
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
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(width: 12),
                          // Status compact
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              displayStatus,
                              style: TextStyle(
                                color: statusColor,
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
                                    ? missingIngredientsMessage!
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
                      if (specialRequest != null &&
                          specialRequest!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          specialRequest!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
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
                    if (status == OrderItemStatus.pending) ...[
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

                    // Nút Phục vụ
                    // - Món cần nấu: chỉ hiển thị khi status == OrderItemStatus.ready
                    // - Món không cần nấu: hiển thị ngay từ
                    if (onServe != null && _canShowServeButton()) ...[
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: onServe,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Phục vụ ngay',
                            style: const TextStyle(
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
