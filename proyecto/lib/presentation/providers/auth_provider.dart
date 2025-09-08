import 'package:flutter/foundation.dart';
import 'package:proyecto/Domain/Entities/user.dart';
import 'package:proyecto/Domain/usecases/login_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  UserEntity? _user;
  bool _isLoading = false;

  AuthProvider({required this.loginUseCase});

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
}


