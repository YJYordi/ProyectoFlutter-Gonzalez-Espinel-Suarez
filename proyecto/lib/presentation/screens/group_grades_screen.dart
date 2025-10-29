import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/Entities/evaluation.dart';
import 'package:proyecto/presentation/providers/course_provider.dart';
import 'package:proyecto/presentation/providers/evaluation_provider.dart';

class GroupGradesScreen extends StatefulWidget {
  final CourseEntity course;
  final String professorUsername;

  const GroupGradesScreen({
    super.key,
    required this.course,
    required this.professorUsername,
  });

  @override
  State<GroupGradesScreen> createState() => _GroupGradesScreenState();
}

class _GroupGradesScreenState extends State<GroupGradesScreen> {
  String? _selectedCategoryId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    await courseProvider.loadCourses();
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildCategorySelector() {
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        // Obtener categorías del curso
        final categories = courseProvider.courses
            .where((c) => c.id == widget.course.id)
            .expand((c) => c.categories)
            .toSet()
            .toList();

        if (categories.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No hay categorías disponibles en este curso'),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seleccionar Categoría:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Todas'),
                      selected: _selectedCategoryId == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryId = null;
                        });
                      },
                    ),
                    ...categories.map((category) {
                      return FilterChip(
                        label: Text(category),
                        selected: _selectedCategoryId == category,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryId = selected ? category : null;
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupGradesCard(String categoryName, List<EvaluationEntity> evaluations) {
    // Agrupar evaluaciones por grupo
    final Map<String, List<EvaluationEntity>> groupEvaluations = {};
    
    for (final evaluation in evaluations) {
      final groupKey = '${evaluation.groupId}';
      groupEvaluations.putIfAbsent(groupKey, () => []).add(evaluation);
    }

    if (groupEvaluations.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.group_off, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'No hay evaluaciones en esta categoría',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categoría: $categoryName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...groupEvaluations.entries.map((entry) {
              final groupId = entry.key;
              final groupEvals = entry.value;
              
              // Calcular promedio del grupo
              final totalScore = groupEvals.fold<double>(0, (sum, eval) => sum + eval.averageScore);
              final averageScore = groupEvals.isNotEmpty ? totalScore / groupEvals.length : 0.0;
              
              // Obtener estudiantes únicos en el grupo
              final students = groupEvals.map((e) => e.evaluatedUsername).toSet().toList();
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Grupo $groupId',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getScoreColor(averageScore),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Promedio: ${averageScore.toStringAsFixed(1)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Estudiantes: ${students.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: students.map((student) {
                        return Chip(
                          label: Text(
                            student,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.blue[100],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Evaluaciones completadas: ${groupEvals.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 4.0) return Colors.green;
    if (score >= 3.0) return Colors.orange;
    return Colors.red;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assessment_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay evaluaciones disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las evaluaciones aparecerán cuando los estudiantes las completen',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Promedios - ${widget.course.title}'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Selector de categoría
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildCategorySelector(),
                ),
                
                // Contenido
                Expanded(
                  child: Consumer<EvaluationProvider>(
                    builder: (context, evaluationProvider, child) {
                      // Filtrar evaluaciones por curso y categoría
                      List<EvaluationEntity> filteredEvaluations = evaluationProvider.completedEvaluations
                          .where((eval) => eval.courseId == widget.course.id)
                          .toList();

                      if (_selectedCategoryId != null) {
                        // Filtrar por categoría específica si está seleccionada
                        filteredEvaluations = filteredEvaluations
                            .where((eval) => eval.categoryId == _selectedCategoryId)
                            .toList();
                      }

                      if (filteredEvaluations.isEmpty) {
                        return _buildEmptyState();
                      }

                      // Agrupar por categoría
                      final Map<String, List<EvaluationEntity>> categoryEvaluations = {};
                      for (final evaluation in filteredEvaluations) {
                        categoryEvaluations.putIfAbsent(evaluation.categoryId, () => []).add(evaluation);
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: categoryEvaluations.entries.map((entry) {
                            return _buildGroupGradesCard(entry.key, entry.value);
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
