import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/error/result.dart';
import '../../../core/error/exceptions.dart';

class SignUpUseCase {
  final AuthRepository _authRepository;

  const SignUpUseCase(this._authRepository);

  /// Signs up a new user with email, password, and name
  /// 
  /// Validates all input fields and creates new user account
  /// Returns [Result<User>] with user data on success or exception on failure
  Future<Result<User>> execute(String email, String password, String name) async {
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

      // Validate name
      final nameError = User.validateName(name);
      if (nameError != null) {
        return Failure(ValidationException(nameError));
      }

      // Attempt sign up
      final result = await _authRepository.signUp(
        email.trim().toLowerCase(), 
        password, 
        name.trim()
      );
      
      return result.fold(
        onSuccess: (user) => Success(user),
        onFailure: (exception) => Failure(exception),
      );
    } catch (e) {
      return Failure(UnknownException('회원가입 중 오류가 발생했습니다: ${e.toString()}'));
    }
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    
    if (password.length < 6) {
      return '비밀번호는 6글자 이상이어야 합니다';
    }

    if (password.length > 128) {
      return '비밀번호는 128글자 이하여야 합니다';
    }

    // Check for at least one letter and one number
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password)) {
      return '비밀번호는 영문자와 숫자를 포함해야 합니다';
    }
    
    return null;
  }
}