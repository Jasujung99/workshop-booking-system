import 'package:flutter/foundation.dart';

import '../../domain/entities/booking.dart';
import '../../domain/entities/workshop.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/workshop_repository.dart';
import '../../core/error/result.dart';
import '../../core/error/exceptions.dart';

/// Provider for managing admin dashboard data and statistics
class AdminDashboardProvider extends ChangeNotifier {
  final BookingRepository _bookingRepository;
  final WorkshopRepository _workshopRepository;

  // Dashboard statistics
  DashboardStats _stats = DashboardStats.empty();
  List<Booking> _recentBookings = [];
  List<Workshop> _popularWorkshops = [];
  List<RevenueData> _revenueData = [];
  List<BookingStatusData> _bookingStatusData = [];

  // UI State
  bool _isLoading = false;
  String? _errorMessage;

  AdminDashboardProvider({
    required BookingRepository bookingRepository,
    required WorkshopRepository workshopRepository,
  })  : _bookingRepository = bookingRepository,
        _workshopRepository = workshopRepository;

  // Getters
  DashboardStats get stats => _stats;
  List<Booking> get recentBookings => _recentBookings;
  List<Workshop> get popularWorkshops => _popularWorkshops;
  List<RevenueData> get revenueData => _revenueData;
  List<BookingStatusData> get bookingStatusData => _bookingStatusData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load dashboard data
  Future<void> loadDashboardData() async {
    _setLoading(true);
    _clearError();

    try {
      // Load all data concurrently
      final results = await Future.wait([
        _loadBookingStats(),
        _loadRecentBookings(),
        _loadPopularWorkshops(),
        _loadRevenueData(),
      ]);

      // Check if any operation failed
      final hasError = results.any((result) => !result);
      if (!hasError) {
        _setLoading(false);
      }
    } catch (e) {
      _setError('대시보드 데이터를 불러오는 중 오류가 발생했습니다');
      _setLoading(false);
    }
  }

  /// Refresh dashboard data
  Future<void> refreshDashboardData() async {
    await loadDashboardData();
  }

  /// Load booking statistics
  Future<bool> _loadBookingStats() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final result = await _bookingRepository.getBookingsByDateRange(
        startOfMonth,
        endOfMonth,
      );

      return result.fold(
        onSuccess: (bookings) {
          _calculateStats(bookings);
          return true;
        },
        onFailure: (exception) {
          _setError(_getErrorMessage(exception));
          return false;
        },
      );
    } catch (e) {
      _setError('예약 통계를 불러오는 중 오류가 발생했습니다');
      return false;
    }
  }

  /// Load recent bookings
  Future<bool> _loadRecentBookings() async {
    try {
      final result = await _bookingRepository.getRecentBookings(limit: 10);

      return result.fold(
        onSuccess: (bookings) {
          _recentBookings = bookings;
          return true;
        },
        onFailure: (exception) {
          _setError(_getErrorMessage(exception));
          return false;
        },
      );
    } catch (e) {
      _setError('최근 예약을 불러오는 중 오류가 발생했습니다');
      return false;
    }
  }

  /// Load popular workshops
  Future<bool> _loadPopularWorkshops() async {
    try {
      final result = await _workshopRepository.getPopularWorkshops(limit: 5);

      return result.fold(
        onSuccess: (workshops) {
          _popularWorkshops = workshops;
          return true;
        },
        onFailure: (exception) {
          _setError(_getErrorMessage(exception));
          return false;
        },
      );
    } catch (e) {
      _setError('인기 워크샵을 불러오는 중 오류가 발생했습니다');
      return false;
    }
  }

  /// Load revenue data for charts
  Future<bool> _loadRevenueData() async {
    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month - 6, 1);
      final endDate = DateTime(now.year, now.month + 1, 0);

      final result = await _bookingRepository.getBookingsByDateRange(
        startDate,
        endDate,
      );

      return result.fold(
        onSuccess: (bookings) {
          _generateRevenueData(bookings);
          _generateBookingStatusData(bookings);
          return true;
        },
        onFailure: (exception) {
          _setError(_getErrorMessage(exception));
          return false;
        },
      );
    } catch (e) {
      _setError('수익 데이터를 불러오는 중 오류가 발생했습니다');
      return false;
    }
  }

  /// Calculate dashboard statistics
  void _calculateStats(List<Booking> bookings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayBookings = bookings.where((b) {
      final bookingDate = DateTime(
        b.createdAt.year,
        b.createdAt.month,
        b.createdAt.day,
      );
      return bookingDate == today;
    }).toList();

    final yesterdayBookings = bookings.where((b) {
      final bookingDate = DateTime(
        b.createdAt.year,
        b.createdAt.month,
        b.createdAt.day,
      );
      return bookingDate == yesterday;
    }).toList();

    final confirmedBookings = bookings
        .where((b) => b.status == BookingStatus.confirmed)
        .toList();

    final totalRevenue = bookings
        .where((b) => b.status != BookingStatus.cancelled)
        .fold<double>(0, (sum, booking) => sum + booking.totalAmount);

    final todayRevenue = todayBookings
        .where((b) => b.status != BookingStatus.cancelled)
        .fold<double>(0, (sum, booking) => sum + booking.totalAmount);

    final yesterdayRevenue = yesterdayBookings
        .where((b) => b.status != BookingStatus.cancelled)
        .fold<double>(0, (sum, booking) => sum + booking.totalAmount);

    _stats = DashboardStats(
      totalBookings: bookings.length,
      todayBookings: todayBookings.length,
      confirmedBookings: confirmedBookings.length,
      cancelledBookings: bookings
          .where((b) => b.status == BookingStatus.cancelled)
          .length,
      totalRevenue: totalRevenue,
      todayRevenue: todayRevenue,
      bookingGrowth: _calculateGrowthRate(
        todayBookings.length.toDouble(),
        yesterdayBookings.length.toDouble(),
      ),
      revenueGrowth: _calculateGrowthRate(todayRevenue, yesterdayRevenue),
    );
  }

  /// Generate revenue data for charts
  void _generateRevenueData(List<Booking> bookings) {
    final Map<String, double> monthlyRevenue = {};

    for (final booking in bookings) {
      if (booking.status == BookingStatus.cancelled) continue;

      final monthKey = '${booking.createdAt.year}-${booking.createdAt.month.toString().padLeft(2, '0')}';
      monthlyRevenue[monthKey] = (monthlyRevenue[monthKey] ?? 0) + booking.totalAmount;
    }

    _revenueData = monthlyRevenue.entries
        .map((entry) => RevenueData(
              month: entry.key,
              revenue: entry.value,
            ))
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));
  }

  /// Generate booking status data for charts
  void _generateBookingStatusData(List<Booking> bookings) {
    final statusCounts = <BookingStatus, int>{};

    for (final booking in bookings) {
      statusCounts[booking.status] = (statusCounts[booking.status] ?? 0) + 1;
    }

    _bookingStatusData = statusCounts.entries
        .map((entry) => BookingStatusData(
              status: entry.key,
              count: entry.value,
            ))
        .toList();
  }

  /// Calculate growth rate percentage
  double _calculateGrowthRate(double current, double previous) {
    if (previous == 0) return current > 0 ? 100.0 : 0.0;
    return ((current - previous) / previous) * 100;
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Convert exception to user-friendly error message
  String _getErrorMessage(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        return '네트워크 연결을 확인해주세요';
      case ServerException:
        return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요';
      case AuthException:
        return '권한이 없습니다. 다시 로그인해주세요';
      default:
        return exception.message.isNotEmpty 
            ? exception.message 
            : '알 수 없는 오류가 발생했습니다';
    }
  }
}

/// Dashboard statistics data class
class DashboardStats {
  final int totalBookings;
  final int todayBookings;
  final int confirmedBookings;
  final int cancelledBookings;
  final double totalRevenue;
  final double todayRevenue;
  final double bookingGrowth;
  final double revenueGrowth;

  const DashboardStats({
    required this.totalBookings,
    required this.todayBookings,
    required this.confirmedBookings,
    required this.cancelledBookings,
    required this.totalRevenue,
    required this.todayRevenue,
    required this.bookingGrowth,
    required this.revenueGrowth,
  });

  static DashboardStats empty() => const DashboardStats(
        totalBookings: 0,
        todayBookings: 0,
        confirmedBookings: 0,
        cancelledBookings: 0,
        totalRevenue: 0,
        todayRevenue: 0,
        bookingGrowth: 0,
        revenueGrowth: 0,
      );
}

/// Revenue data for charts
class RevenueData {
  final String month;
  final double revenue;

  const RevenueData({
    required this.month,
    required this.revenue,
  });
}

/// Booking status data for charts
class BookingStatusData {
  final BookingStatus status;
  final int count;

  const BookingStatusData({
    required this.status,
    required this.count,
  });
}