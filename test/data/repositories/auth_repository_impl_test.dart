import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:workshop_booking_system/domain/entities/user.dart';
import 'package:workshop_booking_system/data/repositories/auth_repository_impl.dart';
import 'package:workshop_booking_system/data/services/firebase_auth_service.dart';
import 'package:workshop_booking_system/core/error/result.dart';
import 'package:workshop_booking_system/core/error/exceptions.dart';

import 'auth_repository_impl_test.mocks.dart';

@GenerateMocks([FirebaseAuthService])
void main() {
  group('AuthRepositoryImpl Tests', () {
    late AuthRepositoryImpl repository;
    late MockFirebaseAuthService mockAuthService;
    late User testUser;

    setUp(() {
      mockAuthService = MockFirebaseAuthService();
      repository = AuthRepositoryImpl(authService: mockAuthService);
      testUser = User(
        id: 'user123',
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.user,
        createdAt: DateTime(2024, 1, 1),
      );
    });

    group('getCurrentUser', () {
      test('should return user when service returns user', () async {
        // Arrange
        when(mockAuthService.getCurrentUser())
            .thenAnswer((_) async => testUser);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, equals(testUser));
        verify(mockAuthService.getCurrentUser()).called(1);
      });

      test('should return null when service returns null', () async {
        // Arrange
        when(mockAuthService.getCurrentUser())
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isNull);
        verify(mockAuthService.getCurrentUser()).called(1);
      });
    });

    group('signIn', () {
      test('should return Success when service succeeds', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        
        when(mockAuthService.signIn(email, password))
            .thenAnswer((_) async => Success(testUser));

        // Act
        final result = await repository.signIn(email, password);

        // Assert
        expect(result, isA<Success<User>>());
        expect((result as Success<User>).data, equals(testUser));
        verify(mockAuthService.signIn(email, password)).called(1);
      });

      test('should return Failure when service fails', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrongpassword';
        final authException = AuthException('잘못된 자격증명입니다');
        
        when(mockAuthService.signIn(email, password))
            .thenAnswer((_) async => Failure(authException));

        // Act
        final result = await repository.signIn(email, password);

        // Assert
        expect(result, isA<Failure<User>>());
        expect((result as Failure<User>).exception, equals(authException));
        verify(mockAuthService.signIn(email, password)).called(1);
      });
    });

    group('signUp', () {
      test('should return Success when service succeeds', () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'password123';
        const name = 'New User';
        
        when(mockAuthService.signUp(email, password, name))
            .thenAnswer((_) async => Success(testUser));

        // Act
        final result = await repository.signUp(email, password, name);

        // Assert
        expect(result, isA<Success<User>>());
        expect((result as Success<User>).data, equals(testUser));
        verify(mockAuthService.signUp(email, password, name)).called(1);
      });

      test('should return Failure when service fails', () async {
        // Arrange
        const email = 'existing@example.com';
        const password = 'password123';
        const name = 'Existing User';
        final authException = AuthException('이미 존재하는 이메일입니다');
        
        when(mockAuthService.signUp(email, password, name))
            .thenAnswer((_) async => Failure(authException));

        // Act
        final result = await repository.signUp(email, password, name);

        // Assert
        expect(result, isA<Failure<User>>());
        expect((result as Failure<User>).exception, equals(authException));
        verify(mockAuthService.signUp(email, password, name)).called(1);
      });
    });

    group('signOut', () {
      test('should return Success when service succeeds', () async {
        // Arrange
        when(mockAuthService.signOut())
            .thenAnswer((_) async => Success(null));

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result, isA<Success<void>>());
        verify(mockAuthService.signOut()).called(1);
      });

      test('should return Failure when service fails', () async {
        // Arrange
        final authException = AuthException('로그아웃 실패');
        
        when(mockAuthService.signOut())
            .thenAnswer((_) async => Failure(authException));

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result, isA<Failure<void>>());
        expect((result as Failure<void>).exception, equals(authException));
        verify(mockAuthService.signOut()).called(1);
      });
    });

    group('sendPasswordResetEmail', () {
      test('should return Success when service succeeds', () async {
        // Arrange
        const email = 'test@example.com';
        
        when(mockAuthService.sendPasswordResetEmail(email))
            .thenAnswer((_) async => Success(null));

        // Act
        final result = await repository.sendPasswordResetEmail(email);

        // Assert
        expect(result, isA<Success<void>>());
        verify(mockAuthService.sendPasswordResetEmail(email)).called(1);
      });

      test('should return Failure when service fails', () async {
        // Arrange
        const email = 'nonexistent@example.com';
        final authException = AuthException('사용자를 찾을 수 없습니다');
        
        when(mockAuthService.sendPasswordResetEmail(email))
            .thenAnswer((_) async => Failure(authException));

        // Act
        final result = await repository.sendPasswordResetEmail(email);

        // Assert
        expect(result, isA<Failure<void>>());
        expect((result as Failure<void>).exception, equals(authException));
        verify(mockAuthService.sendPasswordResetEmail(email)).called(1);
      });
    });

    group('updateProfile', () {
      test('should return Success when service succeeds', () async {
        // Arrange
        final updatedUser = testUser.copyWith(name: 'Updated Name');
        
        when(mockAuthService.updateProfile(testUser))
            .thenAnswer((_) async => Success(updatedUser));

        // Act
        final result = await repository.updateProfile(testUser);

        // Assert
        expect(result, isA<Success<User>>());
        expect((result as Success<User>).data, equals(updatedUser));
        verify(mockAuthService.updateProfile(testUser)).called(1);
      });

      test('should return Failure when service fails', () async {
        // Arrange
        final authException = AuthException('프로필 업데이트 실패');
        
        when(mockAuthService.updateProfile(testUser))
            .thenAnswer((_) async => Failure(authException));

        // Act
        final result = await repository.updateProfile(testUser);

        // Assert
        expect(result, isA<Failure<User>>());
        expect((result as Failure<User>).exception, equals(authException));
        verify(mockAuthService.updateProfile(testUser)).called(1);
      });
    });

    group('deleteAccount', () {
      test('should return Success when service succeeds', () async {
        // Arrange
        when(mockAuthService.deleteAccount())
            .thenAnswer((_) async => Success(null));

        // Act
        final result = await repository.deleteAccount();

        // Assert
        expect(result, isA<Success<void>>());
        verify(mockAuthService.deleteAccount()).called(1);
      });

      test('should return Failure when service fails', () async {
        // Arrange
        final authException = AuthException('계정 삭제 실패');
        
        when(mockAuthService.deleteAccount())
            .thenAnswer((_) async => Failure(authException));

        // Act
        final result = await repository.deleteAccount();

        // Assert
        expect(result, isA<Failure<void>>());
        expect((result as Failure<void>).exception, equals(authException));
        verify(mockAuthService.deleteAccount()).called(1);
      });
    });

    group('getAllUsers', () {
      test('should return Success with user list when service succeeds', () async {
        // Arrange
        final userList = [testUser];
        
        when(mockAuthService.getAllUsers())
            .thenAnswer((_) async => Success(userList));

        // Act
        final result = await repository.getAllUsers();

        // Assert
        expect(result, isA<Success<List<User>>>());
        expect((result as Success<List<User>>).data, equals(userList));
        verify(mockAuthService.getAllUsers()).called(1);
      });

      test('should return Failure when service fails', () async {
        // Arrange
        final authException = AuthException('사용자 목록 조회 실패');
        
        when(mockAuthService.getAllUsers())
            .thenAnswer((_) async => Failure(authException));

        // Act
        final result = await repository.getAllUsers();

        // Assert
        expect(result, isA<Failure<List<User>>>());
        expect((result as Failure<List<User>>).exception, equals(authException));
        verify(mockAuthService.getAllUsers()).called(1);
      });
    });

    group('updateUserRole', () {
      test('should return Success when service succeeds', () async {
        // Arrange
        const userId = 'user123';
        const newRole = UserRole.admin;
        final updatedUser = testUser.copyWith(role: newRole);
        
        when(mockAuthService.updateUserRole(userId, newRole))
            .thenAnswer((_) async => Success(updatedUser));

        // Act
        final result = await repository.updateUserRole(userId, newRole);

        // Assert
        expect(result, isA<Success<User>>());
        expect((result as Success<User>).data, equals(updatedUser));
        verify(mockAuthService.updateUserRole(userId, newRole)).called(1);
      });

      test('should return Failure when service fails', () async {
        // Arrange
        const userId = 'user123';
        const newRole = UserRole.admin;
        final authException = AuthException('권한 업데이트 실패');
        
        when(mockAuthService.updateUserRole(userId, newRole))
            .thenAnswer((_) async => Failure(authException));

        // Act
        final result = await repository.updateUserRole(userId, newRole);

        // Assert
        expect(result, isA<Failure<User>>());
        expect((result as Failure<User>).exception, equals(authException));
        verify(mockAuthService.updateUserRole(userId, newRole)).called(1);
      });
    });

    group('authStateChanges', () {
      test('should return stream from service', () {
        // Arrange
        final userStream = Stream.value(testUser);
        when(mockAuthService.authStateChanges).thenAnswer((_) => userStream);

        // Act
        final result = repository.authStateChanges;

        // Assert
        expect(result, equals(userStream));
        verify(mockAuthService.authStateChanges).called(1);
      });

      test('should handle null user in stream', () {
        // Arrange
        final userStream = Stream.value(null);
        when(mockAuthService.authStateChanges).thenAnswer((_) => userStream);

        // Act
        final result = repository.authStateChanges;

        // Assert
        expect(result, equals(userStream));
        verify(mockAuthService.authStateChanges).called(1);
      });
    });
  });
}