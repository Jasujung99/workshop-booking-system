import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_booking_system/domain/entities/user.dart';
import 'package:workshop_booking_system/domain/repositories/auth_repository.dart';
import 'package:workshop_booking_system/domain/usecases/auth/sign_in_use_case.dart';
import 'package:workshop_booking_system/domain/usecases/auth/sign_up_use_case.dart';
import 'package:workshop_booking_system/domain/usecases/auth/sign_out_use_case.dart';
import 'package:workshop_booking_system/presentation/providers/auth_provider.dart';
import 'package:workshop_booking_system/core/error/result.dart';
import 'package:workshop_booking_system/core/error/exceptions.dart';

// Simple fake implementations for testing
class FakeAuthRepository implements AuthRepository {
  User? _currentUser;
  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();

  void setCurrentUser(User? user) {
    _currentUser = user;
    _authStateController.add(user);
  }

  @override
  Future<User?> getCurrentUser() async => _currentUser;

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  @override
  Future<Result<User>> signIn(String email, String password) async {
    if (email == 'test@example.com' && password == 'password123') {
      final user = User(
        id: 'user123',
        email: email,
        name: 'Test User',
        role: UserRole.user,
        createdAt: DateTime.now(),
      );
      setCurrentUser(user);
      return Success(user);
    }
    return Failure(AuthException('Invalid credentials'));
  }

  @override
  Future<Result<User>> signUp(String email, String password, String name) async {
    final user = User(
      id: 'user123',
      email: email,
      name: name,
      role: UserRole.user,
      createdAt: DateTime.now(),
    );
    setCurrentUser(user);
    return Success(user);
  }

  @override
  Future<Result<void>> signOut() async {
    setCurrentUser(null);
    return Success(null);
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    return Success(null);
  }

  @override
  Future<Result<User>> updateProfile(User user) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteAccount() async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<User>>> getAllUsers() async {
    throw UnimplementedError();
  }

  @override
  Future<Result<User>> updateUserRole(String userId, UserRole role) async {
    throw UnimplementedError();
  }

  void dispose() {
    _authStateController.close();
  }
}

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;
    late FakeAuthRepository fakeRepository;
    late SignInUseCase signInUseCase;
    late SignUpUseCase signUpUseCase;
    late SignOutUseCase signOutUseCase;

    setUp(() {
      fakeRepository = FakeAuthRepository();
      signInUseCase = SignInUseCase(fakeRepository);
      signUpUseCase = SignUpUseCase(fakeRepository);
      signOutUseCase = SignOutUseCase(fakeRepository);
      
      authProvider = AuthProvider(
        authRepository: fakeRepository,
        signInUseCase: signInUseCase,
        signUpUseCase: signUpUseCase,
        signOutUseCase: signOutUseCase,
      );
    });

    tearDown(() {
      fakeRepository.dispose();
      authProvider.dispose();
    });

    group('Initial State', () {
      test('should have correct initial state', () {
        expect(authProvider.currentUser, isNull);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.errorMessage, isNull);
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.isAdmin, isFalse);
        expect(authProvider.isUser, isFalse);
      });
    });

    group('Authentication State', () {
      test('should update state when user signs in', () async {
        // Arrange
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.user,
          createdAt: DateTime.now(),
        );

        // Act
        fakeRepository.setCurrentUser(user);
        await Future.delayed(Duration(milliseconds: 10)); // Allow stream to emit

        // Assert
        expect(authProvider.currentUser, equals(user));
        expect(authProvider.isAuthenticated, isTrue);
        expect(authProvider.isUser, isTrue);
        expect(authProvider.isAdmin, isFalse);
      });

      test('should update state when admin user signs in', () async {
        // Arrange
        final adminUser = User(
          id: 'admin123',
          email: 'admin@example.com',
          name: 'Admin User',
          role: UserRole.admin,
          createdAt: DateTime.now(),
        );

        // Act
        fakeRepository.setCurrentUser(adminUser);
        await Future.delayed(Duration(milliseconds: 10)); // Allow stream to emit

        // Assert
        expect(authProvider.currentUser, equals(adminUser));
        expect(authProvider.isAuthenticated, isTrue);
        expect(authProvider.isUser, isFalse);
        expect(authProvider.isAdmin, isTrue);
      });

      test('should update state when user signs out', () async {
        // Arrange - first sign in a user
        final user = User(
          id: 'user123',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.user,
          createdAt: DateTime.now(),
        );
        fakeRepository.setCurrentUser(user);
        await Future.delayed(Duration(milliseconds: 10));

        // Act - sign out
        fakeRepository.setCurrentUser(null);
        await Future.delayed(Duration(milliseconds: 10));

        // Assert
        expect(authProvider.currentUser, isNull);
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.isUser, isFalse);
        expect(authProvider.isAdmin, isFalse);
      });
    });

    group('Sign In', () {
      test('should successfully sign in with valid credentials', () async {
        // Act
        await authProvider.signIn('test@example.com', 'password123');

        // Assert
        expect(authProvider.currentUser, isNotNull);
        expect(authProvider.currentUser!.email, 'test@example.com');
        expect(authProvider.isAuthenticated, isTrue);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.errorMessage, isNull);
      });

      test('should fail to sign in with invalid credentials', () async {
        // Act
        await authProvider.signIn('wrong@example.com', 'wrongpassword');

        // Assert
        expect(authProvider.currentUser, isNull);
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.errorMessage, isNotNull);
      });

      test('should set loading state during sign in', () async {
        // Arrange
        bool wasLoading = false;
        authProvider.addListener(() {
          if (authProvider.isLoading) {
            wasLoading = true;
          }
        });

        // Act
        await authProvider.signIn('test@example.com', 'password123');

        // Assert
        expect(wasLoading, isTrue);
        expect(authProvider.isLoading, isFalse); // Should be false after completion
      });
    });

    group('Sign Up', () {
      test('should successfully sign up new user', () async {
        // Act
        await authProvider.signUp('new@example.com', 'password123', 'New User');

        // Assert
        expect(authProvider.currentUser, isNotNull);
        expect(authProvider.currentUser!.email, 'new@example.com');
        expect(authProvider.currentUser!.name, 'New User');
        expect(authProvider.isAuthenticated, isTrue);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.errorMessage, isNull);
      });
    });

    group('Sign Out', () {
      test('should successfully sign out user', () async {
        // Arrange - first sign in
        await authProvider.signIn('test@example.com', 'password123');
        expect(authProvider.isAuthenticated, isTrue);

        // Act
        await authProvider.signOut();

        // Assert
        expect(authProvider.currentUser, isNull);
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.errorMessage, isNull);
      });
    });

    group('Error Handling', () {
      test('should clear error message on successful operation', () async {
        // Arrange - cause an error first
        await authProvider.signIn('wrong@example.com', 'wrongpassword');
        expect(authProvider.errorMessage, isNotNull);

        // Act - perform successful operation
        await authProvider.signIn('test@example.com', 'password123');

        // Assert
        expect(authProvider.errorMessage, isNull);
      });

      test('should handle validation errors', () async {
        // Act - try to sign in with empty email
        await authProvider.signIn('', 'password123');

        // Assert
        expect(authProvider.errorMessage, isNotNull);
        expect(authProvider.isAuthenticated, isFalse);
      });
    });

    group('Notifications', () {
      test('should notify listeners when state changes', () async {
        // Arrange
        int notificationCount = 0;
        authProvider.addListener(() {
          notificationCount++;
        });

        // Act
        await authProvider.signIn('test@example.com', 'password123');

        // Assert
        expect(notificationCount, greaterThan(0));
      });
    });
  });
}