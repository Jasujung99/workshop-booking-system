import 'package:logger/logger.dart';
import '../../domain/entities/payment_info.dart';
import 'notification_service.dart';

class RefundNotificationService {
  final NotificationService _notificationService;
  final Logger _logger;

  RefundNotificationService({
    required NotificationService notificationService,
    Logger? logger,
  }) : _notificationService = notificationService,
       _logger = logger ?? Logger();

  /// Send refund processed notification to user
  Future<void> sendRefundProcessedNotification({
    required String userId,
    required RefundInfo refundInfo,
    required String bookingTitle,
  }) async {
    try {
      _logger.i('Sending refund processed notification to user: $userId');

      await _notificationService.sendNotification(
        userId: userId,
        title: '환불 처리 완료',
        message: '$bookingTitle 예약의 환불이 완료되었습니다. 환불 금액: ${refundInfo.formattedRefundAmount}',
        type: NotificationType.refund,
        data: {
          'refundId': refundInfo.refundId,
          'refundAmount': refundInfo.refundAmount,
          'reason': refundInfo.reason,
          'refundedAt': refundInfo.refundedAt.toIso8601String(),
        },
      );

      _logger.i('Refund processed notification sent successfully');
    } catch (e) {
      _logger.e('Failed to send refund processed notification: $e');
    }
  }

  /// Send refund failed notification to user
  Future<void> sendRefundFailedNotification({
    required String userId,
    required String bookingTitle,
    required String reason,
  }) async {
    try {
      _logger.i('Sending refund failed notification to user: $userId');

      await _notificationService.sendNotification(
        userId: userId,
        title: '환불 처리 실패',
        message: '$bookingTitle 예약의 환불 처리에 실패했습니다. 고객센터로 문의해주세요.',
        type: NotificationType.error,
        data: {
          'failureReason': reason,
          'bookingTitle': bookingTitle,
        },
      );

      _logger.i('Refund failed notification sent successfully');
    } catch (e) {
      _logger.e('Failed to send refund failed notification: $e');
    }
  }

  /// Send refund request notification to admin
  Future<void> sendRefundRequestNotification({
    required String adminUserId,
    required String paymentId,
    required double refundAmount,
    required String reason,
    required String bookingTitle,
    required String customerName,
  }) async {
    try {
      _logger.i('Sending refund request notification to admin: $adminUserId');

      final formattedAmount = '${refundAmount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )}원';

      await _notificationService.sendNotification(
        userId: adminUserId,
        title: '환불 요청',
        message: '$customerName님이 $bookingTitle 예약에 대해 $formattedAmount 환불을 요청했습니다.',
        type: NotificationType.admin,
        data: {
          'paymentId': paymentId,
          'refundAmount': refundAmount,
          'reason': reason,
          'bookingTitle': bookingTitle,
          'customerName': customerName,
          'requestType': 'refund',
        },
      );

      _logger.i('Refund request notification sent successfully');
    } catch (e) {
      _logger.e('Failed to send refund request notification: $e');
    }
  }

  /// Send automatic refund notification to user
  Future<void> sendAutomaticRefundNotification({
    required String userId,
    required RefundInfo refundInfo,
    required String bookingTitle,
    required String cancellationReason,
  }) async {
    try {
      _logger.i('Sending automatic refund notification to user: $userId');

      await _notificationService.sendNotification(
        userId: userId,
        title: '자동 환불 처리',
        message: '$bookingTitle 예약이 취소되어 자동으로 환불 처리되었습니다. 환불 금액: ${refundInfo.formattedRefundAmount}',
        type: NotificationType.refund,
        data: {
          'refundId': refundInfo.refundId,
          'refundAmount': refundInfo.refundAmount,
          'reason': refundInfo.reason,
          'refundedAt': refundInfo.refundedAt.toIso8601String(),
          'cancellationReason': cancellationReason,
          'isAutomatic': true,
        },
      );

      _logger.i('Automatic refund notification sent successfully');
    } catch (e) {
      _logger.e('Failed to send automatic refund notification: $e');
    }
  }

  /// Send partial refund notification to user
  Future<void> sendPartialRefundNotification({
    required String userId,
    required RefundInfo refundInfo,
    required double originalAmount,
    required String bookingTitle,
  }) async {
    try {
      _logger.i('Sending partial refund notification to user: $userId');

      final formattedOriginalAmount = '${originalAmount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )}원';

      await _notificationService.sendNotification(
        userId: userId,
        title: '부분 환불 처리 완료',
        message: '$bookingTitle 예약의 부분 환불이 완료되었습니다. 환불 금액: ${refundInfo.formattedRefundAmount} (원래 금액: $formattedOriginalAmount)',
        type: NotificationType.refund,
        data: {
          'refundId': refundInfo.refundId,
          'refundAmount': refundInfo.refundAmount,
          'originalAmount': originalAmount,
          'reason': refundInfo.reason,
          'refundedAt': refundInfo.refundedAt.toIso8601String(),
          'isPartial': true,
        },
      );

      _logger.i('Partial refund notification sent successfully');
    } catch (e) {
      _logger.e('Failed to send partial refund notification: $e');
    }
  }
}