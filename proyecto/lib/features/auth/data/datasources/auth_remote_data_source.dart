import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:proyecto/features/auth/domain/entities/user.dart';
import 'package:proyecto/core/domain/services/error_service.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity> login(String username, String password);
  Future<UserEntity> register(String name, String username, String password);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  AuthRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<UserEntity> login(String username, String password) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserEntity.fromJson(data['user']);
      } else {
        throw ErrorService.handleHttpError(response);
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ErrorService.handleNetworkError(e as Exception);
    }
  }

  @override
  Future<UserEntity> register(String name, String username, String password) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return UserEntity.fromJson(data['user']);
      } else {
        throw ErrorService.handleHttpError(response);
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ErrorService.handleNetworkError(e as Exception);
    }
  }

  @override
  Future<void> logout() async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw ErrorService.handleHttpError(response);
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ErrorService.handleNetworkError(e as Exception);
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserEntity.fromJson(data['user']);
      } else if (response.statusCode == 401) {
        return null; // Usuario no autenticado
      } else {
        throw ErrorService.handleHttpError(response);
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ErrorService.handleNetworkError(e as Exception);
    }
  }
}