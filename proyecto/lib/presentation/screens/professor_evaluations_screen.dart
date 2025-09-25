import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/Entities/category.dart';
import 'package:proyecto/Domain/Entities/evaluation.dart';
import 'package:proyecto/presentation/providers/evaluation_provider.dart';
import 'package:proyecto/presentation/widgets/star_rating_widget.dart';

class ProfessorEvaluationsScreen extends StatefulWidget {
  final CourseEntity course;
  final String professorUsername;

  const ProfessorEvaluationsScreen({
    super.key,
    required this.course,
    required this.professorUsername,
  });

  @override
  State<ProfessorEvaluationsScreen> createState() => _ProfessorEvaluationsScreenState();
}

class _ProfessorEvaluationsScreenState extends State<ProfessorEvaluationsScreen> {
  String? _selectedCategoryId;
  String? _selectedGroupId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvaluations();
  }

  Future<void> _loadEvaluations() async {
    final evaluationProvider = Provider.of<EvaluationProvider>(context, listen: false);
    
    // Cargar todas las evaluaciones del curso
    await evaluationProvider.loadPendingEvaluations(
      username: widget.professorUsername,
      courseId: widget.course.id,
    );

    setState(() {
      _isLoading = false;
    });
  }

  String _getUserName(String username) {
    return username.split('@')[0].replaceAll('.', ' ').toUpperCase();
  }

  Widget _buildCategoryFilter(List<CategoryEntity> categories) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrar por categoría:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Todas'),
                  selected: _selectedCategoryId == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategoryId = null;
                      _selectedGroupId = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ...categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(category.name),
                      selected: _selectedCategoryId == category.id,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryId = selected ? category.id : null;
                          _selectedGroupId = null;
                        });
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupFilter(CategoryEntity category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrar por grupo:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Todos'),
                  selected: _selectedGroupId == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedGroupId = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ...category.groups.map((group) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text('Grupo ${group.groupNumber}'),
                      selected: _selectedGroupId == group.id,
                      onSelected: (selected) {
                        setState(() {
                          _selectedGroupId = selected ? group.id : null;
                        });
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationSummary(List<EvaluationEntity> evaluations) {
    if (evaluations.isEmpty) {
      return const Center(
        child: Text(
          'No hay evaluaciones disponibles',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    final completedEvaluations = evaluations.where((e) => e.isCompleted).length;
    final totalEvaluations = evaluations.length;
    final progress = totalEvaluations > 0 ? completedEvaluations / totalEvaluations : 0.0;

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Resumen de Evaluaciones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              Text(
                '$completedEvaluations / $totalEvaluations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.blue[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}% completado',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationCard(EvaluationEntity evaluation) {
    final evaluatorName = _getUserName(evaluation.evaluatorUsername);
    final evaluatedName = _getUserName(evaluation.evaluatedUsername);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información de la evaluación
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: evaluation.isCompleted ? Colors.green[100] : Colors.orange[100],
                  child: Icon(
                    evaluation.isCompleted ? Icons.check : Icons.pending,
                    color: evaluation.isCompleted ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$evaluatorName → $evaluatedName',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${evaluation.evaluatorUsername} → ${evaluation.evaluatedUsername}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (evaluation.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Promedio: ${evaluation.averageScore.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Criterios de evaluación
            if (evaluation.isCompleted) ...[
              const Text(
                'Calificaciones:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ...EvaluationCriteriaEntity.defaultCriteria.map((criteria) {
                final rating = _getRatingForCriterion(evaluation, criteria.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: StarRatingDisplayWidget(
                    rating: rating,
                    criterion: criteria.name,
                    description: criteria.description,
                    spanishDescription: criteria.spanishDescriptions[rating] ?? 
                                      criteria.spanishDescriptions[1]!,
                  ),
                );
              }).toList(),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.orange[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Evaluación pendiente',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 8),
            
            // Fechas
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Creado: ${_formatDate(evaluation.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                if (evaluation.isCompleted) ...[
                  Icon(Icons.update, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Actualizado: ${_formatDate(evaluation.updatedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _getRatingForCriterion(EvaluationEntity evaluation, String criterionId) {
    switch (criterionId) {
      case 'punctuality':
        return evaluation.punctuality;
      case 'contributions':
        return evaluation.contributions;
      case 'commitment':
        return evaluation.commitment;
      case 'attitude':
        return evaluation.attitude;
      default:
        return 0;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  List<EvaluationEntity> _getFilteredEvaluations(List<EvaluationEntity> allEvaluations) {
    return allEvaluations.where((evaluation) {
      if (_selectedCategoryId != null && evaluation.categoryId != _selectedCategoryId) {
        return false;
      }
      if (_selectedGroupId != null && evaluation.groupId != _selectedGroupId) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evaluaciones - ${widget.course.title}'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<EvaluationProvider>(
              builder: (context, evaluationProvider, child) {
                // Obtener categorías del curso (esto debería venir de un provider)
                // Por ahora, usamos datos mock
                final categories = <CategoryEntity>[];
                
                final allEvaluations = evaluationProvider.pendingEvaluations;
                final filteredEvaluations = _getFilteredEvaluations(allEvaluations);
                
                return Column(
                  children: [
                    // Filtros
                    if (categories.isNotEmpty) ...[
                      _buildCategoryFilter(categories),
                      if (_selectedCategoryId != null) ...[
                        _buildGroupFilter(categories.firstWhere((c) => c.id == _selectedCategoryId)),
                      ],
                    ],
                    
                    // Resumen
                    _buildEvaluationSummary(filteredEvaluations),
                    
                    // Lista de evaluaciones
                    Expanded(
                      child: filteredEvaluations.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay evaluaciones que coincidan con los filtros',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredEvaluations.length,
                              itemBuilder: (context, index) {
                                return _buildEvaluationCard(filteredEvaluations[index]);
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
