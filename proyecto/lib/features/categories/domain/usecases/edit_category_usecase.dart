import 'package:proyecto/features/categories/domain/entities/category.dart';
import 'package:proyecto/features/courses/domain/entities/course.dart';
import 'package:proyecto/features/courses/domain/entities/course_enrollment.dart';
import 'package:proyecto/features/courses/domain/repositories/course_repository.dart';
import 'dart:math';

class EditCategoryUseCase {
  final CourseRepository repository;

  EditCategoryUseCase(this.repository);

  Future<CategoryEntity> execute({
    required String categoryId,
    required String name,
    required int numberOfGroups,
    required bool isRandomAssignment,
    required int maxEnrollments,
  }) async {
    // Validar que el número de grupos esté entre 1 y 10
    if (numberOfGroups < 1 || numberOfGroups > 10) {
      throw ArgumentError('El número de grupos debe estar entre 1 y 10');
    }

    // Obtener la categoría existente
    final existingCategory = await repository.getCategoryById(categoryId);
    if (existingCategory == null) {
      throw ArgumentError('La categoría no existe');
    }

    // Obtener el curso para la asignación aleatoria
    final course = await repository.getCourseById(existingCategory.courseId);
    if (course == null) {
      throw ArgumentError('El curso no existe');
    }

    // Eliminar la categoría existente (esto borra todas las inscripciones)
    await repository.deleteCategory(categoryId);

    // Calcular el tamaño máximo de cada grupo
    final maxMembersPerGroup = (maxEnrollments / numberOfGroups).ceil();

    // Crear nuevos grupos
    final groups = <GroupEntity>[];
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

    // Crear la nueva categoría
    final newCategory = CategoryEntity(
      id: categoryId, // Mantener el mismo ID
      courseId: existingCategory.courseId,
      name: name,
      numberOfGroups: numberOfGroups,
      isRandomAssignment: isRandomAssignment,
      createdAt: existingCategory.createdAt, // Mantener la fecha original
      groups: groups,
    );

    await repository.createCategory(newCategory);

    // Si es asignación aleatoria, asignar automáticamente a todos los usuarios inscritos
    if (isRandomAssignment) {
      await _assignUsersRandomly(newCategory, course);
    }

    return newCategory;
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