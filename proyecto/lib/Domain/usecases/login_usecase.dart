import 'package:proyecto/Domain/Entities/user.dart';
import 'package:proyecto/Domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository authRepository;

  const LoginUseCase(this.authRepository);

  Future<UserEntity?> call(String username, String password) {
    return authRepository.login(username: username, password: password);
  }
}


