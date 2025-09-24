import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proyecto/Domain/Entities/user.dart';

class SupabaseRemoteDataSource {
  final SupabaseClient client;
  SupabaseRemoteDataSource(this.client);

  Future<List<UserEntity>> fetchUsers() async {
    final res = await client.from('user').select();
    return (res as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(UserEntity.fromJson)
        .toList();
  }

  Future<void> upsertUser(UserEntity user) async {
    await client.from('user').upsert(user.toJson(), onConflict: 'username');
  }

  Future<void> insertActivity({required String type, required Map<String, dynamic> payload, required String? username}) async {
    await client.from('activity').insert({
      'type': type,
      'payload': payload,
      'username': username,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}


