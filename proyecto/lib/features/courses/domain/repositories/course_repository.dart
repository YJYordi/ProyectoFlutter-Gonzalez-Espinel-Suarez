import 'package:proyecto/features/courses/domain/entities/course.dart';
import 'package:proyecto/features/courses/domain/entities/course_enrollment.dart';

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
}
