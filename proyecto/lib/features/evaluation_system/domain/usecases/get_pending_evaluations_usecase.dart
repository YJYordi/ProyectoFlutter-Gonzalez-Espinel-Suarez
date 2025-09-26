import 'package:proyecto/features/evaluation_system/domain/entities/evaluation.dart';
import 'package:proyecto/features/course_management/domain/repositories/course_repository.dart';

class GetPendingEvaluationsUseCase {
  final CourseRepository repository;

  GetPendingEvaluationsUseCase(this.repository);

  Future<List<EvaluationEntity>> execute({
    required String username,
    String? courseId,
    String? categoryId,
  }) async {
    // Obtener todas las evaluaciones pendientes del usuario
    final evaluations = await repository.getPendingEvaluations(
      username: username,
      courseId: courseId,
      categoryId: categoryId,
    );

    return evaluations;
  }
}
