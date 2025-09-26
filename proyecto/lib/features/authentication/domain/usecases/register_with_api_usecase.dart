import 'package:proyecto/features/authentication/domain/entities/auth_response.dart';
import 'package:proyecto/features/authentication/domain/repositories/auth_repository.dart';

class RegisterWithAPIUseCase {
  final AuthRepository authRepository;

  const RegisterWithAPIUseCase(this.authRepository);

  Future<AuthResponse> call({
    required String name,
    required String username,
    required String password,
  }) async {
    return await authRepository.registerWithAPI(
      name: name,
      username: username,
      password: password,
    );
  }
}
