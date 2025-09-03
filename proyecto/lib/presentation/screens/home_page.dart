import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String usuario =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'Usuario';

    // Ejemplo de cursos
    final cursos = [
      {'titulo': 'Flutter Básico', 'descripcion': 'Aprende Flutter desde cero'},
      {
        'titulo': 'Dart Intermedio',
        'descripcion': 'Mejora tus habilidades en Dart',
      },
      {'titulo': 'UI Avanzada', 'descripcion': 'Crea interfaces atractivas'},
      {
        'titulo': 'Backend con Firebase',
        'descripcion': 'Conecta tu app a la nube',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido $usuario',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Cursos disponibles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: cursos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final curso = cursos[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        width: 220,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              curso['titulo']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              curso['descripcion']!,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text('Ver curso'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Categorías',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.code),
                    title: const Text('Frontend'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.storage),
                    title: const Text('Backend'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.design_services),
                    title: const Text('UI/UX'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.web),
                    title: const Text('Diseño Web'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.developer_mode),
                    title: const Text('Desarrollo Web'),
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
