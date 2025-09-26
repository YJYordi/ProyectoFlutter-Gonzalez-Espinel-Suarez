import 'package:proyecto/features/category_management/domain/entities/category.dart';
import 'package:proyecto/features/course_management/domain/repositories/course_repository.dart';

class UnenrollCategoryUseCase {
  final CourseRepository repository;

  UnenrollCategoryUseCase(this.repository);

  Future<void> execute({
    required String categoryId,
    required String username,
  }) async {
    // Obtener la categoría
    final category = await repository.getCategoryById(categoryId);
    if (category == null) {
      throw ArgumentError('La categoría no existe');
    }

    // Encontrar el grupo donde está inscrito el usuario
    GroupEntity? userGroup;
    for (final group in category.groups) {
      if (group.members.contains(username)) {
        userGroup = group;
        break;
      }
    }

    if (userGroup == null) {
      throw ArgumentError('No estás inscrito en ningún grupo de esta categoría');
    }

    // Remover el usuario del grupo
    final updatedGroup = userGroup.copyWith(
      members: userGroup.members.where((member) => member != username).toList(),
    );

    // Actualizar la categoría con el grupo modificado
    final updatedGroups = category.groups.map((g) => g.id == userGroup!.id ? updatedGroup : g).toList();
    final updatedCategory = category.copyWith(groups: updatedGroups);

    await repository.updateCategory(updatedCategory);
  }
}
