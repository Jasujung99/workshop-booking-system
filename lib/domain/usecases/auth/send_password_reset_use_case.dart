import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class SendPasswordResetUseCase {
  final AuthRepository _authRepository;

  const SendPasswordResetUseCase(this._authRepository);

  /// Sends password reset email to the specified email address
  /// 
  /// Validates email format and sends reset link
  /// Returns [Result<void>] indicating success or failure
  Future<Result<void>> execute(String email) async {
    try {
      // Validate email format
      final emailError = User.validateEmail(email);
      if (emailError != null) {
        return Failure(ValidationException(emailError));
      }

      // Attempt to send password reset email
      final result = await _authRepository.sendPasswordResetEmail(email.trim().toLowerCase());
      
      return result.fold(
        onSuccess: (_) => const Success(null),
        onFailure: (exception) => Failure(exception),
      );
    } catch (e) {
      return Failure(UnknownException('비밀번호 재설정 이메일 발송 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }
}