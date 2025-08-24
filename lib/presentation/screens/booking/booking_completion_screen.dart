import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/entities/booking.dart';
import '../../../domain/entities/workshop.dart';
import '../../../domain/entities/time_slot.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../theme/app_theme.dart';
import '../booking/booking_list_screen.dart';

/// Booking completion screen
/// 
/// Displays booking confirmation, receipt, and navigation options
class BookingCompletionScreen extends StatelessWidget {
  final Booking booking;
  final Workshop workshop;
  final TimeSlot timeSlot;
  
  const BookingCompletionScreen({
    super.key,
    required this.booking,
    required this.workshop,
    required this.timeSlot,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _buildContent(context),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: _buildContent(context),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('예약 완료'),
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
      automaticallyImplyLeading: false, // Remove back button
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _shareBooking(context),
          tooltip: '예약 정보 공유',
        ),
      ],
    );
  }

  /// Build main body content
  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: _buildContent(context),
    );
  }

  /// Build main content
  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSuccessHeader(context),
        const SizedBox(height: AppTheme.spacingLg),
        _buildBookingConfirmation(context),
        const SizedBox(height: AppTheme.spacingLg),
        _buildReceiptSection(context),
        const SizedBox(height: AppTheme.spacingLg),
        _buildImportantInfo(context),
        const SizedBox(height: AppTheme.spacingLg),
        _buildNextSteps(context),
      ],
    );
  }

  /// Build success header
  Widget _buildSuccessHeader(BuildContext context) {
    return Card(
      color: Colors.green.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              '예약이 완료되었습니다!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              '예약 확인서와 결제 영수증을 확인해주세요',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build booking confirmation section
  Widget _buildBookingConfirmation(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '예약 확인서',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    booking.statusDisplayName,
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingLg),
            
            // Booking ID
            _buildConfirmationRow(
              context,
              '예약 번호',
              booking.id,
              copyable: true,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            
            // Workshop info
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: workshop.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            workshop.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.business_center,
                                color: Theme.of(context).colorScheme.primary,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.business_center,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workshop.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        '최대 ${workshop.capacity}명',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            const Divider(),
            const SizedBox(height: AppTheme.spacingMd),
            
            // Booking details
            _buildConfirmationRow(context, '날짜', _formatDate(timeSlot.date)),
            const SizedBox(height: AppTheme.spacingSm),
            _buildConfirmationRow(context, '시간', timeSlot.timeRangeString),
            const SizedBox(height: AppTheme.spacingSm),
            _buildConfirmationRow(context, '예약 인원', '1명'),
            const SizedBox(height: AppTheme.spacingSm),
            _buildConfirmationRow(context, '예약일시', _formatDateTime(booking.createdAt)),
            
            if (booking.notes != null) ...[
              const SizedBox(height: AppTheme.spacingSm),
              _buildConfirmationRow(context, '특별 요청사항', booking.notes!),
            ],
          ],
        ),
      ),
    );
  }

  /// Build receipt section
  Widget _buildReceiptSection(BuildContext context) {
    final paymentInfo = booking.paymentInfo;
    if (paymentInfo == null) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '결제 영수증',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (paymentInfo.receiptUrl != null)
                  TextButton.icon(
                    onPressed: () => _downloadReceipt(context),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('영수증 다운로드'),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            
            // Payment details
            _buildConfirmationRow(context, '결제 방법', paymentInfo.methodDisplayName),
            const SizedBox(height: AppTheme.spacingSm),
            _buildConfirmationRow(context, '결제 상태', paymentInfo.statusDisplayName),
            const SizedBox(height: AppTheme.spacingSm),
            _buildConfirmationRow(context, '결제 일시', _formatDateTime(paymentInfo.paidAt)),
            
            if (paymentInfo.transactionId != null) ...[
              const SizedBox(height: AppTheme.spacingSm),
              _buildConfirmationRow(
                context, 
                '거래 번호', 
                paymentInfo.transactionId!,
                copyable: true,
              ),
            ],
            
            const SizedBox(height: AppTheme.spacingLg),
            const Divider(),
            const SizedBox(height: AppTheme.spacingMd),
            
            // Amount breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '워크샵 요금',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  paymentInfo.formattedAmount,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingMd),
            const Divider(thickness: 2),
            const SizedBox(height: AppTheme.spacingMd),
            
            // Total amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '총 결제 금액',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  paymentInfo.formattedAmount,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build important information section
  Widget _buildImportantInfo(BuildContext context) {
    return Card(
      color: Colors.blue.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  '중요 안내사항',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            
            _buildInfoItem(
              context,
              '워크샵 참석',
              '예약된 시간에 맞춰 참석해주세요. 늦으시면 입장이 제한될 수 있습니다.',
            ),
            const SizedBox(height: AppTheme.spacingSm),
            _buildInfoItem(
              context,
              '취소 정책',
              '워크샵 시작 24시간 전까지 취소 가능하며, 그 이후에는 취소가 불가능합니다.',
            ),
            const SizedBox(height: AppTheme.spacingSm),
            _buildInfoItem(
              context,
              '준비물',
              '특별한 준비물은 없으며, 필요한 모든 재료는 제공됩니다.',
            ),
            const SizedBox(height: AppTheme.spacingSm),
            _buildInfoItem(
              context,
              '문의사항',
              '궁금한 점이 있으시면 고객센터로 연락해주세요.',
            ),
          ],
        ),
      ),
    );
  }

  /// Build next steps section
  Widget _buildNextSteps(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '다음 단계',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            
            _buildNextStepItem(
              context,
              Icons.email_outlined,
              '확인 이메일',
              '예약 확인 이메일이 발송되었습니다. 스팸함도 확인해주세요.',
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildNextStepItem(
              context,
              Icons.calendar_today,
              '캘린더 추가',
              '워크샵 일정을 개인 캘린더에 추가하여 놓치지 마세요.',
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildNextStepItem(
              context,
              Icons.notifications_outlined,
              '알림 설정',
              '워크샵 시작 전 알림을 받으려면 앱 알림을 허용해주세요.',
            ),
          ],
        ),
      ),
    );
  }

  /// Build confirmation row
  Widget _buildConfirmationRow(
    BuildContext context,
    String label,
    String value, {
    bool copyable = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (copyable)
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () => _copyToClipboard(context, value),
                  tooltip: '복사',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build info item
  Widget _buildInfoItem(BuildContext context, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build next step item
  Widget _buildNextStepItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build bottom bar with navigation buttons
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                text: '예약 내역 보기',
                onPressed: () => _navigateToBookingList(context),
                type: AppButtonType.secondary,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: AppButton(
                text: '홈으로 가기',
                onPressed: () => _navigateToHome(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to booking list
  void _navigateToBookingList(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const BookingListScreen(),
      ),
      (route) => route.isFirst,
    );
  }

  /// Navigate to home
  void _navigateToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Copy text to clipboard
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('클립보드에 복사되었습니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Share booking information
  void _shareBooking(BuildContext context) {
    final shareText = '''
워크샵 예약 완료!

📋 예약 번호: ${booking.id}
🎯 워크샵: ${workshop.title}
📅 날짜: ${_formatDate(timeSlot.date)}
⏰ 시간: ${timeSlot.timeRangeString}
💰 금액: ${booking.paymentInfo?.formattedAmount ?? ''}

워크샵 예약 앱에서 예약했습니다.
''';

    // In a real app, you would use the share_plus package
    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('예약 정보가 클립보드에 복사되었습니다'),
      ),
    );
  }

  /// Download receipt (placeholder)
  void _downloadReceipt(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('영수증 다운로드 기능은 향후 구현 예정입니다'),
      ),
    );
  }

  /// Format date
  String _formatDate(DateTime date) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.year}년 ${date.month}월 ${date.day}일 ($weekday)';
  }

  /// Format date time
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}