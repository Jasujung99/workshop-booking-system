import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../theme/app_theme.dart';
import '../../../domain/entities/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _emailController.text.isNotEmpty && 
                   _passwordController.text.isNotEmpty;
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
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

  void _navigateToSignUp() {
    Navigator.of(context).pushNamed('/signup');
  }

  void _navigateToPasswordReset() {
    Navigator.of(context).pushNamed('/password-reset');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: _buildLoginForm(),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: _buildLoginForm(),
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
          child: _buildLoginForm(),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo or App Title
              Icon(
                Icons.event_available,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              
              Text(
                '워크샵 예약',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              
              Text(
                '계정에 로그인하세요',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                textInputAction: TextInputAction.next,
                validator: User.validateEmail,
                prefixIcon: const Icon(Icons.email_outlined),
                enabled: !authProvider.isLoading,
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Password Field
              AppTextField(
                label: '비밀번호',
                hint: '비밀번호를 입력하세요',
                controller: _passwordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _isFormValid ? _handleLogin() : null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요';
                  }
                  return null;
                },
                prefixIcon: const Icon(Icons.lock_outlined),
                enabled: !authProvider.isLoading,
              ),
              const SizedBox(height: AppTheme.spacingSm),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: authProvider.isLoading ? null : _navigateToPasswordReset,
                  child: Text(
                    '비밀번호를 잊으셨나요?',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // Login Button
              AppButton(
                text: '로그인',
                onPressed: _isFormValid && !authProvider.isLoading ? _handleLogin : null,
                isLoading: authProvider.isLoading,
                isExpanded: true,
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                    child: Text(
                      '또는',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
                ],
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '계정이 없으신가요? ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton(
                    onPressed: authProvider.isLoading ? null : _navigateToSignUp,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '회원가입',
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