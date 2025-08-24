import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../theme/app_theme.dart';
import '../../../domain/entities/user.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _isFormValid = false;
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _emailController.text.isNotEmpty;
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  Future<void> _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendPasswordResetEmail(
      _emailController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _emailSent = true;
      });
      AppSnackBar.showSuccess(
        context: context, 
        message: '비밀번호 재설정 이메일이 발송되었습니다. 이메일을 확인해주세요.',
      );
    } else {
      // Show error message
      if (authProvider.errorMessage != null) {
        AppSnackBar.showError(
          context: context, 
          message: authProvider.errorMessage!,
        );
      }
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pop();
  }

  void _resendEmail() {
    setState(() {
      _emailSent = false;
    });
    _handlePasswordReset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비밀번호 재설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToLogin,
        ),
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: _buildPasswordResetForm(),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: _buildPasswordResetForm(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Card(
        elevation: AppTheme.elevationMd,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(AppTheme.spacingXl),
          child: _buildPasswordResetForm(),
        ),
      ),
    );
  }

  Widget _buildPasswordResetForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (_emailSent) {
          return _buildEmailSentView(authProvider);
        }
        
        return _buildEmailInputView(authProvider);
      },
    );
  }

  Widget _buildEmailInputView(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Icon(
            Icons.lock_reset,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          
          // Title
          Text(
            '비밀번호를 잊으셨나요?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          
          // Description
          Text(
            '가입하신 이메일 주소를 입력하시면\n비밀번호 재설정 링크를 보내드립니다.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXl),

          // Email Field
          AppTextField(
            label: '이메일',
            hint: 'example@email.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _isFormValid ? _handlePasswordReset() : null,
            validator: User.validateEmail,
            prefixIcon: const Icon(Icons.email_outlined),
            enabled: !authProvider.isLoading,
            autofocus: true,
          ),
          const SizedBox(height: AppTheme.spacingXl),

          // Send Reset Email Button
          AppButton(
            text: '재설정 이메일 보내기',
            onPressed: _isFormValid && !authProvider.isLoading ? _handlePasswordReset : null,
            isLoading: authProvider.isLoading,
            isExpanded: true,
            icon: Icons.send,
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // Back to Login Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '로그인 화면으로 ',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: authProvider.isLoading ? null : _navigateToLogin,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '돌아가기',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSentView(AuthProvider authProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read,
            size: 40,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        
        // Success Title
        Text(
          '이메일이 발송되었습니다!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        
        // Success Description
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            children: [
              const TextSpan(text: ''),
              TextSpan(
                text: _emailController.text.trim(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const TextSpan(
                text: ' 주소로 비밀번호 재설정 링크를 보냈습니다.\n\n이메일을 확인하고 링크를 클릭하여 새 비밀번호를 설정하세요.',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingXl),

        // Instructions Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Text(
                      '안내사항',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  '• 이메일이 도착하지 않았다면 스팸 폴더를 확인해주세요\n• 링크는 24시간 동안 유효합니다\n• 이메일을 받지 못했다면 아래 버튼을 눌러 다시 발송하세요',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingXl),

        // Resend Email Button
        AppButton(
          text: '이메일 다시 보내기',
          type: AppButtonType.outlined,
          onPressed: authProvider.isLoading ? null : _resendEmail,
          isLoading: authProvider.isLoading,
          isExpanded: true,
          icon: Icons.refresh,
        ),
        const SizedBox(height: AppTheme.spacingMd),

        // Back to Login Button
        AppButton(
          text: '로그인 화면으로 돌아가기',
          type: AppButtonType.text,
          onPressed: authProvider.isLoading ? null : _navigateToLogin,
          isExpanded: true,
        ),
      ],
    );
  }
}