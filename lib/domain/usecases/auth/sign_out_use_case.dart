import '../../repositories/auth_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class SignOutUseCase {
  final AuthRepository _authRepository;

  const SignOutUseCase(this._authRepository);

  /// Signs out the current user
  /// 
  /// Clears authentication state and returns to login screen
  /// Returns [Result<void>] indicating success or failure
  Future<Result<void>> execute() async {
    try {
      // Check if user is currently signed in
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        return Failure(AuthException('로그인된 사용자가 없습니다'));
      }

      // Attempt sign out
      final result = await _authRepository.signOut();
      
      return result.fold(
        onSuccess: (_) => const Success(null),
        onFailure: (exception) => Failure(exception),
      );
    } catch (e) {
      return Failure(UnknownException('로그아웃 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }
}