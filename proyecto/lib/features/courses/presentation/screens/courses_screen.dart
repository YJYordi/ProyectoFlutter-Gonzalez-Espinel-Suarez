import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/features/auth/presentation/controllers/auth_controller.dart';
import 'package:proyecto/features/courses/presentation/providers/course_provider.dart';
import 'package:proyecto/features/courses/domain/entities/course.dart';
import 'package:proyecto/core/presentation/widgets/error_widget.dart';
import 'package:proyecto/core/domain/services/error_service.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cursos'),
        actions: [
          // Usar GetX para auth
          GetBuilder<AuthController>(
            builder: (authController) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  authController.logout();
                  Get.offAllNamed('/login');
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<CourseProvider>(
        builder: (context, courseProvider, child) {
          if (courseProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando cursos...'),
                ],
              ),
            );
          }

          if (courseProvider.courses.isEmpty) {
            return const AppErrorWidget(
              title: 'No hay cursos disponibles',
              message: 'No se encontraron cursos. Intenta crear uno nuevo o verifica tu conexión.',
              icon: Icons.school_outlined,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: courseProvider.courses.length,
            itemBuilder: (context, index) {
              final course = courseProvider.courses[index];
              return CourseCard(
                course: course,
                onEnroll: () => _enrollInCourse(context, courseProvider, course),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateCourseDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _enrollInCourse(BuildContext context, CourseProvider courseProvider, CourseEntity course) async {
    try {
      // Obtener usuario actual usando GetX
      final authController = Get.find<AuthController>();
      if (authController.user.value != null) {
        await courseProvider.enrollInCourse(
          courseId: course.id,
          username: authController.user.value!.username,
          userName: authController.user.value!.name,
        );
        
        AppSnackBar.showSuccess(context, 'Te has inscrito al curso exitosamente');
      } else {
        AppSnackBar.showError(context, 'Debes iniciar sesión para inscribirte');
      }
    } catch (e) {
      final error = ErrorService.handleGenericError(e);
      AppSnackBar.showError(context, error.message);
    }
  }

  void _showCreateCourseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateCourseDialog(),
    );
  }
}

class CourseCard extends StatelessWidget {
  final CourseEntity course;
  final VoidCallback onEnroll;

  const CourseCard({
    super.key,
    required this.course,
    required this.onEnroll,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del curso
            Text(
              course.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Información del creador
            Text(
              'Por: ${course.creatorName}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            
            // Descripción
            Text(
              course.description,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            
            // Categorías
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: course.categories.map<Widget>((category) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            // Información adicional
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${course.currentEnrollments}/${course.maxEnrollments} inscritos',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Text(
                  'Precio: \$${course.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Botón Inscribirse
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onEnroll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Inscribirse',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateCourseDialog extends StatefulWidget {
  @override
  _CreateCourseDialogState createState() => _CreateCourseDialogState();
}

class _CreateCourseDialogState extends State<CreateCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoriesController = TextEditingController();
  final _maxEnrollmentsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear Curso'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: (value) => value?.isEmpty == true ? 'Requerido' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              validator: (value) => value?.isEmpty == true ? 'Requerido' : null,
            ),
            TextFormField(
              controller: _categoriesController,
              decoration: const InputDecoration(labelText: 'Categorías (separadas por coma)'),
              validator: (value) => value?.isEmpty == true ? 'Requerido' : null,
            ),
            TextFormField(
              controller: _maxEnrollmentsController,
              decoration: const InputDecoration(labelText: 'Máximo de inscripciones'),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty == true ? 'Requerido' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => _createCourse(context),
          child: const Text('Crear'),
        ),
      ],
    );
  }

  void _createCourse(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        // Obtener usuario actual usando GetX
        final authController = Get.find<AuthController>();
        if (authController.user.value != null) {
          final courseProvider = Provider.of<CourseProvider>(context, listen: false);
          
          await courseProvider.createCourse(
            title: _titleController.text,
            description: _descriptionController.text,
            creatorUsername: authController.user.value!.username,
            creatorName: authController.user.value!.name,
            categories: _categoriesController.text.split(',').map((e) => e.trim()).toList(),
            maxEnrollments: int.parse(_maxEnrollmentsController.text),
            isRandomAssignment: false,
          );
          
          Navigator.pop(context);
          AppSnackBar.showSuccess(context, 'Curso creado exitosamente');
        } else {
          AppSnackBar.showError(context, 'Debes iniciar sesión para crear cursos');
        }
      } catch (e) {
        final error = ErrorService.handleGenericError(e);
        AppSnackBar.showError(context, error.message);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoriesController.dispose();
    _maxEnrollmentsController.dispose();
    super.dispose();
  }
}
