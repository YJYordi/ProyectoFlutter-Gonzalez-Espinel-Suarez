import 'package:proyecto/Domain/Entities/user.dart';

abstract class AuthRepository {
  Future<UserEntity?> login({required String username, required String password});
  Future<void> logout();
  UserEntity? get currentUser;
}


