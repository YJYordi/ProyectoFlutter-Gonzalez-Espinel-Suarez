import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proyecto/Domain/Entities/user.dart';

class SupabaseRemoteDataSource {
  final SupabaseClient client;
  SupabaseRemoteDataSource(this.client);

  Future<List<UserEntity>> fetchUsers() async {
    final res = await client.from('profiles').select();
    return (res as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map((data) => UserEntity(
          username: data['username'],
          name: data['name'],
          email: data['email'],
          password: '', // No almacenamos contraseñas en profiles
          role: UserRole.values.firstWhere(
            (role) => role.name == data['role'],
            orElse: () => UserRole.student,
          ),
          createdAt: DateTime.parse(data['created_at']),
          supabaseUserId: data['id'],
        ))
        .toList();
  }

  Future<void> upsertUser(UserEntity user) async {
    await client.from('profiles').upsert({
      'id': user.supabaseUserId,
      'name': user.name,
      'username': user.username,
      'email': user.email,
      'role': user.role.name,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> insertActivity({required String type, required Map<String, dynamic> payload, required String? username}) async {
    await client.from('user_activities').insert({
      'type': type,
      'payload': payload,
      'username': username,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}


