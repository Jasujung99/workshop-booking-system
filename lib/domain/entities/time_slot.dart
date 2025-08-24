import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum SlotType {
  workshop,
  space,
}

class TimeSlot extends Equatable {
  final String id;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final SlotType type;
  final String? itemId; // workshop ID for workshop slots, space ID for space slots
  final bool isAvailable;
  final int maxCapacity;
  final int currentBookings;
  final double? price; // Override price for specific time slots
  final DateTime createdAt;

  const TimeSlot({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.itemId,
    required this.isAvailable,
    required this.maxCapacity,
    required this.currentBookings,
    this.price,
    required this.createdAt,
  });

  /// Creates a copy of this TimeSlot with the given fields replaced with new values
  TimeSlot copyWith({
    String? id,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    SlotType? type,
    String? itemId,
    bool? isAvailable,
    int? maxCapacity,
    int? currentBookings,
    double? price,
    DateTime? createdAt,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      itemId: itemId ?? this.itemId,
      isAvailable: isAvailable ?? this.isAvailable,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      currentBookings: currentBookings ?? this.currentBookings,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Validates time slot data
  static String? validateTimeRange(TimeOfDay? startTime, TimeOfDay? endTime) {
    if (startTime == null || endTime == null) {
      return '시작 시간과 종료 시간을 모두 입력해주세요';
    }
    
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    
    if (startMinutes >= endMinutes) {
      return '종료 시간은 시작 시간보다 늦어야 합니다';
    }
    
    final durationMinutes = endMinutes - startMinutes;
    if (durationMinutes < 30) {
      return '최소 30분 이상의 시간대를 설정해주세요';
    }
    
    if (durationMinutes > 480) { // 8 hours
      return '최대 8시간까지 설정 가능합니다';
    }
    
    return null;
  }

  static String? validateDate(DateTime? date) {
    if (date == null) {
      return '날짜를 선택해주세요';
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);
    
    if (selectedDate.isBefore(today)) {
      return '과거 날짜는 선택할 수 없습니다';
    }
    
    // Allow booking up to 6 months in advance
    final maxDate = today.add(const Duration(days: 180));
    if (selectedDate.isAfter(maxDate)) {
      return '6개월 이후 날짜는 선택할 수 없습니다';
    }
    
    return null;
  }

  static String? validateCapacity(int? capacity) {
    if (capacity == null) {
      return '최대 수용인원을 입력해주세요';
    }
    
    if (capacity < 1) {
      return '최대 수용인원은 1명 이상이어야 합니다';
    }
    
    if (capacity > 100) {
      return '최대 수용인원은 100명 이하여야 합니다';
    }
    
    return null;
  }

  /// Gets the full DateTime for start time
  DateTime get startDateTime {
    return DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );
  }

  /// Gets the full DateTime for end time
  DateTime get endDateTime {
    return DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );
  }

  /// Gets duration in minutes
  int get durationInMinutes {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return endMinutes - startMinutes;
  }

  /// Gets formatted time range string
  String get timeRangeString {
    return '${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Checks if this time slot has available capacity
  bool get hasAvailableCapacity {
    return isAvailable && currentBookings < maxCapacity;
  }

  /// Gets remaining capacity
  int get remainingCapacity {
    return maxCapacity - currentBookings;
  }

  /// Checks if the time slot is in the past
  bool get isPast {
    final now = DateTime.now();
    return startDateTime.isBefore(now);
  }

  /// Checks if booking is still allowed (not too close to start time)
  bool get isBookingAllowed {
    final now = DateTime.now();
    final bookingCutoff = startDateTime.subtract(const Duration(hours: 1));
    return now.isBefore(bookingCutoff) && !isPast;
  }

  @override
  List<Object?> get props => [
        id,
        date,
        startTime,
        endTime,
        type,
        itemId,
        isAvailable,
        maxCapacity,
        currentBookings,
        price,
        createdAt,
      ];

  @override
  String toString() {
    return 'TimeSlot(id: $id, date: $date, timeRange: $timeRangeString, type: $type, available: $hasAvailableCapacity)';
  }
}