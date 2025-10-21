import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyecto/Domain/Entities/user.dart';

class RobleRemoteDataSource {
  final String baseUrl; // e.g. https://roble.openlab.uninorte.edu.co/api
  final String projectToken; // e.g. appstudents_45c2d5e1e5

  const RobleRemoteDataSource({required this.baseUrl, required this.projectToken});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        // Roble: el token de proyecto en header; si la doc indica otro nombre, ajústalo aquí
        'X-Project-Id': projectToken,
      };

  // Auth
  Future<UserEntity?> login(String username, String password) async {
    final uri = Uri.parse('$baseUrl/auth/login');
    final res = await http.post(uri, headers: _headers, body: jsonEncode({'username': username, 'password': password}));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      // Suponemos que la respuesta incluye el usuario normalizado
      return UserEntity.fromJson(data['user'] as Map<String, dynamic>);
    }
    return null;
  }

  Future<UserEntity> register({required String name, required String username, required String password, String role = 'student'}) async {
    final uri = Uri.parse('$baseUrl/auth/register');
    final res = await http.post(uri, headers: _headers, body: jsonEncode({'name': name, 'username': username, 'password': password, 'role': role}));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return UserEntity.fromJson(data['user'] as Map<String, dynamic>);
    }
    throw Exception('Roble register failed: ${res.statusCode} ${res.body}');
  }

  // Database API
  Future<List<UserEntity>> fetchUsers() async {
    final uri = Uri.parse('$baseUrl/database/user');
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list.map((e) => UserEntity.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Roble fetchUsers failed: ${res.statusCode} ${res.body}');
  }

  Future<void> insertActivity({required String type, required Map<String, dynamic> payload, String? username}) async {
    final uri = Uri.parse('$baseUrl/database/activity');
    final body = {
      'type': type,
      'payload': payload,
      'username': username,
    };
    final res = await http.post(uri, headers: _headers, body: jsonEncode(body));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Roble insertActivity failed: ${res.statusCode} ${res.body}');
    }
  }
}



