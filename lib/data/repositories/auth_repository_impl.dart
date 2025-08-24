import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/error/result.dart';
import '../services/firebase_auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;

  AuthRepositoryImpl({
    required FirebaseAuthService authService,
  }) : _authService = authService;

  @override
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  @override
  Future<User?> getCurrentUser() async {
    return await _authService.getCurrentUser();
  }

  @override
  Future<Result<User>> signIn(String email, String password) async {
    return await _authService.signIn(email, password);
  }

  @override
  Future<Result<User>> signUp(String email, String password, String name) async {
    return await _authService.signUp(email, password, name);
  }

  @override
  Future<Result<void>> signOut() async {
    return await _authService.signOut();
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    return await _authService.sendPasswordResetEmail(email);
  }

  @override
  Future<Result<User>> updateProfile(User user) async {
    return await _authService.updateProfile(user);
  }

  @override
  Future<Result<void>> deleteAccount() async {
    return await _authService.deleteAccount();
  }
}