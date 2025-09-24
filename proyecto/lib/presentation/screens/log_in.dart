import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/presentation/providers/auth_provider.dart';
import 'package:proyecto/presentation/screens/sign_up.dart';
import 'package:proyecto/data/datasources/persistent_data_source.dart';
import 'package:get/get.dart';

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
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _userController.text,
      _passController.text,
    );

    if (mounted) {
      if (success) {
        // Guardar configuración de recordar usuario
        await _dataSource.saveRememberUserSettings(
          rememberUser: _rememberUser,
          username: _rememberUser ? _userController.text : null,
          password: _rememberUser ? _passController.text : null,
        );

        if (mounted) {
          // Obtener el nombre real del usuario desde el AuthProvider
          final authProvider = context.read<AuthProvider>();
          final userName = authProvider.user?.name ?? _userController.text;

          // 👇 reemplazo de Navigator con GetX
          Get.offAllNamed('/home', arguments: userName);
        }
      } else {
        // 👇 reemplazo de showDialog con GetX
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
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
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
              onPressed: () {
                // 👇 reemplazo de Navigator con GetX
                Get.to(() => const SignUpPage());
              },
              child: const Text(
                '¿No tienes cuenta? Regístrate aquí',
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
