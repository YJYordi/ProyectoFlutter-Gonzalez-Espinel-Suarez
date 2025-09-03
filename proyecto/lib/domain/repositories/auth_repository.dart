import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> signup(UserEntity user);
  Future<bool> login(String username, String password);
}
