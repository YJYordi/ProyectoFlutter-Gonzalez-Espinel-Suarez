import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proyecto/Domain/Entities/user.dart';

class SupabaseAuthService {
  static SupabaseAuthService? _instance;
  static SupabaseAuthService get instance => _instance ??= SupabaseAuthService._();
  
  SupabaseAuthService._();

  SupabaseClient get client => Supabase.instance.client;
  User? get currentUser => client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  /// Inicializar Supabase
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  /// Registro de usuario
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String username,
    required UserRole role,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'username': username,
        'role': role.name,
      },
    );

    if (response.user != null) {
      // Crear perfil de usuario en la tabla profiles
      await _createUserProfile(
        userId: response.user!.id,
        name: name,
        username: username,
        email: email,
        role: role,
      );
    }

    return response;
  }

  /// Inicio de sesión
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Obtener usuario actual
  UserEntity? getCurrentUserEntity() {
    final user = currentUser;
    if (user == null) return null;

    return UserEntity(
      username: user.userMetadata?['username'] ?? '',
      name: user.userMetadata?['name'] ?? '',
      email: user.email ?? '',
      password: '', // No almacenamos la contraseña
      role: UserRole.values.firstWhere(
        (e) => e.name == user.userMetadata?['role'],
        orElse: () => UserRole.student,
      ),
      createdAt: DateTime.parse(user.createdAt),
    );
  }

  /// Crear perfil de usuario en la base de datos
  Future<void> _createUserProfile({
    required String userId,
    required String name,
    required String username,
    required String email,
    required UserRole role,
  }) async {
    await client.from('profiles').insert({
      'id': userId,
      'name': name,
      'username': username,
      'email': email,
      'role': role.name,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Obtener perfil de usuario desde la base de datos
  Future<UserEntity?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserEntity(
        username: response['username'],
        name: response['name'],
        email: response['email'],
        password: '', // No devolvemos la contraseña
        role: UserRole.values.firstWhere(
          (e) => e.name == response['role'],
          orElse: () => UserRole.student,
        ),
        createdAt: DateTime.parse(response['created_at']),
      );
    } catch (e) {
      return null;
    }
  }

  /// Actualizar perfil de usuario
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? username,
    String? email,
  }) async {
    final updateData = <String, dynamic>{};
    
    if (name != null) updateData['name'] = name;
    if (username != null) updateData['username'] = username;
    if (email != null) updateData['email'] = email;
    
    if (updateData.isNotEmpty) {
      updateData['updated_at'] = DateTime.now().toIso8601String();
      
      await client
          .from('profiles')
          .update(updateData)
          .eq('id', userId);
    }
  }

  /// Cambiar contraseña
  Future<void> changePassword(String newPassword) async {
    await client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  /// Restablecer contraseña
  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  /// Escuchar cambios de autenticación
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}

