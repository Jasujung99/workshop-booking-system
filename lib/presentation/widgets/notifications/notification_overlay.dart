import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/notification_service.dart';
import 'notification_bell.dart';

/// Overlay widget for displaying floating notifications
/// 
/// Wraps the app and shows floating notifications when they arrive
class NotificationOverlay extends StatefulWidget {
  final Widget child;

  const NotificationOverlay({
    required this.child,
    super.key,
  });

  @override
  State<NotificationOverlay> createState() => _NotificationOverlayState();
}

class _NotificationOverlayState extends State<NotificationOverlay> {
  final List<AppNotification> _activeNotifications = [];
  late OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _overlayEntry = null;
    
    // Listen to notification stream
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationService>().notificationStream.listen(
        _handleNewNotification,
      );
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _handleNewNotification(AppNotification notification) {
    if (!mounted) return;

    setState(() {
      _activeNotifications.add(notification);
    });

    _showFloatingNotification(notification);
  }

  void _showFloatingNotification(AppNotification notification) {
    if (_overlayEntry != null) {
      _removeOverlay();
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 0,
        right: 0,
        child: FloatingNotification(
          notification: notification,
          onTap: () => _handleNotificationTap(notification),
          onDismiss: () => _dismissFloatingNotification(notification),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _handleNotificationTap(AppNotification notification) {
    _dismissFloatingNotification(notification);
    
    // Mark as read
    context.read<NotificationService>().markAsRead(notification.id);
    
    // Handle navigation based on notification type
    _navigateToNotificationTarget(notification);
  }

  void _dismissFloatingNotification(AppNotification notification) {
    _removeOverlay();
    
    setState(() {
      _activeNotifications.remove(notification);
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _navigateToNotificationTarget(AppNotification notification) {
    // This would handle navigation to the appropriate screen
    // based on the notification type and data
    switch (notification.type) {
      case NotificationType.bookingReminder:
      case NotificationType.bookingStatusChange:
      case NotificationType.paymentCompleted:
      case NotificationType.refundProcessed:
        // Navigate to booking detail if booking ID is available
        final bookingId = notification.data['bookingId'] as String?;
        if (bookingId != null) {
          // Navigation would be handled by the parent widget
          // or through a navigation service
        }
        break;
      case NotificationType.general:
        // Handle general notifications
        break;
    }
  }
}

/// Provider for managing notification overlay state
class NotificationOverlayProvider extends ChangeNotifier {
  bool _isEnabled = true;
  
  bool get isEnabled => _isEnabled;
  
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    notifyListeners();
  }
  
  void toggleEnabled() {
    _isEnabled = !_isEnabled;
    notifyListeners();
  }
}