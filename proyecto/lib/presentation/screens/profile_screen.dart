import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String usuario;
  const ProfileScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          children: [
            // Foto/Icono usuario
            Center(
              child: CircleAvatar(
                radius: 48,
                child: Text(
                  usuario.isNotEmpty ? usuario[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Nombre usuario
            Center(
              child: Text(
                usuario,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Botones alineados a la izquierda
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('Información personal'),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Privacidad')),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Eliminar cuenta'),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Botón cerrar sesión centrado y rojo
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(180, 48),
                ),
                onPressed: () {
                  // Aquí puedes limpiar el estado de sesión si lo tienes
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
                child: const Text('Cerrar sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
