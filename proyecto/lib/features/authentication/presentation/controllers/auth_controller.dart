import 'package:get/get.dart';
import 'package:proyecto/features/authentication/domain/entities/user.dart';
import 'package:proyecto/features/authentication/domain/entities/auth_response.dart';
import 'package:proyecto/features/authentication/domain/usecases/login_usecase.dart';
import 'package:proyecto/features/authentication/domain/usecases/register_usecase.dart';
import 'package:proyecto/features/authentication/domain/usecases/login_with_api_usecase.dart';
import 'package:proyecto/features/authentication/domain/usecases/register_with_api_usecase.dart';
import 'package:proyecto/features/authentication/domain/usecases/logout_with_api_usecase.dart';
import 'package:proyecto/features/authentication/domain/usecases/refresh_token_usecase.dart';
import 'package:proyecto/features/authentication/domain/usecases/validate_token_usecase.dart';

class AuthController extends GetxController {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LoginWithAPIUseCase loginWithAPIUseCase;
  final RegisterWithAPIUseCase registerWithAPIUseCase;
  final LogoutWithAPIUseCase logoutWithAPIUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;
  final ValidateTokenUseCase validateTokenUseCase;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.loginWithAPIUseCase,
    required this.registerWithAPIUseCase,
    required this.logoutWithAPIUseCase,
    required this.refreshTokenUseCase,
    required this.validateTokenUseCase,
  });

  // Variables reactivas
  final _user = Rxn<UserEntity>();
  final _isLoading = false.obs;
  final _error = RxnString();

  // Getters
  UserEntity? get user => _user.value;
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _user.value != null;
  String? get error => _error.value;

  // Métodos locales (existentes)
  Future<bool> login(String username, String password) async {
    _isLoading.value = true;
    _error.value = null;

    try {
      final result = await loginUseCase(username, password);
      _user.value = result;
      _isLoading.value = false;
      return result != null;
    } catch (e) {
      _error.value = e.toString();
      _isLoading.value = false;
      return false;
    }
  }

  Future<String?> register({
    required String name,
    required String username,
    required String password,
  }) async {
    try {
      await registerUseCase(name: name, username: username, password: password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void logout() {
    _user.value = null;
    _error.value = null;
  }

  // Métodos para API
  Future<AuthResponse> loginWithAPI(String username, String password) async {
    _isLoading.value = true;
    _error.value = null;

    try {
      final response = await loginWithAPIUseCase(
        username: username,
        password: password,
      );

      if (response.success && response.user != null) {
        _user.value = UserEntity(
          name: response.user!['name']?.toString() ?? 'Usuario',
          username: response.user!['username']?.toString() ?? username,
          email: response.user!['email']?.toString() ?? username,
          password: '', // No guardamos la contraseña
          role: UserRole
              .student, // Por defecto, se puede ajustar según la respuesta
          createdAt: DateTime.now(),
        );
      } else {
        _error.value = response.error;
      }

      _isLoading.value = false;
      return response;
    } catch (e) {
      _error.value = e.toString();
      _isLoading.value = false;
      return AuthResponse(success: false, error: e.toString());
    }
  }

  Future<AuthResponse> registerWithAPI({
    required String name,
    required String username,
    required String password,
  }) async {
    _isLoading.value = true;
    _error.value = null;

    try {
      final response = await registerWithAPIUseCase(
        name: name,
        username: username,
        password: password,
      );

      if (response.success && response.user != null) {
        _user.value = UserEntity(
          name: response.user!['name']?.toString() ?? 'Usuario',
          username: response.user!['username']?.toString() ?? username,
          email: response.user!['email']?.toString() ?? username,
          password: '', // No guardamos la contraseña
          role: UserRole
              .student, // Por defecto, se puede ajustar según la respuesta
          createdAt: DateTime.now(),
        );
      } else {
        _error.value = response.error;
      }

      _isLoading.value = false;
      return response;
    } catch (e) {
      _error.value = e.toString();
      _isLoading.value = false;
      return AuthResponse(success: false, error: e.toString());
    }
  }

  Future<AuthResponse> logoutWithAPI() async {
    _isLoading.value = true;
    _error.value = null;

    try {
      final response = await logoutWithAPIUseCase();

      if (response.success) {
        _user.value = null;
      } else {
        _error.value = response.error;
      }

      _isLoading.value = false;
      return response;
    } catch (e) {
      _error.value = e.toString();
      _isLoading.value = false;
      return AuthResponse(success: false, error: e.toString());
    }
  }

  Future<AuthResponse> refreshToken() async {
    try {
      return await refreshTokenUseCase();
    } catch (e) {
      return AuthResponse(success: false, error: e.toString());
    }
  }

  Future<AuthResponse> validateToken() async {
    try {
      return await validateTokenUseCase();
    } catch (e) {
      return AuthResponse(success: false, error: e.toString());
    }
  }

  void clearError() {
    _error.value = null;
  }
}
