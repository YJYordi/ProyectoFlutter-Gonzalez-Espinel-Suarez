import 'package:proyecto/Domain/Entities/evaluation.dart';
import 'package:proyecto/Domain/repositories/course_repository.dart';

class CreateEvaluationUseCase {
  final CourseRepository repository;

  CreateEvaluationUseCase(this.repository);

  Future<EvaluationEntity> execute({
    required String courseId,
    required String categoryId,
    required String groupId,
    required String evaluatorUsername,
    required String evaluatedUsername,
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

    // Validar que no se esté evaluando a sí mismo
    if (evaluatorUsername == evaluatedUsername) {
      throw ArgumentError('No puedes evaluarte a ti mismo');
    }

    // Verificar que el evaluador esté en el grupo
    final category = await repository.getCategoryById(categoryId);
    if (category == null) {
      throw ArgumentError('La categoría no existe');
    }

    final group = category.groups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => throw ArgumentError('El grupo no existe'),
    );

    if (!group.members.contains(evaluatorUsername)) {
      throw ArgumentError('No estás inscrito en este grupo');
    }

    if (!group.members.contains(evaluatedUsername)) {
      throw ArgumentError('El usuario a evaluar no está en este grupo');
    }

    // Verificar que la evaluación no exista ya
    final existingEvaluation = await repository.getEvaluation(
      courseId: courseId,
      categoryId: categoryId,
      groupId: groupId,
      evaluatorUsername: evaluatorUsername,
      evaluatedUsername: evaluatedUsername,
    );

    if (existingEvaluation != null) {
      throw ArgumentError('Ya existe una evaluación para este usuario');
    }

    final evaluationId = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    final evaluation = EvaluationEntity(
      id: evaluationId,
      courseId: courseId,
      categoryId: categoryId,
      groupId: groupId,
      evaluatorUsername: evaluatorUsername,
      evaluatedUsername: evaluatedUsername,
      punctuality: punctuality,
      contributions: contributions,
      commitment: commitment,
      attitude: attitude,
      createdAt: now,
      updatedAt: now,
      isCompleted: punctuality > 0 || contributions > 0 || commitment > 0 || attitude > 0,
    );

    await repository.createEvaluation(evaluation);
    return evaluation;
  }
}
