import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/Entities/course_enrollment.dart';
import 'package:proyecto/Domain/Entities/category.dart';

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
}


