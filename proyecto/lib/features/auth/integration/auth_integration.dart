import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../auth.dart';

/// Clase para integrar el feature auth con GetX sin tocar el main.dart existente
class AuthIntegration {
  static bool _initialized = false;

  /// Inicializa el feature auth
  static void initialize() {
    if (_initialized) return;
    
    // Inicializar Loggy
    Loggy.initLoggy(
      logPrinter: const PrettyPrinter(),
      logOptions: const LogOptions(
        LogLevel.all,
        stackTraceLevel: LogLevel.error,
      ),
    );
    
    // Inicializar dependencias de autenticación
    AuthDependencies.init();
    
    _initialized = true;
  }

  /// Crea un GetMaterialApp con las rutas de auth integradas
  static GetMaterialApp createGetMaterialApp({
    required String title,
    required String initialRoute,
    required List<GetPage> additionalRoutes,
    ThemeData? theme,
    Widget? home,
  }) {
    initialize();
    
    return GetMaterialApp(
      title: title,
      theme: theme ?? ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      getPages: [
        ...AuthRoutes.routes,
        ...additionalRoutes,
      ],
      // Middleware para verificar autenticación
      routingCallback: (routing) {
        final authController = Get.find<AuthController>();
        if (routing?.current != '/login' && 
            routing?.current != '/signup' && 
            routing?.current != '/' &&
            !authController.isLogged) {
          Get.offAllNamed('/');
        }
      },
    );
  }

  /// Obtiene el controlador de autenticación
  static AuthController get authController => Get.find<AuthController>();

  /// Verifica si el usuario está autenticado
  static bool get isAuthenticated => authController.isLogged;

  /// Navega a la página de autenticación
  static void goToAuth() => Get.offAllNamed('/');

  /// Navega al home después de autenticación
  static void goToHome() => Get.offAllNamed('/home');

  /// Cierra sesión
  static Future<void> logout() => authController.logOut();
}
