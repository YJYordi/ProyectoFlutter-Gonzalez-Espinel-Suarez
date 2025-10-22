import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proyecto/config/supabase_config.dart';

class SupabaseTest {
  static Future<void> testConnection() async {
    try {
      print('🔍 Probando conexión con Supabase...');
      
      // Inicializar Supabase
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      
      final client = Supabase.instance.client;
      
      // Probar conexión básica
      print('✅ Supabase inicializado correctamente');
      
      // Probar acceso a las tablas
      print('🔍 Verificando tablas...');
      
      // Verificar tabla profiles
      try {
        final profilesResponse = await client.from('profiles').select().limit(1);
        print('✅ Tabla "profiles" accesible');
      } catch (e) {
        print('❌ Error accediendo a tabla "profiles": $e');
      }
      
      // Verificar tabla courses
      try {
        final coursesResponse = await client.from('courses').select().limit(1);
        print('✅ Tabla "courses" accesible');
      } catch (e) {
        print('❌ Error accediendo a tabla "courses": $e');
      }
      
      // Verificar tabla course_enrollments
      try {
        final enrollmentsResponse = await client.from('course_enrollments').select().limit(1);
        print('✅ Tabla "course_enrollments" accesible');
      } catch (e) {
        print('❌ Error accediendo a tabla "course_enrollments": $e');
      }
      
      // Verificar tabla categories
      try {
        final categoriesResponse = await client.from('categories').select().limit(1);
        print('✅ Tabla "categories" accesible');
      } catch (e) {
        print('❌ Error accediendo a tabla "categories": $e');
      }
      
      // Verificar tabla groups
      try {
        final groupsResponse = await client.from('groups').select().limit(1);
        print('✅ Tabla "groups" accesible');
      } catch (e) {
        print('❌ Error accediendo a tabla "groups": $e');
      }
      
      // Verificar tabla user_activities
      try {
        final activitiesResponse = await client.from('user_activities').select().limit(1);
        print('✅ Tabla "user_activities" accesible');
      } catch (e) {
        print('❌ Error accediendo a tabla "user_activities": $e');
      }
      
      print('🎉 ¡Conexión con Supabase exitosa!');
      
    } catch (e) {
      print('❌ Error conectando con Supabase: $e');
      rethrow;
    }
  }
  
  static Future<void> testAuth() async {
    try {
      print('🔍 Probando autenticación...');
      
      final client = Supabase.instance.client;
      
      // Verificar estado de autenticación
      final currentUser = client.auth.currentUser;
      print('👤 Usuario actual: ${currentUser?.email ?? "No autenticado"}');
      
      print('✅ Autenticación configurada correctamente');
      
    } catch (e) {
      print('❌ Error en autenticación: $e');
      rethrow;
    }
  }
}

