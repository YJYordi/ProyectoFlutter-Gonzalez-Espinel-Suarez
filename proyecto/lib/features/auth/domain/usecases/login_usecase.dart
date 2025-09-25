import 'package:proyecto/features/auth/domain/entities/user.dart';
import 'package:proyecto/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository authRepository;

  const LoginUseCase(this.authRepository);

  Future<UserEntity?> call(String username, String password) {
    return authRepository.login(username: username, password: password);
  }
}
