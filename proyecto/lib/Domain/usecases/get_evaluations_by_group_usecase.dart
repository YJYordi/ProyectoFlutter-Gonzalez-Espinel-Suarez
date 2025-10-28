import 'package:proyecto/Domain/Entities/evaluation.dart';
import 'package:proyecto/Domain/repositories/course_repository.dart';

class GetEvaluationsByGroupUseCase {
  final CourseRepository repository;

  GetEvaluationsByGroupUseCase(this.repository);

  Future<List<EvaluationEntity>> execute({
    required String courseId,
    required String categoryId,
    required String groupId,
    required String evaluatorUsername,
  }) async {
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

    // Obtener todas las evaluaciones del grupo para este evaluador
    final evaluations = await repository.getEvaluationsByGroup(
      courseId: courseId,
      categoryId: categoryId,
      groupId: groupId,
      evaluatorUsername: evaluatorUsername,
    );

    return evaluations;
  }
}
