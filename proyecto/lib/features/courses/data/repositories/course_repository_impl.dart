import 'package:proyecto/features/courses/domain/entities/course.dart';
import 'package:proyecto/features/courses/domain/entities/course_enrollment.dart';
import 'package:proyecto/features/courses/domain/repositories/course_repository.dart';
import 'package:proyecto/core/data/datasources/persistent_data_source.dart';

class CourseRepositoryImpl implements CourseRepository {
  final PersistentDataSource dataSource;
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
}
