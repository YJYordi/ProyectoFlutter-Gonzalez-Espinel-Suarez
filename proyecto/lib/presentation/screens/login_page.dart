import 'package:flutter/material.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/local_datasource.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginUseCase loginUseCase;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _message = "";

  @override
  void initState() {
    super.initState();
    loginUseCase = LoginUseCase(AuthRepositoryImpl(LocalDataSource()));
  }

  Future<void> _onLogin() async {
    final success = await loginUseCase(
      _usernameController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _message = success ? "Login successful 🎉" : "Invalid credentials ❌";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _onLogin, child: const Text("Login")),
            const SizedBox(height: 20),
            Text(_message),
          ],
        ),
      ),
    );
  }
}
