import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class SignInUseCase {
  final AuthRepository _authRepository;

  const SignInUseCase(this._authRepository);

  /// Signs in a user with email and password
  /// 
  /// Validates input and delegates to repository
  /// Returns [Result<User>] with user data on success or exception on failure
  Future<Result<User>> execute(String email, String password) async {
    try {
      // Validate email format
      final emailError = User.validateEmail(email);
      if (emailError != null) {
        return Failure(ValidationException(emailError));
      }

      // Validate password
      final passwordError = _validatePassword(password);
      if (passwordError != null) {
        return Failure(ValidationException(passwordError));
      }

      // Attempt sign in
      final result = await _authRepository.signIn(email.trim().toLowerCase(), password);
      
      return result.fold(
        onSuccess: (user) => Success(user),
        onFailure: (exception) => Failure(exception),
      );
    } catch (e) {
      return Failure(UnknownException('로그인 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    
    if (password.length < 6) {
      return '비밀번호는 6글자 이상이어야 합니다';
    }
    
    return null;
  }
}