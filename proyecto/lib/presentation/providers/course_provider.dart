import 'package:flutter/foundation.dart';
import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/Entities/course_enrollment.dart';
import 'package:proyecto/Domain/usecases/create_course_usecase.dart';
import 'package:proyecto/Domain/usecases/get_courses_usecase.dart';
import 'package:proyecto/Domain/usecases/enroll_in_course_usecase.dart';
import 'package:proyecto/Domain/usecases/get_course_enrollments_usecase.dart';
import 'package:proyecto/Domain/usecases/delete_course_usecase.dart';
import 'package:proyecto/Domain/usecases/unenroll_from_course_usecase.dart';
import 'package:proyecto/Domain/usecases/get_courses_by_creator_usecase.dart';
import 'package:proyecto/Domain/usecases/get_courses_by_student_usecase.dart';
import 'package:proyecto/Domain/repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  final GetCoursesUseCase getCoursesUseCase;
  final CreateCourseUseCase createCourseUseCase;
  final EnrollInCourseUseCase enrollInCourseUseCase;
  final GetCourseEnrollmentsUseCase getCourseEnrollmentsUseCase;
  final DeleteCourseUseCase deleteCourseUseCase;
  final UnenrollFromCourseUseCase unenrollFromCourseUseCase;
  final GetCoursesByCreatorUseCase getCoursesByCreatorUseCase;
  final GetCoursesByStudentUseCase getCoursesByStudentUseCase;
  final CourseRepository courseRepository;

  List<CourseEntity> _courses = <CourseEntity>[];
  List<CourseEntity> _createdCourses = <CourseEntity>[];
  List<CourseEntity> _enrolledCourses = <CourseEntity>[];
  bool _isLoading = false;

  CourseProvider({
    required this.getCoursesUseCase,
    required this.createCourseUseCase,
    required this.enrollInCourseUseCase,
    required this.getCourseEnrollmentsUseCase,
    required this.deleteCourseUseCase,
    required this.unenrollFromCourseUseCase,
    required this.getCoursesByCreatorUseCase,
    required this.getCoursesByStudentUseCase,
    required this.courseRepository,
  });

  List<CourseEntity> get courses => _courses;
  List<CourseEntity> get createdCourses => _createdCourses;
  List<CourseEntity> get enrolledCourses => _enrolledCourses;
  bool get isLoading => _isLoading;

  Future<void> loadCourses() async {
    _isLoading = true;
    notifyListeners();
    _courses = await getCoursesUseCase();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCreatedCourses(String creatorUsername) async {
    _createdCourses = await getCoursesByCreatorUseCase(creatorUsername);
    notifyListeners();
  }

  Future<void> loadEnrolledCourses(String username) async {
    _enrolledCourses = await getCoursesByStudentUseCase(username);
    notifyListeners();
  }

  Future<void> createCourse({
    required String title,
    required String description,
    required String creatorUsername,
    required String creatorName,
    required List<String> categories,
    required int maxEnrollments,
  }) async {
    if (_createdCourses.length >= 3) {
      throw Exception('No puedes crear más de 3 cursos');
    }
    
    await createCourseUseCase(
      title: title,
      description: description,
      creatorUsername: creatorUsername,
      creatorName: creatorName,
      categories: categories,
      maxEnrollments: maxEnrollments,
    );
    await loadCourses();
    await loadCreatedCourses(creatorUsername);
  }

  Future<List<CourseEnrollment>> getCourseEnrollments(String courseId) async {
    return await getCourseEnrollmentsUseCase(courseId);
  }

  Future<bool> isUserEnrolledInCourse(String courseId, String username) async {
    return await courseRepository.isUserEnrolledInCourse(courseId, username);
  }

  Future<void> enrollInCourse({
    required String courseId,
    required String username,
    required String userName,
  }) async {
    if (_enrolledCourses.length >= 3) {
      throw Exception('No puedes inscribirte a más de 3 cursos');
    }
    
    await enrollInCourseUseCase(
      courseId: courseId,
      username: username,
      userName: userName,
    );
    await loadEnrolledCourses(username);
  }

  Future<void> unenrollFromCourse(String courseId, String username) async {
    await unenrollFromCourseUseCase(courseId, username);
    await loadEnrolledCourses(username);
  }

  Future<void> deleteCourse(String courseId, String creatorUsername) async {
    await deleteCourseUseCase(courseId, creatorUsername);
    await loadCourses();
    await loadCreatedCourses(creatorUsername);
  }
}


