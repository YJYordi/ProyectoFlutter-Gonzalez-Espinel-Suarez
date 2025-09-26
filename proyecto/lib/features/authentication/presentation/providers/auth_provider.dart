import 'package:flutter/foundation.dart';
import 'package:proyecto/features/authentication/domain/entities/user.dart';
import 'package:proyecto/features/authentication/domain/entities/auth_response.dart';
import 'package:proyecto/features/authentication/domain/usecases/login_usecase.dart';
import 'package:proyecto/features/authentication/domain/usecases/register_usecase.dart';
import 'package:proyecto/features/authentication/domain/usecases/login_with_api_usecase.dart';
import 'package:proyecto/features/authentication/domain/usecases/register_with_api_usecase.dart';
import 'package:proyecto/features/authentication/domain/usecases/logout_with_api_usecase.dart';
import 'package:proyecto/features/authentication/domain/usecases/refresh_token_usecase.dart';
import 'package:proyecto/features/authentication/domain/usecases/validate_token_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LoginWithAPIUseCase loginWithAPIUseCase;
  final RegisterWithAPIUseCase registerWithAPIUseCase;
  final LogoutWithAPIUseCase logoutWithAPIUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;
  final ValidateTokenUseCase validateTokenUseCase;

  UserEntity? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.loginWithAPIUseCase,
    required this.registerWithAPIUseCase,
    required this.logoutWithAPIUseCase,
    required this.refreshTokenUseCase,
    required this.validateTokenUseCase,
  });

  UserEntity? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;

  // Métodos locales (existentes)
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await loginUseCase(username, password);
      _user = result;
      _isLoading = false;
      notifyListeners();
      return result != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> register({required String name, required String username, required String password}) async {
    try {
      await registerUseCase(name: name, username: username, password: password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void logout() {
    _user = null;
    _error = null;
    notifyListeners();
  }

  // Métodos para API
  Future<AuthResponse> loginWithAPI(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await loginWithAPIUseCase(username: username, password: password);
      
      if (response.success && response.user != null) {
        _user = UserEntity(
          name: response.user!['name'] as String,
          username: response.user!['username'] as String,
          email: response.user!['email'] as String? ?? '',
          password: '', // No guardamos la contraseña
          role: UserRole.student, // Por defecto, se puede ajustar según la respuesta
          createdAt: DateTime.now(),
        );
      } else {
        _error = response.error;
      }
      
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return AuthResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<AuthResponse> registerWithAPI({
    required String name,
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await registerWithAPIUseCase(
        name: name,
        username: username,
        password: password,
      );
      
      if (response.success && response.user != null) {
        _user = UserEntity(
          name: response.user!['name'] as String,
          username: response.user!['username'] as String,
          email: response.user!['email'] as String? ?? '',
          password: '', // No guardamos la contraseña
          role: UserRole.student, // Por defecto, se puede ajustar según la respuesta
          createdAt: DateTime.now(),
        );
      } else {
        _error = response.error;
      }
      
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return AuthResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<AuthResponse> logoutWithAPI() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await logoutWithAPIUseCase();
      
      if (response.success) {
        _user = null;
      } else {
        _error = response.error;
      }
      
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return AuthResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<AuthResponse> refreshToken() async {
    try {
      return await refreshTokenUseCase();
    } catch (e) {
      return AuthResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<AuthResponse> validateToken() async {
    try {
      return await validateTokenUseCase();
    } catch (e) {
      return AuthResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}


