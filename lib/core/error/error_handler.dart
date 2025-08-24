import 'package:flutter/material.dart';
import 'exceptions.dart';
import '../utils/logger.dart';

class ErrorHandler {
  static void handleError(AppException exception, {BuildContext? context}) {
    AppLogger.error(exception.message, exception: exception);
    
    if (context != null) {
      _showErrorSnackBar(context, exception);
    }
  }

  static void _showErrorSnackBar(BuildContext context, AppException exception) {
    final message = _getUserFriendlyMessage(exception);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static String _getUserFriendlyMessage(AppException exception) {
    return switch (exception) {
      AuthException authException => _getAuthErrorMessage(authException),
      NetworkException _ => 'Network error. Please check your connection and try again.',
      ValidationException _ => exception.message,
      BookingException _ => exception.message,
      PaymentException _ => 'Payment failed. Please try again or use a different payment method.',
      StorageException _ => 'File upload failed. Please try again.',
      _ => 'Something went wrong. Please try again.',
    };
  }

  static String _getAuthErrorMessage(AuthException exception) {
    switch (exception.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      default:
        return exception.message;
    }
  }
}