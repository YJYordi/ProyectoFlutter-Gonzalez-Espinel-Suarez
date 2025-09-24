import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyecto/Domain/Entities/user.dart';
import 'package:proyecto/data/datasources/auth_datasource.dart';
import 'package:proyecto/data/models/auth_user_model.dart';

class RemoteDataSource implements AuthDataSource {
  final String baseUrl;
  final http.Client client;

  RemoteDataSource({required this.baseUrl}) : client = http.Client();

  UserEntity? _currentUser;
  String? _accessToken;
  String? _refreshToken;

  @override
  UserEntity? get currentUser => _currentUser;

  @override
  Future<UserEntity?> login(String username, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Aquí creamos el UserModel desde la respuesta JSON
      final user = UserModel.fromJson(data);

      _accessToken = user.accessToken;
      _refreshToken = user.refreshToken;

      _currentUser = user; // guardamos el modelo pero cumple como UserEntity

      return _currentUser;
    } else {
      throw Exception('Error en login: ${response.body}');
    }
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String password,
    required String username,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/signup-direct'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': username, 'password': password, 'name': name}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Igual que en login, usamos UserModel
      final user = UserModel.fromJson(data);

      _accessToken = user.accessToken;
      _refreshToken = user.refreshToken;

      _currentUser = user;

      return _currentUser!;
    } else {
      throw Exception('Error en register: ${response.body}');
    }
  }

  @override
  Future<void> logout() async {
    if (_accessToken == null) return;

    final response = await client.post(
      Uri.parse('$baseUrl/logout'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      _currentUser = null;
      _accessToken = null;
      _refreshToken = null;
    } else {
      throw Exception('Error en logout: ${response.body}');
    }
  }

  Future<void> refreshToken() async {
    if (_refreshToken == null) return;

    final response = await client.post(
      Uri.parse('$baseUrl/refresh-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': _refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['accessToken'];
    } else {
      throw Exception('Error en refreshToken: ${response.body}');
    }
  }

  Future<bool> verifyToken() async {
    if (_accessToken == null) return false;

    final response = await client.get(
      Uri.parse('$baseUrl/verify-token'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    return response.statusCode == 200;
  }
}
