import '../../repositories/payment_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';
import '../../../data/services/payment_analytics_service.dart';

class GetPaymentStatisticsUseCase {
  final PaymentRepository _paymentRepository;
  final PaymentAnalyticsService _analyticsService;

  GetPaymentStatisticsUseCase(
    this._paymentRepository,
    this._analyticsService,
  );

  /// Get basic payment statistics
  Future<Result<PaymentStatistics>> execute({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Validate date range
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      return Failure(PaymentException(
        '시작 날짜는 종료 날짜보다 이전이어야 합니다',
        code: 'INVALID_DATE_RANGE',
      ));
    }

    return await _paymentRepository.getPaymentStatistics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get comprehensive payment report
  Future<Result<PaymentReport>> getPaymentReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Validate date range
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      return Failure(PaymentException(
        '시작 날짜는 종료 날짜보다 이전이어야 합니다',
        code: 'INVALID_DATE_RANGE',
      ));
    }

    return await _analyticsService.generatePaymentReport(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get revenue trends
  Future<Result<List<RevenueTrend>>> getRevenueTrends({
    required DateTime startDate,
    required DateTime endDate,
    TrendPeriod period = TrendPeriod.daily,
  }) async {
    // Validate date range
    if (startDate.isAfter(endDate)) {
      return Failure(PaymentException(
        '시작 날짜는 종료 날짜보다 이전이어야 합니다',
        code: 'INVALID_DATE_RANGE',
      ));
    }

    // Validate period length
    final daysDifference = endDate.difference(startDate).inDays;
    switch (period) {
      case TrendPeriod.daily:
        if (daysDifference > 90) {
          return Failure(PaymentException(
            '일별 트렌드는 최대 90일까지 조회 가능합니다',
            code: 'PERIOD_TOO_LONG',
          ));
        }
        break;
      case TrendPeriod.weekly:
        if (daysDifference > 365) {
          return Failure(PaymentException(
            '주별 트렌드는 최대 1년까지 조회 가능합니다',
            code: 'PERIOD_TOO_LONG',
          ));
        }
        break;
      case TrendPeriod.monthly:
        if (daysDifference > 1095) { // 3 years
          return Failure(PaymentException(
            '월별 트렌드는 최대 3년까지 조회 가능합니다',
            code: 'PERIOD_TOO_LONG',
          ));
        }
        break;
    }

    return await _analyticsService.getRevenueTrends(
      startDate: startDate,
      endDate: endDate,
      period: period,
    );
  }

  /// Get payment method analysis
  Future<Result<List<PaymentMethodAnalysis>>> getPaymentMethodAnalysis({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Validate date range
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      return Failure(PaymentException(
        '시작 날짜는 종료 날짜보다 이전이어야 합니다',
        code: 'INVALID_DATE_RANGE',
      ));
    }

    return await _analyticsService.getPaymentMethodAnalysis(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Export payment data
  Future<Result<String>> exportPaymentData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Validate date range
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      return Failure(PaymentException(
        '시작 날짜는 종료 날짜보다 이전이어야 합니다',
        code: 'INVALID_DATE_RANGE',
      ));
    }

    return await _analyticsService.exportPaymentDataToCsv(
      startDate: startDate,
      endDate: endDate,
    );
  }
}