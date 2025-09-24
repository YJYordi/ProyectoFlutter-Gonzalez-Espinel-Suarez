import 'package:proyecto/Domain/Entities/category.dart';
import 'package:proyecto/Domain/Entities/evaluation.dart';
import 'package:proyecto/Domain/repositories/course_repository.dart';

class StartEvaluationSessionUseCase {
  final CourseRepository repository;

  StartEvaluationSessionUseCase(this.repository);

  Future<CategoryEntity> execute({
    required String categoryId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Validar que la categoría exista
    final category = await repository.getCategoryById(categoryId);
    if (category == null) {
      throw ArgumentError('La categoría no existe');
    }

    // Validar que la fecha de inicio sea anterior a la fecha de fin
    if (startDate.isAfter(endDate)) {
      throw ArgumentError('La fecha de inicio debe ser anterior a la fecha de fin');
    }

    // Validar que la fecha de inicio no sea en el pasado
    if (startDate.isBefore(DateTime.now())) {
      throw ArgumentError('La fecha de inicio no puede ser en el pasado');
    }

    // Actualizar la categoría con las fechas de evaluación
    final updatedCategory = category.copyWith(
      evaluationStartDate: startDate,
      evaluationEndDate: endDate,
      isEvaluationActive: true,
    );

    await repository.updateCategory(updatedCategory);

    // Crear evaluaciones para todos los grupos de la categoría
    for (final group in category.groups) {
      await _createEvaluationsForGroup(updatedCategory, group);
    }

    return updatedCategory;
  }

  Future<void> _createEvaluationsForGroup(CategoryEntity category, GroupEntity group) async {
    // Para cada miembro del grupo, crear evaluaciones para todos los demás miembros
    for (final evaluator in group.members) {
      for (final evaluated in group.members) {
        if (evaluator != evaluated) {
          // Verificar si la evaluación ya existe
          final existingEvaluation = await repository.getEvaluation(
            courseId: category.courseId,
            categoryId: category.id,
            groupId: group.id,
            evaluatorUsername: evaluator,
            evaluatedUsername: evaluated,
          );

          if (existingEvaluation == null) {
            // Crear evaluación pendiente
            final evaluationId = DateTime.now().millisecondsSinceEpoch.toString() + 
                                '_${evaluator}_${evaluated}';
            final now = DateTime.now();

            final evaluation = EvaluationEntity(
              id: evaluationId,
              courseId: category.courseId,
              categoryId: category.id,
              groupId: group.id,
              evaluatorUsername: evaluator,
              evaluatedUsername: evaluated,
              punctuality: 0,
              contributions: 0,
              commitment: 0,
              attitude: 0,
              createdAt: now,
              updatedAt: now,
              isCompleted: false,
            );

            await repository.createEvaluation(evaluation);
          }
        }
      }
    }
  }
}
