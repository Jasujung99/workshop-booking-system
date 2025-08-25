import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/booking_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/app_button.dart';

import '../../widgets/layout/responsive_layout.dart';
import '../../theme/app_theme.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/entities/time_slot.dart';

/// Booking detail screen showing comprehensive booking information
/// 
/// Displays booking details, payment information, and cancellation options
class BookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailScreen({
    required this.bookingId,
    super.key,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  Booking? _booking;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
  }

  Future<void> _loadBookingDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bookingProvider = context.read<BookingProvider>();
      final booking = await bookingProvider.getBookingById(widget.bookingId);
      
      if (booking != null) {
        setState(() {
          _booking = booking;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = '예약 정보를 찾을 수 없습니다';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '예약 정보를 불러오는 중 오류가 발생했습니다';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예약 상세'),
        actions: [
          if (_booking != null && _canCancelBooking())
            IconButton(
              icon: const Icon(Icons.cancel_outlined),
              onPressed: _showCancelDialog,
              tooltip: '예약 취소',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예약 상세'),
        actions: [
          if (_booking != null && _canCancelBooking())
            IconButton(
              icon: const Icon(Icons.cancel_outlined),
              onPressed: _showCancelDialog,
              tooltip: '예약 취소',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  '예약 상세',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_booking != null && _canCancelBooking())
                  AppButton(
                    text: '예약 취소',
                    onPressed: _showCancelDialog,
                    type: AppButtonType.outlined,
                    icon: Icons.cancel_outlined,
                  ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: '예약 정보를 불러오는 중...');
    }

    if (_errorMessage != null) {
      return AppErrorWidget(
        message: _errorMessage!,
        onRetry: _loadBookingDetails,
      );
    }

    if (_booking == null) {
      return const EmptyStateWidget(
        title: '예약 정보 없음',
        message: '예약 정보를 찾을 수 없습니다.',
        icon: Icons.receipt_long_outlined,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBookingStatusCard(),
          const SizedBox(height: AppTheme.spacingMd),
          _buildBookingInfoCard(),
          const SizedBox(height: AppTheme.spacingMd),
          _buildPaymentInfoCard(),
          if (_booking!.notes != null && _booking!.notes!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingMd),
            _buildNotesCard(),
          ],
          if (_canCancelBooking()) ...[
            const SizedBox(height: AppTheme.spacingMd),
            _buildCancellationPolicyCard(),
            const SizedBox(height: AppTheme.spacingLg),
            _buildCancelButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildBookingStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 24,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  '예약 상태',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSm,
                    vertical: AppTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _booking!.statusDisplayName,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildInfoRow('예약 번호', _booking!.id),
            _buildInfoRow('예약 일시', _formatDateTime(_booking!.createdAt)),
            if (_booking!.updatedAt != null)
              _buildInfoRow('수정 일시', _formatDateTime(_booking!.updatedAt!)),
            if (_booking!.cancelledAt != null) ...[
              _buildInfoRow('취소 일시', _formatDateTime(_booking!.cancelledAt!)),
              if (_booking!.cancellationReason != null)
                _buildInfoRow('취소 사유', _booking!.cancellationReason!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookingInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.business_center_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  '예약 정보',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildInfoRow('예약 유형', _booking!.typeDisplayName),
            _buildInfoRow('시간대 ID', _booking!.timeSlotId),
            if (_booking!.itemId != null)
              _buildInfoRow('워크샵/공간 ID', _booking!.itemId!),
            _buildInfoRow('총 금액', _booking!.formattedTotalAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    final paymentInfo = _booking!.paymentInfo;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payment_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  '결제 정보',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            if (paymentInfo != null) ...[
              _buildInfoRow('결제 ID', paymentInfo.paymentId),
              _buildInfoRow('결제 방법', paymentInfo.methodDisplayName),
              _buildInfoRow('결제 상태', paymentInfo.statusDisplayName),
              _buildInfoRow('결제 금액', paymentInfo.formattedAmount),
              _buildInfoRow('결제 일시', _formatDateTime(paymentInfo.paidAt)),
              if (paymentInfo.receiptUrl != null)
                _buildInfoRow('영수증', '영수증 보기', isLink: true),
            ] else ...[
              Text(
                '결제 정보가 없습니다',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  '특별 요청사항',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _booking!.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancellationPolicyCard() {
    // Mock time slot for demonstration - in real app, this would be fetched
    final mockSlotTime = DateTime.now().add(const Duration(days: 3));
    final refundAmount = _booking!.calculateRefundAmount(mockSlotTime);
    final policyText = _booking!.getRefundPolicyText(mockSlotTime);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.policy_outlined,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  '취소 정책',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    policyText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    '예상 환불 금액: ${refundAmount.toInt().toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    )}원',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        return AppButton(
          text: '예약 취소',
          onPressed: bookingProvider.isCancellingBooking ? null : _showCancelDialog,
          isLoading: bookingProvider.isCancellingBooking,
          type: AppButtonType.outlined,
          icon: Icons.cancel_outlined,
          isExpanded: true,
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: isLink
                ? GestureDetector(
                    onTap: () {
                      // Handle link tap (e.g., open receipt)
                    },
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
          ),
        ],
      ),
    );
  }

  bool _canCancelBooking() {
    if (_booking == null) return false;
    
    // Mock time slot for demonstration - in real app, this would be fetched
    final mockSlotTime = DateTime.now().add(const Duration(days: 3));
    return _booking!.canBeCancelled(mockSlotTime);
  }

  IconData _getStatusIcon() {
    switch (_booking!.status) {
      case BookingStatus.pending:
        return Icons.schedule;
      case BookingStatus.confirmed:
        return Icons.check_circle_outline;
      case BookingStatus.completed:
        return Icons.task_alt;
      case BookingStatus.cancelled:
        return Icons.cancel_outlined;
      case BookingStatus.noShow:
        return Icons.person_off_outlined;
      case BookingStatus.refunded:
        return Icons.money_off_outlined;
    }
  }

  Color _getStatusColor() {
    switch (_booking!.status) {
      case BookingStatus.pending:
        return Theme.of(context).colorScheme.secondary;
      case BookingStatus.confirmed:
        return Theme.of(context).colorScheme.primary;
      case BookingStatus.completed:
        return Theme.of(context).colorScheme.tertiary;
      case BookingStatus.cancelled:
        return Theme.of(context).colorScheme.error;
      case BookingStatus.noShow:
        return Theme.of(context).colorScheme.onSurfaceVariant;
      case BookingStatus.refunded:
        return Theme.of(context).colorScheme.outline;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => BookingCancelDialog(
        booking: _booking!,
        onConfirm: _cancelBooking,
      ),
    );
  }

  Future<void> _cancelBooking(String reason) async {
    final bookingProvider = context.read<BookingProvider>();
    final success = await bookingProvider.cancelBooking(_booking!.id, reason);
    
    if (success && mounted) {
      // Refresh booking details
      await _loadBookingDetails();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('예약이 성공적으로 취소되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted && bookingProvider.errorMessage != null) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.errorMessage!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

/// Dialog for booking cancellation with reason input
class BookingCancelDialog extends StatefulWidget {
  final Booking booking;
  final Function(String reason) onConfirm;

  const BookingCancelDialog({
    required this.booking,
    required this.onConfirm,
    super.key,
  });

  @override
  State<BookingCancelDialog> createState() => _BookingCancelDialogState();
}

class _BookingCancelDialogState extends State<BookingCancelDialog> {
  final _reasonController = TextEditingController();
  String? _selectedReason;

  final List<String> _predefinedReasons = [
    '일정 변경',
    '개인 사정',
    '건강상 이유',
    '교통 문제',
    '기타',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mock time slot for demonstration
    final mockSlotTime = DateTime.now().add(const Duration(days: 3));
    final refundAmount = widget.booking.calculateRefundAmount(mockSlotTime);
    final policyText = widget.booking.getRefundPolicyText(mockSlotTime);

    return AlertDialog(
      title: const Text('예약 취소'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '정말로 예약을 취소하시겠습니까?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    policyText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    '환불 금액: ${refundAmount.toInt().toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    )}원',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              '취소 사유를 선택해주세요:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            ..._predefinedReasons.map((reason) => RadioListTile<String>(
              title: Text(reason),
              value: reason,
              groupValue: _selectedReason,
              onChanged: (value) {
                setState(() {
                  _selectedReason = value;
                  if (value != '기타') {
                    _reasonController.text = value!;
                  } else {
                    _reasonController.clear();
                  }
                });
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
            )),
            if (_selectedReason == '기타') ...[
              const SizedBox(height: AppTheme.spacingSm),
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: '취소 사유를 입력해주세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                maxLength: 200,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        Consumer<BookingProvider>(
          builder: (context, bookingProvider, child) {
            return FilledButton(
              onPressed: _canConfirm() && !bookingProvider.isCancellingBooking
                  ? _confirmCancel
                  : null,
              child: bookingProvider.isCancellingBooking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('확인'),
            );
          },
        ),
      ],
    );
  }

  bool _canConfirm() {
    if (_selectedReason == null) return false;
    if (_selectedReason == '기타' && _reasonController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  void _confirmCancel() {
    final reason = _selectedReason == '기타' 
        ? _reasonController.text.trim()
        : _selectedReason!;
    
    Navigator.of(context).pop();
    widget.onConfirm(reason);
  }
}