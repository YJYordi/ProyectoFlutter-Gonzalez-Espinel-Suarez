import 'package:proyecto/Domain/Entities/user.dart';
import 'package:proyecto/Domain/repositories/auth_repository.dart';
import 'package:proyecto/data/datasources/memory_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final InMemoryDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  UserEntity? get currentUser => dataSource.currentUser;

  @override
  Future<UserEntity?> login({required String username, required String password}) {
    return dataSource.login(username, password);
  }

  @override
  Future<void> logout() {
    return dataSource.logout();
  }

  @override
  Future<UserEntity> register({required String name, required String username, required String password}) {
    return dataSource.register(name: name, username: username, password: password);
  }
}


