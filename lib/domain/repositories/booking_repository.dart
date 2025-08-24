import '../entities/booking.dart';
import '../entities/time_slot.dart';
import '../entities/payment_info.dart';
import '../../core/error/result.dart';

abstract class BookingRepository {
  /// Create new booking
  Future<Result<Booking>> createBooking(Booking booking);
  
  /// Get booking by ID
  Future<Result<Booking>> getBookingById(String id);
  
  /// Get bookings by user
  Future<Result<List<Booking>>> getBookingsByUser(String userId);
  
  /// Get bookings by time slot
  Future<Result<List<Booking>>> getBookingsByTimeSlot(String timeSlotId);
  
  /// Update booking status
  Future<Result<Booking>> updateBookingStatus(String bookingId, BookingStatus status);
  
  /// Cancel booking
  Future<Result<Booking>> cancelBooking(String bookingId, String reason);
  
  /// Get available time slots for item
  Future<Result<List<TimeSlot>>> getAvailableTimeSlots(String itemId, DateTime startDate, DateTime endDate);
  
  /// Create time slot
  Future<Result<TimeSlot>> createTimeSlot(TimeSlot timeSlot);
  
  /// Update time slot
  Future<Result<TimeSlot>> updateTimeSlot(TimeSlot timeSlot);
  
  /// Delete time slot
  Future<Result<void>> deleteTimeSlot(String timeSlotId);
  
  /// Process payment
  Future<Result<PaymentInfo>> processPayment(PaymentInfo paymentInfo);
  
  /// Get payment info
  Future<Result<PaymentInfo>> getPaymentInfo(String paymentId);
  
  /// Process refund
  Future<Result<PaymentInfo>> processRefund(String paymentId, double amount);
}