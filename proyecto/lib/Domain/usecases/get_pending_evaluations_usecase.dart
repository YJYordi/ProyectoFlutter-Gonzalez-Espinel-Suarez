import 'package:proyecto/Domain/Entities/evaluation.dart';
import 'package:proyecto/Domain/repositories/course_repository.dart';

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
