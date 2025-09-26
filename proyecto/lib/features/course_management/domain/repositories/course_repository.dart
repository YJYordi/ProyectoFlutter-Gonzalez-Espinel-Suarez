import 'package:proyecto/features/course_management/domain/entities/course.dart';
import 'package:proyecto/features/course_management/domain/entities/course_enrollment.dart';
import 'package:proyecto/features/category_management/domain/entities/category.dart';
import 'package:proyecto/features/evaluation_system/domain/entities/evaluation.dart';

abstract class CourseRepository {
  Future<List<CourseEntity>> getAvailableCourses();
  Future<CourseEntity?> getCourseById(String courseId);
  Future<void> createCourse({
    required String title,
    required String description,
    required String creatorUsername,
    required String creatorName,
    required List<String> categories,
    required int maxEnrollments,
    required bool isRandomAssignment,
    int? groupSize,
  });
  Future<List<CourseEnrollment>> getCourseEnrollments(String courseId);
  Future<void> enrollInCourse({
    required String courseId,
    required String username,
    required String userName,
  });
  Future<void> unenrollFromCourse(String courseId, String username);
  Future<bool> isUserEnrolledInCourse(String courseId, String username);
  Future<List<CourseEntity>> getCoursesByCategory(String category);
  Future<void> deleteCourse(String courseId, String creatorUsername);
  Future<List<CourseEntity>> getCoursesByCreator(String creatorUsername);
  Future<List<CourseEntity>> getCoursesByStudent(String username);
  
  // Category management methods
  Future<List<CategoryEntity>> getCategoriesByCourse(String courseId);
  Future<CategoryEntity?> getCategoryById(String categoryId);
  Future<void> createCategory(CategoryEntity category);
  Future<void> updateCategory(CategoryEntity category);
  Future<void> deleteCategory(String categoryId);
  
  // Evaluation management methods
  Future<void> createEvaluation(EvaluationEntity evaluation);
  Future<void> updateEvaluation(EvaluationEntity evaluation);
  Future<EvaluationEntity?> getEvaluationById(String evaluationId);
  Future<EvaluationEntity?> getEvaluation({
    required String courseId,
    required String categoryId,
    required String groupId,
    required String evaluatorUsername,
    required String evaluatedUsername,
  });
  Future<List<EvaluationEntity>> getEvaluationsByGroup({
    required String courseId,
    required String categoryId,
    required String groupId,
    required String evaluatorUsername,
  });
  Future<List<EvaluationEntity>> getPendingEvaluations({
    required String username,
    String? courseId,
    String? categoryId,
  });
  Future<List<EvaluationEntity>> getCompletedEvaluations({
    required String username,
    String? courseId,
    String? categoryId,
  });
  
  // Método para limpiar todos los cursos (útil para testing)
  Future<void> clearAllCourses();
}


