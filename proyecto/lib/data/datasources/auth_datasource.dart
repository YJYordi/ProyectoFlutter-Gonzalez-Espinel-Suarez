import 'package:proyecto/Domain/Entities/user.dart';

abstract class AuthDataSource {
  Future<UserEntity?> login(String username, String password);
  Future<void> logout();
  Future<UserEntity> register({
    required String name,
    required String username,
    required String password,
  });

  UserEntity? get currentUser;
}
