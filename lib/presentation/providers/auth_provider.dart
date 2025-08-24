import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/sign_in_use_case.dart';
import '../../domain/usecases/auth/sign_up_use_case.dart';
import '../../domain/usecases/auth/sign_out_use_case.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/error/result.dart';
import '../../core/error/exceptions.dart';

/// Provider for managing authentication state and operations
/// 
/// Handles user authentication state, login/logout operations,
/// and provides access to current user information and permissions
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;

  // State variables
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authStateSubscription;

  AuthProvider({
    required AuthRepository authRepository,
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
  })  : _authRepository = authRepository,
        _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase {
    _initializeAuthState();
  }

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isUser => _currentUser?.role == UserRole.user;

  /// Initialize authentication state by listening to auth changes
  void _initializeAuthState() {
    _authStateSubscription = _authRepository.authStateChanges.listen(
      (user) {
        _currentUser = user;
        _clearError();
        notifyListeners();
      },
      onError: (error) {
        _setError('인증 상태 확인 중 오류가 발생했습니다');
        notifyListeners();
      },
    );
  }

  /// Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _signInUseCase.execute(email, password);
      
      return result.fold(
        onSuccess: (user) {
          _currentUser = user;
          _setLoading(false);
          return true;
        },
        onFailure: (exception) {
          _setError(_getErrorMessage(exception));
          _setLoading(false);
          return false;
        },
      );
    } catch (e) {
      _setError('로그인 중 예상치 못한 오류가 발생했습니다');
      _setLoading(false);
      return false;
    }
  }

  /// Sign up with email, password, and name
  Future<bool> signUp(String email, String password, String name) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _signUpUseCase.execute(email, password, name);
      
      return result.fold(
        onSuccess: (user) {
          _currentUser = user;
          _setLoading(false);
          return true;
        },
        onFailure: (exception) {
          _setError(_getErrorMessage(exception));
          _setLoading(false);
          return false;
        },
      );
    } catch (e) {
      _setError('회원가입 중 예상치 못한 오류가 발생했습니다');
      _setLoading(false);
      return false;
    }
  }

  /// Sign out current user
  Future<bool> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _signOutUseCase.execute();
      
      return result.fold(
        onSuccess: (_) {
          _currentUser = null;
          _setLoading(false);
          return true;
        },
        onFailure: (exception) {
          _setError(_getErrorMessage(exception));
          _setLoading(false);
          return false;
        },
      );
    } catch (e) {
      _setError('로그아웃 중 예상치 못한 오류가 발생했습니다');
      _setLoading(false);
      return false;
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate email format first
      final emailError = User.validateEmail(email);
      if (emailError != null) {
        _setError(emailError);
        _setLoading(false);
        return false;
      }

      final result = await _authRepository.sendPasswordResetEmail(email.trim().toLowerCase());
      
      return result.fold(
        onSuccess: (_) {
          _setLoading(false);
          return true;
        },
        onFailure: (exception) {
          _setError(_getErrorMessage(exception));
          _setLoading(false);
          return false;
        },
      );
    } catch (e) {
      _setError('비밀번호 재설정 이메일 발송 중 오류가 발생했습니다');
      _setLoading(false);
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile(User updatedUser) async {
    if (_currentUser == null) {
      _setError('로그인이 필요합니다');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _authRepository.updateProfile(updatedUser);
      
      return result.fold(
        onSuccess: (user) {
          _currentUser = user;
          _setLoading(false);
          return true;
        },
        onFailure: (exception) {
          _setError(_getErrorMessage(exception));
          _setLoading(false);
          return false;
        },
      );
    } catch (e) {
      _setError('프로필 업데이트 중 오류가 발생했습니다');
      _setLoading(false);
      return false;
    }
  }

  /// Check if current user has admin permissions
  bool hasAdminPermission() {
    return isAuthenticated && isAdmin;
  }

  /// Check if current user can perform admin actions
  bool canPerformAdminAction() {
    return hasAdminPermission() && !isLoading;
  }

  /// Check if current user can access user features
  bool canAccessUserFeatures() {
    return isAuthenticated && !isLoading;
  }

  /// Refresh current user data
  Future<void> refreshUser() async {
    if (!isAuthenticated) return;

    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (e) {
      _setError('사용자 정보 새로고침 중 오류가 발생했습니다');
    }
  }

  /// Clear any existing error message
  void clearError() {
    _clearError();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Convert exception to user-friendly error message
  String _getErrorMessage(AppException exception) {
    switch (exception.runtimeType) {
      case AuthException:
        return exception.message;
      case ValidationException:
        return exception.message;
      case NetworkException:
        return '네트워크 연결을 확인해주세요';
      case ServerException:
        return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요';
      default:
        return exception.message.isNotEmpty 
            ? exception.message 
            : '알 수 없는 오류가 발생했습니다';
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}