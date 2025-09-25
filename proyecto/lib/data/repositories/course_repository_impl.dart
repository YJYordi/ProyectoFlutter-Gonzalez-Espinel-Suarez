import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/Entities/course_enrollment.dart';
import 'package:proyecto/Domain/Entities/category.dart';
import 'package:proyecto/Domain/Entities/evaluation.dart';
import 'package:proyecto/Domain/repositories/course_repository.dart';
import 'package:proyecto/data/datasources/memory_data_source.dart';

class CourseRepositoryImpl implements CourseRepository {
  final InMemoryDataSource dataSource;

  CourseRepositoryImpl(this.dataSource);

  @override
  Future<void> createCourse({
    required String title,
    required String description,
    required String creatorUsername,
    required String creatorName,
    required List<String> categories,
    required int maxEnrollments,
    required bool isRandomAssignment,
    int? groupSize,
  }) {
    return dataSource.createCourse(
      title: title,
      description: description,
      creatorUsername: creatorUsername,
      creatorName: creatorName,
      categories: categories,
      maxEnrollments: maxEnrollments,
      isRandomAssignment: isRandomAssignment,
      groupSize: groupSize,
    );
  }

  @override
  Future<List<CourseEntity>> getAvailableCourses() {
    return dataSource.getCourses();
  }

  @override
  Future<CourseEntity?> getCourseById(String courseId) {
    return dataSource.getCourseById(courseId);
  }

  @override
  Future<List<CourseEnrollment>> getCourseEnrollments(String courseId) {
    return dataSource.getCourseEnrollments(courseId);
  }

  @override
  Future<void> enrollInCourse({
    required String courseId,
    required String username,
    required String userName,
  }) {
    return dataSource.enrollInCourse(
      courseId: courseId,
      username: username,
      userName: userName,
    );
  }

  @override
  Future<bool> isUserEnrolledInCourse(String courseId, String username) {
    return dataSource.isUserEnrolledInCourse(courseId, username);
  }

  @override
  Future<List<CourseEntity>> getCoursesByCategory(String category) {
    return dataSource.getCoursesByCategory(category);
  }

  @override
  Future<void> deleteCourse(String courseId, String creatorUsername) {
    return dataSource.deleteCourse(courseId, creatorUsername);
  }

  @override
  Future<void> unenrollFromCourse(String courseId, String username) {
    return dataSource.unenrollFromCourse(courseId, username);
  }

  @override
  Future<List<CourseEntity>> getCoursesByCreator(String creatorUsername) {
    return dataSource.getCoursesByCreator(creatorUsername);
  }

  @override
  Future<List<CourseEntity>> getCoursesByStudent(String username) {
    return dataSource.getCoursesByStudent(username);
  }

  @override
  Future<List<CategoryEntity>> getCategoriesByCourse(String courseId) {
    return dataSource.getCategoriesByCourse(courseId);
  }

  @override
  Future<CategoryEntity?> getCategoryById(String categoryId) {
    return dataSource.getCategoryById(categoryId);
  }

  @override
  Future<void> createCategory(CategoryEntity category) {
    return dataSource.createCategory(category);
  }

  @override
  Future<void> updateCategory(CategoryEntity category) {
    return dataSource.updateCategory(category);
  }

  @override
  Future<void> deleteCategory(String categoryId) {
    return dataSource.deleteCategory(categoryId);
  }

  // Evaluation management methods
  @override
  Future<void> createEvaluation(EvaluationEntity evaluation) {
    return dataSource.createEvaluation(evaluation);
  }

  @override
  Future<void> updateEvaluation(EvaluationEntity evaluation) {
    return dataSource.updateEvaluation(evaluation);
  }

  @override
  Future<EvaluationEntity?> getEvaluationById(String evaluationId) {
    return dataSource.getEvaluationById(evaluationId);
  }

  @override
  Future<EvaluationEntity?> getEvaluation({
    required String courseId,
    required String categoryId,
    required String groupId,
    required String evaluatorUsername,
    required String evaluatedUsername,
  }) {
    return dataSource.getEvaluation(
      courseId: courseId,
      categoryId: categoryId,
      groupId: groupId,
      evaluatorUsername: evaluatorUsername,
      evaluatedUsername: evaluatedUsername,
    );
  }

  @override
  Future<List<EvaluationEntity>> getEvaluationsByGroup({
    required String courseId,
    required String categoryId,
    required String groupId,
    required String evaluatorUsername,
  }) {
    return dataSource.getEvaluationsByGroup(
      courseId: courseId,
      categoryId: categoryId,
      groupId: groupId,
      evaluatorUsername: evaluatorUsername,
    );
  }

  @override
  Future<List<EvaluationEntity>> getPendingEvaluations({
    required String username,
    String? courseId,
    String? categoryId,
  }) {
    return dataSource.getPendingEvaluations(
      username: username,
      courseId: courseId,
      categoryId: categoryId,
    );
  }

  @override
  Future<List<EvaluationEntity>> getCompletedEvaluations({
    required String username,
    String? courseId,
    String? categoryId,
  }) {
    return dataSource.getCompletedEvaluations(
      username: username,
      courseId: courseId,
      categoryId: categoryId,
    );
  }

  @override
  Future<void> clearAllCourses() {
    return dataSource.clearAllCourses();
  }
}


