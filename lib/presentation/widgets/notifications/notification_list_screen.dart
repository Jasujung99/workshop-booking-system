import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/notification_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../theme/app_theme.dart';
import '../../screens/booking/booking_detail_screen.dart';

/// Screen displaying list of all notifications
/// 
/// Shows notifications with options to mark as read, delete, and navigate to related content
class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        actions: [
          Consumer<NotificationService>(
            builder: (context, notificationService, child) {
              if (notificationService.hasUnreadNotifications) {
                return TextButton(
                  onPressed: () => notificationService.markAllAsRead(),
                  child: const Text('모두 읽음'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('모든 알림 삭제'),
              ),
            ],
          ),
        ],
      ),
      body: _buildNotificationList(),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        actions: [
          Consumer<NotificationService>(
            builder: (context, notificationService, child) {
              if (notificationService.hasUnreadNotifications) {
                return TextButton(
                  onPressed: () => notificationService.markAllAsRead(),
                  child: const Text('모두 읽음'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('모든 알림 삭제'),
              ),
            ],
          ),
        ],
      ),
      body: _buildNotificationList(),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  '알림',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Consumer<NotificationService>(
                  builder: (context, notificationService, child) {
                    if (notificationService.hasUnreadNotifications) {
                      return TextButton(
                        onPressed: () => notificationService.markAllAsRead(),
                        child: const Text('모두 읽음'),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(width: AppTheme.spacingSm),
                PopupMenuButton<String>(
                  onSelected: _handleMenuAction,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'clear_all',
                      child: Text('모든 알림 삭제'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: _buildNotificationList()),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return Consumer<NotificationService>(
      builder: (context, notificationService, child) {
        final notifications = notificationService.notifications;

        if (notifications.isEmpty) {
          return const EmptyStateWidget(
            title: '알림이 없습니다',
            message: '새로운 알림이 있을 때 여기에 표시됩니다.',
            icon: Icons.notifications_none,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return NotificationTile(
              notification: notification,
              onTap: () => _handleNotificationTap(notification),
              onDismiss: () => _dismissNotification(notification.id),
            );
          },
        );
      },
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'clear_all':
        _showClearAllDialog();
        break;
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모든 알림 삭제'),
        content: const Text('모든 알림을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              context.read<NotificationService>().clearAllNotifications();
              Navigator.of(context).pop();
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    // Mark as read
    context.read<NotificationService>().markAsRead(notification.id);

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.bookingReminder:
      case NotificationType.bookingStatusChange:
      case NotificationType.paymentCompleted:
      case NotificationType.refundProcessed:
        final bookingId = notification.data['bookingId'] as String?;
        if (bookingId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BookingDetailScreen(bookingId: bookingId),
            ),
          );
        }
        break;
      case NotificationType.general:
        // Handle general notifications
        break;
    }
  }

  void _dismissNotification(String notificationId) {
    context.read<NotificationService>().removeNotification(notificationId);
  }
}

/// Individual notification tile widget
class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationTile({
    required this.notification,
    this.onTap,
    this.onDismiss,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: notification.isRead 
                  ? null 
                  : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: _getNotificationColor(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getNotificationIcon(),
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: notification.isRead 
                                    ? FontWeight.normal 
                                    : FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Text(
                        notification.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Text(
                        notification.timeAgo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon() {
    switch (notification.type) {
      case NotificationType.bookingReminder:
        return Icons.schedule;
      case NotificationType.bookingStatusChange:
        return Icons.update;
      case NotificationType.paymentCompleted:
        return Icons.payment;
      case NotificationType.refundProcessed:
        return Icons.account_balance_wallet;
      case NotificationType.general:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(BuildContext context) {
    switch (notification.type) {
      case NotificationType.bookingReminder:
        return Theme.of(context).colorScheme.secondaryContainer;
      case NotificationType.bookingStatusChange:
        return Theme.of(context).colorScheme.primaryContainer;
      case NotificationType.paymentCompleted:
        return Theme.of(context).colorScheme.tertiaryContainer;
      case NotificationType.refundProcessed:
        return Theme.of(context).colorScheme.errorContainer;
      case NotificationType.general:
        return Theme.of(context).colorScheme.surfaceVariant;
    }
  }
}