import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../domain/entities/booking.dart';

/// Service for managing notifications
/// 
/// Handles both push notifications and in-app notifications
/// for booking-related events and reminders
class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<AppNotification> _notifications = [];
  final StreamController<AppNotification> _notificationStream = 
      StreamController<AppNotification>.broadcast();

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  Stream<AppNotification> get notificationStream => _notificationStream.stream;
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get hasUnreadNotifications => unreadCount > 0;

  /// Initialize notification service
  Future<void> initialize() async {
    // Initialize push notification service
    await _initializePushNotifications();
    
    // Set up periodic booking reminders
    _setupBookingReminders();
  }

  /// Add a new notification
  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    _notificationStream.add(notification);
    notifyListeners();
    
    // Show push notification if app is in background
    _showPushNotification(notification);
  }

  /// Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  /// Remove notification
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  /// Clear all notifications
  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  /// Schedule booking reminder notification
  void scheduleBookingReminder(Booking booking, DateTime reminderTime) {
    final notification = AppNotification(
      id: 'booking_reminder_${booking.id}',
      title: '예약 알림',
      message: '${booking.typeDisplayName} 예약이 곧 시작됩니다.',
      type: NotificationType.bookingReminder,
      data: {'bookingId': booking.id},
      scheduledTime: reminderTime,
      createdAt: DateTime.now(),
    );

    // In a real app, this would schedule a local notification
    // For now, we'll add it to the list if the time has passed
    if (reminderTime.isBefore(DateTime.now())) {
      addNotification(notification);
    }
  }

  /// Notify about booking status change
  void notifyBookingStatusChange(Booking booking, BookingStatus oldStatus) {
    String message;
    switch (booking.status) {
      case BookingStatus.confirmed:
        message = '예약이 확정되었습니다.';
        break;
      case BookingStatus.cancelled:
        message = '예약이 취소되었습니다.';
        break;
      case BookingStatus.completed:
        message = '예약이 완료되었습니다. 후기를 남겨주세요!';
        break;
      default:
        message = '예약 상태가 변경되었습니다.';
    }

    final notification = AppNotification(
      id: 'booking_status_${booking.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: '예약 상태 변경',
      message: message,
      type: NotificationType.bookingStatusChange,
      data: {'bookingId': booking.id, 'status': booking.status.name},
      createdAt: DateTime.now(),
    );

    addNotification(notification);
  }

  /// Notify about payment completion
  void notifyPaymentCompleted(Booking booking) {
    final notification = AppNotification(
      id: 'payment_completed_${booking.id}',
      title: '결제 완료',
      message: '${booking.formattedTotalAmount} 결제가 완료되었습니다.',
      type: NotificationType.paymentCompleted,
      data: {'bookingId': booking.id},
      createdAt: DateTime.now(),
    );

    addNotification(notification);
  }

  /// Notify about refund processed
  void notifyRefundProcessed(Booking booking, double refundAmount) {
    final formattedAmount = '${refundAmount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}원';

    final notification = AppNotification(
      id: 'refund_processed_${booking.id}',
      title: '환불 완료',
      message: '$formattedAmount 환불이 완료되었습니다.',
      type: NotificationType.refundProcessed,
      data: {'bookingId': booking.id, 'refundAmount': refundAmount.toString()},
      createdAt: DateTime.now(),
    );

    addNotification(notification);
  }

  /// Initialize push notifications
  Future<void> _initializePushNotifications() async {
    // In a real app, this would initialize Firebase Cloud Messaging
    // or another push notification service
    if (kDebugMode) {
      print('Push notifications initialized');
    }
  }

  /// Set up periodic booking reminders
  void _setupBookingReminders() {
    // In a real app, this would set up background tasks
    // to check for upcoming bookings and send reminders
    Timer.periodic(const Duration(hours: 1), (timer) {
      _checkUpcomingBookings();
    });
  }

  /// Check for upcoming bookings and send reminders
  void _checkUpcomingBookings() {
    // This would typically fetch bookings from the repository
    // and check for upcoming ones that need reminders
    if (kDebugMode) {
      print('Checking for upcoming bookings...');
    }
  }

  /// Show push notification
  void _showPushNotification(AppNotification notification) {
    // In a real app, this would show a system notification
    // when the app is in the background
    if (kDebugMode) {
      print('Push notification: ${notification.title} - ${notification.message}');
    }
  }

  /// Dispose resources
  @override
  void dispose() {
    _notificationStream.close();
    super.dispose();
  }
}

/// Represents an app notification
class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime? scheduledTime;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.data = const {},
    required this.createdAt,
    this.scheduledTime,
    this.isRead = false,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? scheduledTime,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isRead: isRead ?? this.isRead,
    );
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  /// Get notification icon
  String get iconName {
    switch (type) {
      case NotificationType.bookingReminder:
        return 'schedule';
      case NotificationType.bookingStatusChange:
        return 'update';
      case NotificationType.paymentCompleted:
        return 'payment';
      case NotificationType.refundProcessed:
        return 'account_balance_wallet';
      case NotificationType.general:
        return 'notifications';
    }
  }
}

/// Types of notifications
enum NotificationType {
  bookingReminder,
  bookingStatusChange,
  paymentCompleted,
  refundProcessed,
  general,
}