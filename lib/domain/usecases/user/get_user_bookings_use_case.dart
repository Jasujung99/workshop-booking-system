import '../../entities/booking.dart';
import '../../repositories/booking_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class GetUserBookingsUseCase {
  final BookingRepository _bookingRepository;

  GetUserBookingsUseCase(this._bookingRepository);

  Future<Result<List<Booking>>> execute(String userId) async {
    if (userId.isEmpty) {
      return const Failure(ValidationException('사용자 ID가 필요합니다'));
    }

    return await _bookingRepository.getBookingsByUser(userId);
  }
}