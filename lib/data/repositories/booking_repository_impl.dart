import '../../domain/entities/booking.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/entities/payment_info.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../core/error/result.dart';
import '../../core/error/exceptions.dart';
import '../services/firestore_service.dart';

class BookingRepositoryImpl implements BookingRepository {
  final FirestoreService _firestoreService;

  BookingRepositoryImpl({
    required FirestoreService firestoreService,
  }) : _firestoreService = firestoreService;

  @override
  Future<Result<Booking>> createBooking(Booking booking) async {
    return await _firestoreService.createBooking(booking);
  }

  @override
  Future<Result<Booking>> getBookingById(String id) async {
    try {
      final result = await _firestoreService.getBookings();
      
      return result.when(
        success: (bookings) {
          final booking = bookings.firstWhere(
            (b) => b.id == id,
            orElse: () => throw const DataException('Booking not found'),
          );
          return Success(booking);
        },
        failure: (exception) => Failure(exception),
      );
    } catch (e) {
      if (e is AppException) {
        return Failure(e);
      }
      return Failure(DataException('Failed to get booking: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<Booking>>> getBookingsByUser(String userId) async {
    return await _firestoreService.getBookings(userId: userId);
  }

  @override
  Future<Result<List<Booking>>> getBookingsByTimeSlot(String timeSlotId) async {
    return await _firestoreService.getBookings(timeSlotId: timeSlotId);
  }

  @override
  Future<Result<Booking>> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      // First get the booking
      final getResult = await getBookingById(bookingId);
      
      return await getResult.when(
        success: (booking) async {
          final updatedBooking = booking.copyWith(
            status: status,
            updatedAt: DateTime.now(),
          );
          
          return await _firestoreService.updateBooking(updatedBooking);
        },
        failure: (exception) async => Failure(exception),
      );
    } catch (e) {
      return Failure(DataException('Failed to update booking status: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Booking>> cancelBooking(String bookingId, String reason) async {
    return await _firestoreService.cancelBooking(bookingId, reason);
  }

  @override
  Future<Result<List<TimeSlot>>> getAvailableTimeSlots(
    String itemId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    final result = await _firestoreService.getTimeSlots(
      itemId: itemId,
      startDate: startDate,
      endDate: endDate,
      isAvailable: true,
    );

    return result.when(
      success: (timeSlots) {
        // Filter out time slots that are in the past or don't allow booking
        final availableSlots = timeSlots.where((slot) {
          return slot.hasAvailableCapacity && slot.isBookingAllowed;
        }).toList();
        
        return Success(availableSlots);
      },
      failure: (exception) => Failure(exception),
    );
  }

  @override
  Future<Result<TimeSlot>> createTimeSlot(TimeSlot timeSlot) async {
    return await _firestoreService.createTimeSlot(timeSlot);
  }

  @override
  Future<Result<TimeSlot>> updateTimeSlot(TimeSlot timeSlot) async {
    return await _firestoreService.updateTimeSlot(timeSlot);
  }

  @override
  Future<Result<void>> deleteTimeSlot(String timeSlotId) async {
    return await _firestoreService.deleteTimeSlot(timeSlotId);
  }

  @override
  Future<Result<PaymentInfo>> processPayment(PaymentInfo paymentInfo) async {
    try {
      // This is a placeholder implementation for payment processing
      // In a real application, you would integrate with a payment gateway
      // like Stripe, PayPal, or Korean payment services like KakaoPay
      
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));
      
      // For demo purposes, assume payment is successful
      final processedPayment = paymentInfo.copyWith(
        status: PaymentStatus.completed,
        paidAt: DateTime.now(),
        transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        updatedAt: DateTime.now(),
      );
      
      return Success(processedPayment);
    } catch (e) {
      return Failure(PaymentException('Payment processing failed: ${e.toString()}'));
    }
  }

  @override
  Future<Result<PaymentInfo>> getPaymentInfo(String paymentId) async {
    try {
      // This is a placeholder implementation
      // In a real application, you would fetch payment info from your payment service
      // or from a payments collection in Firestore
      
      // For now, return a failure as this is not implemented
      return const Failure(DataException('Payment info retrieval not implemented'));
    } catch (e) {
      return Failure(DataException('Failed to get payment info: ${e.toString()}'));
    }
  }

  @override
  Future<Result<PaymentInfo>> processRefund(String paymentId, double amount) async {
    try {
      // This is a placeholder implementation for refund processing
      // In a real application, you would integrate with your payment gateway's refund API
      
      // Simulate refund processing
      await Future.delayed(const Duration(seconds: 2));
      
      // For demo purposes, create a refund info
      final refundInfo = RefundInfo(
        refundId: 'ref_${DateTime.now().millisecondsSinceEpoch}',
        refundAmount: amount,
        reason: 'Booking cancellation',
        refundedAt: DateTime.now(),
      );
      
      // Create updated payment info with refund
      final refundedPayment = PaymentInfo(
        paymentId: paymentId,
        method: PaymentMethod.creditCard, // This should come from the original payment
        status: PaymentStatus.refunded,
        amount: amount,
        paidAt: DateTime.now().subtract(const Duration(days: 1)), // Placeholder
        refundInfo: refundInfo,
        createdAt: DateTime.now().subtract(const Duration(days: 1)), // Placeholder
        updatedAt: DateTime.now(),
      );
      
      return Success(refundedPayment);
    } catch (e) {
      return Failure(PaymentException('Refund processing failed: ${e.toString()}'));
    }
  }
}