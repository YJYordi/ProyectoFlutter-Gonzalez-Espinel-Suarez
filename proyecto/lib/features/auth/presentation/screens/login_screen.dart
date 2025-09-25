import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto/features/auth/presentation/controllers/auth_controller.dart';
import 'package:proyecto/core/presentation/widgets/error_widget.dart';
import 'package:proyecto/core/domain/services/error_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) => value?.isEmpty == true ? 'Requerido' : null,
              ),
              const SizedBox(height: 24),
              // Usar GetX para manejar el estado de auth
              GetBuilder<AuthController>(
                builder: (authController) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: authController.isLoading
                              ? null
                              : () => _login(authController),
                          child: authController.isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Iniciar Sesión'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Get.toNamed('/register'),
                        child: const Text('¿No tienes cuenta? Regístrate'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login(AuthController authController) async {
    if (_formKey.currentState!.validate()) {
      try {
        await authController.login(
          _usernameController.text,
          _passwordController.text,
        );
        
        // Verificar si el login fue exitoso
        if (authController.isLoggedIn) {
          AppSnackBar.showSuccess(context, '¡Bienvenido!');
          Get.offAllNamed('/home');
        }
      } catch (e) {
        final error = ErrorService.handleGenericError(e);
        AppSnackBar.showError(context, error.message);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
