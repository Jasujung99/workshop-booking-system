import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:workshop_booking_system/domain/entities/user.dart';
import 'package:workshop_booking_system/domain/repositories/auth_repository.dart';
import 'package:workshop_booking_system/domain/usecases/auth/sign_in_use_case.dart';
import 'package:workshop_booking_system/core/error/result.dart';
import 'package:workshop_booking_system/core/error/exceptions.dart';



// Create a simple mock implementation
class MockAuthRepository extends Mock implements AuthRepository {
  @override
  Future<Result<User>> signIn(String email, String password) =>
      super.noSuchMethod(
        Invocation.method(#signIn, [email, password]),
        returnValue: Future.value(Failure(UnknownException('dummy'))),
      );

  @override
  Future<User?> getCurrentUser() =>
      super.noSuchMethod(
        Invocation.method(#getCurrentUser, []),
        returnValue: Future.value(null),
      );

  @override
  Stream<User?> get authStateChanges =>
      super.noSuchMethod(
        Invocation.getter(#authStateChanges),
        returnValue: Stream.value(null),
      );

  @override
  Future<Result<User>> signUp(String email, String password, String name) =>
      super.noSuchMethod(
        Invocation.method(#signUp, [email, password, name]),
        returnValue: Future.value(Failure(UnknownException('dummy'))),
      );

  @override
  Future<Result<void>> signOut() =>
      super.noSuchMethod(
        Invocation.method(#signOut, []),
        returnValue: Future.value(Failure(UnknownException('dummy'))),
      );

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) =>
      super.noSuchMethod(
        Invocation.method(#sendPasswordResetEmail, [email]),
        returnValue: Future.value(Failure(UnknownException('dummy'))),
      );

  @override
  Future<Result<User>> updateProfile(User user) =>
      super.noSuchMethod(
        Invocation.method(#updateProfile, [user]),
        returnValue: Future.value(Failure(UnknownException('dummy'))),
      );

  @override
  Future<Result<void>> deleteAccount() =>
      super.noSuchMethod(
        Invocation.method(#deleteAccount, []),
        returnValue: Future.value(Failure(UnknownException('dummy'))),
      );

  @override
  Future<Result<List<User>>> getAllUsers() =>
      super.noSuchMethod(
        Invocation.method(#getAllUsers, []),
        returnValue: Future.value(Failure(UnknownException('dummy'))),
      );

  @override
  Future<Result<User>> updateUserRole(String userId, UserRole role) =>
      super.noSuchMethod(
        Invocation.method(#updateUserRole, [userId, role]),
        returnValue: Future.value(Failure(UnknownException('dummy'))),
      );
}

void main() {
  group('SignInUseCase Tests', () {
    late SignInUseCase useCase;
    late MockAuthRepository mockAuthRepository;
    late User testUser;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      useCase = SignInUseCase(mockAuthRepository);
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
        const email = 'test@example.com';
        const password = 'password123';
        
        when(mockAuthRepository.signIn(email, password))
            .thenAnswer((_) async => Success(testUser));

        // Act
        final result = await useCase.execute(email, password);

        // Assert
        expect(result, isA<Success<User>>());
        expect((result as Success<User>).data, equals(testUser));
        verify(mockAuthRepository.signIn(email, password)).called(1);
      });

      test('should trim and lowercase email before calling repository', () async {
        // Arrange
        const email = '  TEST@EXAMPLE.COM  ';
        const password = 'password123';
        const expectedEmail = 'test@example.com';
        
        when(mockAuthRepository.signIn(expectedEmail, password))
            .thenAnswer((_) async => Success(testUser));

        // Act
        final result = await useCase.execute(email, password);

        // Assert
        expect(result, isA<Success<User>>());
        verify(mockAuthRepository.signIn(expectedEmail, password)).called(1);
      });
    });

    group('Email Validation', () {
      test('should return Failure when email is null', () async {
        // Act
        final result = await useCase.execute('', 'password123');

        // Assert
        expect(result, isA<Failure<User>>());
        expect((result as Failure<User>).exception, isA<ValidationException>());
        expect(result.exception.message, '이메일을 입력해주세요');
        verifyNever(mockAuthRepository.signIn(any, any));
      });

      test('should return Failure when email is empty', () async {
        // Act
        final result = await useCase.execute('', 'password123');

        // Assert
        expect(result, isA<Failure<User>>());
        expect((result as Failure<User>).exception, isA<ValidationException>());
        expect(result.exception.message, '이메일을 입력해주세요');
        verifyNever(mockAuthRepository.signIn(any, any));
      });

      test('should return Failure when email format is invalid', () async {
        // Act
        final result = await useCase.execute('invalid-email', 'password123');

        // Assert
        expect(result, isA<Failure<User>>());
        expect((result as Failure<User>).exception, isA<ValidationException>());
        expect(result.exception.message, '올바른 이메일 형식을 입력해주세요');
        verifyNever(mockAuthRepository.signIn(any, any));
      });
    });

    group('Password Validation', () {
      test('should return Failure when password is null', () async {
        // Act
        final result = await useCase.execute('test@example.com', '');

        // Assert
        expect(result, isA<Failure<User>>());
        expect((result as Failure<User>).exception, isA<ValidationException>());
        expect(result.exception.message, '비밀번호를 입력해주세요');
        verifyNever(mockAuthRepository.signIn(any, any));
      });

      test('should return Failure when password is empty', () async {
        // Act
        final result = await useCase.execute('test@example.com', '');

        // Assert
        expect(result, isA<Failure<User>>());
        expect((result as Failure<User>).exception, isA<ValidationException>());
        expect(result.exception.message, '비밀번호를 입력해주세요');
        verifyNever(mockAuthRepository.signIn(any, any));
      });

      test('should return Failure when password is too short', () async {
        // Act
        final result = await useCase.execute('test@example.com', '12345');

        // Assert
        expect(result, isA<Failure<User>>());
        expect((result as Failure<User>).exception, isA<ValidationException>());
        expect(result.exception.message, '비밀번호는 6글자 이상이어야 합니다');
        verifyNever(mockAuthRepository.signIn(any, any));
      });

      test('should accept password with minimum length', () async {
        // Arrange
        const email = 'test@example.com';
        const password = '123456'; // exactly 6 characters
        
        when(mockAuthRepository.signIn(email, password))
            .thenAnswer((_) async => Success(testUser));

        // Act
        final result = await useCase.execute(email, password);

        // Assert
        expect(result, isA<Success<User>>());
        verify(mockAuthRepository.signIn(email, password)).called(1);
      });
    });

    group('Repository Error Handling', () {
      test('should return Failure when repository returns failure', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        final authException = AuthException('잘못된 자격증명입니다');
        
        when(mockAuthRepository.signIn(email, password))
            .thenAnswer((_) async => Failure(authException));

        // Act
        final result = await useCase.execute(email, password);

        // Assert
        expect(result, isA<Failure<User>>());
        expect((result as Failure<User>).exception, equals(authException));
        verify(mockAuthRepository.signIn(email, password)).called(1);
      });

      test('should handle repository throwing exception', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        
        when(mockAuthRepository.signIn(email, password))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await useCase.execute(email, password);

        // Assert
        expect(result, isA<Failure<User>>());
        expect((result as Failure<User>).exception, isA<UnknownException>());
        expect(result.exception.message, contains('로그인 중 오류가 발생했습니다'));
        verify(mockAuthRepository.signIn(email, password)).called(1);
      });
    });

    group('Edge Cases', () {
      test('should handle special characters in email', () async {
        // Arrange
        const email = 'test+tag@example.com';
        const password = 'password123';
        
        when(mockAuthRepository.signIn(email, password))
            .thenAnswer((_) async => Success(testUser));

        // Act
        final result = await useCase.execute(email, password);

        // Assert
        expect(result, isA<Success<User>>());
        verify(mockAuthRepository.signIn(email, password)).called(1);
      });

      test('should handle long password', () async {
        // Arrange
        const email = 'test@example.com';
        final password = 'a' * 100; // very long password
        
        when(mockAuthRepository.signIn(email, password))
            .thenAnswer((_) async => Success(testUser));

        // Act
        final result = await useCase.execute(email, password);

        // Assert
        expect(result, isA<Success<User>>());
        verify(mockAuthRepository.signIn(email, password)).called(1);
      });
    });
  });
}