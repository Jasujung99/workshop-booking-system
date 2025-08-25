import 'package:logger/logger.dart';
import '../../core/error/result.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/payment_info.dart';
import '../../domain/repositories/payment_repository.dart';

class PaymentAnalyticsService {
  final PaymentRepository _paymentRepository;
  final Logger _logger;

  PaymentAnalyticsService({
    required PaymentRepository paymentRepository,
    Logger? logger,
  }) : _paymentRepository = paymentRepository,
       _logger = logger ?? Logger();

  /// Generate comprehensive payment report
  Future<Result<PaymentReport>> generatePaymentReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _logger.i('Generating payment report');

      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();

      // Get payment statistics
      final statisticsResult = await _paymentRepository.getPaymentStatistics(
        startDate: start,
        endDate: end,
      );

      if (statisticsResult is Failure) {
        return Failure(statisticsResult.exception);
      }

      final statistics = (statisticsResult as Success).data;

      // Calculate additional metrics
      final report = PaymentReport(
        period: PaymentPeriod(startDate: start, endDate: end),
        totalRevenue: statistics.totalRevenue,
        totalTransactions: statistics.totalTransactions,
        successfulTransactions: statistics.successfulTransactions,
        failedTransactions: statistics.failedTransactions,
        refundedTransactions: statistics.refundedTransactions,
        totalRefunds: statistics.totalRefunds,
        netRevenue: statistics.totalRevenue - statistics.totalRefunds,
        successRate: statistics.successRate,
        refundRate: statistics.refundRate,
        averageTransactionAmount: statistics.totalTransactions > 0 
            ? statistics.totalRevenue / statistics.successfulTransactions 
            : 0.0,
        paymentMethodBreakdown: statistics.paymentMethodBreakdown,
        dailyRevenue: statistics.dailyRevenue,
        generatedAt: DateTime.now(),
      );

      _logger.i('Payment report generated successfully');
      return Success(report);
    } catch (e) {
      _logger.e('Error generating payment report: $e');
      return Failure(PaymentException(
        '결제 리포트 생성 중 오류가 발생했습니다: ${e.toString()}',
        code: 'PAYMENT_REPORT_ERROR',
      ));
    }
  }

  /// Get revenue trends over time
  Future<Result<List<RevenueTrend>>> getRevenueTrends({
    required DateTime startDate,
    required DateTime endDate,
    TrendPeriod period = TrendPeriod.daily,
  }) async {
    try {
      _logger.i('Getting revenue trends');

      final statisticsResult = await _paymentRepository.getPaymentStatistics(
        startDate: startDate,
        endDate: endDate,
      );

      if (statisticsResult is Failure) {
        return Failure(statisticsResult.exception);
      }

      final statistics = (statisticsResult as Success).data;
      final trends = <RevenueTrend>[];

      // Process daily revenue data based on requested period
      switch (period) {
        case TrendPeriod.daily:
          for (final entry in statistics.dailyRevenue.entries) {
            trends.add(RevenueTrend(
              date: DateTime.parse(entry.key),
              revenue: entry.value,
              period: period,
            ));
          }
          break;
        case TrendPeriod.weekly:
          // Group daily data into weekly trends
          final weeklyData = <String, double>{};
          for (final entry in statistics.dailyRevenue.entries) {
            final date = DateTime.parse(entry.key);
            final weekKey = _getWeekKey(date);
            weeklyData[weekKey] = (weeklyData[weekKey] ?? 0) + entry.value;
          }
          for (final entry in weeklyData.entries) {
            trends.add(RevenueTrend(
              date: DateTime.parse(entry.key),
              revenue: entry.value,
              period: period,
            ));
          }
          break;
        case TrendPeriod.monthly:
          // Group daily data into monthly trends
          final monthlyData = <String, double>{};
          for (final entry in statistics.dailyRevenue.entries) {
            final date = DateTime.parse(entry.key);
            final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-01';
            monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + entry.value;
          }
          for (final entry in monthlyData.entries) {
            trends.add(RevenueTrend(
              date: DateTime.parse(entry.key),
              revenue: entry.value,
              period: period,
            ));
          }
          break;
      }

      trends.sort((a, b) => a.date.compareTo(b.date));
      return Success(trends);
    } catch (e) {
      _logger.e('Error getting revenue trends: $e');
      return Failure(PaymentException(
        '수익 트렌드 조회 중 오류가 발생했습니다: ${e.toString()}',
        code: 'REVENUE_TRENDS_ERROR',
      ));
    }
  }

  /// Get payment method performance analysis
  Future<Result<List<PaymentMethodAnalysis>>> getPaymentMethodAnalysis({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _logger.i('Getting payment method analysis');

      final statisticsResult = await _paymentRepository.getPaymentStatistics(
        startDate: startDate,
        endDate: endDate,
      );

      if (statisticsResult is Failure) {
        return Failure(statisticsResult.exception);
      }

      final statistics = (statisticsResult as Success).data;
      final analysis = <PaymentMethodAnalysis>[];

      for (final entry in statistics.paymentMethodBreakdown.entries) {
        final method = entry.key;
        final count = entry.value;
        final percentage = statistics.totalTransactions > 0 
            ? (count / statistics.totalTransactions) * 100 
            : 0.0;

        analysis.add(PaymentMethodAnalysis(
          method: method,
          transactionCount: count,
          percentage: percentage,
          // Note: We don't have revenue per method in current statistics
          // This would need to be added to the statistics calculation
          revenue: 0.0,
        ));
      }

      analysis.sort((a, b) => b.transactionCount.compareTo(a.transactionCount));
      return Success(analysis);
    } catch (e) {
      _logger.e('Error getting payment method analysis: $e');
      return Failure(PaymentException(
        '결제 방법 분석 중 오류가 발생했습니다: ${e.toString()}',
        code: 'PAYMENT_METHOD_ANALYSIS_ERROR',
      ));
    }
  }

  /// Export payment data to CSV format
  Future<Result<String>> exportPaymentDataToCsv({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _logger.i('Exporting payment data to CSV');

      // This is a simplified implementation
      // In a real app, you'd want to get actual payment records and format them
      final reportResult = await generatePaymentReport(
        startDate: startDate,
        endDate: endDate,
      );

      if (reportResult is Failure) {
        return Failure(reportResult.exception);
      }

      final report = (reportResult as Success<PaymentReport>).data;

      final csvData = StringBuffer();
      csvData.writeln('Payment Report CSV Export');
      csvData.writeln('Generated At,${report.generatedAt.toIso8601String()}');
      csvData.writeln('Period,${report.period.startDate.toIso8601String()} to ${report.period.endDate.toIso8601String()}');
      csvData.writeln('');
      csvData.writeln('Summary');
      csvData.writeln('Total Revenue,${report.totalRevenue}');
      csvData.writeln('Total Transactions,${report.totalTransactions}');
      csvData.writeln('Successful Transactions,${report.successfulTransactions}');
      csvData.writeln('Failed Transactions,${report.failedTransactions}');
      csvData.writeln('Refunded Transactions,${report.refundedTransactions}');
      csvData.writeln('Total Refunds,${report.totalRefunds}');
      csvData.writeln('Net Revenue,${report.netRevenue}');
      csvData.writeln('Success Rate,${(report.successRate * 100).toStringAsFixed(2)}%');
      csvData.writeln('Refund Rate,${(report.refundRate * 100).toStringAsFixed(2)}%');
      csvData.writeln('');
      csvData.writeln('Daily Revenue');
      csvData.writeln('Date,Revenue');
      for (final entry in report.dailyRevenue.entries) {
        csvData.writeln('${entry.key},${entry.value}');
      }

      return Success(csvData.toString());
    } catch (e) {
      _logger.e('Error exporting payment data to CSV: $e');
      return Failure(PaymentException(
        'CSV 내보내기 중 오류가 발생했습니다: ${e.toString()}',
        code: 'CSV_EXPORT_ERROR',
      ));
    }
  }

  /// Get week key for grouping (Monday of the week)
  String _getWeekKey(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  }
}

/// Comprehensive payment report
class PaymentReport {
  final PaymentPeriod period;
  final double totalRevenue;
  final int totalTransactions;
  final int successfulTransactions;
  final int failedTransactions;
  final int refundedTransactions;
  final double totalRefunds;
  final double netRevenue;
  final double successRate;
  final double refundRate;
  final double averageTransactionAmount;
  final Map<PaymentMethod, int> paymentMethodBreakdown;
  final Map<String, double> dailyRevenue;
  final DateTime generatedAt;

  const PaymentReport({
    required this.period,
    required this.totalRevenue,
    required this.totalTransactions,
    required this.successfulTransactions,
    required this.failedTransactions,
    required this.refundedTransactions,
    required this.totalRefunds,
    required this.netRevenue,
    required this.successRate,
    required this.refundRate,
    required this.averageTransactionAmount,
    required this.paymentMethodBreakdown,
    required this.dailyRevenue,
    required this.generatedAt,
  });

  /// Format total revenue as Korean Won
  String get formattedTotalRevenue {
    return '${totalRevenue.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}원';
  }

  /// Format net revenue as Korean Won
  String get formattedNetRevenue {
    return '${netRevenue.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}원';
  }

  /// Format average transaction amount as Korean Won
  String get formattedAverageTransactionAmount {
    return '${averageTransactionAmount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}원';
  }

  /// Get success rate as percentage
  String get successRatePercentage {
    return '${(successRate * 100).toStringAsFixed(1)}%';
  }

  /// Get refund rate as percentage
  String get refundRatePercentage {
    return '${(refundRate * 100).toStringAsFixed(1)}%';
  }
}

/// Payment period for reports
class PaymentPeriod {
  final DateTime startDate;
  final DateTime endDate;

  const PaymentPeriod({
    required this.startDate,
    required this.endDate,
  });

  /// Get period duration in days
  int get durationInDays {
    return endDate.difference(startDate).inDays;
  }

  /// Get formatted period string
  String get formattedPeriod {
    return '${startDate.toIso8601String().substring(0, 10)} ~ ${endDate.toIso8601String().substring(0, 10)}';
  }
}

/// Revenue trend data point
class RevenueTrend {
  final DateTime date;
  final double revenue;
  final TrendPeriod period;

  const RevenueTrend({
    required this.date,
    required this.revenue,
    required this.period,
  });

  /// Format revenue as Korean Won
  String get formattedRevenue {
    return '${revenue.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}원';
  }
}

/// Payment method analysis
class PaymentMethodAnalysis {
  final PaymentMethod method;
  final int transactionCount;
  final double percentage;
  final double revenue;

  const PaymentMethodAnalysis({
    required this.method,
    required this.transactionCount,
    required this.percentage,
    required this.revenue,
  });

  /// Get method display name in Korean
  String get methodDisplayName {
    switch (method) {
      case PaymentMethod.creditCard:
        return '신용카드';
      case PaymentMethod.bankTransfer:
        return '계좌이체';
      case PaymentMethod.kakaoPayment:
        return '카카오페이';
      case PaymentMethod.naverPayment:
        return '네이버페이';
      case PaymentMethod.paypal:
        return 'PayPal';
    }
  }

  /// Format percentage
  String get formattedPercentage {
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// Format revenue as Korean Won
  String get formattedRevenue {
    return '${revenue.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}원';
  }
}

/// Trend period options
enum TrendPeriod {
  daily,
  weekly,
  monthly,
}