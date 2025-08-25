import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/error/result.dart';

class GetAllUsersUseCase {
  final AuthRepository _authRepository;

  GetAllUsersUseCase(this._authRepository);

  Future<Result<List<User>>> execute() async {
    return await _authRepository.getAllUsers();
  }
}