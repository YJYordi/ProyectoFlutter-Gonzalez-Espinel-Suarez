import 'package:proyecto/Domain/Entities/category.dart';
import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/repositories/course_repository.dart';
import 'dart:math';

class CreateCategoryUseCase {
  final CourseRepository repository;

  CreateCategoryUseCase(this.repository);

  Future<CategoryEntity> execute({
    required String courseId,
    required String name,
    required int numberOfGroups,
    required bool isRandomAssignment,
    required int maxEnrollments,
  }) async {
    // Validar que el número de grupos esté entre 1 y 10
    if (numberOfGroups < 1 || numberOfGroups > 10) {
      throw ArgumentError('El número de grupos debe estar entre 1 y 10');
    }

    // Obtener el curso para validar que existe
    final course = await repository.getCourseById(courseId);
    if (course == null) {
      throw ArgumentError('El curso no existe');
    }

    // Calcular el tamaño máximo de cada grupo
    final maxMembersPerGroup = (maxEnrollments / numberOfGroups).ceil();

    // Crear la categoría
    final categoryId = DateTime.now().millisecondsSinceEpoch.toString();
    final groups = <GroupEntity>[];

    // Crear los grupos
    for (int i = 1; i <= numberOfGroups; i++) {
      final groupId = '${categoryId}_group_$i';
      groups.add(GroupEntity(
        id: groupId,
        categoryId: categoryId,
        groupNumber: i,
        members: [],
        maxMembers: maxMembersPerGroup,
      ));
    }

    final category = CategoryEntity(
      id: categoryId,
      courseId: courseId,
      name: name,
      numberOfGroups: numberOfGroups,
      isRandomAssignment: isRandomAssignment,
      createdAt: DateTime.now(),
      groups: groups,
    );

    await repository.createCategory(category);

    // Si es asignación aleatoria, asignar automáticamente a todos los usuarios inscritos
    if (isRandomAssignment) {
      await _assignUsersRandomly(category, course);
    }

    return category;
  }

  Future<void> _assignUsersRandomly(CategoryEntity category, CourseEntity course) async {
    // Obtener todos los usuarios inscritos en el curso
    final enrollments = await repository.getCourseEnrollments(course.id);
    final usernames = enrollments.map((e) => e.username).toList();
    
    if (usernames.isEmpty) return;

    // Mezclar la lista de usuarios para asignación aleatoria
    final random = Random();
    usernames.shuffle(random);

    // Asignar usuarios a grupos de manera equilibrada
    final updatedGroups = <GroupEntity>[];
    for (int i = 0; i < category.groups.length; i++) {
      final group = category.groups[i];
      final startIndex = i * (usernames.length / category.groups.length).floor();
      final endIndex = (i + 1) * (usernames.length / category.groups.length).floor();
      
      final groupMembers = usernames.sublist(
        startIndex,
        i == category.groups.length - 1 ? usernames.length : endIndex,
      );

      updatedGroups.add(group.copyWith(members: groupMembers));
    }

    // Actualizar la categoría con los grupos asignados
    final updatedCategory = category.copyWith(groups: updatedGroups);
    await repository.updateCategory(updatedCategory);
  }
}
