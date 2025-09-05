import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_models.dart';
import '../services/order_tracking_service.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';

class OrderStatusTrackingWidget extends StatefulWidget {
  final String orderId;
  final VoidCallback? onOrderCompleted;

  const OrderStatusTrackingWidget({
    super.key,
    required this.orderId,
    this.onOrderCompleted,
  });

  @override
  State<OrderStatusTrackingWidget> createState() => _OrderStatusTrackingWidgetState();
}

class _OrderStatusTrackingWidgetState extends State<OrderStatusTrackingWidget>
    with TickerProviderStateMixin {
  late OrderTrackingService _trackingService;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _trackingService = context.read<OrderTrackingService>();
    _trackingService.startTracking(widget.orderId);
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _trackingService.stopTracking();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderTrackingService>(
      builder: (context, trackingService, child) {
        if (trackingService.isLoading) {
          return const LoadingWidget(message: 'Đang tải thông tin đơn hàng...');
        }

        if (trackingService.error != null) {
          return CustomErrorWidget(
            message: trackingService.error!,
            onRetry: () => trackingService.startTracking(widget.orderId),
          );
        }

        final order = trackingService.currentOrder;
        if (order == null) {
          return _buildOrderNotFoundState();
        }

        return _buildTrackingContent(order, trackingService);
      },
    );
  }

  Widget _buildOrderNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy đơn hàng',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Đơn hàng có thể đã được xử lý hoặc không tồn tại',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Quay lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingContent(Order order, OrderTrackingService trackingService) {
    return Column(
      children: [
        _buildOrderHeader(order),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderInfo(order),
                const SizedBox(height: 24),
                _buildStatusTimeline(order),
                const SizedBox(height: 24),
                _buildOrderItems(order),
                if (_shouldShowKitchenActions(order)) ...[
                  const SizedBox(height: 24),
                  _buildKitchenActions(order, trackingService),
                ],
              ],
            ),
          ),
        ),
        if (_shouldShowBottomActions(order))
          _buildBottomActions(order, trackingService),
      ],
    );
  }

  Widget _buildOrderHeader(Order order) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đơn hàng ${order.orderNumber}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    VietnameseFormatter.formatDateTime(order.creationTime),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusChip(order.status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        icon = Icons.schedule;
        break;
      case OrderStatus.confirmed:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade700;
        icon = Icons.check_circle_outline;
        break;
      case OrderStatus.preparing:
        backgroundColor = Colors.amber.shade100;
        textColor = Colors.amber.shade700;
        icon = Icons.restaurant;
        break;
      case OrderStatus.ready:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        icon = Icons.done;
        break;
      case OrderStatus.served:
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade700;
        icon = Icons.room_service;
        break;
      case OrderStatus.paid:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        icon = Icons.payment;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == OrderStatus.preparing)
            ScaleTransition(
              scale: _pulseAnimation,
              child: Icon(icon, color: textColor, size: 16),
            )
          else
            Icon(icon, color: textColor, size: 16),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin đơn hàng',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.restaurant_menu,
              'Loại đơn hàng',
              order.orderType.displayName,
            ),
            if (order.tableId != null)
              _buildInfoRow(
                Icons.table_restaurant,
                'Bàn số',
                'Bàn ${order.tableId}', // Would get table number from TableService
              ),
            _buildInfoRow(
              Icons.attach_money,
              'Tổng tiền',
              VietnameseFormatter.formatCurrency(order.totalAmount),
            ),
            _buildInfoRow(
              Icons.receipt,
              'Số món',
              '${order.items.length} món (${order.items.fold(0, (sum, item) => sum + item.quantity)} phần)',
            ),
            if (order.notes?.isNotEmpty == true)
              _buildInfoRow(
                Icons.note,
                'Ghi chú',
                order.notes!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(Order order) {
    final statusHistory = _getStatusHistory(order);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tiến trình đơn hàng',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: statusHistory.length,
              itemBuilder: (context, index) {
                final step = statusHistory[index];
                final isLast = index == statusHistory.length - 1;
                return _buildTimelineItem(step, isLast);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(OrderStatusStep step, bool isLast) {
    final isCompleted = step.isCompleted;
    final isCurrent = step.isCurrent;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? AppColors.success 
                    : isCurrent 
                        ? AppColors.primary 
                        : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted 
                    ? Icons.check 
                    : isCurrent 
                        ? Icons.radio_button_checked 
                        : Icons.radio_button_unchecked,
                color: isCompleted || isCurrent ? Colors.white : Colors.grey[600],
                size: 16,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? AppColors.success : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.status.displayName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCompleted || isCurrent 
                        ? Colors.black87 
                        : Colors.grey[600],
                  ),
                ),
                Text(
                  step.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                if (step.timestamp != null)
                  Text(
                    VietnameseFormatter.formatTime(step.timestamp!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItems(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Chi tiết món ăn',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${order.items.length} món',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final item = order.items[index];
                return _buildOrderItemRow(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemRow(OrderItem item) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.quantity}x ${item.menuItemName}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (item.notes?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  'Ghi chú: ${item.notes}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                VietnameseFormatter.formatCurrency(item.totalPrice),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _buildItemStatusChip(item.status),
      ],
    );
  }

  Widget _buildItemStatusChip(OrderItemStatus status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case OrderItemStatus.pending:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        icon = Icons.schedule;
        break;
      case OrderItemStatus.preparing:
        backgroundColor = Colors.amber.shade100;
        textColor = Colors.amber.shade700;
        icon = Icons.restaurant;
        break;
      case OrderItemStatus.ready:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        icon = Icons.done;
        break;
      case OrderItemStatus.served:
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade700;
        icon = Icons.check_circle;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 14),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKitchenActions(Order order, OrderTrackingService trackingService) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.kitchen, color: AppColors.success),
                const SizedBox(width: 8),
                Text(
                  'Món đã sẵn sàng!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Các món ăn đã được chuẩn bị xong. Vui lòng đến bếp để nhận món và mang ra cho khách.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: trackingService.isLoading 
                    ? null 
                    : () => _markAsPickedUp(order, trackingService),
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Đã nhận món từ bếp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(Order order, OrderTrackingService trackingService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trackingService.error != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trackingService.error!,
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: trackingService.isLoading 
                        ? null 
                        : () => trackingService.refreshOrder(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Cập nhật'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: trackingService.isLoading 
                        ? null 
                        : () => _markAsServed(order, trackingService),
                    icon: const Icon(Icons.room_service),
                    label: const Text('Đã phục vụ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowKitchenActions(Order order) {
    return order.status == OrderStatus.ready;
  }

  bool _shouldShowBottomActions(Order order) {
    return order.status == OrderStatus.ready || 
           order.status == OrderStatus.confirmed || 
           order.status == OrderStatus.preparing;
  }

  List<OrderStatusStep> _getStatusHistory(Order order) {
    final currentTime = DateTime.now();
    final steps = <OrderStatusStep>[];

    // Pending
    steps.add(OrderStatusStep(
      status: OrderStatus.pending,
      description: 'Đơn hàng được tạo và chờ xác nhận',
      timestamp: order.creationTime,
      isCompleted: order.status.index >= OrderStatus.confirmed.index,
      isCurrent: order.status == OrderStatus.pending,
    ));

    // Confirmed
    steps.add(OrderStatusStep(
      status: OrderStatus.confirmed,
      description: 'Đơn hàng đã được xác nhận và gửi đến bếp',
      timestamp: order.status.index >= OrderStatus.confirmed.index 
          ? order.creationTime.add(const Duration(minutes: 1))
          : null,
      isCompleted: order.status.index >= OrderStatus.preparing.index,
      isCurrent: order.status == OrderStatus.confirmed,
    ));

    // Preparing
    steps.add(OrderStatusStep(
      status: OrderStatus.preparing,
      description: 'Đầu bếp đang chuẩn bị món ăn',
      timestamp: order.status.index >= OrderStatus.preparing.index 
          ? order.creationTime.add(const Duration(minutes: 5))
          : null,
      isCompleted: order.status.index >= OrderStatus.ready.index,
      isCurrent: order.status == OrderStatus.preparing,
    ));

    // Ready
    steps.add(OrderStatusStep(
      status: OrderStatus.ready,
      description: 'Món ăn đã sẵn sàng, chờ nhân viên nhận',
      timestamp: order.status.index >= OrderStatus.ready.index 
          ? order.creationTime.add(const Duration(minutes: 15))
          : null,
      isCompleted: order.status.index >= OrderStatus.served.index,
      isCurrent: order.status == OrderStatus.ready,
    ));

    // Served
    steps.add(OrderStatusStep(
      status: OrderStatus.served,
      description: 'Đã phục vụ khách hàng',
      timestamp: order.status.index >= OrderStatus.served.index 
          ? order.creationTime.add(const Duration(minutes: 20))
          : null,
      isCompleted: order.status.index >= OrderStatus.paid.index,
      isCurrent: order.status == OrderStatus.served,
    ));

    return steps;
  }

  Future<void> _markAsPickedUp(Order order, OrderTrackingService trackingService) async {
    final confirmed = await _showConfirmationDialog(
      'Xác nhận nhận món',
      'Bạn có chắc chắn đã nhận tất cả món ăn từ bếp?',
      'Đã nhận món',
    );

    if (confirmed == true) {
      await trackingService.updateOrderStatus(
        order.id,
        OrderStatus.ready, // Keep as ready, but mark items as picked up
        'Nhân viên đã nhận món từ bếp',
      );
    }
  }

  Future<void> _markAsServed(Order order, OrderTrackingService trackingService) async {
    final confirmed = await _showConfirmationDialog(
      'Xác nhận đã phục vụ',
      'Bạn có chắc chắn đã mang món ra và phục vụ khách hàng?',
      'Đã phục vụ',
    );

    if (confirmed == true) {
      await trackingService.updateOrderStatus(
        order.id,
        OrderStatus.served,
        'Đã phục vụ khách hàng',
      );
      
      if (mounted) {
        widget.onOrderCompleted?.call();
      }
    }
  }

  Future<bool?> _showConfirmationDialog(String title, String content, String confirmText) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

class OrderStatusStep {
  final OrderStatus status;
  final String description;
  final DateTime? timestamp;
  final bool isCompleted;
  final bool isCurrent;

  const OrderStatusStep({
    required this.status,
    required this.description,
    this.timestamp,
    required this.isCompleted,
    required this.isCurrent,
  });
}