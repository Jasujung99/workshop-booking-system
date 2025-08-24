import 'package:equatable/equatable.dart';

enum UserRole {
  user,
  admin,
}

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a copy of this User with the given fields replaced with new values
  User copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Validates user data
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return '이메일을 입력해주세요';
    }
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return '올바른 이메일 형식을 입력해주세요';
    }
    
    return null;
  }

  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return '이름을 입력해주세요';
    }
    
    if (name.length < 2) {
      return '이름은 2글자 이상이어야 합니다';
    }
    
    if (name.length > 50) {
      return '이름은 50글자 이하여야 합니다';
    }
    
    return null;
  }

  /// Checks if user is admin
  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object?> get props => [id, email, name, role, phoneNumber, profileImageUrl, createdAt, updatedAt];

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, role: $role, phoneNumber: $phoneNumber, profileImageUrl: $profileImageUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}