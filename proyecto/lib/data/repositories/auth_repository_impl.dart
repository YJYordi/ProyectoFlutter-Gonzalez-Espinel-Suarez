import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalDataSource localDataSource;

  AuthRepositoryImpl(this.localDataSource);

  @override
  Future<void> signup(UserEntity user) async {
    final userModel = UserModel(
      username: user.username,
      password: user.password,
    );
    await localDataSource.saveUser(userModel);
  }

  @override
  Future<bool> login(String username, String password) async {
    final user = await localDataSource.getUser();
    if (user == null) return false;
    return user.username == username && user.password == password;
  }
}
