import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto/data/datasources/persistent_data_source.dart';
import 'package:proyecto/presentation/controllers/auth_controller.dart';
import 'sign_up.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _rememberUser = false;
  late PersistentDataSource _dataSource;
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _dataSource = PersistentDataSource();
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    final credentials = await _dataSource.getRememberedCredentials();
    if (credentials['username'] != null && credentials['password'] != null) {
      setState(() {
        _userController.text = credentials['username']!;
        _passController.text = credentials['password']!;
        _rememberUser = true;
      });
    }
  }

  void _login() async {
    await authController.login(_userController.text, _passController.text);

    if (authController.isLoggedIn) {
      await _dataSource.saveRememberUserSettings(
        rememberUser: _rememberUser,
        username: _rememberUser ? _userController.text : null,
        password: _rememberUser ? _passController.text : null,
      );
      // Central se encargará de mostrar HomePage
    } else {
      Get.dialog(
        AlertDialog(
          title: const Text('Error'),
          content: const Text('Usuario o contraseña incorrectos'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Obx(() {
          final isLoading = authController.isLoading.value;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, size: 80, color: Colors.blue[600]),
              const SizedBox(height: 20),
              Text(
                'Sistema de Cursos',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.blue[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _userController,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _rememberUser,
                    onChanged: (value) {
                      setState(() {
                        _rememberUser = value ?? false;
                      });
                    },
                  ),
                  const Text('Recordar usuario y contraseña'),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isLoading ? 'Iniciando...' : 'Iniciar Sesión',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.to(() => const SignUpPage()),
                child: const Text(
                  '¿No tienes cuenta? Regístrate aquí',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        }),
      ),
    );
  }
}
