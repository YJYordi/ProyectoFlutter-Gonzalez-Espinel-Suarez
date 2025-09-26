import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto/features/evaluation_system/domain/entities/evaluation.dart';
import 'package:proyecto/features/evaluation_system/presentation/controllers/evaluation_controller.dart';

class EvaluationFormWidget extends StatefulWidget {
  final String courseId;
  final String categoryId;
  final String groupId;
  final String evaluatorUsername;
  final String evaluatedUsername;
  final EvaluationEntity? existingEvaluation;
  final VoidCallback? onSaved;

  const EvaluationFormWidget({
    super.key,
    required this.courseId,
    required this.categoryId,
    required this.groupId,
    required this.evaluatorUsername,
    required this.evaluatedUsername,
    this.existingEvaluation,
    this.onSaved,
  });

  @override
  State<EvaluationFormWidget> createState() => _EvaluationFormWidgetState();
}

class _EvaluationFormWidgetState extends State<EvaluationFormWidget> {
  final Map<String, int> _ratings = {
    'punctuality': 0,
    'contributions': 0,
    'commitment': 0,
    'attitude': 0,
  };

  bool get _isFormValid {
    return _ratings.values.any((rating) => rating > 0);
  }

  Future<void> _saveEvaluation() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, califica al menos un criterio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final evaluationController = Get.find<EvaluationController>();

    try {
      if (widget.existingEvaluation != null) {
        // Actualizar evaluación existente
        await evaluationController.updateEvaluation(
          evaluationId: widget.existingEvaluation!.id,
          ratings: _ratings,
        );
      } else {
        // Crear nueva evaluación
        await evaluationController.createEvaluation(
          evaluatorId: widget.evaluatorUsername,
          evaluatedId: widget.evaluatedUsername,
          groupId: widget.groupId,
          courseId: widget.courseId,
          categoryId: widget.categoryId,
          ratings: _ratings,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evaluación guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        if (widget.onSaved != null) {
          widget.onSaved!();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar evaluación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            'Evaluar a ${widget.evaluatedUsername}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Criterios de evaluación
          ...EvaluationCriteriaEntity.defaultCriteria.map((criteria) {
            return _buildRatingCriterion(criteria);
          }),

          const SizedBox(height: 32),

          // Botón de guardar
          SizedBox(
            width: double.infinity,
            child: Obx(() {
              final evaluationController = Get.find<EvaluationController>();
              return ElevatedButton(
                onPressed: evaluationController.isLoading
                    ? null
                    : _saveEvaluation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid ? Colors.green : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: evaluationController.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save),
                          const SizedBox(width: 8),
                          Text(
                            widget.existingEvaluation != null
                                ? 'Actualizar Evaluación'
                                : 'Guardar Evaluación',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              );
            }),
          ),

          // Progreso de la evaluación
          Obx(() {
            final evaluationController = Get.find<EvaluationController>();
            if (evaluationController.evaluations.isNotEmpty) {
              return Column(
                children: [
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Progreso de evaluación:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${(evaluationController.evaluationProgress * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: evaluationController.evaluationProgress,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildRatingCriterion(EvaluationCriteriaEntity criteria) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            criteria.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            criteria.description,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final rating = index + 1;
              final isSelected = _ratings[criteria.id] == rating;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _ratings[criteria.id] = rating;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: isSelected ? Colors.white : Colors.grey[400],
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$rating',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          if (_ratings[criteria.id]! > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
                criteria.spanishDescriptions[_ratings[criteria.id]] ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[800],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
