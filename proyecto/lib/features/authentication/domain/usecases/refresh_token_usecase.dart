import 'package:proyecto/features/authentication/domain/entities/auth_response.dart';
import 'package:proyecto/features/authentication/domain/repositories/auth_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository authRepository;

  const RefreshTokenUseCase(this.authRepository);

  Future<AuthResponse> call() async {
    final refreshToken = await authRepository.refreshToken;
    if (refreshToken == null) {
      return const AuthResponse(
        success: false,
        error: 'No hay refresh token disponible',
      );
    }
    
    return await authRepository.refreshTokenWithAPI(refreshToken);
  }
}
