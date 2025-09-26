import 'package:proyecto/features/course_management/domain/repositories/course_repository.dart';

class EnrollCategoryUseCase {
  final CourseRepository repository;

  EnrollCategoryUseCase(this.repository);

  Future<void> execute({
    required String categoryId,
    required String groupId,
    required String username,
  }) async {
    // Obtener la categoría
    final category = await repository.getCategoryById(categoryId);
    if (category == null) {
      throw ArgumentError('La categoría no existe');
    }

    // Verificar que el grupo existe en la categoría
    final group = category.groups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => throw ArgumentError('El grupo no existe'),
    );

    // Verificar que el usuario no esté ya en algún grupo de esta categoría
    final isAlreadyEnrolled = category.groups.any((g) => g.members.contains(username));
    if (isAlreadyEnrolled) {
      throw ArgumentError('Ya estás inscrito en un grupo de esta categoría');
    }

    // Verificar que el grupo no esté lleno
    if (group.members.length >= group.maxMembers) {
      throw ArgumentError('El grupo está lleno');
    }

    // Agregar el usuario al grupo
    final updatedGroup = group.copyWith(
      members: [...group.members, username],
    );

    // Actualizar la categoría con el grupo modificado
    final updatedGroups = category.groups.map((g) => g.id == groupId ? updatedGroup : g).toList();
    final updatedCategory = category.copyWith(groups: updatedGroups);

    await repository.updateCategory(updatedCategory);
  }
}
