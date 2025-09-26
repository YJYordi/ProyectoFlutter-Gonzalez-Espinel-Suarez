import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto/features/course_management/domain/entities/course.dart';
import 'package:proyecto/features/course_management/domain/entities/course_enrollment.dart';
import 'package:proyecto/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:proyecto/features/course_management/presentation/controllers/course_controller.dart';
import 'package:proyecto/shared/presentation/controllers/role_controller.dart';
import 'package:proyecto/features/course_management/presentation/screens/course_management_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseEntity course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  List<CourseEnrollment> _enrollments = [];
  bool _isEnrolled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourseDetails();
  }

  Future<void> _loadCourseDetails() async {
    final courseController = Get.find<CourseController>();
    final authController = Get.find<AuthController>();

    if (authController.user != null) {
      final enrollments = await courseController.getCourseEnrollments(
        widget.course.id,
      );
      final isEnrolled = await courseController.isUserEnrolledInCourse(
        widget.course.id,
        authController.user!.username,
      );

      setState(() {
        _enrollments = enrollments;
        _isEnrolled = isEnrolled;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _enrollInCourse() async {
    final authController = Get.find<AuthController>();
    final courseController = Get.find<CourseController>();

    if (authController.user != null) {
      try {
        await courseController.enrollInCourse(
          widget.course.id,
          authController.user!.username,
          authController.user!.name,
        );
        await _loadCourseDetails();
      } catch (e) {
        if (mounted) {
          Get.snackbar('Error', e.toString());
        }
      }
    }
  }

  Future<void> _deleteCourse() async {
    final authController = Get.find<AuthController>();
    final courseController = Get.find<CourseController>();

    if (authController.user != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Eliminar curso'),
          content: const Text(
            '¿Estás seguro de que quieres eliminar este curso? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        try {
          await courseController.deleteCourse(widget.course.id);
          if (mounted) {
            Get.back();
          }
        } catch (e) {
          if (mounted) {
            Get.snackbar('Error', e.toString());
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final roleController = Get.find<RoleController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Botón de gestión - solo para el creador del curso
          if (authController.user?.username == widget.course.creatorUsername)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Get.to(
                  () => CourseManagementScreen(
                    course: widget.course,
                    currentUser: authController.user!,
                  ),
                );
              },
              child: const Text('Gestionar'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del curso
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.course.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Creado por: ${widget.course.creatorName} (@${widget.course.creatorUsername})',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Descripción:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.course.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          // Tags
                          const Text(
                            'Tags:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.course.categories.map((category) {
                              return Chip(
                                label: Text(category),
                                backgroundColor: Colors.blue[100],
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          // Información de inscripciones
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Inscripciones: ${_enrollments.length}/${widget.course.maxEnrollments}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Creado: ${_formatDate(widget.course.createdAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botones de acción
                  Obx(() {
                    final isCreator =
                        authController.user?.username ==
                        widget.course.creatorUsername;
                    final isProfessor = roleController.isProfessor;

                    return Row(
                      children: [
                        // Si es el creador del curso, mostrar botón "Gestionar"
                        if (isCreator)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Get.to(
                                  () => CourseManagementScreen(
                                    course: widget.course,
                                    currentUser: authController.user!,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text('Gestionar'),
                            ),
                          )
                        // Si es profesor pero no es el creador, mostrar mensaje
                        else if (isProfessor)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.grey[600],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                'Cambiar a vista de estudiante',
                              ),
                            ),
                          )
                        // Si es estudiante y no está inscrito
                        else if (!_isEnrolled &&
                            _enrollments.length < widget.course.maxEnrollments)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _enrollInCourse,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text('Inscribirse'),
                            ),
                          )
                        // Si está inscrito
                        else if (_isEnrolled)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Get.to(
                                  () => CourseManagementScreen(
                                    course: widget.course,
                                    currentUser: authController.user!,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text('Empezar'),
                            ),
                          )
                        // Si el curso está lleno
                        else
                          Expanded(
                            child: ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text('Curso lleno'),
                            ),
                          ),
                      ],
                    );
                  }),

                  // Botón de eliminar (solo para el creador)
                  if (authController.user?.username ==
                      widget.course.creatorUsername) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _deleteCourse,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                        ),
                        child: const Icon(Icons.delete),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Lista de usuarios inscritos
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Usuarios Inscritos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_enrollments.isEmpty)
                            const Text(
                              'No hay usuarios inscritos aún.',
                              style: TextStyle(color: Colors.grey),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _enrollments.length,
                              itemBuilder: (context, index) {
                                final enrollment = _enrollments[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text(
                                      enrollment.userName[0].toUpperCase(),
                                    ),
                                  ),
                                  title: Text(enrollment.userName),
                                  subtitle: Text('@${enrollment.username}'),
                                  trailing: Text(
                                    _formatDate(enrollment.enrolledAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
