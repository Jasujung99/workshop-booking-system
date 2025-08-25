import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_booking_system/domain/entities/user.dart';
import 'package:workshop_booking_system/domain/repositories/auth_repository.dart';
import 'package:workshop_booking_system/domain/usecases/auth/sign_in_use_case.dart';
import 'package:workshop_booking_system/core/error/result.dart';
import 'package:workshop_booking_system/core/error/exceptions.dart';

// Simple fake repository for testing
class FakeAuthRepository implements AuthRepository {
  User? _currentUser;
  bool _shouldSucceed = true;
  String? _errorMessage;

  void setSuccessResponse(User user) {
    _currentUser = user;
    _shouldSucceed = true;
    _errorMessage = null;
  }

  void setErrorResponse(String error) {
    _shouldSucceed = false;
    _errorMessage = error;
  }

  @override
  Future<Result<User>> signIn(String email, String password) async {
    if (_shouldSucceed && _currentUser != null) {
      return Success(_currentUser!);
    }
    return Failure(AuthException(_errorMessage ?? 'Sign in failed'));
  }

  @override
  Future<User?> getCurrentUser() async => _currentUser;

  @override
  Stream<User?> get authStateChanges => Stream.value(_currentUser);

  @override
  Future<Result<User>> signUp(String email, String password, String name) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> signOut() async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    throw UnimplementedError();
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
}

void main() {
  group('SignInUseCase Tests', () {
    late SignInUseCase useCase;
    late FakeAuthRepository fakeRepository;
    late User testUser;

    setUp(() {
      fakeRepository = FakeAuthRepository();
      useCase = SignInUseCase(fakeRepository);
      testUser = User(
        id: 'user123',
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.user,
        createdAt: DateTime(2024, 1, 1),
      );
    });

    group('Successful Sign In', () {
      test('should return Success with user when credentials are valid', () async {
        // Arrange
        fakeRepository.setSuccessResponse(testUser);

        // Act
        final result = await useCase.execute('test@example.com', 'password123');

        // Assert
        expect(result, isA<Success<User>>());
        expect((result as Success<User>).data, equals(testUser));
      });
    });

    group('Email Validation', () {
      test('should return Failure when email is empty', () async {
        // Act
        final result = await useCase.execute('', 'password123');

        // Assert
        expect(result, isA<Failure<User>>());
        expect((result as Failure<User>).exception, isA<ValidationException>());
        expect(result.exception.message, '이메일을 입력해주세요');
      });

      test('should return Failure when email format is invalid', () async {
        // Act
        final result = await useCase.execute('invalid-email', 'password123');

        // Assert
        expect(result, isA<Failure<User>>());
        expect((result as Failure<User>).exception, isA<ValidationException>());
        expect(result.exception.message, '올바른 이메일 형식을 입력해주세요');
      });
    });

    group('Password Validation', () {
      test('should return Failure when password is empty', () async {
        // Act
        final result = await useCase.execute('test@example.com', '');

        // Assert
        expect(result, isA<Failure<User>>());
        expect((result as Failure<User>).exception, isA<ValidationException>());
        expect(result.exception.message, '비밀번호를 입력해주세요');
      });

      test('should return Failure when password is too short', () async {
        // Act
        final result = await useCase.execute('test@example.com', '12345');

        // Assert
        expect(result, isA<Failure<User>>());
        expect((result as Failure<User>).exception, isA<ValidationException>());
        expect(result.exception.message, '비밀번호는 6글자 이상이어야 합니다');
      });

      test('should accept password with minimum length', () async {
        // Arrange
        fakeRepository.setSuccessResponse(testUser);

        // Act
        final result = await useCase.execute('test@example.com', '123456');

        // Assert
        expect(result, isA<Success<User>>());
      });
    });

    group('Repository Error Handling', () {
      test('should return Failure when repository returns failure', () async {
        // Arrange
        fakeRepository.setErrorResponse('잘못된 자격증명입니다');

        // Act
        final result = await useCase.execute('test@example.com', 'password123');

        // Assert
        expect(result, isA<Failure<User>>());
        expect((result as Failure<User>).exception, isA<AuthException>());
        expect(result.exception.message, '잘못된 자격증명입니다');
      });
    });

    group('Edge Cases', () {
      test('should handle special characters in email', () async {
        // Arrange
        fakeRepository.setSuccessResponse(testUser);

        // Act
        final result = await useCase.execute('test+tag@example.com', 'password123');

        // Assert
        expect(result, isA<Success<User>>());
      });

      test('should handle long password', () async {
        // Arrange
        fakeRepository.setSuccessResponse(testUser);
        final longPassword = 'a' * 100;

        // Act
        final result = await useCase.execute('test@example.com', longPassword);

        // Assert
        expect(result, isA<Success<User>>());
      });
    });
  });
}