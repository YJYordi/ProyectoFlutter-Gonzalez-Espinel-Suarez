import 'package:proyecto/Domain/Entities/evaluation.dart';
import 'package:proyecto/Domain/repositories/course_repository.dart';

class UpdateEvaluationUseCase {
  final CourseRepository repository;

  UpdateEvaluationUseCase(this.repository);

  Future<EvaluationEntity> execute({
    required String evaluationId,
    required int punctuality,
    required int contributions,
    required int commitment,
    required int attitude,
  }) async {
    // Validar que las calificaciones estén en el rango correcto
    if (punctuality < 0 || punctuality > 5 ||
        contributions < 0 || contributions > 5 ||
        commitment < 0 || commitment > 5 ||
        attitude < 0 || attitude > 5) {
      throw ArgumentError('Las calificaciones deben estar entre 0 y 5 estrellas');
    }

    // Obtener la evaluación existente
    final existingEvaluation = await repository.getEvaluationById(evaluationId);
    if (existingEvaluation == null) {
      throw ArgumentError('La evaluación no existe');
    }

    // Verificar que la evaluación no esté vencida
    final category = await repository.getCategoryById(existingEvaluation.categoryId);
    if (category == null) {
      throw ArgumentError('La categoría no existe');
    }

    if (category.evaluationEndDate != null && 
        DateTime.now().isAfter(category.evaluationEndDate!)) {
      throw ArgumentError('El período de evaluación ha terminado');
    }

    // Crear la evaluación actualizada
    final updatedEvaluation = existingEvaluation.copyWith(
      punctuality: punctuality,
      contributions: contributions,
      commitment: commitment,
      attitude: attitude,
      updatedAt: DateTime.now(),
      isCompleted: punctuality > 0 || contributions > 0 || commitment > 0 || attitude > 0,
    );

    await repository.updateEvaluation(updatedEvaluation);
    return updatedEvaluation;
  }
}
