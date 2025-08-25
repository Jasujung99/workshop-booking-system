import 'package:flutter/material.dart';

import '../../domain/entities/time_slot.dart';
import '../../domain/entities/workshop.dart';
import '../../domain/usecases/time_slot/create_time_slot_use_case.dart';
import '../../domain/usecases/time_slot/update_time_slot_use_case.dart';
import '../../domain/usecases/time_slot/delete_time_slot_use_case.dart';
import '../../domain/usecases/time_slot/get_time_slots_use_case.dart';
import '../../domain/usecases/time_slot/create_bulk_time_slots_use_case.dart';
import '../../domain/usecases/workshop/get_workshops_use_case.dart';
import '../../core/error/result.dart';

class TimeSlotProvider extends ChangeNotifier {
  final CreateTimeSlotUseCase _createTimeSlotUseCase;
  final UpdateTimeSlotUseCase _updateTimeSlotUseCase;
  final DeleteTimeSlotUseCase _deleteTimeSlotUseCase;
  final GetTimeSlotsUseCase _getTimeSlotsUseCase;
  final CreateBulkTimeSlotsUseCase _createBulkTimeSlotsUseCase;
  final GetWorkshopsUseCase _getWorkshopsUseCase;

  TimeSlotProvider({
    required CreateTimeSlotUseCase createTimeSlotUseCase,
    required UpdateTimeSlotUseCase updateTimeSlotUseCase,
    required DeleteTimeSlotUseCase deleteTimeSlotUseCase,
    required GetTimeSlotsUseCase getTimeSlotsUseCase,
    required CreateBulkTimeSlotsUseCase createBulkTimeSlotsUseCase,
    required GetWorkshopsUseCase getWorkshopsUseCase,
  })  : _createTimeSlotUseCase = createTimeSlotUseCase,
        _updateTimeSlotUseCase = updateTimeSlotUseCase,
        _deleteTimeSlotUseCase = deleteTimeSlotUseCase,
        _getTimeSlotsUseCase = getTimeSlotsUseCase,
        _createBulkTimeSlotsUseCase = createBulkTimeSlotsUseCase,
        _getWorkshopsUseCase = getWorkshopsUseCase;

  // State
  List<TimeSlot> _timeSlots = [];
  List<Workshop> _workshops = [];
  bool _isLoading = false;
  String? _error;
  
  // Filters
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  String? _selectedWorkshopId;
  SlotType? _selectedSlotType;

  // Bulk creation state
  bool _isBulkCreating = false;
  int _bulkCreationProgress = 0;
  int _bulkCreationTotal = 0;

  // Getters
  List<TimeSlot> get timeSlots => _timeSlots;
  List<Workshop> get workshops => _workshops;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  String? get selectedWorkshopId => _selectedWorkshopId;
  SlotType? get selectedSlotType => _selectedSlotType;
  bool get isBulkCreating => _isBulkCreating;
  int get bulkCreationProgress => _bulkCreationProgress;
  int get bulkCreationTotal => _bulkCreationTotal;

  // Filtered time slots
  List<TimeSlot> get filteredTimeSlots {
    var filtered = _timeSlots;

    if (_selectedWorkshopId != null) {
      filtered = filtered.where((slot) => slot.itemId == _selectedWorkshopId).toList();
    }

    if (_selectedSlotType != null) {
      filtered = filtered.where((slot) => slot.type == _selectedSlotType).toList();
    }

    return filtered;
  }

  // Grouped time slots by date
  Map<DateTime, List<TimeSlot>> get groupedTimeSlots {
    final Map<DateTime, List<TimeSlot>> grouped = {};
    
    for (final slot in filteredTimeSlots) {
      final dateKey = DateTime(slot.date.year, slot.date.month, slot.date.day);
      grouped.putIfAbsent(dateKey, () => []).add(slot);
    }

    // Sort slots within each day
    grouped.forEach((date, slots) {
      slots.sort((a, b) {
        final aStartMinutes = a.startTime.hour * 60 + a.startTime.minute;
        final bStartMinutes = b.startTime.hour * 60 + b.startTime.minute;
        return aStartMinutes.compareTo(bStartMinutes);
      });
    });

    return grouped;
  }

  /// Load time slots for the current date range and filters
  Future<void> loadTimeSlots() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _getTimeSlotsUseCase.execute(
        itemId: _selectedWorkshopId,
        startDate: _startDate,
        endDate: _endDate,
      );

      result.fold(
        onSuccess: (timeSlots) {
          _timeSlots = timeSlots;
          notifyListeners();
        },
        onFailure: (exception) {
          _setError(exception.message);
        },
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Load workshops for selection
  Future<void> loadWorkshops() async {
    try {
      final result = await _getWorkshopsUseCase.execute();

      result.fold(
        onSuccess: (workshops) {
          _workshops = workshops;
          notifyListeners();
        },
        onFailure: (exception) {
          // Don't show error for workshops loading failure
          debugPrint('Failed to load workshops: ${exception.message}');
        },
      );
    } catch (e) {
      debugPrint('Error loading workshops: $e');
    }
  }

  /// Create a single time slot
  Future<bool> createTimeSlot(TimeSlot timeSlot) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _createTimeSlotUseCase.execute(timeSlot);

      return result.fold(
        onSuccess: (createdTimeSlot) {
          _timeSlots.add(createdTimeSlot);
          _timeSlots.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
          notifyListeners();
          return true;
        },
        onFailure: (exception) {
          _setError(exception.message);
          return false;
        },
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Update a time slot
  Future<bool> updateTimeSlot(TimeSlot timeSlot) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _updateTimeSlotUseCase.execute(timeSlot);

      return result.fold(
        onSuccess: (updatedTimeSlot) {
          final index = _timeSlots.indexWhere((slot) => slot.id == updatedTimeSlot.id);
          if (index != -1) {
            _timeSlots[index] = updatedTimeSlot;
            notifyListeners();
          }
          return true;
        },
        onFailure: (exception) {
          _setError(exception.message);
          return false;
        },
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a time slot
  Future<bool> deleteTimeSlot(String timeSlotId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _deleteTimeSlotUseCase.execute(timeSlotId);

      return result.fold(
        onSuccess: (_) {
          _timeSlots.removeWhere((slot) => slot.id == timeSlotId);
          notifyListeners();
          return true;
        },
        onFailure: (exception) {
          _setError(exception.message);
          return false;
        },
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Create multiple time slots in bulk
  Future<bool> createBulkTimeSlots({
    required DateTime startDate,
    required DateTime endDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int slotDurationMinutes,
    required int maxCapacity,
    required SlotType type,
    String? itemId,
    double? price,
    List<int> excludeWeekdays = const [],
  }) async {
    _isBulkCreating = true;
    _bulkCreationProgress = 0;
    _bulkCreationTotal = 0;
    _clearError();
    notifyListeners();

    try {
      final result = await _createBulkTimeSlotsUseCase.execute(
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

      return result.fold(
        onSuccess: (createdTimeSlots) {
          _timeSlots.addAll(createdTimeSlots);
          _timeSlots.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
          _bulkCreationProgress = createdTimeSlots.length;
          _bulkCreationTotal = createdTimeSlots.length;
          notifyListeners();
          return true;
        },
        onFailure: (exception) {
          _setError(exception.message);
          return false;
        },
      );
    } finally {
      _isBulkCreating = false;
      notifyListeners();
    }
  }

  /// Update date range filter
  void updateDateRange(DateTime startDate, DateTime endDate) {
    _startDate = startDate;
    _endDate = endDate;
    notifyListeners();
  }

  /// Update workshop filter
  void updateWorkshopFilter(String? workshopId) {
    _selectedWorkshopId = workshopId;
    notifyListeners();
  }

  /// Update slot type filter
  void updateSlotTypeFilter(SlotType? slotType) {
    _selectedSlotType = slotType;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _selectedWorkshopId = null;
    _selectedSlotType = null;
    notifyListeners();
  }

  /// Refresh data
  Future<void> refresh() async {
    await Future.wait([
      loadTimeSlots(),
      loadWorkshops(),
    ]);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}