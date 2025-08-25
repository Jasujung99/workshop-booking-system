import 'package:logger/logger.dart';
import '../../core/error/result.dart';
import '../../core/error/exceptions.dart';
import '../../core/services/refund_notification_service.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/payment_info.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/usecases/payment/process_refund_use_case.dart';

class AutomatedRefundService {
  final PaymentRepository _paymentRepository;
  final BookingRepository _bookingRepository;
  final ProcessRefundUseCase _processRefundUseCase;
  final RefundNotificationService _notificationService;
  final Logger _logger;

  AutomatedRefundService({
    required PaymentRepository paymentRepository,
    required BookingRepository bookingRepository,
    required ProcessRefundUseCase processRefundUseCase,
    required RefundNotificationService notificationService,
    Logger? logger,
  }) : _paymentRepository = paymentRepository,
       _bookingRepository = bookingRepository,
       _processRefundUseCase = processRefundUseCase,
       _notificationService = notificationService,
       _logger = logger ?? Logger();

  /// Process automatic refund for a cancelled booking
  Future<Result<RefundInfo?>> processAutomaticRefund({
    required String bookingId,
    required DateTime slotStartTime,
    required String cancellationReason,
  }) async {
    try {
      _logger.i('Processing automatic refund for booking: $bookingId');

      // Get booking information
      final bookingResult = await _bookingRepository.getBookingById(bookingId);
      if (bookingResult is Failure) {
        _logger.e('Failed to get booking for automatic refund: $bookingId');
        return Failure(bookingResult.exception);
      }

      final booking = (bookingResult as Success<Booking>).data;

      // Check if booking has payment info
      if (booking.paymentInfo == null || !booking.paymentInfo!.isSuccessful) {
        _logger.i('No successful payment found for booking: $bookingId');
        return const Success(null);
      }

      final paymentInfo = booking.paymentInfo!;

      // Calculate refund amount based on cancellation policy
      final refundAmountResult = await _processRefundUseCase.calculateRefundAmount(
        paymentId: paymentInfo.paymentId,
        slotStartTime: slotStartTime,
      );

      if (refundAmountResult is Failure) {
        _logger.e('Failed to calculate refund amount for booking: $bookingId');
        return Failure(refundAmountResult.exception);
      }

      final refundAmount = (refundAmountResult as Success<double>).data;

      // If no refund is due, return null
      if (refundAmount <= 0) {
        _logger.i('No refund due for booking: $bookingId (amount: $refundAmount)');
        return const Success(null);
      }

      // Process the refund
      final refundResult = await _processRefundUseCase.execute(
        paymentId: paymentInfo.paymentId,
        refundAmount: refundAmount,
        reason: '예약 취소에 따른 자동 환불: $cancellationReason',
      );

      if (refundResult is Failure) {
        _logger.e('Failed to process automatic refund for booking: $bookingId');
        
        // Send failure notification
        await _notificationService.sendRefundFailedNotification(
          userId: booking.userId,
          bookingTitle: 'Booking #${booking.id}', // This should be replaced with actual title
          reason: refundResult.exception.message,
        );

        return Failure(refundResult.exception);
      }

      final refundInfo = (refundResult as Success<RefundInfo>).data;

      // Send success notification
      await _notificationService.sendAutomaticRefundNotification(
        userId: booking.userId,
        refundInfo: refundInfo,
        bookingTitle: 'Booking #${booking.id}', // This should be replaced with actual title
        cancellationReason: cancellationReason,
      );

      _logger.i('Automatic refund processed successfully: ${refundInfo.refundId}');
      return Success(refundInfo);
    } catch (e) {
      _logger.e('Error processing automatic refund: $e');
      return Failure(PaymentException(
        '자동 환불 처리 중 오류가 발생했습니다: ${e.toString()}',
        code: 'AUTOMATIC_REFUND_ERROR',
      ));
    }
  }

  /// Process batch refunds for multiple bookings (e.g., when a workshop is cancelled)
  Future<Result<List<RefundInfo>>> processBatchRefunds({
    required List<String> bookingIds,
    required String reason,
    bool isFullRefund = true,
  }) async {
    try {
      _logger.i('Processing batch refunds for ${bookingIds.length} bookings');

      final List<RefundInfo> processedRefunds = [];
      final List<String> failedBookings = [];

      for (final bookingId in bookingIds) {
        try {
          // Get booking information
          final bookingResult = await _bookingRepository.getBookingById(bookingId);
          if (bookingResult is Failure) {
            failedBookings.add(bookingId);
            continue;
          }

          final booking = (bookingResult as Success<Booking>).data;

          // Check if booking has payment info
          if (booking.paymentInfo == null || !booking.paymentInfo!.isSuccessful) {
            continue;
          }

          final paymentInfo = booking.paymentInfo!;
          final refundAmount = isFullRefund ? paymentInfo.amount : paymentInfo.amount * 0.8; // 80% for partial

          // Process the refund
          final refundResult = await _processRefundUseCase.execute(
            paymentId: paymentInfo.paymentId,
            refundAmount: refundAmount,
            reason: reason,
          );

          if (refundResult is Success) {
            final refundInfo = refundResult.data;
            processedRefunds.add(refundInfo);

            // Send notification
            await _notificationService.sendAutomaticRefundNotification(
              userId: booking.userId,
              refundInfo: refundInfo,
              bookingTitle: 'Booking #${booking.id}',
              cancellationReason: reason,
            );
          } else {
            failedBookings.add(bookingId);
          }
        } catch (e) {
          _logger.e('Error processing refund for booking $bookingId: $e');
          failedBookings.add(bookingId);
        }
      }

      if (failedBookings.isNotEmpty) {
        _logger.w('Failed to process refunds for ${failedBookings.length} bookings: $failedBookings');
      }

      _logger.i('Batch refunds completed: ${processedRefunds.length} successful, ${failedBookings.length} failed');
      return Success(processedRefunds);
    } catch (e) {
      _logger.e('Error processing batch refunds: $e');
      return Failure(PaymentException(
        '일괄 환불 처리 중 오류가 발생했습니다: ${e.toString()}',
        code: 'BATCH_REFUND_ERROR',
      ));
    }
  }

  /// Check and process pending refunds (scheduled job)
  Future<void> processPendingRefunds() async {
    try {
      _logger.i('Checking for pending refunds');

      // This would typically query for bookings that are cancelled but haven't been refunded yet
      // For now, this is a placeholder for the scheduled refund processing logic
      
      _logger.i('Pending refunds check completed');
    } catch (e) {
      _logger.e('Error processing pending refunds: $e');
    }
  }

  /// Validate refund eligibility
  Future<Result<bool>> validateRefundEligibility({
    required String bookingId,
    required DateTime slotStartTime,
  }) async {
    try {
      final bookingResult = await _bookingRepository.getBookingById(bookingId);
      if (bookingResult is Failure) {
        return Failure(PaymentException(
          '예약 정보를 찾을 수 없습니다',
          code: 'BOOKING_NOT_FOUND',
        ));
      }

      final booking = (bookingResult as Success<Booking>).data;

      // Check if booking has successful payment
      if (booking.paymentInfo == null || !booking.paymentInfo!.isSuccessful) {
        return const Success(false);
      }

      // Check if payment can be refunded
      if (!booking.paymentInfo!.canRefund) {
        return const Success(false);
      }

      // Check cancellation policy timing
      final now = DateTime.now();
      final hoursUntilStart = slotStartTime.difference(now).inHours;
      
      // Allow refund if more than 1 hour before start time
      return Success(hoursUntilStart >= 1);
    } catch (e) {
      _logger.e('Error validating refund eligibility: $e');
      return Failure(PaymentException(
        '환불 가능 여부 확인 중 오류가 발생했습니다: ${e.toString()}',
        code: 'REFUND_ELIGIBILITY_ERROR',
      ));
    }
  }
}

