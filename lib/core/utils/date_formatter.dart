/// Utility class for formatting dates and times
class DateFormatter {
  /// Format date time to relative time string (e.g., "2시간 전", "3일 전")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  /// Format date to Korean format (e.g., "2024년 1월 15일")
  static String formatKoreanDate(DateTime dateTime) {
    return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일';
  }

  /// Format date and time to Korean format (e.g., "2024년 1월 15일 오후 2:30")
  static String formatKoreanDateTime(DateTime dateTime) {
    final period = dateTime.hour < 12 ? '오전' : '오후';
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final displayHour = hour == 0 ? 12 : hour;
    
    return '${formatKoreanDate(dateTime)} $period $displayHour:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Format time to Korean format (e.g., "오후 2:30")
  static String formatKoreanTime(DateTime dateTime) {
    final period = dateTime.hour < 12 ? '오전' : '오후';
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final displayHour = hour == 0 ? 12 : hour;
    
    return '$period $displayHour:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Format amount to Korean currency format
  static String formatCurrency(double amount) {
    if (amount >= 100000000) {
      return '${(amount / 100000000).toStringAsFixed(1)}억원';
    } else if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(0)}만원';
    } else {
      return '${amount.toStringAsFixed(0)}원';
    }
  }

  /// Format date to simple format (e.g., "2024-01-15")
  static String formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  /// Format date with weekday (e.g., "2024-01-15 (월)")
  static String formatDateWithWeekday(DateTime dateTime) {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    final weekday = weekdays[dateTime.weekday % 7];
    return '${formatDate(dateTime)} ($weekday)';
  }

  /// Format time to 24-hour format (e.g., "14:30")
  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Format date and time to simple format (e.g., "2024-01-15 14:30")
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }
}