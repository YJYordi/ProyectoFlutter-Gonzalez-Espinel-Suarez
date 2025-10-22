import 'package:flutter/material.dart';
import 'package:proyecto/config/supabase_config.dart';
import 'package:proyecto/utils/supabase_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Iniciando prueba de configuración de Supabase...');
  print('📋 URL: ${SupabaseConfig.supabaseUrl}');
  print('🔑 Key: ${SupabaseConfig.supabaseAnonKey.substring(0, 20)}...');
  
  try {
    await SupabaseTest.testConnection();
    await SupabaseTest.testAuth();
    print('✅ ¡Configuración completada exitosamente!');
  } catch (e) {
    print('❌ Error en la configuración: $e');
  }
}

