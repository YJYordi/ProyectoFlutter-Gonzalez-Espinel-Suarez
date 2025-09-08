import 'package:proyecto/Domain/Entities/user.dart';
import 'package:proyecto/Domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository authRepository;
  const RegisterUseCase(this.authRepository);

  Future<UserEntity> call({required String name, required String username, required String password}) {
    return authRepository.register(name: name, username: username, password: password);
  }
}


