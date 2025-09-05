import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_models.dart';
import '../services/order_tracking_service.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/constants/app_colors.dart';

class KitchenIntegrationWidget extends StatefulWidget {
  const KitchenIntegrationWidget({super.key});

  @override
  State<KitchenIntegrationWidget> createState() => _KitchenIntegrationWidgetState();
}

class _KitchenIntegrationWidgetState extends State<KitchenIntegrationWidget>
    with TickerProviderStateMixin {
  late AnimationController _notificationController;
  late Animation<double> _notificationAnimation;
  
  final List<OrderTrackingNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    
    _notificationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _notificationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _notificationController,
      curve: Curves.elasticOut,
    ));
    
    // Listen for kitchen notifications
    _setupNotificationListener();
  }

  @override
  void dispose() {
    _notificationController.dispose();
    super.dispose();
  }

  void _setupNotificationListener() {
    // Mock notification system - in real app, this would be WebSocket or FCM
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _addNotification(OrderTrackingNotification(
          orderId: 'mock-order-1',
          message: 'Phở Bò Tái đã sẵn sàng',
          status: OrderStatus.ready,
          timestamp: DateTime.now(),
          type: NotificationType.kitchenReady,
        ));
      }
    });
    
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        _addNotification(OrderTrackingNotification(
          orderId: 'mock-order-2',
          message: 'Bàn T03 yêu cầu thêm đồ ăn kèm',
          status: OrderStatus.preparing,
          timestamp: DateTime.now(),
          type: NotificationType.customerRequest,
        ));
      }
    });
  }

  void _addNotification(OrderTrackingNotification notification) {
    setState(() {
      _notifications.insert(0, notification);
      if (_notifications.length > 10) {
        _notifications.removeRange(10, _notifications.length);
      }
    });
    
    _notificationController.forward().then((_) {
      _notificationController.reset();
    });
    
    // Show snackbar for important notifications
    if (notification.type == NotificationType.kitchenReady) {
      _showKitchenReadySnackbar(notification);
    }
  }

  void _showKitchenReadySnackbar(OrderTrackingNotification notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.restaurant_menu,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                notification.message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Xem',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to specific order tracking
            // Implementation would depend on navigation structure
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderTrackingService>(
      builder: (context, trackingService, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildConnectionStatus(trackingService),
            Expanded(
              child: _buildNotificationsList(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active,
            color: AppColors.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông báo từ bếp',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Theo dõi trạng thái đơn hàng real-time',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _clearAllNotifications(),
            icon: Icon(
              Icons.clear_all,
              color: Colors.grey[600],
            ),
            tooltip: 'Xóa tất cả thông báo',
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(OrderTrackingService trackingService) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: trackingService.isConnected 
            ? Colors.green.shade50 
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: trackingService.isConnected 
              ? Colors.green.shade200 
              : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: trackingService.isConnected 
                  ? Colors.green 
                  : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            trackingService.isConnected 
                ? 'Kết nối với bếp thành công' 
                : 'Mất kết nối với bếp',
            style: TextStyle(
              color: trackingService.isConnected 
                  ? Colors.green.shade700 
                  : Colors.red.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          if (!trackingService.isConnected) ...[
            const Spacer(),
            Text(
              'Đang kết nối lại...',
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context) {
    if (_notifications.isEmpty) {
      return _buildEmptyNotificationsState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        final isFirst = index == 0;
        
        Widget child = _buildNotificationCard(notification);
        
        if (isFirst) {
          return ScaleTransition(
            scale: _notificationAnimation,
            child: child,
          );
        }
        
        return child;
      },
    );
  }

  Widget _buildEmptyNotificationsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có thông báo nào',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thông báo từ bếp sẽ xuất hiện ở đây',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(OrderTrackingNotification notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(notification.type).withOpacity(0.1),
          child: Icon(
            notification.type.icon,
            color: _getNotificationColor(notification.type),
            size: 20,
          ),
        ),
        title: Text(
          notification.message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đơn hàng: ${notification.orderId}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              VietnameseFormatter.formatDateTime(notification.timestamp),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(notification.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            notification.status.displayName,
            style: TextStyle(
              color: _getStatusColor(notification.status),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
        onTap: () => _handleNotificationTap(context, notification),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.statusUpdate:
        return Colors.blue;
      case NotificationType.kitchenReady:
        return Colors.green;
      case NotificationType.customerRequest:
        return Colors.orange;
      case NotificationType.systemAlert:
        return Colors.red;
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.amber;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.served:
        return Colors.purple;
      case OrderStatus.paid:
        return Colors.grey;
    }
  }

  void _handleNotificationTap(BuildContext context, OrderTrackingNotification notification) {
    // Navigate to specific order tracking screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderTrackingScreen(orderId: notification.orderId),
      ),
    );
  }

  void _clearAllNotifications() {
    setState(() {
      _notifications.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã xóa tất cả thông báo'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}