import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto/features/evaluation_system/domain/entities/evaluation.dart';
import 'package:proyecto/features/course_management/domain/entities/course.dart';
import 'package:proyecto/features/category_management/domain/entities/category.dart';
import 'package:proyecto/features/evaluation_system/presentation/controllers/evaluation_controller.dart';
import 'package:proyecto/features/evaluation_system/presentation/screens/evaluation_screen.dart';

class PendingEvaluationsScreen extends StatefulWidget {
  final String username;

  const PendingEvaluationsScreen({super.key, required this.username});

  @override
  State<PendingEvaluationsScreen> createState() =>
      _PendingEvaluationsScreenState();
}

class _PendingEvaluationsScreenState extends State<PendingEvaluationsScreen> {
  String? _selectedCourseId;
  String? _selectedCategoryId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvaluations();
  }

  Future<void> _loadEvaluations() async {
    final evaluationController = Get.find<EvaluationController>();

    await evaluationController.loadPendingEvaluations(
      username: widget.username,
      courseId: _selectedCourseId,
      categoryId: _selectedCategoryId,
    );

    setState(() {
      _isLoading = false;
    });
  }

  String _getUserName(String username) {
    return username.split('@')[0].replaceAll('.', ' ').toUpperCase();
  }

  Widget _buildEvaluationCard(EvaluationEntity evaluation) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange[100],
          child: const Icon(Icons.assignment, color: Colors.orange),
        ),
        title: Text(
          'Evaluar a: ${_getUserName(evaluation.evaluatedUsername)}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(evaluation.evaluatedUsername),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Creado: ${_formatDate(evaluation.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _navigateToEvaluation(evaluation);
        },
      ),
    );
  }

  Widget _buildCompletedEvaluationCard(EvaluationEntity evaluation) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: const Icon(Icons.check, color: Colors.green),
        ),
        title: Text(
          'Evaluado: ${_getUserName(evaluation.evaluatedUsername)}',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.green[700],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              evaluation.evaluatedUsername,
              style: TextStyle(color: Colors.green[600]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber[600]),
                const SizedBox(width: 4),
                Text(
                  'Promedio: ${evaluation.averageScore.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.update, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Actualizado: ${_formatDate(evaluation.updatedAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _navigateToEvaluation(evaluation);
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Obx(() {
      final evaluationController = Get.find<EvaluationController>();
      // Obtener cursos únicos de las evaluaciones
      final courses = evaluationController.pendingEvaluations
          .map((e) => e.courseId)
          .toSet()
          .toList();

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('Todos'),
              selected: _selectedCourseId == null,
              onSelected: (selected) {
                setState(() {
                  _selectedCourseId = null;
                  _selectedCategoryId = null;
                });
                _loadEvaluations();
              },
            ),
            const SizedBox(width: 8),
            ...courses.map((courseId) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text('Curso $courseId'),
                  selected: _selectedCourseId == courseId,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCourseId = selected ? courseId : null;
                      _selectedCategoryId = null;
                    });
                    _loadEvaluations();
                  },
                ),
              );
            }).toList(),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay evaluaciones pendientes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Todas las evaluaciones han sido completadas',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _navigateToEvaluation(EvaluationEntity evaluation) async {
    // En un sistema real, necesitarías obtener el curso y categoría
    // Por ahora, creamos objetos mock
    final course = CourseEntity(
      id: evaluation.courseId,
      title: 'Curso ${evaluation.courseId}',
      description: 'Descripción del curso',
      creatorUsername: 'profesor@ejemplo.com',
      creatorName: 'Profesor',
      categories: ['Programación'],
      maxEnrollments: 30,
      currentEnrollments: 10,
      createdAt: DateTime.now(),
      schedule: 'Lunes y Miércoles',
      location: 'Aula 101',
      price: 0.0,
      isRandomAssignment: true,
      groupSize: 5,
    );

    final category = CategoryEntity(
      id: evaluation.categoryId,
      courseId: evaluation.courseId,
      name: 'Categoría ${evaluation.categoryId}',
      numberOfGroups: 3,
      isRandomAssignment: true,
      createdAt: DateTime.now(),
      groups: [
        GroupEntity(
          id: evaluation.groupId,
          categoryId: evaluation.categoryId,
          groupNumber: 1,
          members: [evaluation.evaluatorUsername, evaluation.evaluatedUsername],
          maxMembers: 10,
        ),
      ],
    );

    final group = category.groups.first;

    if (mounted) {
      await Get.to(
        () => EvaluationScreen(
          course: course,
          category: category,
          group: group,
          evaluatorUsername: evaluation.evaluatorUsername,
        ),
      );

      // Recargar evaluaciones al regresar
      _loadEvaluations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluaciones'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filtrar por curso:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                _buildFilterChips(),
              ],
            ),
          ),

          // Contenido
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Obx(() {
                    final evaluationController =
                        Get.find<EvaluationController>();
                    if (evaluationController.pendingEvaluations.isEmpty &&
                        evaluationController.completedEvaluations.isEmpty) {
                      return _buildEmptyState();
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Evaluaciones pendientes
                          if (evaluationController
                              .pendingEvaluations
                              .isNotEmpty) ...[
                            const Text(
                              'Evaluaciones Pendientes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...evaluationController.pendingEvaluations
                                .map(
                                  (evaluation) =>
                                      _buildEvaluationCard(evaluation),
                                )
                                .toList(),
                            const SizedBox(height: 24),
                          ],

                          // Evaluaciones completadas
                          if (evaluationController
                              .completedEvaluations
                              .isNotEmpty) ...[
                            const Text(
                              'Evaluaciones Completadas',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...evaluationController.completedEvaluations
                                .map(
                                  (evaluation) =>
                                      _buildCompletedEvaluationCard(evaluation),
                                )
                                .toList(),
                          ],
                        ],
                      ),
                    );
                  }),
          ),
        ],
      ),
    );
  }
}
