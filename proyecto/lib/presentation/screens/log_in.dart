import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/presentation/providers/auth_provider.dart';
import 'package:proyecto/presentation/screens/sign_up.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _rememberUser = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    // Get data source from AuthProvider
    final authProvider = context.read<AuthProvider>();
    final credentials = await authProvider.getRememberedCredentials();
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
    final success = await auth.login(_userController.text, _passController.text);
    
    if (mounted) {
      if (success) {
        // Guardar configuración de recordar usuario
        await auth.saveRememberUserSettings(
          rememberUser: _rememberUser,
          username: _rememberUser ? _userController.text : null,
          password: _rememberUser ? _passController.text : null,
        );
        
        if (mounted) {
          // Obtener el nombre real del usuario desde el AuthProvider
          final authProvider = context.read<AuthProvider>();
          final userName = authProvider.user?.name ?? _userController.text;
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: userName,
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Usuario o contraseña incorrectos'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
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
            // Logo o título principal
            Icon(
              Icons.school,
              size: 80,
              color: Colors.blue[600],
            ),
            const SizedBox(height: 20),
            Text(
              'Sistema de Cursos',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.blue[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            
            // Campo de usuario
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
            
            // Campo de contraseña
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
            
            // Checkbox para recordar usuario
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
            
            // Botón de login
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
            
            // Botón de registro
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SignUpPage()),
                );
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
