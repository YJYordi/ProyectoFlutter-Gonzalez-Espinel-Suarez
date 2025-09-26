import 'package:proyecto/features/authentication/domain/entities/auth_response.dart';
import 'package:proyecto/features/authentication/domain/repositories/auth_repository.dart';

class ValidateTokenUseCase {
  final AuthRepository authRepository;

  const ValidateTokenUseCase(this.authRepository);

  Future<AuthResponse> call() async {
    final token = await authRepository.accessToken;
    if (token == null) {
      return const AuthResponse(
        success: false,
        error: 'No hay token de acceso disponible',
      );
    }
    
    return await authRepository.validateTokenWithAPI(token);
  }
}
