import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/main/main_screen.dart';
import '../widgets/common/loading_widget.dart';

/// App router that handles navigation based on authentication state
/// 
/// Automatically redirects users to appropriate screens based on their
/// authentication status and role
class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading while checking authentication state
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: LoadingWidget(),
            ),
          );
        }

        // Navigate to main screen if authenticated
        if (authProvider.isAuthenticated) {
          return const MainScreen();
        }

        // Navigate to login screen if not authenticated
        return const LoginScreen();
      },
    );
  }
}