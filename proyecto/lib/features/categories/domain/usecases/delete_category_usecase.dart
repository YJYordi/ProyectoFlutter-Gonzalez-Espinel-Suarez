import 'package:proyecto/features/courses/domain/repositories/course_repository.dart';

class DeleteCategoryUseCase {
  final CourseRepository repository;

  DeleteCategoryUseCase(this.repository);

  Future<void> execute({
    required String categoryId,
    required String courseId,
  }) async {
    // Verificar que la categoría existe y pertenece al curso
    final category = await repository.getCategoryById(categoryId);
    if (category == null) {
      throw ArgumentError('La categoría no existe');
    }

    if (category.courseId != courseId) {
      throw ArgumentError('La categoría no pertenece a este curso');
    }

    await repository.deleteCategory(categoryId);
  }
}