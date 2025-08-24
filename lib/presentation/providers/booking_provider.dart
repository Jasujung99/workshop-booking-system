import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../domain/entities/booking.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/entities/payment_info.dart';
import '../../domain/usecases/booking/create_booking_use_case.dart';
import '../../domain/usecases/booking/cancel_booking_use_case.dart';
import '../../domain/usecases/booking/get_bookings_use_case.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../core/error/result.dart';
import '../../core/error/exceptions.dart';
import '../../core/services/notification_service.dart';

/// Provider for managing booking state and operations
/// 
/// Handles booking process, booking history, payment processing,
/// and booking confirmation workflows
class BookingProvider extends ChangeNotifier {
  final CreateBookingUseCase _createBookingUseCase;
  final CancelBookingUseCase _cancelBookingUseCase;
  final GetBookingsUseCase _getBookingsUseCase;
  final BookingRepository _bookingRepository;
  final NotificationService? _notificationService;

  // State variables
  List<Booking> _bookings = [];
  List<TimeSlot> _availableTimeSlots = [];
  Booking? _currentBooking;
  TimeSlot? _selectedTimeSlot;
  PaymentInfo? _currentPayment;
  
  // UI State
  bool _isLoading = false;
  bool _isProcessingPayment = false;
  bool _isCreatingBooking = false;
  bool _isCancellingBooking = false;
  String? _errorMessage;
  
  // Booking process state
  BookingStep _currentStep = BookingStep.selectTimeSlot;
  String? _selectedWorkshopId;
  double _totalAmount = 0.0;

  BookingProvider({
    required CreateBookingUseCase createBookingUseCase,
    required CancelBookingUseCase cancelBookingUseCase,
    required GetBookingsUseCase getBookingsUseCase,
    required BookingRepository bookingRepository,
    NotificationService? notificationService,
  })  : _createBookingUseCase = createBookingUseCase,
        _cancelBookingUseCase = cancelBookingUseCase,
        _getBookingsUseCase = getBookingsUseCase,
        _bookingRepository = bookingRepository,
        _notificationService = notificationService;

  // Getters
  List<Booking> get bookings => _bookings;
  List<Booking> get allBookings => _bookings;
  List<TimeSlot> get availableTimeSlots => _availableTimeSlots;
  Booking? get currentBooking => _currentBooking;
  TimeSlot? get selectedTimeSlot => _selectedTimeSlot;
  PaymentInfo? get currentPayment => _currentPayment;
  
  bool get isLoading => _isLoading;
  bool get isProcessingPayment => _isProcessingPayment;
  bool get isCreatingBooking => _isCreatingBooking;
  bool get isCancellingBooking => _isCancellingBooking;
  String? get errorMessage => _errorMessage;
  
  BookingStep get currentStep => _currentStep;
  String? get selectedWorkshopId => _selectedWorkshopId;
  double get totalAmount => _totalAmount;
  
  bool get isEmpty => _bookings.isEmpty && !_isLoading;
  bool get hasBookings => _bookings.isNotEmpty;

  // Filtered booking lists
  List<Booking> get upcomingBookings => _bookings
      .where((booking) => booking.status == BookingStatus.confirmed)
      .toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  List<Booking> get completedBookings => _bookings
      .where((booking) => booking.status == BookingStatus.completed)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Booking> get cancelledBookings => _bookings
      .where((booking) => booking.status == BookingStatus.cancelled)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// Load user bookings
  Future<void> loadBookings(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _getBookingsUseCase.execute(userId: userId);
      
      result.fold(
        onSuccess: (bookings) {
          _bookings = bookings;
          _setLoading(false);
        },
        onFailure: (exception) {
          _setError(_getErrorMessage(exception));
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError('예약 내역을 불러오는 중 오류가 발생했습니다');
      _setLoading(false);
    }
  }

  /// Refresh bookings
  Future<void> refreshBookings(String userId) async {
    await loadBookings(userId);
  }

  /// Start booking process for a workshop
  void startBookingProcess(String workshopId) {
    _selectedWorkshopId = workshopId;
    _currentStep = BookingStep.selectTimeSlot;
    _selectedTimeSlot = null;
    _currentBooking = null;
    _currentPayment = null;
    _totalAmount = 0.0;
    _clearError();
    notifyListeners();
  }

  /// Load available time slots for selected workshop
  Future<void> loadAvailableTimeSlots(DateTime startDate, DateTime endDate) async {
    if (_selectedWorkshopId == null) {
      _setError('워크샵을 먼저 선택해주세요');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _bookingRepository.getAvailableTimeSlots(
        _selectedWorkshopId!,
        startDate,
        endDate,
      );
      
      result.fold(
        onSuccess: (timeSlots) {
          _availableTimeSlots = timeSlots
              .where((slot) => slot.isAvailable && slot.hasAvailableCapacity)
              .toList();
          _setLoading(false);
        },
        onFailure: (exception) {
          _setError(_getErrorMessage(exception));
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError('예약 가능한 시간대를 불러오는 중 오류가 발생했습니다');
      _setLoading(false);
    }
  }

  /// Select time slot for booking
  void selectTimeSlot(TimeSlot timeSlot, double workshopPrice) {
    _selectedTimeSlot = timeSlot;
    _totalAmount = workshopPrice;
    _currentStep = BookingStep.confirmBooking;
    _clearError();
    notifyListeners();
  }

  /// Proceed to payment step
  void proceedToPayment() {
    if (_selectedTimeSlot == null) {
      _setError('시간대를 선택해주세요');
      return;
    }

    _currentStep = BookingStep.payment;
    _clearError();
    notifyListeners();
  }

  /// Create booking with payment
  Future<bool> createBookingWithPayment({
    required String userId,
    required PaymentMethod paymentMethod,
    String? specialRequests,
  }) async {
    if (_selectedTimeSlot == null || _selectedWorkshopId == null) {
      _setError('예약 정보가 완전하지 않습니다');
      return false;
    }

    _setCreatingBooking(true);
    _clearError();

    try {
      // Create payment info
      final paymentInfo = PaymentInfo(
        paymentId: '', // Will be generated by payment service
        method: paymentMethod,
        status: PaymentStatus.pending,
        amount: _totalAmount,
        currency: 'KRW',
        paidAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Process payment first
      _setProcessingPayment(true);
      final paymentResult = await _bookingRepository.processPayment(paymentInfo);
      
      final processedPayment = await paymentResult.fold(
        onSuccess: (payment) async {
          _currentPayment = payment;
          _setProcessingPayment(false);
          return payment;
        },
        onFailure: (exception) async {
          _setError('결제 처리 중 오류가 발생했습니다: ${_getErrorMessage(exception)}');
          _setProcessingPayment(false);
          _setCreatingBooking(false);
          return null;
        },
      );

      if (processedPayment == null) return false;

      // Create booking after successful payment
      final booking = Booking(
        id: '', // Will be generated by repository
        userId: userId,
        timeSlotId: _selectedTimeSlot!.id,
        type: BookingType.workshop,
        itemId: _selectedWorkshopId,
        status: BookingStatus.confirmed,
        totalAmount: _totalAmount,
        paymentInfo: processedPayment,
        notes: specialRequests,
        createdAt: DateTime.now(),
      );

      final result = await _createBookingUseCase.execute(
        timeSlotId: booking.timeSlotId,
        type: booking.type,
        itemId: booking.itemId,
        totalAmount: booking.totalAmount,
        paymentInfo: processedPayment,
        notes: booking.notes,
      );
      
      return result.fold(
        onSuccess: (createdBooking) {
          _currentBooking = createdBooking;
          _bookings.insert(0, createdBooking);
          _currentStep = BookingStep.confirmation;
          _setCreatingBooking(false);
          
          // Send notifications
          _notificationService?.notifyPaymentCompleted(createdBooking);
          _notificationService?.notifyBookingStatusChange(createdBooking, BookingStatus.pending);
          
          return true;
        },
        onFailure: (exception) {
          _setError(_getErrorMessage(exception));
          _setCreatingBooking(false);
          return false;
        },
      );
    } catch (e) {
      _setError('예약 생성 중 오류가 발생했습니다');
      _setCreatingBooking(false);
      _setProcessingPayment(false);
      return false;
    }
  }

  /// Cancel booking
  Future<bool> cancelBooking(String bookingId, String reason) async {
    _setCancellingBooking(true);
    _clearError();

    try {
      final result = await _cancelBookingUseCase.execute(
        bookingId: bookingId,
        reason: reason,
      );
      
      return result.fold(
        onSuccess: (cancelledBooking) {
          // Update booking in list
          final index = _bookings.indexWhere((b) => b.id == bookingId);
          final oldBooking = index != -1 ? _bookings[index] : null;
          
          if (index != -1) {
            _bookings[index] = cancelledBooking;
          }
          _setCancellingBooking(false);
          
          // Send notifications
          if (oldBooking != null) {
            _notificationService?.notifyBookingStatusChange(cancelledBooking, oldBooking.status);
            
            // Calculate and notify about refund if applicable
            final mockSlotTime = DateTime.now().add(const Duration(days: 3));
            final refundAmount = cancelledBooking.calculateRefundAmount(mockSlotTime);
            if (refundAmount > 0) {
              _notificationService?.notifyRefundProcessed(cancelledBooking, refundAmount);
            }
          }
          
          return true;
        },
        onFailure: (exception) {
          _setError(_getErrorMessage(exception));
          _setCancellingBooking(false);
          return false;
        },
      );
    } catch (e) {
      _setError('예약 취소 중 오류가 발생했습니다');
      _setCancellingBooking(false);
      return false;
    }
  }

  /// Get booking by ID
  Future<Booking?> getBookingById(String bookingId) async {
    // First check if booking is already in memory
    try {
      return _bookings.firstWhere((booking) => booking.id == bookingId);
    } catch (e) {
      // Booking not found in memory, fetch from repository
      try {
        final result = await _bookingRepository.getBookingById(bookingId);
        return result.fold(
          onSuccess: (booking) => booking,
          onFailure: (exception) {
            _setError(_getErrorMessage(exception));
            return null;
          },
        );
      } catch (e) {
        _setError('예약 정보를 불러오는 중 오류가 발생했습니다');
        return null;
      }
    }
  }

  /// Check if booking can be cancelled
  bool canCancelBooking(Booking booking) {
    if (booking.status != BookingStatus.confirmed) return false;
    
    // Find the time slot to check cancellation policy
    final timeSlot = _availableTimeSlots
        .where((slot) => slot.id == booking.timeSlotId)
        .firstOrNull;
    
    if (timeSlot == null) return false;
    
    // Allow cancellation up to 24 hours before the event
    final cancellationDeadline = DateTime(
      timeSlot.date.year,
      timeSlot.date.month,
      timeSlot.date.day,
      timeSlot.startTime.hour,
      timeSlot.startTime.minute,
    ).subtract(const Duration(hours: 24));
    
    return DateTime.now().isBefore(cancellationDeadline);
  }

  /// Reset booking process
  void resetBookingProcess() {
    _selectedWorkshopId = null;
    _selectedTimeSlot = null;
    _currentBooking = null;
    _currentPayment = null;
    _currentStep = BookingStep.selectTimeSlot;
    _totalAmount = 0.0;
    _availableTimeSlots.clear();
    _clearError();
    notifyListeners();
  }

  /// Go back to previous step in booking process
  void goBackStep() {
    switch (_currentStep) {
      case BookingStep.selectTimeSlot:
        // Can't go back from first step
        break;
      case BookingStep.confirmBooking:
        _currentStep = BookingStep.selectTimeSlot;
        _selectedTimeSlot = null;
        _totalAmount = 0.0;
        break;
      case BookingStep.payment:
        _currentStep = BookingStep.confirmBooking;
        break;
      case BookingStep.confirmation:
        // Can't go back from confirmation
        break;
    }
    _clearError();
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set creating booking state
  void _setCreatingBooking(bool creating) {
    _isCreatingBooking = creating;
    notifyListeners();
  }

  /// Set processing payment state
  void _setProcessingPayment(bool processing) {
    _isProcessingPayment = processing;
    notifyListeners();
  }

  /// Set cancelling booking state
  void _setCancellingBooking(bool cancelling) {
    _isCancellingBooking = cancelling;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Clear any existing error message
  void clearError() {
    _clearError();
  }

  /// Convert exception to user-friendly error message
  String _getErrorMessage(AppException exception) {
    switch (exception.runtimeType) {
      case ValidationException:
        return exception.message;
      case NetworkException:
        return '네트워크 연결을 확인해주세요';
      case ServerException:
        return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요';
      case AuthException:
        return '권한이 없습니다. 다시 로그인해주세요';
      case PaymentException:
        return '결제 처리 중 오류가 발생했습니다';
      default:
        return exception.message.isNotEmpty 
            ? exception.message 
            : '알 수 없는 오류가 발생했습니다';
    }
  }
}

/// Enum for booking process steps
enum BookingStep {
  selectTimeSlot,
  confirmBooking,
  payment,
  confirmation,
}