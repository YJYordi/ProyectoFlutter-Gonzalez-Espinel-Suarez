import 'package:proyecto/features/authentication/domain/entities/auth_response.dart';
import 'package:proyecto/features/authentication/domain/repositories/auth_repository.dart';

class LoginWithAPIUseCase {
  final AuthRepository authRepository;

  const LoginWithAPIUseCase(this.authRepository);

  Future<AuthResponse> call({
    required String username,
    required String password,
  }) async {
    return await authRepository.loginWithAPI(
      username: username,
      password: password,
    );
  }
}
