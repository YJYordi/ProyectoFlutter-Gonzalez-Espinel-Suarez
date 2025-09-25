import 'package:proyecto/features/auth/domain/entities/user.dart';
import 'package:proyecto/features/auth/domain/repositories/auth_repository.dart';
import 'package:proyecto/features/auth/data/datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  UserEntity? get currentUser => null; // Se manejará desde la API

  @override
  Future<UserEntity?> login({
    required String username,
    required String password,
  }) async {
    try {
      return await remoteDataSource.login(username, password);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String username,
    required String password,
  }) async {
    return await remoteDataSource.register(name, username, password);
  }
}
