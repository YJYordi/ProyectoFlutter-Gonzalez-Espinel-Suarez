import 'package:proyecto/features/courses/domain/entities/course.dart';
import 'package:proyecto/features/courses/domain/entities/course_enrollment.dart';
import 'package:proyecto/features/courses/domain/repositories/course_repository.dart';
import 'package:proyecto/features/courses/data/datasources/courses_remote_data_source.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CoursesRemoteDataSource remoteDataSource;

  CourseRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CourseEntity>> getAvailableCourses() async {
    return await remoteDataSource.getCourses();
  }

  @override
  Future<CourseEntity?> getCourseById(String courseId) async {
    return await remoteDataSource.getCourseById(courseId);
  }

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
  }) async {
    final course = CourseEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      creatorUsername: creatorUsername,
      creatorName: creatorName,
      categories: categories,
      maxEnrollments: maxEnrollments,
      currentEnrollments: 0,
      createdAt: DateTime.now(),
      schedule: 'Por definir',
      location: 'Por definir',
      price: 0.0,
      isRandomAssignment: isRandomAssignment,
      groupSize: groupSize,
    );

    await remoteDataSource.createCourse(course);
  }

  @override
  Future<List<CourseEnrollment>> getCourseEnrollments(String courseId) async {
    return await remoteDataSource.getCourseEnrollments(courseId);
  }

  @override
  Future<void> enrollInCourse({
    required String courseId,
    required String username,
    required String userName,
  }) async {
    await remoteDataSource.enrollInCourse(courseId, username, userName);
  }

  @override
  Future<void> unenrollFromCourse(String courseId, String username) async {
    await remoteDataSource.unenrollFromCourse(courseId, username);
  }

  @override
  Future<bool> isUserEnrolledInCourse(String courseId, String username) async {
    return await remoteDataSource.isUserEnrolledInCourse(courseId, username);
  }

  @override
  Future<List<CourseEntity>> getCoursesByCategory(String category) async {
    return await remoteDataSource.getCoursesByCategory(category);
  }

  @override
  Future<void> deleteCourse(String courseId, String creatorUsername) async {
    await remoteDataSource.deleteCourse(courseId, creatorUsername);
  }

  @override
  Future<List<CourseEntity>> getCoursesByCreator(String creatorUsername) async {
    return await remoteDataSource.getCoursesByCreator(creatorUsername);
  }

  @override
  Future<List<CourseEntity>> getCoursesByStudent(String username) async {
    return await remoteDataSource.getCoursesByStudent(username);
  }
}
