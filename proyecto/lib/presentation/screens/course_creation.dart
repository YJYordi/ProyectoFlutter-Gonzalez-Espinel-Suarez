import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/presentation/providers/course_provider.dart';
import 'package:proyecto/presentation/providers/auth_provider.dart';

class CourseCreationScreen extends StatefulWidget {
  const CourseCreationScreen({super.key});

  @override
  State<CourseCreationScreen> createState() => _CourseCreationScreenState();
}

class _CourseCreationScreenState extends State<CourseCreationScreen> {
  int _selectedIndex = 0;
  final _formKey = GlobalKey<FormState>();
  final _courseTitleController = TextEditingController();
  final _courseDescriptionController = TextEditingController();
  final _maxEnrollmentsController = TextEditingController(text: '20');
  
  // Removed random assignment toggle and group size

  final List<String> _availableCategories = [
    'Desarrollo Backend',
    'Desarrollo Frontend', 
    'Desarrollo Full Stack',
    'Desarrollo Web',
    'Docker',
    'Diseño Web',
    'UX/UI',
    'Bases de Datos',
    'Flutter Básico',
    'Flutter Intermedio',
    'Flutter Avanzado',
  ];
  
  List<String> _selectedCategories = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Curso'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título del curso
              TextFormField(
                controller: _courseTitleController,
                decoration: const InputDecoration(
                  labelText: 'Título del Curso',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título para el curso';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Descripción del curso
              TextFormField(
                controller: _courseDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción del Curso',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción para el curso';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Límite de inscripciones
              TextFormField(
                controller: _maxEnrollmentsController,
                decoration: const InputDecoration(
                  labelText: 'Límite de Inscripciones',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el límite de inscripciones';
                  }
                  final n = int.tryParse(value);
                  if (n == null || n < 1) {
                    return 'El límite debe ser un número mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Tags
              const Text(
                'Tags',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableCategories.map((category) {
                  final isSelected = _selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(category);
                        } else {
                          _selectedCategories.remove(category);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nuevo tag',
                        border: OutlineInputBorder(),
                      ),
                      onFieldSubmitted: (value) {
                        if (value.isNotEmpty && !_availableCategories.contains(value)) {
                          setState(() {
                            _availableCategories.add(value);
                            _selectedCategories.add(value);
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // El botón no hace nada, la categoría se añade al presionar Enter
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    child: const Text('Añadir'),
                  ),
                ],
              ),
              if (_selectedCategories.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Debes seleccionar al menos un tag',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 30),
              
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _createCourse,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Crear Curso'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Navegación a otras pantallas (por implementar)
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Contactos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Pendientes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }


  void _createCourse() async {
    if (_formKey.currentState!.validate() && _selectedCategories.isNotEmpty) {
      final courseTitle = _courseTitleController.text;
      final courseDescription = _courseDescriptionController.text;
      final maxEnrollments = int.parse(_maxEnrollmentsController.text);

      final authProvider = context.read<AuthProvider>();
      final courseProvider = context.read<CourseProvider>();
      
      if (authProvider.user != null) {
        try {
          await courseProvider.createCourse(
            title: courseTitle,
            description: courseDescription,
            creatorUsername: authProvider.user!.username,
            creatorName: authProvider.user!.name,
            categories: _selectedCategories,
            maxEnrollments: maxEnrollments,
            isRandomAssignment: false, // Default to false since we removed the toggle
            groupSize: null, // Default to null since we removed group size input
          );
          if (mounted) {
            Navigator.of(context).pop();
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _courseTitleController.dispose();
    _courseDescriptionController.dispose();
    _maxEnrollmentsController.dispose();
    super.dispose();
  }
}