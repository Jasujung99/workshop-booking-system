import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/workshop.dart';
import '../../../domain/entities/time_slot.dart';
import '../../../domain/entities/payment_info.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../theme/app_theme.dart';
import 'booking_completion_screen.dart';

/// Booking confirmation and payment screen
/// 
/// Displays booking summary, payment method selection, and handles payment processing
class BookingConfirmationScreen extends StatefulWidget {
  final Workshop workshop;
  final TimeSlot timeSlot;
  
  const BookingConfirmationScreen({
    super.key,
    required this.workshop,
    required this.timeSlot,
  });

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _specialRequestsController = TextEditingController();
  
  PaymentMethod _selectedPaymentMethod = PaymentMethod.creditCard;
  bool _agreedToTerms = false;
  bool _agreedToPrivacy = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider = context.read<BookingProvider>();
      bookingProvider.proceedToPayment();
    });
  }

  @override
  void dispose() {
    _specialRequestsController.dispose();
    super.dispose();
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
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildBookingSummary(),
            ),
            const SizedBox(width: AppTheme.spacingLg),
            Expanded(
              flex: 1,
              child: _buildPaymentSection(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildBookingSummary(),
            ),
            const SizedBox(width: AppTheme.spacingXl),
            Expanded(
              flex: 2,
              child: _buildPaymentSection(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('예약 확인'),
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: _showPaymentHelp,
          tooltip: '결제 도움말',
        ),
      ],
    );
  }

  /// Build main body content
  Widget _buildBody() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        if (bookingProvider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: AppErrorWidget(
                message: bookingProvider.errorMessage!,
                onRetry: () => bookingProvider.clearError(),
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBookingSummary(),
                const SizedBox(height: AppTheme.spacingLg),
                _buildPaymentSection(),
                const SizedBox(height: AppTheme.spacingLg),
                _buildSpecialRequestsSection(),
                const SizedBox(height: AppTheme.spacingLg),
                _buildTermsSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build booking summary section
  Widget _buildBookingSummary() {
    final price = widget.timeSlot.price ?? widget.workshop.price;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '예약 정보',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
                  child: widget.workshop.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.workshop.imageUrl!,
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
                        widget.workshop.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        '최대 ${widget.workshop.capacity}명',
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
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: '날짜',
              value: _formatDate(widget.timeSlot.date),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            _buildDetailRow(
              icon: Icons.schedule,
              label: '시간',
              value: widget.timeSlot.timeRangeString,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            _buildDetailRow(
              icon: Icons.people,
              label: '예약 인원',
              value: '1명',
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            const Divider(),
            const SizedBox(height: AppTheme.spacingMd),
            
            // Price breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '워크샵 요금',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  _formatPrice(price),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            
            if (widget.timeSlot.price != null && widget.timeSlot.price != widget.workshop.price) ...[
              const SizedBox(height: AppTheme.spacingSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '특별 할인',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    '-${_formatPrice(widget.workshop.price - price)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
            
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
                  _formatPrice(price),
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

  /// Build payment section
  Widget _buildPaymentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '결제 방법',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            
            // Payment method selection
            ...PaymentMethod.values.map((method) {
              return _buildPaymentMethodTile(method);
            }),
          ],
        ),
      ),
    );
  }

  /// Build payment method tile
  Widget _buildPaymentMethodTile(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method;
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      color: isSelected 
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: RadioListTile<PaymentMethod>(
        value: method,
        groupValue: _selectedPaymentMethod,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedPaymentMethod = value;
            });
          }
        },
        title: Row(
          children: [
            Icon(
              _getPaymentMethodIcon(method),
              color: isSelected 
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              _getPaymentMethodName(method),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected 
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : null,
              ),
            ),
          ],
        ),
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// Build special requests section
  Widget _buildSpecialRequestsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '특별 요청사항',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              '워크샵 진행에 필요한 특별한 요청사항이 있으시면 작성해주세요 (선택사항)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            AppTextField(
              controller: _specialRequestsController,
              label: '특별 요청사항',
              hint: '예: 알레르기, 접근성 요구사항, 기타 요청사항',
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
      ),
    );
  }

  /// Build terms and conditions section
  Widget _buildTermsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '약관 동의',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            
            // Terms agreement
            CheckboxListTile(
              value: _agreedToTerms,
              onChanged: (value) {
                setState(() {
                  _agreedToTerms = value ?? false;
                });
              },
              title: const Text('이용약관에 동의합니다'),
              subtitle: TextButton(
                onPressed: _showTermsDialog,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                child: const Text('약관 보기'),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            
            // Privacy agreement
            CheckboxListTile(
              value: _agreedToPrivacy,
              onChanged: (value) {
                setState(() {
                  _agreedToPrivacy = value ?? false;
                });
              },
              title: const Text('개인정보 처리방침에 동의합니다'),
              subtitle: TextButton(
                onPressed: _showPrivacyDialog,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                child: const Text('개인정보 처리방침 보기'),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }

  /// Build detail row
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  /// Build bottom bar with payment button
  Widget _buildBottomBar() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        final canProceed = _agreedToTerms && _agreedToPrivacy;
        final price = widget.timeSlot.price ?? widget.workshop.price;
        
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '총 결제 금액',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        _formatPrice(price),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                AppButton(
                  text: canProceed ? '결제하기' : '약관에 동의해주세요',
                  onPressed: canProceed ? _processPayment : null,
                  isLoading: bookingProvider.isCreatingBooking || bookingProvider.isProcessingPayment,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Process payment and create booking
  void _processPayment() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms || !_agreedToPrivacy) return;

    final authProvider = context.read<AuthProvider>();
    final bookingProvider = context.read<BookingProvider>();
    
    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      return;
    }

    // Show payment processing dialog
    _showPaymentProcessingDialog();

    final success = await bookingProvider.createBookingWithPayment(
      userId: authProvider.currentUser!.id,
      paymentMethod: _selectedPaymentMethod,
      specialRequests: _specialRequestsController.text.trim().isEmpty 
          ? null 
          : _specialRequestsController.text.trim(),
    );

    // Close processing dialog
    if (mounted) Navigator.of(context).pop();

    if (success) {
      // Navigate to completion screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BookingCompletionScreen(
            booking: bookingProvider.currentBooking!,
            workshop: widget.workshop,
            timeSlot: widget.timeSlot,
          ),
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.errorMessage ?? '결제 처리 중 오류가 발생했습니다'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Show payment processing dialog
  void _showPaymentProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LoadingWidget(),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              '결제를 처리하고 있습니다...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              '잠시만 기다려주세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get payment method icon
  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.kakaoPayment:
        return Icons.chat;
      case PaymentMethod.naverPayment:
        return Icons.shopping_bag;
      case PaymentMethod.paypal:
        return Icons.payment;
    }
  }

  /// Get payment method name
  String _getPaymentMethodName(PaymentMethod method) {
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

  /// Format date
  String _formatDate(DateTime date) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.month}월 ${date.day}일 ($weekday)';
  }

  /// Format price
  String _formatPrice(double price) {
    return '${price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}원';
  }

  /// Show payment help dialog
  void _showPaymentHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('결제 도움말'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• 결제는 안전하게 암호화되어 처리됩니다'),
            SizedBox(height: AppTheme.spacingSm),
            Text('• 결제 완료 후 즉시 예약이 확정됩니다'),
            SizedBox(height: AppTheme.spacingSm),
            Text('• 취소는 시작 24시간 전까지 가능합니다'),
            SizedBox(height: AppTheme.spacingSm),
            Text('• 결제 영수증은 이메일로 발송됩니다'),
            SizedBox(height: AppTheme.spacingSm),
            Text('• 문의사항은 고객센터로 연락해주세요'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// Show terms dialog
  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이용약관'),
        content: const SingleChildScrollView(
          child: Text(
            '워크샵 예약 서비스 이용약관\n\n'
            '제1조 (목적)\n'
            '본 약관은 워크샵 예약 서비스의 이용조건 및 절차에 관한 사항을 규정함을 목적으로 합니다.\n\n'
            '제2조 (예약 및 결제)\n'
            '1. 예약은 결제 완료 시점에 확정됩니다.\n'
            '2. 결제는 신용카드, 계좌이체 등의 방법으로 가능합니다.\n\n'
            '제3조 (취소 및 환불)\n'
            '1. 취소는 워크샵 시작 24시간 전까지 가능합니다.\n'
            '2. 환불은 취소 정책에 따라 처리됩니다.\n\n'
            '제4조 (기타)\n'
            '본 약관에 명시되지 않은 사항은 관련 법령에 따릅니다.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// Show privacy dialog
  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개인정보 처리방침'),
        content: const SingleChildScrollView(
          child: Text(
            '개인정보 처리방침\n\n'
            '1. 개인정보의 처리 목적\n'
            '워크샵 예약 서비스 제공, 결제 처리, 고객 지원\n\n'
            '2. 처리하는 개인정보 항목\n'
            '이름, 이메일, 전화번호, 결제 정보\n\n'
            '3. 개인정보의 보유 및 이용기간\n'
            '서비스 이용 종료 후 5년간 보관\n\n'
            '4. 개인정보의 제3자 제공\n'
            '원칙적으로 제공하지 않으며, 법령에 의한 경우에만 제공\n\n'
            '5. 개인정보 처리의 위탁\n'
            '결제 처리를 위해 결제대행업체에 위탁\n\n'
            '6. 정보주체의 권리\n'
            '개인정보 열람, 정정, 삭제, 처리정지 요구 가능',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}