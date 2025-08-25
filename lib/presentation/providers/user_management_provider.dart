import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/payment_info.dart';
import '../../domain/usecases/user/get_all_users_use_case.dart';
import '../../domain/usecases/user/get_user_bookings_use_case.dart';
import '../../domain/usecases/booking/update_booking_status_use_case.dart';
import '../../domain/usecases/booking/process_refund_use_case.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/error/result.dart';


class UserManagementProvider extends ChangeNotifier {
  final GetAllUsersUseCase _getAllUsersUseCase;
  final GetUserBookingsUseCase _getUserBookingsUseCase;
  final UpdateBookingStatusUseCase _updateBookingStatusUseCase;
  final ProcessRefundUseCase _processRefundUseCase;
  final AuthRepository _authRepository;

  UserManagementProvider({
    required GetAllUsersUseCase getAllUsersUseCase,
    required GetUserBookingsUseCase getUserBookingsUseCase,
    required UpdateBookingStatusUseCase updateBookingStatusUseCase,
    required ProcessRefundUseCase processRefundUseCase,
    required AuthRepository authRepository,
  })  : _getAllUsersUseCase = getAllUsersUseCase,
        _getUserBookingsUseCase = getUserBookingsUseCase,
        _updateBookingStatusUseCase = updateBookingStatusUseCase,
        _processRefundUseCase = processRefundUseCase,
        _authRepository = authRepository;

  List<User> _users = [];
  Map<String, List<Booking>> _userBookings = {};
  bool _isLoading = false;
  String? _error;
  User? _selectedUser;

  List<User> get users => _users;
  Map<String, List<Booking>> get userBookings => _userBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get selectedUser => _selectedUser;

  List<Booking> getUserBookingsList(String userId) {
    return _userBookings[userId] ?? [];
  }

  Future<void> loadUsers() async {
    _setLoading(true);
    _setError(null);

    final result = await _getAllUsersUseCase.execute();
    
    switch (result) {
      case Success<List<User>> success:
        _users = success.data;
        notifyListeners();
        break;
      case Failure<List<User>> failure:
        _setError('사용자 목록을 불러오는데 실패했습니다: ${failure.exception.toString()}');
        break;
    }

    _setLoading(false);
  }

  Future<void> loadUserBookings(String userId) async {
    if (_userBookings.containsKey(userId)) {
      return; // Already loaded
    }

    final result = await _getUserBookingsUseCase.execute(userId);
    
    switch (result) {
      case Success<List<Booking>> success:
        _userBookings[userId] = success.data;
        notifyListeners();
        break;
      case Failure<List<Booking>> failure:
        _setError('사용자 예약 내역을 불러오는데 실패했습니다: ${failure.exception.toString()}');
        break;
    }
  }

  Future<bool> updateBookingStatus(String bookingId, BookingStatus newStatus) async {
    _setLoading(true);
    _setError(null);

    final result = await _updateBookingStatusUseCase.execute(bookingId, newStatus);
    
    bool success = false;
    switch (result) {
      case Success<Booking> successResult:
        // Update the booking in the local cache
        _updateBookingInCache(successResult.data);
        success = true;
        break;
      case Failure<Booking> failure:
        _setError('예약 상태 변경에 실패했습니다: ${failure.exception.toString()}');
        break;
    }

    _setLoading(false);
    return success;
  }

  Future<bool> processRefund(String paymentId, double refundAmount) async {
    _setLoading(true);
    _setError(null);

    final result = await _processRefundUseCase.execute(paymentId, refundAmount);
    
    bool success = false;
    switch (result) {
      case Success<PaymentInfo> _:
        success = true;
        break;
      case Failure<PaymentInfo> failure:
        _setError('환불 처리에 실패했습니다: ${failure.exception.toString()}');
        break;
    }

    _setLoading(false);
    return success;
  }

  Future<bool> updateUserRole(String userId, UserRole newRole) async {
    _setLoading(true);
    _setError(null);

    final result = await _authRepository.updateUserRole(userId, newRole);
    
    bool success = false;
    switch (result) {
      case Success<User> successResult:
        // Update the user in the local cache
        final index = _users.indexWhere((user) => user.id == userId);
        if (index != -1) {
          _users[index] = successResult.data;
          notifyListeners();
        }
        success = true;
        break;
      case Failure<User> failure:
        _setError('사용자 권한 변경에 실패했습니다: ${failure.exception.toString()}');
        break;
    }

    _setLoading(false);
    return success;
  }

  void selectUser(User? user) {
    _selectedUser = user;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  void _updateBookingInCache(Booking updatedBooking) {
    for (final userId in _userBookings.keys) {
      final bookings = _userBookings[userId]!;
      final index = bookings.indexWhere((b) => b.id == updatedBooking.id);
      if (index != -1) {
        bookings[index] = updatedBooking;
        notifyListeners();
        break;
      }
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}