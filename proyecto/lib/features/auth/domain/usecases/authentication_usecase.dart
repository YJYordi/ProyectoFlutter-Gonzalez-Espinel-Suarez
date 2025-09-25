import '../entities/authentication_user.dart';
import '../repositories/i_auth_repository.dart';

class AuthenticationUseCase {
  final IAuthRepository repository;

  AuthenticationUseCase(this.repository);

  Future<bool> login(String email, String password) async {
    return await repository.login(email, password);
  }

  Future<bool> signUp(String email, String password) async {
    final user = AuthenticationUser(username: email, password: password);
    return await repository.signUp(user);
  }

  Future<bool> logOut() async {
    return await repository.logOut();
  }

  Future<bool> validate(String email, String validationCode) async {
    return await repository.validate(email, validationCode);
  }

  Future<bool> validateToken() async {
    return await repository.validateToken();
  }

  Future<void> forgotPassword(String email) async {
    return await repository.forgotPassword(email);
  }
}
