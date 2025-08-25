import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_booking_system/domain/entities/user.dart';

void main() {
  group('User Entity Tests', () {
    late User testUser;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 1);
      testUser = User(
        id: 'user123',
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.user,
        phoneNumber: '010-1234-5678',
        profileImageUrl: 'https://example.com/image.jpg',
        createdAt: testDate,
        updatedAt: testDate,
      );
    });

    group('Constructor and Properties', () {
      test('should create user with all properties', () {
        expect(testUser.id, 'user123');
        expect(testUser.email, 'test@example.com');
        expect(testUser.name, 'Test User');
        expect(testUser.role, UserRole.user);
        expect(testUser.phoneNumber, '010-1234-5678');
        expect(testUser.profileImageUrl, 'https://example.com/image.jpg');
        expect(testUser.createdAt, testDate);
        expect(testUser.updatedAt, testDate);
      });

      test('should create user with minimal required properties', () {
        final minimalUser = User(
          id: 'user456',
          email: 'minimal@example.com',
          name: 'Minimal User',
          role: UserRole.admin,
          createdAt: testDate,
        );

        expect(minimalUser.id, 'user456');
        expect(minimalUser.email, 'minimal@example.com');
        expect(minimalUser.name, 'Minimal User');
        expect(minimalUser.role, UserRole.admin);
        expect(minimalUser.phoneNumber, isNull);
        expect(minimalUser.profileImageUrl, isNull);
        expect(minimalUser.updatedAt, isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated properties', () {
        final updatedUser = testUser.copyWith(
          name: 'Updated Name',
          role: UserRole.admin,
        );

        expect(updatedUser.id, testUser.id);
        expect(updatedUser.email, testUser.email);
        expect(updatedUser.name, 'Updated Name');
        expect(updatedUser.role, UserRole.admin);
        expect(updatedUser.phoneNumber, testUser.phoneNumber);
        expect(updatedUser.profileImageUrl, testUser.profileImageUrl);
        expect(updatedUser.createdAt, testUser.createdAt);
        expect(updatedUser.updatedAt, testUser.updatedAt);
      });

      test('should create identical copy when no parameters provided', () {
        final copiedUser = testUser.copyWith();

        expect(copiedUser, equals(testUser));
        expect(copiedUser.hashCode, equals(testUser.hashCode));
      });
    });

    group('Email Validation', () {
      test('should return null for valid email', () {
        expect(User.validateEmail('test@example.com'), isNull);
        expect(User.validateEmail('user.name@domain.co.kr'), isNull);
        expect(User.validateEmail('123@test.org'), isNull);
      });

      test('should return error for null or empty email', () {
        expect(User.validateEmail(null), '이메일을 입력해주세요');
        expect(User.validateEmail(''), '이메일을 입력해주세요');
      });

      test('should return error for invalid email format', () {
        expect(User.validateEmail('invalid-email'), '올바른 이메일 형식을 입력해주세요');
        expect(User.validateEmail('@example.com'), '올바른 이메일 형식을 입력해주세요');
        expect(User.validateEmail('test@'), '올바른 이메일 형식을 입력해주세요');
        expect(User.validateEmail('test.example.com'), '올바른 이메일 형식을 입력해주세요');
      });
    });

    group('Name Validation', () {
      test('should return null for valid name', () {
        expect(User.validateName('홍길동'), isNull);
        expect(User.validateName('John Doe'), isNull);
        expect(User.validateName('김철수'), isNull);
      });

      test('should return error for null or empty name', () {
        expect(User.validateName(null), '이름을 입력해주세요');
        expect(User.validateName(''), '이름을 입력해주세요');
      });

      test('should return error for name too short', () {
        expect(User.validateName('김'), '이름은 2글자 이상이어야 합니다');
      });

      test('should return error for name too long', () {
        final longName = 'a' * 51;
        expect(User.validateName(longName), '이름은 50글자 이하여야 합니다');
      });

      test('should accept name at boundary lengths', () {
        expect(User.validateName('김철'), isNull); // 2 characters
        expect(User.validateName('a' * 50), isNull); // 50 characters
      });
    });

    group('isAdmin Property', () {
      test('should return true for admin user', () {
        final adminUser = testUser.copyWith(role: UserRole.admin);
        expect(adminUser.isAdmin, isTrue);
      });

      test('should return false for regular user', () {
        expect(testUser.isAdmin, isFalse);
      });
    });

    group('Equality and HashCode', () {
      test('should be equal when all properties are same', () {
        final sameUser = User(
          id: 'user123',
          email: 'test@example.com',
          name: 'Test User',
          role: UserRole.user,
          phoneNumber: '010-1234-5678',
          profileImageUrl: 'https://example.com/image.jpg',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(testUser, equals(sameUser));
        expect(testUser.hashCode, equals(sameUser.hashCode));
      });

      test('should not be equal when properties differ', () {
        final differentUser = testUser.copyWith(name: 'Different Name');

        expect(testUser, isNot(equals(differentUser)));
        expect(testUser.hashCode, isNot(equals(differentUser.hashCode)));
      });
    });

    group('toString', () {
      test('should return string representation with all properties', () {
        final userString = testUser.toString();

        expect(userString, contains('User('));
        expect(userString, contains('id: user123'));
        expect(userString, contains('email: test@example.com'));
        expect(userString, contains('name: Test User'));
        expect(userString, contains('role: UserRole.user'));
      });
    });

    group('UserRole Enum', () {
      test('should have correct enum values', () {
        expect(UserRole.values, contains(UserRole.user));
        expect(UserRole.values, contains(UserRole.admin));
        expect(UserRole.values.length, 2);
      });
    });
  });
}