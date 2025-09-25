import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../auth.dart';
import 'auth_integration.dart';

/// Ejemplo de cómo usar el feature auth sin tocar el main.dart existente
///
/// Para usar este feature auth en tu proyecto:
///
/// 1. En tu main.dart, importa AuthIntegration:
///    import 'features/auth/integration/auth_integration.dart';
///
/// 2. Reemplaza tu MaterialApp con GetMaterialApp usando AuthIntegration:
///    return AuthIntegration.createGetMaterialApp(
///      title: 'Tu App',
///      initialRoute: '/',
///      additionalRoutes: [
///        GetPage(name: '/home', page: () => HomePage()),
///        // ... otras rutas
///      ],
///    );
///
/// 3. Usa el controlador de auth donde necesites:
///    final authController = AuthIntegration.authController;
///    if (AuthIntegration.isAuthenticated) {
///      // Usuario autenticado
///    }

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthIntegration.createGetMaterialApp(
      title: 'Mi App con Auth',
      initialRoute: '/',
      additionalRoutes: [
        GetPage(
          name: '/',
          page: () => const AuthPage(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/home',
          page: () => const ExampleHomePage(),
          transition: Transition.fadeIn,
        ),
      ],
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthIntegration.logout(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              '¡Bienvenido!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Estado de autenticación: ${AuthIntegration.isAuthenticated ? "Autenticado" : "No autenticado"}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => AuthIntegration.logout(),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
