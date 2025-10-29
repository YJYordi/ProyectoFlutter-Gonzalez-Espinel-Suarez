import 'package:flutter/material.dart';
import 'package:proyecto/Domain/Entities/category.dart';
import 'package:proyecto/Domain/Entities/evaluation.dart';
import 'package:proyecto/Domain/repositories/course_repository.dart';

class StudentManagementProvider with ChangeNotifier {
  final CourseRepository courseRepository;

  StudentManagementProvider({
    required this.courseRepository,
  });

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> moveStudentToGroup({
    required String categoryId,
    required String studentUsername,
    required String targetGroupId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Obtener la categoría actual
      final category = await courseRepository.getCategoryById(categoryId);
      if (category == null) {
        throw Exception('Categoría no encontrada');
      }

      // Encontrar el grupo actual del estudiante
      GroupEntity? currentGroup;
      for (final group in category.groups) {
        if (group.members.contains(studentUsername)) {
          currentGroup = group;
          break;
        }
      }

      if (currentGroup == null) {
        throw Exception('Estudiante no encontrado en ningún grupo');
      }

      // Encontrar el grupo destino
      final targetGroup = category.groups.firstWhere(
        (group) => group.id == targetGroupId,
        orElse: () => throw Exception('Grupo destino no encontrado'),
      );

      // Verificar que el grupo destino no esté lleno
      if (targetGroup.members.length >= targetGroup.maxMembers) {
        throw Exception('El grupo destino está lleno');
      }

      // Crear nuevos grupos con los cambios
      final updatedGroups = category.groups.map((group) {
        if (group.id == currentGroup!.id) {
          // Remover estudiante del grupo actual
          final updatedMembers = List<String>.from(group.members)
            ..remove(studentUsername);
          return group.copyWith(members: updatedMembers);
        } else if (group.id == targetGroupId) {
          // Agregar estudiante al grupo destino
          final updatedMembers = List<String>.from(group.members)
            ..add(studentUsername);
          return group.copyWith(members: updatedMembers);
        }
        return group;
      }).toList();

      // Actualizar la categoría
      final updatedCategory = category.copyWith(groups: updatedGroups);
      await courseRepository.updateCategory(updatedCategory);

      // Reiniciar evaluaciones del estudiante
      await _resetStudentEvaluations(studentUsername, categoryId);

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _resetStudentEvaluations(String studentUsername, String categoryId) async {
    try {
      // Obtener todas las evaluaciones del estudiante en esta categoría
      // Necesitamos obtener el courseId y groupId para usar el método correcto
      final category = await courseRepository.getCategoryById(categoryId);
      if (category == null) return;
      
      // Obtener evaluaciones de todos los grupos de la categoría
      for (final group in category.groups) {
        final evaluations = await courseRepository.getEvaluationsByGroup(
          courseId: category.courseId,
          categoryId: categoryId,
          groupId: group.id,
          evaluatorUsername: studentUsername,
        );
        
        // Filtrar evaluaciones donde el estudiante es evaluador o evaluado
        final studentEvaluations = evaluations.where((eval) => 
          eval.evaluatorUsername == studentUsername || 
          eval.evaluatedUsername == studentUsername
        ).toList();

        // Eliminar estas evaluaciones
        for (final evaluation in studentEvaluations) {
          // Por ahora, solo marcamos como no completada
          final updatedEvaluation = evaluation.copyWith(isCompleted: false);
          await courseRepository.updateEvaluation(updatedEvaluation);
        }
      }
    } catch (e) {
      // Log error but don't fail the entire operation
      print('Error al reiniciar evaluaciones: $e');
    }
  }

  Future<List<EvaluationEntity>> getGroupEvaluations(String groupId) async {
    try {
      // Necesitamos obtener todas las categorías para encontrar la que contiene este grupo
      final allCategories = await courseRepository.getCategoriesByCourse(''); // Esto no funcionará
      
      // Mejor enfoque: obtener todas las evaluaciones y filtrar por groupId
      // Por ahora, retornamos una lista vacía ya que necesitamos implementar un método diferente
      return [];
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<double> calculateGroupAverage(String groupId) async {
    try {
      // Por ahora, retornamos 0.0 ya que necesitamos implementar un método diferente
      // para obtener las evaluaciones por grupo
      return 0.0;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0.0;
    }
  }

  Future<Map<String, double>> getStudentAveragesInGroup(String groupId) async {
    try {
      // Por ahora, retornamos un mapa vacío ya que necesitamos implementar un método diferente
      return {};
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {};
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
