import 'package:flutter/material.dart';
import '../../entities/time_slot.dart';
import '../../repositories/booking_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class CreateBulkTimeSlotsUseCase {
  final BookingRepository _bookingRepository;

  const CreateBulkTimeSlotsUseCase(this._bookingRepository);

  /// Creates multiple time slots in bulk
  /// 
  /// Generates time slots based on the provided parameters and creates them
  /// Returns [Result<List<TimeSlot>>] with created time slots on success or exception on failure
  Future<Result<List<TimeSlot>>> execute({
    required DateTime startDate,
    required DateTime endDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int slotDurationMinutes,
    required int maxCapacity,
    required SlotType type,
    String? itemId,
    double? price,
    List<int> excludeWeekdays = const [], // 0 = Sunday, 1 = Monday, etc.
  }) async {
    try {
      // Validate input parameters
      final dateError = _validateDateRange(startDate, endDate);
      if (dateError != null) {
        return Failure(ValidationException(dateError));
      }

      final timeError = TimeSlot.validateTimeRange(startTime, endTime);
      if (timeError != null) {
        return Failure(ValidationException(timeError));
      }

      final capacityError = TimeSlot.validateCapacity(maxCapacity);
      if (capacityError != null) {
        return Failure(ValidationException(capacityError));
      }

      if (slotDurationMinutes < 30 || slotDurationMinutes > 480) {
        return Failure(ValidationException('슬롯 지속시간은 30분에서 8시간 사이여야 합니다'));
      }

      // Generate time slots
      final timeSlots = _generateTimeSlots(
        startDate: startDate,
        endDate: endDate,
        startTime: startTime,
        endTime: endTime,
        slotDurationMinutes: slotDurationMinutes,
        maxCapacity: maxCapacity,
        type: type,
        itemId: itemId,
        price: price,
        excludeWeekdays: excludeWeekdays,
      );

      if (timeSlots.isEmpty) {
        return Failure(ValidationException('생성할 시간대가 없습니다. 설정을 확인해주세요.'));
      }

      // Create time slots in batches to avoid overwhelming the system
      final List<TimeSlot> createdTimeSlots = [];
      const batchSize = 10;
      
      for (int i = 0; i < timeSlots.length; i += batchSize) {
        final batch = timeSlots.skip(i).take(batchSize).toList();
        
        for (final timeSlot in batch) {
          final result = await _bookingRepository.createTimeSlot(timeSlot);
          
          final createdSlot = result.fold(
            onSuccess: (slot) => slot,
            onFailure: (exception) => throw exception,
          );
          
          createdTimeSlots.add(createdSlot);
        }
      }

      return Success(createdTimeSlots);
    } catch (e) {
      if (e is AppException) {
        return Failure(e);
      }
      return Failure(UnknownException('일괄 시간대 생성 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }

  String? _validateDateRange(DateTime startDate, DateTime endDate) {
    if (startDate.isAfter(endDate)) {
      return '시작 날짜는 종료 날짜보다 이전이어야 합니다';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final queryStartDate = DateTime(startDate.year, startDate.month, startDate.day);
    
    if (queryStartDate.isBefore(today)) {
      return '과거 날짜는 선택할 수 없습니다';
    }

    final daysDifference = endDate.difference(startDate).inDays;
    if (daysDifference > 90) {
      return '일괄 생성은 최대 3개월까지 가능합니다';
    }

    return null;
  }

  List<TimeSlot> _generateTimeSlots({
    required DateTime startDate,
    required DateTime endDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int slotDurationMinutes,
    required int maxCapacity,
    required SlotType type,
    String? itemId,
    double? price,
    required List<int> excludeWeekdays,
  }) {
    final List<TimeSlot> timeSlots = [];
    final now = DateTime.now();

    // Iterate through each day in the date range
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate.add(const Duration(days: 1)))) {
      // Skip excluded weekdays
      if (excludeWeekdays.contains(currentDate.weekday % 7)) {
        currentDate = currentDate.add(const Duration(days: 1));
        continue;
      }

      // Generate time slots for this day
      final daySlots = _generateDayTimeSlots(
        date: currentDate,
        startTime: startTime,
        endTime: endTime,
        slotDurationMinutes: slotDurationMinutes,
        maxCapacity: maxCapacity,
        type: type,
        itemId: itemId,
        price: price,
      );

      timeSlots.addAll(daySlots);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return timeSlots;
  }

  List<TimeSlot> _generateDayTimeSlots({
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int slotDurationMinutes,
    required int maxCapacity,
    required SlotType type,
    String? itemId,
    double? price,
  }) {
    final List<TimeSlot> daySlots = [];
    
    int currentMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    while (currentMinutes + slotDurationMinutes <= endMinutes) {
      final slotStartTime = TimeOfDay(
        hour: currentMinutes ~/ 60,
        minute: currentMinutes % 60,
      );
      
      final slotEndMinutes = currentMinutes + slotDurationMinutes;
      final slotEndTime = TimeOfDay(
        hour: slotEndMinutes ~/ 60,
        minute: slotEndMinutes % 60,
      );

      final timeSlot = TimeSlot(
        id: '', // Will be generated by repository
        date: date,
        startTime: slotStartTime,
        endTime: slotEndTime,
        type: type,
        itemId: itemId,
        isAvailable: true,
        maxCapacity: maxCapacity,
        currentBookings: 0,
        price: price,
        createdAt: DateTime.now(),
      );

      daySlots.add(timeSlot);
      currentMinutes += slotDurationMinutes;
    }

    return daySlots;
  }
}