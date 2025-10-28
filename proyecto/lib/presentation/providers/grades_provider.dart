import 'package:flutter/material.dart';
import 'package:proyecto/Domain/Entities/evaluation.dart';
import 'package:proyecto/Domain/Entities/category.dart';
import 'package:proyecto/Domain/repositories/course_repository.dart';

class GradesProvider with ChangeNotifier {
  final CourseRepository repository;

  GradesProvider({required this.repository});

  List<EvaluationEntity> _evaluations = [];
  List<CategoryEntity> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<EvaluationEntity> get evaluations => _evaluations;
  List<CategoryEntity> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadEvaluationsForCourse(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Cargar categorías del curso
      _categories = await repository.getCategoriesByCourse(courseId);
      
      // Cargar todas las evaluaciones
      _evaluations = [];
      for (final category in _categories) {
        for (final group in category.groups) {
          final groupEvaluations = await repository.getEvaluationsByGroup(
            categoryId: category.id,
            courseId: courseId,
            evaluatorUsername: '', // Obtener todas las evaluaciones
            groupId: group.id,
          );
          _evaluations.addAll(groupEvaluations);
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener calificaciones por categoría
  Map<String, List<StudentGrade>> getGradesByCategory() {
    final Map<String, List<StudentGrade>> gradesByCategory = {};

    for (final category in _categories) {
      final categoryEvaluations = _evaluations
          .where((e) => e.categoryId == category.id)
          .toList();

      final Map<String, List<EvaluationEntity>> evaluationsByStudent = {};
      
      // Agrupar evaluaciones por estudiante evaluado
      for (final evaluation in categoryEvaluations) {
        if (!evaluationsByStudent.containsKey(evaluation.evaluatedUsername)) {
          evaluationsByStudent[evaluation.evaluatedUsername] = [];
        }
        evaluationsByStudent[evaluation.evaluatedUsername]!.add(evaluation);
      }

      // Calcular promedio para cada estudiante
      final List<StudentGrade> studentGrades = [];
      for (final entry in evaluationsByStudent.entries) {
        final username = entry.key;
        final evaluations = entry.value;
        
        if (evaluations.isNotEmpty) {
          final average = _calculateAverage(evaluations);
          final evaluators = evaluations.map((e) => e.evaluatorUsername).toList();
          
          studentGrades.add(StudentGrade(
            username: username,
            average: average,
            evaluators: evaluators,
            evaluations: evaluations,
          ));
        }
      }

      // Ordenar por promedio descendente
      studentGrades.sort((a, b) => b.average.compareTo(a.average));
      gradesByCategory[category.name] = studentGrades;
    }

    return gradesByCategory;
  }

  // Obtener evaluaciones de un estudiante específico
  List<EvaluationEntity> getStudentEvaluations(String username, String categoryId) {
    return _evaluations
        .where((e) => e.evaluatedUsername == username && e.categoryId == categoryId)
        .toList();
  }

  double _calculateAverage(List<EvaluationEntity> evaluations) {
    if (evaluations.isEmpty) return 0.0;

    double total = 0.0;
    int count = 0;

    for (final evaluation in evaluations) {
      if (evaluation.isCompleted) {
        total += (evaluation.punctuality + 
                 evaluation.contributions + 
                 evaluation.commitment + 
                 evaluation.attitude) / 4.0;
        count++;
      }
    }

    return count > 0 ? total / count : 0.0;
  }
}

class StudentGrade {
  final String username;
  final double average;
  final List<String> evaluators;
  final List<EvaluationEntity> evaluations;

  StudentGrade({
    required this.username,
    required this.average,
    required this.evaluators,
    required this.evaluations,
  });
}
