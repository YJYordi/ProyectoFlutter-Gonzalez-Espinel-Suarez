import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto/features/authentication/domain/entities/user.dart';
import 'package:proyecto/features/authentication/domain/entities/auth_response.dart';
import 'package:proyecto/features/authentication/domain/repositories/auth_repository.dart';
import 'package:proyecto/features/authentication/data/datasources/remote_auth_data_source.dart';
import 'package:proyecto/shared/data/datasources/memory_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final InMemoryDataSource dataSource;
  final RemoteAuthDataSource remoteDataSource;

  // Claves para SharedPreferences
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  AuthRepositoryImpl(this.dataSource, this.remoteDataSource);

  // Métodos existentes (local)
  @override
  UserEntity? get currentUser => dataSource.currentUser;

  @override
  Future<UserEntity?> login({
    required String username,
    required String password,
  }) {
    return dataSource.login(username, password);
  }

  @override
  Future<void> logout() {
    return dataSource.logout();
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String username,
    required String password,
  }) {
    return dataSource.register(
      name: name,
      username: username,
      password: password,
    );
  }

  // Métodos para API
  @override
  Future<AuthResponse> loginWithAPI({
    required String username,
    required String password,
  }) async {
    final response = await remoteDataSource.login(
      username: username,
      password: password,
    );

    if (response['success'] == true) {
      // Guardar tokens
      await saveTokens(
        response['token']?.toString() ?? '',
        response['refreshToken']?.toString() ?? '',
      );

      // Crear UserEntity desde la respuesta de la API
      final userData = response['user'] as Map<String, dynamic>? ?? {};
      final user = UserEntity(
        name: userData['name']?.toString() ?? 'Usuario',
        username: userData['username']?.toString() ?? '',
        email: userData['email']?.toString() ?? '',
        password: '', // No guardamos la contraseña
        role: UserRole.student, // Por defecto
        createdAt: DateTime.now(),
      );

      // Guardar usuario en memoria local
      dataSource.setCurrentUser(user);
    }

    return AuthResponse.fromJson(response);
  }

  @override
  Future<AuthResponse> registerWithAPI({
    required String name,
    required String username,
    required String password,
  }) async {
    final response = await remoteDataSource.signupDirect(
      name: name,
      username: username,
      password: password,
    );

    if (response['success'] == true) {
      // Guardar tokens
      await saveTokens(
        response['token']?.toString() ?? '',
        response['refreshToken']?.toString() ?? '',
      );

      // Crear UserEntity desde la respuesta de la API
      final userData = response['user'] as Map<String, dynamic>? ?? {};
      final user = UserEntity(
        name: userData['name']?.toString() ?? 'Usuario',
        username: userData['username']?.toString() ?? '',
        email: userData['email']?.toString() ?? '',
        password: '', // No guardamos la contraseña
        role: UserRole.student, // Por defecto
        createdAt: DateTime.now(),
      );

      // Guardar usuario en memoria local
      dataSource.setCurrentUser(user);
    }

    return AuthResponse.fromJson(response);
  }

  @override
  Future<AuthResponse> logoutWithAPI(String token) async {
    final response = await remoteDataSource.logout(token);

    if (response['success'] == true) {
      // Limpiar tokens y usuario local
      await clearTokens();
      await dataSource.logout();
    }

    return AuthResponse.fromJson(response);
  }

  @override
  Future<AuthResponse> refreshTokenWithAPI(String refreshToken) async {
    final response = await remoteDataSource.refreshToken(refreshToken);

    if (response['success'] == true) {
      // Guardar nuevos tokens
      await saveTokens(
        response['token']?.toString() ?? '',
        response['refreshToken']?.toString() ?? '',
      );
    }

    return AuthResponse.fromJson(response);
  }

  @override
  Future<AuthResponse> validateTokenWithAPI(String token) async {
    return AuthResponse.fromJson(await remoteDataSource.validateToken(token));
  }

  @override
  Future<AuthResponse> getCurrentUserWithAPI(String token) async {
    return AuthResponse.fromJson(await remoteDataSource.getCurrentUser(token));
  }

  // Gestión de tokens
  @override
  Future<String?> get accessToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  @override
  Future<String?> get refreshToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  @override
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
