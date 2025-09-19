import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/notification_models.dart';
import '../services/notification_service.dart';

/// Widget hiển thị danh sách notifications
class NotificationListWidget extends StatelessWidget {
  final bool showOnlyUnread;
  final int? maxItems;
  final VoidCallback? onNotificationTap;
  
  const NotificationListWidget({
    Key? key,
    this.showOnlyUnread = false,
    this.maxItems,
    this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, child) {
        final notifications = showOnlyUnread 
            ? notificationService.unreadNotifications
            : notificationService.notifications;
            
        final displayNotifications = maxItems != null 
            ? notifications.take(maxItems!).toList()
            : notifications;

        if (displayNotifications.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayNotifications.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final notification = displayNotifications[index];
            return NotificationTile(
              notification: notification,
              onTap: () {
                notificationService.markAsRead(notification.id);
                onNotificationTap?.call();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            showOnlyUnread ? Icons.notifications_none : Icons.inbox,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            showOnlyUnread 
                ? 'Không có thông báo mới'
                : 'Chưa có thông báo nào',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            showOnlyUnread
                ? 'Thông báo mới từ bếp sẽ hiển thị ở đây'
                : 'Thông báo từ bếp sẽ xuất hiện ở đây',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Widget tile cho từng notification
class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  
  const NotificationTile({
    Key? key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        context.read<NotificationService>().removeNotification(notification.id);
        onDismiss?.call();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: ListTile(
        leading: _buildLeadingIcon(),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.body,
              style: TextStyle(
                color: notification.isRead ? Colors.grey[600] : Colors.grey[800],
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(notification.timestamp),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: notification.isRead 
            ? null 
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: onTap,
        tileColor: notification.isRead ? null : Colors.blue.withOpacity(0.05),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    Color color;
    IconData icon;

    switch (notification.type) {
      case NotificationType.newOrder:
        color = Colors.green;
        icon = Icons.restaurant_menu;
        break;
      case NotificationType.orderItemServed:
        color = Colors.blue;
        icon = Icons.check_circle;
        break;
      case NotificationType.orderItemQuantityUpdated:
        color = Colors.orange;
        icon = Icons.edit;
        break;
      case NotificationType.orderItemsAdded:
        color = Colors.purple;
        icon = Icons.add_circle;
        break;
      case NotificationType.orderItemRemoved:
        color = Colors.red;
        icon = Icons.remove_circle;
        break;
      case NotificationType.other:
      default:
        color = Colors.grey;
        icon = Icons.notifications;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '$difference.inMinutes phút trước';
    } else if (difference.inHours < 24) {
      return '$difference.inHours giờ trước';
    } else if (difference.inDays < 7) {
      return '$difference.inDays ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
    }
  }
}

/// Badge hiển thị số lượng notifications chưa đọc
class NotificationBadge extends StatelessWidget {
  final Widget child;
  final bool showCount;
  
  const NotificationBadge({
    Key? key,
    required this.child,
    this.showCount = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, _) {
        final unreadCount = notificationService.unreadCount;
        
        if (unreadCount == 0) {
          return child;
        }

        return Stack(
          children: [
            child,
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: showCount && unreadCount < 100
                    ? Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Bottom sheet để hiển thị notifications
class NotificationBottomSheet extends StatelessWidget {
  const NotificationBottomSheet({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const NotificationBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, child) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Thông báo từ bếp',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (notificationService.unreadCount > 0)
                        TextButton(
                          onPressed: () {
                            notificationService.markAllAsRead();
                          },
                          child: const Text('Đánh dấu tất cả đã đọc'),
                        ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                // Notifications list
                Expanded(
                  child: notificationService.notifications.isEmpty
                      ? const Center(
                          child: NotificationListWidget(),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: notificationService.notifications.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final notification = notificationService.notifications[index];
                            return NotificationTile(
                              notification: notification,
                              onTap: () {
                                notificationService.markAsRead(notification.id);
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}