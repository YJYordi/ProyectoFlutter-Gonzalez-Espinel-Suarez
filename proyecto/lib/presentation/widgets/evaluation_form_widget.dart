import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/Domain/Entities/evaluation.dart';
import 'package:proyecto/presentation/providers/evaluation_provider.dart';
import 'package:proyecto/presentation/widgets/star_rating_widget.dart';

class EvaluationFormWidget extends StatefulWidget {
  final String courseId;
  final String categoryId;
  final String groupId;
  final String evaluatorUsername;
  final String evaluatedUsername;
  final String evaluatedUserName;
  final EvaluationEntity? existingEvaluation;
  final VoidCallback? onSaved;

  const EvaluationFormWidget({
    super.key,
    required this.courseId,
    required this.categoryId,
    required this.groupId,
    required this.evaluatorUsername,
    required this.evaluatedUsername,
    required this.evaluatedUserName,
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

  @override
  void initState() {
    super.initState();
    _initializeRatings();
  }

  void _initializeRatings() {
    if (widget.existingEvaluation != null) {
      _ratings['punctuality'] = widget.existingEvaluation!.punctuality;
      _ratings['contributions'] = widget.existingEvaluation!.contributions;
      _ratings['commitment'] = widget.existingEvaluation!.commitment;
      _ratings['attitude'] = widget.existingEvaluation!.attitude;
    }
  }

  void _updateRating(String criterion, int rating) {
    setState(() {
      _ratings[criterion] = rating;
    });
  }

  bool get _isFormValid {
    return _ratings.values.every((rating) => rating > 0);
  }

  Future<void> _saveEvaluation() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, califica todos los criterios'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final evaluationProvider = Provider.of<EvaluationProvider>(context, listen: false);
    
    try {
      if (widget.existingEvaluation != null) {
        // Actualizar evaluación existente
        await evaluationProvider.updateEvaluation(
          evaluationId: widget.existingEvaluation!.id,
          punctuality: _ratings['punctuality']!,
          contributions: _ratings['contributions']!,
          commitment: _ratings['commitment']!,
          attitude: _ratings['attitude']!,
        );
      } else {
        // Crear nueva evaluación
        await evaluationProvider.createEvaluation(
          courseId: widget.courseId,
          categoryId: widget.categoryId,
          groupId: widget.groupId,
          evaluatorUsername: widget.evaluatorUsername,
          evaluatedUsername: widget.evaluatedUsername,
          punctuality: _ratings['punctuality']!,
          contributions: _ratings['contributions']!,
          commitment: _ratings['commitment']!,
          attitude: _ratings['attitude']!,
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
    return Consumer<EvaluationProvider>(
      builder: (context, evaluationProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      widget.evaluatedUserName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Evaluando a: ${widget.evaluatedUserName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.evaluatedUsername,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Instrucciones
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Califica cada criterio de 1 a 5 estrellas. Todas las calificaciones son obligatorias.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Criterios de evaluación
              ...EvaluationCriteriaEntity.defaultCriteria.map((criteria) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: StarRatingWidget(
                    initialRating: _ratings[criteria.id]!,
                    onRatingChanged: (rating) => _updateRating(criteria.id, rating),
                    criterion: criteria.name,
                    description: criteria.description,
                    spanishDescription: criteria.spanishDescriptions[_ratings[criteria.id]!] ?? 
                                      criteria.spanishDescriptions[1]!,
                  ),
                );
              }).toList(),
              
              const SizedBox(height: 32),
              
              // Botón de guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: evaluationProvider.isLoading ? null : _saveEvaluation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormValid ? Colors.green : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: evaluationProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                ),
              ),
              
              // Progreso de la evaluación
              if (evaluationProvider.evaluations.isNotEmpty) ...[
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
                            '${(evaluationProvider.evaluationProgress * 100).toInt()}%',
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
                        value: evaluationProvider.evaluationProgress,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
