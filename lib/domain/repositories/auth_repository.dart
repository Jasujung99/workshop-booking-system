import '../entities/user.dart';
import '../../core/error/result.dart';

abstract class AuthRepository {
  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;
  
  /// Get current authenticated user
  Future<User?> getCurrentUser();
  
  /// Sign in with email and password
  Future<Result<User>> signIn(String email, String password);
  
  /// Sign up with email, password and name
  Future<Result<User>> signUp(String email, String password, String name);
  
  /// Sign out current user
  Future<Result<void>> signOut();
  
  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail(String email);
  
  /// Update user profile
  Future<Result<User>> updateProfile(User user);
  
  /// Delete user account
  Future<Result<void>> deleteAccount();
}