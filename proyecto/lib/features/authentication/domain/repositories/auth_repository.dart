import 'package:proyecto/features/authentication/domain/entities/user.dart';
import 'package:proyecto/features/authentication/domain/entities/auth_response.dart';

abstract class AuthRepository {
  // Métodos existentes
  Future<UserEntity?> login({required String username, required String password});
  Future<void> logout();
  UserEntity? get currentUser;
  Future<UserEntity> register({required String name, required String username, required String password});
  
  // Métodos para API
  Future<AuthResponse> loginWithAPI({required String username, required String password});
  Future<AuthResponse> registerWithAPI({required String name, required String username, required String password});
  Future<AuthResponse> logoutWithAPI(String token);
  Future<AuthResponse> refreshTokenWithAPI(String refreshToken);
  Future<AuthResponse> validateTokenWithAPI(String token);
  Future<AuthResponse> getCurrentUserWithAPI(String token);
  
  // Gestión de tokens
  Future<String?> get accessToken;
  Future<String?> get refreshToken;
  Future<void> saveTokens(String accessToken, String refreshToken);
  Future<void> clearTokens();
}


