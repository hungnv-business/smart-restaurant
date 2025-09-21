import 'package:flutter/material.dart';
import '../../../core/enums/restaurant_enums.dart';
import '../../../core/models/order/dinein_table_models.dart';
import '../screens/table_detail_screen.dart';

/// Widget hiển thị thông tin một bàn dưới dạng card
class TableCard extends StatelessWidget {
  final DineInTableDto table;
  final VoidCallback? onTableUpdated; // Callback khi bàn cập nhật
  final bool isCompact;

  const TableCard({
    super.key,
    required this.table,
    this.onTableUpdated,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final canOrder =
        table.status == TableStatus.available ||
        table.status == TableStatus.occupied;

    final borderRadius = isCompact ? 8.0 : 12.0;
    final cardPadding = isCompact
        ? const EdgeInsets.all(8)
        : const EdgeInsets.all(16);
    final spacing = isCompact ? 10.0 : 12.0; // Tăng spacing

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: isCompact ? 6 : 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Color(table.status.colorValue).withValues(alpha: 0.2),
          width: isCompact ? 1.0 : 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canOrder ? () => _navigateToMenu(context) : null,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: cardPadding,
            width: double.infinity, // Đảm bảo chiều rộng đầy đủ
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                SizedBox(height: spacing),
                _buildStatusBadge(context),
                if (_hasOrderInfo()) ...[
                  SizedBox(height: spacing),
                  _buildOrderInfo(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final tablePadding = isCompact
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 3)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    final dotSize = isCompact ? 10.0 : 12.0;
    final textStyle = isCompact
        ? Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4CAF50),
          )
        : Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4CAF50),
          );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Table number với background
        Flexible(
          child: Container(
            padding: tablePadding,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
            ),
            child: Text(
              table.tableNumber,
              style: textStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        // Status indicator dot
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: Color(table.status.colorValue),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(table.status.colorValue).withValues(alpha: 0.3),
                blurRadius: isCompact ? 3 : 4,
                spreadRadius: isCompact ? 0.5 : 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final badgePadding = isCompact
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 6);
    final fontSize = isCompact ? 11.0 : 12.0;

    return Container(
      padding: badgePadding,
      decoration: BoxDecoration(
        color: Color(table.status.colorValue),
        borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Color(table.status.colorValue).withValues(alpha: 0.3),
            blurRadius: isCompact ? 3 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        table.status.displayName,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOrderInfo(BuildContext context) {
    final totalPending = table.pendingItemsCount;
    final totalReady = table.readyItemsCount;

    // Chỉ hiển thị nếu có món chờ hoặc món sẵn sàng
    if (totalPending == 0 && totalReady == 0) return const SizedBox.shrink();

    final iconSize = isCompact ? 14.0 : 18.0;
    final fontSize = isCompact ? 10.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hiển thị món chờ nếu có
        if (totalPending > 0)
          Row(
            children: [
              Icon(Icons.schedule, size: iconSize, color: Colors.orange),
              const SizedBox(width: 4),
              Text(
                '$totalPending món chờ',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

        // Khoảng cách giữa 2 dòng nếu cả 2 đều hiển thị
        if (totalPending > 0 && totalReady > 0) const SizedBox(height: 2),

        // Hiển thị món sẵn sàng nếu có
        if (totalReady > 0)
          Row(
            children: [
              Icon(Icons.check_circle, size: iconSize, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                '$totalReady món sẵn sàng',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      ],
    );
  }

  bool _hasOrderInfo() {
    return table.hasActiveOrders ||
        table.pendingItemsCount > 0 ||
        table.readyItemsCount > 0;
  }

  void _navigateToMenu(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TableDetailScreen(table: table)),
    );

    // Nếu có result (tức là có thay đổi), gọi callback
    if (result == true && onTableUpdated != null) {
      onTableUpdated!();
    }
  }
}
