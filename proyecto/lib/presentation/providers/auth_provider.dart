import 'package:flutter/foundation.dart';
import 'package:proyecto/Domain/Entities/user.dart';
import 'package:proyecto/Domain/usecases/login_usecase.dart';
import 'package:proyecto/Domain/usecases/register_usecase.dart';
import 'package:proyecto/data/datasources/persistent_data_source.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final PersistentDataSource _dataSource;

  UserEntity? _user;
  bool _isLoading = false;

  AuthProvider({
    required this.loginUseCase, 
    required this.registerUseCase,
    required PersistentDataSource dataSource,
  }) : _dataSource = dataSource;

  UserEntity? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();
    final result = await loginUseCase(username, password);
    _user = result;
    _isLoading = false;
    notifyListeners();
    return result != null;
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
    notifyListeners();
  }

  Future<Map<String, String?>> getRememberedCredentials() async {
    return await _dataSource.getRememberedCredentials();
  }

  Future<void> saveRememberUserSettings({
    required bool rememberUser,
    String? username,
    String? password,
  }) async {
    await _dataSource.saveRememberUserSettings(
      rememberUser: rememberUser,
      username: username,
      password: password,
    );
  }
}


