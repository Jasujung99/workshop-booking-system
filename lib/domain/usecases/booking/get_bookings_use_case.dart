import '../../entities/booking.dart';
import '../../entities/user.dart';
import '../../repositories/booking_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class GetBookingsUseCase {
  final BookingRepository _bookingRepository;
  final AuthRepository _authRepository;

  const GetBookingsUseCase(this._bookingRepository, this._authRepository);

  /// Gets bookings for the current user or all bookings for admin
  /// 
  /// Returns user's bookings or all bookings based on user role
  /// Returns [Result<List<Booking>>] with booking list on success or exception on failure
  Future<Result<List<Booking>>> execute({
    String? userId,
    BookingStatus? statusFilter,
    BookingType? typeFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Check user authentication
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        return Failure(AuthException('로그인이 필요합니다'));
      }

      // Validate date range if provided
      if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
        return Failure(ValidationException('시작 날짜는 종료 날짜보다 이전이어야 합니다'));
      }

      // Determine which user's bookings to fetch
      String targetUserId;
      if (userId != null) {
        // Admin can view any user's bookings, regular users can only view their own
        if (!currentUser.isAdmin && userId != currentUser.id) {
          return Failure(AuthException('다른 사용자의 예약 내역을 볼 권한이 없습니다'));
        }
        targetUserId = userId;
      } else {
        // If no userId specified, use current user's ID
        targetUserId = currentUser.id;
      }

      // Get bookings from repository
      final result = await _bookingRepository.getBookingsByUser(targetUserId);
      
      return result.fold(
        onSuccess: (bookings) {
          // Apply filters
          List<Booking> filteredBookings = bookings;

          // Filter by status
          if (statusFilter != null) {
            filteredBookings = filteredBookings
                .where((booking) => booking.status == statusFilter)
                .toList();
          }

          // Filter by type
          if (typeFilter != null) {
            filteredBookings = filteredBookings
                .where((booking) => booking.type == typeFilter)
                .toList();
          }

          // Filter by date range
          if (startDate != null || endDate != null) {
            filteredBookings = filteredBookings.where((booking) {
              final bookingDate = booking.createdAt;
              
              if (startDate != null && bookingDate.isBefore(startDate)) {
                return false;
              }
              
              if (endDate != null && bookingDate.isAfter(endDate)) {
                return false;
              }
              
              return true;
            }).toList();
          }

          // Sort by creation date (newest first)
          filteredBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return Success(filteredBookings);
        },
        onFailure: (exception) => Failure(exception),
      );
    } catch (e) {
      return Failure(UnknownException('예약 내역 조회 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }
}