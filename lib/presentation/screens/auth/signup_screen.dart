import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../theme/app_theme.dart';
import '../../../domain/entities/user.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isFormValid = false;
  bool _acceptTerms = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _nameController.text.isNotEmpty && 
                   _emailController.text.isNotEmpty &&
                   _passwordController.text.isNotEmpty &&
                   _confirmPasswordController.text.isNotEmpty &&
                   _acceptTerms;
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    
    if (value.length < 6) {
      return '비밀번호는 6글자 이상이어야 합니다';
    }
    
    if (value.length > 128) {
      return '비밀번호는 128글자 이하여야 합니다';
    }
    
    // Check for at least one letter and one number
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
      return '비밀번호는 영문자와 숫자를 포함해야 합니다';
    }
    
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호 확인을 입력해주세요';
    }
    
    if (value != _passwordController.text) {
      return '비밀번호가 일치하지 않습니다';
    }
    
    return null;
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      AppSnackBar.showError(
        context: context, 
        message: '이용약관에 동의해주세요',
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      // Show success message
      AppSnackBar.showSuccess(
        context: context, 
        message: '회원가입이 완료되었습니다',
      );
      
      // Navigate to main screen - this will be handled by the main app routing
      Navigator.of(context).pushReplacementNamed('/home');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: _buildSignUpForm(),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(AppTheme.spacingXl),
          child: _buildSignUpForm(),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: SingleChildScrollView(
        child: Card(
          elevation: AppTheme.elevationMd,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(AppTheme.spacingXl),
            child: _buildSignUpForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Text
              Text(
                '새 계정 만들기',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              
              Text(
                '워크샵 예약 서비스에 가입하세요',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingXl),

              // Name Field
              AppTextField(
                label: '이름',
                hint: '실명을 입력하세요',
                controller: _nameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                validator: User.validateName,
                prefixIcon: const Icon(Icons.person_outlined),
                enabled: !authProvider.isLoading,
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Email Field
              AppTextField(
                label: '이메일',
                hint: 'example@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: User.validateEmail,
                prefixIcon: const Icon(Icons.email_outlined),
                enabled: !authProvider.isLoading,
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Password Field
              AppTextField(
                label: '비밀번호',
                hint: '영문자와 숫자 포함 6글자 이상',
                controller: _passwordController,
                obscureText: true,
                textInputAction: TextInputAction.next,
                validator: _validatePassword,
                prefixIcon: const Icon(Icons.lock_outlined),
                enabled: !authProvider.isLoading,
                helperText: '영문자와 숫자를 포함하여 6글자 이상 입력하세요',
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Confirm Password Field
              AppTextField(
                label: '비밀번호 확인',
                hint: '비밀번호를 다시 입력하세요',
                controller: _confirmPasswordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _isFormValid ? _handleSignUp() : null,
                validator: _validateConfirmPassword,
                prefixIcon: const Icon(Icons.lock_outlined),
                enabled: !authProvider.isLoading,
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // Terms and Conditions Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: authProvider.isLoading ? null : (value) {
                      setState(() {
                        _acceptTerms = value ?? false;
                        _validateForm();
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: authProvider.isLoading ? null : () {
                        setState(() {
                          _acceptTerms = !_acceptTerms;
                          _validateForm();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppTheme.spacingMd),
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            children: [
                              const TextSpan(text: ''),
                              TextSpan(
                                text: '이용약관',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(text: ' 및 '),
                              TextSpan(
                                text: '개인정보처리방침',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(text: '에 동의합니다'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // Sign Up Button
              AppButton(
                text: '회원가입',
                onPressed: _isFormValid && !authProvider.isLoading ? _handleSignUp : null,
                isLoading: authProvider.isLoading,
                isExpanded: true,
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '이미 계정이 있으신가요? ',
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
                      '로그인',
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
      },
    );
  }
}