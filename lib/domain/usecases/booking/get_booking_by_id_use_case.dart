import '../../entities/booking.dart';
import '../../entities/user.dart';
import '../../repositories/booking_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class GetBookingByIdUseCase {
  final BookingRepository _bookingRepository;
  final AuthRepository _authRepository;

  const GetBookingByIdUseCase(this._bookingRepository, this._authRepository);

  /// Gets a booking by its ID
  /// 
  /// Validates user permissions to view the booking
  /// Returns [Result<Booking>] with booking data on success or exception on failure
  Future<Result<Booking>> execute(String bookingId) async {
    try {
      // Check user authentication
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        return Failure(AuthException('로그인이 필요합니다'));
      }

      // Validate booking ID
      if (bookingId.isEmpty) {
        return Failure(ValidationException('예약 ID가 필요합니다'));
      }

      // Get booking from repository
      final result = await _bookingRepository.getBookingById(bookingId);
      
      return result.fold(
        onSuccess: (booking) {
          // Check user permissions (user can view their own booking, admin can view any)
          if (booking.userId != currentUser.id && !currentUser.isAdmin) {
            return Failure(AuthException('이 예약을 볼 권한이 없습니다'));
          }

          return Success(booking);
        },
        onFailure: (exception) => Failure(exception),
      );
    } catch (e) {
      return Failure(UnknownException('예약 조회 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }
}