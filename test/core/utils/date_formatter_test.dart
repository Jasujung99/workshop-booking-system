import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_booking_system/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter Tests', () {
    group('formatRelativeTime', () {
      test('should return "방금 전" for recent time', () {
        final now = DateTime.now();
        final recent = now.subtract(Duration(seconds: 30));
        
        expect(DateFormatter.formatRelativeTime(recent), '방금 전');
      });

      test('should return minutes for time within an hour', () {
        final now = DateTime.now();
        final minutesAgo = now.subtract(Duration(minutes: 15));
        
        expect(DateFormatter.formatRelativeTime(minutesAgo), '15분 전');
      });

      test('should return hours for time within a day', () {
        final now = DateTime.now();
        final hoursAgo = now.subtract(Duration(hours: 3));
        
        expect(DateFormatter.formatRelativeTime(hoursAgo), '3시간 전');
      });

      test('should return days for time more than a day ago', () {
        final now = DateTime.now();
        final daysAgo = now.subtract(Duration(days: 5));
        
        expect(DateFormatter.formatRelativeTime(daysAgo), '5일 전');
      });

      test('should handle edge case of exactly 1 minute', () {
        final now = DateTime.now();
        final oneMinuteAgo = now.subtract(Duration(minutes: 1));
        
        expect(DateFormatter.formatRelativeTime(oneMinuteAgo), '1분 전');
      });

      test('should handle edge case of exactly 1 hour', () {
        final now = DateTime.now();
        final oneHourAgo = now.subtract(Duration(hours: 1));
        
        expect(DateFormatter.formatRelativeTime(oneHourAgo), '1시간 전');
      });

      test('should handle edge case of exactly 1 day', () {
        final now = DateTime.now();
        final oneDayAgo = now.subtract(Duration(days: 1));
        
        expect(DateFormatter.formatRelativeTime(oneDayAgo), '1일 전');
      });
    });

    group('formatKoreanDate', () {
      test('should format date in Korean format', () {
        final date = DateTime(2024, 1, 15);
        
        expect(DateFormatter.formatKoreanDate(date), '2024년 1월 15일');
      });

      test('should handle single digit month and day', () {
        final date = DateTime(2024, 3, 5);
        
        expect(DateFormatter.formatKoreanDate(date), '2024년 3월 5일');
      });

      test('should handle December 31st', () {
        final date = DateTime(2024, 12, 31);
        
        expect(DateFormatter.formatKoreanDate(date), '2024년 12월 31일');
      });
    });

    group('formatKoreanDateTime', () {
      test('should format morning time correctly', () {
        final dateTime = DateTime(2024, 1, 15, 9, 30);
        
        expect(DateFormatter.formatKoreanDateTime(dateTime), '2024년 1월 15일 오전 9:30');
      });

      test('should format afternoon time correctly', () {
        final dateTime = DateTime(2024, 1, 15, 14, 30);
        
        expect(DateFormatter.formatKoreanDateTime(dateTime), '2024년 1월 15일 오후 2:30');
      });

      test('should handle midnight correctly', () {
        final dateTime = DateTime(2024, 1, 15, 0, 30);
        
        expect(DateFormatter.formatKoreanDateTime(dateTime), '2024년 1월 15일 오전 12:30');
      });

      test('should handle noon correctly', () {
        final dateTime = DateTime(2024, 1, 15, 12, 30);
        
        expect(DateFormatter.formatKoreanDateTime(dateTime), '2024년 1월 15일 오후 12:30');
      });

      test('should pad single digit minutes', () {
        final dateTime = DateTime(2024, 1, 15, 14, 5);
        
        expect(DateFormatter.formatKoreanDateTime(dateTime), '2024년 1월 15일 오후 2:05');
      });
    });

    group('formatKoreanTime', () {
      test('should format morning time correctly', () {
        final dateTime = DateTime(2024, 1, 15, 9, 30);
        
        expect(DateFormatter.formatKoreanTime(dateTime), '오전 9:30');
      });

      test('should format afternoon time correctly', () {
        final dateTime = DateTime(2024, 1, 15, 14, 30);
        
        expect(DateFormatter.formatKoreanTime(dateTime), '오후 2:30');
      });

      test('should handle midnight correctly', () {
        final dateTime = DateTime(2024, 1, 15, 0, 30);
        
        expect(DateFormatter.formatKoreanTime(dateTime), '오전 12:30');
      });

      test('should handle noon correctly', () {
        final dateTime = DateTime(2024, 1, 15, 12, 30);
        
        expect(DateFormatter.formatKoreanTime(dateTime), '오후 12:30');
      });
    });

    group('formatCurrency', () {
      test('should format small amounts correctly', () {
        expect(DateFormatter.formatCurrency(5000), '5000원');
        expect(DateFormatter.formatCurrency(9999), '9999원');
      });

      test('should format amounts in 만원 correctly', () {
        expect(DateFormatter.formatCurrency(10000), '1만원');
        expect(DateFormatter.formatCurrency(50000), '5만원');
        expect(DateFormatter.formatCurrency(99999999), '10000만원');
      });

      test('should format amounts in 억원 correctly', () {
        expect(DateFormatter.formatCurrency(100000000), '1.0억원');
        expect(DateFormatter.formatCurrency(150000000), '1.5억원');
        expect(DateFormatter.formatCurrency(1000000000), '10.0억원');
      });

      test('should handle zero amount', () {
        expect(DateFormatter.formatCurrency(0), '0원');
      });

      test('should handle decimal amounts', () {
        expect(DateFormatter.formatCurrency(15500), '2만원');
        expect(DateFormatter.formatCurrency(125000000), '1.3억원');
      });
    });

    group('formatDate', () {
      test('should format date in simple format', () {
        final date = DateTime(2024, 1, 15);
        
        expect(DateFormatter.formatDate(date), '2024-01-15');
      });

      test('should pad single digit month and day', () {
        final date = DateTime(2024, 3, 5);
        
        expect(DateFormatter.formatDate(date), '2024-03-05');
      });

      test('should handle December 31st', () {
        final date = DateTime(2024, 12, 31);
        
        expect(DateFormatter.formatDate(date), '2024-12-31');
      });
    });

    group('formatDateWithWeekday', () {
      test('should format date with weekday correctly', () {
        final monday = DateTime(2024, 1, 15); // Monday
        expect(DateFormatter.formatDateWithWeekday(monday), '2024-01-15 (월)');

        final sunday = DateTime(2024, 1, 14); // Sunday
        expect(DateFormatter.formatDateWithWeekday(sunday), '2024-01-14 (일)');

        final saturday = DateTime(2024, 1, 13); // Saturday
        expect(DateFormatter.formatDateWithWeekday(saturday), '2024-01-13 (토)');
      });
    });

    group('formatTime', () {
      test('should format time in 24-hour format', () {
        final dateTime = DateTime(2024, 1, 15, 14, 30);
        
        expect(DateFormatter.formatTime(dateTime), '14:30');
      });

      test('should pad single digit hour and minute', () {
        final dateTime = DateTime(2024, 1, 15, 9, 5);
        
        expect(DateFormatter.formatTime(dateTime), '09:05');
      });

      test('should handle midnight', () {
        final dateTime = DateTime(2024, 1, 15, 0, 0);
        
        expect(DateFormatter.formatTime(dateTime), '00:00');
      });
    });

    group('formatDateTime', () {
      test('should format date and time correctly', () {
        final dateTime = DateTime(2024, 1, 15, 14, 30);
        
        expect(DateFormatter.formatDateTime(dateTime), '2024-01-15 14:30');
      });

      test('should pad single digits correctly', () {
        final dateTime = DateTime(2024, 3, 5, 9, 5);
        
        expect(DateFormatter.formatDateTime(dateTime), '2024-03-05 09:05');
      });
    });
  });
}