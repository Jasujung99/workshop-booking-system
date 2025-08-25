import 'package:flutter/material.dart';
import '../../../domain/entities/booking.dart';
import '../../../core/utils/date_formatter.dart';

/// Widget for displaying recent booking activities
class RecentActivityWidget extends StatelessWidget {
  final List<Booking> recentBookings;
  final bool isLoading;
  final VoidCallback? onViewAll;

  const RecentActivityWidget({
    required this.recentBookings,
    this.isLoading = false,
    this.onViewAll,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '최근 활동',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('전체 보기'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (recentBookings.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('최근 활동이 없습니다'),
                ),
              )
            else
              ...recentBookings.map((booking) => _buildActivityItem(
                    context,
                    booking,
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, Booking booking) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(booking.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getStatusIcon(booking.status),
              color: _getStatusColor(booking.status),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getActivityDescription(booking),
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormatter.formatRelativeTime(booking.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₩${_formatAmount(booking.totalAmount)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _getStatusColor(booking.status),
            ),
          ),
        ],
      ),
    );
  }

  String _getActivityDescription(Booking booking) {
    switch (booking.status) {
      case BookingStatus.pending:
        return '새로운 예약 요청';
      case BookingStatus.confirmed:
        return '예약이 확정되었습니다';
      case BookingStatus.completed:
        return '예약이 완료되었습니다';
      case BookingStatus.cancelled:
        return '예약이 취소되었습니다';
      case BookingStatus.refunded:
        return '환불이 처리되었습니다';
      case BookingStatus.noShow:
        return '노쇼가 발생했습니다';
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.schedule;
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.completed:
        return Icons.done_all;
      case BookingStatus.cancelled:
        return Icons.cancel;
      case BookingStatus.refunded:
        return Icons.money_off;
      case BookingStatus.noShow:
        return Icons.person_off;
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.completed:
        return Colors.blue;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.refunded:
        return Colors.purple;
      case BookingStatus.noShow:
        return Colors.grey;
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}

