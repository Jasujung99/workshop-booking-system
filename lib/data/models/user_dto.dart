import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

class UserDto {
  final String email;
  final String name;
  final String role;
  final String? phoneNumber;
  final String? profileImageUrl;
  final Timestamp createdAt;
  final Timestamp? updatedAt;

  const UserDto({
    required this.email,
    required this.name,
    required this.role,
    this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserDto(
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'user',
      phoneNumber: data['phoneNumber'],
      profileImageUrl: data['profileImageUrl'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  User toDomain(String id) {
    return User(
      id: id,
      email: email,
      name: name,
      role: UserRole.values.byName(role),
      phoneNumber: phoneNumber,
      profileImageUrl: profileImageUrl,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt?.toDate(),
    );
  }

  static UserDto fromDomain(User user) {
    return UserDto(
      email: user.email,
      name: user.name,
      role: user.role.name,
      phoneNumber: user.phoneNumber,
      profileImageUrl: user.profileImageUrl,
      createdAt: Timestamp.fromDate(user.createdAt),
      updatedAt: user.updatedAt != null ? Timestamp.fromDate(user.updatedAt!) : null,
    );
  }
}