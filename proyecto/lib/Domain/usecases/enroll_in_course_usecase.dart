import 'package:proyecto/Domain/repositories/course_repository.dart';

class EnrollInCourseUseCase {
  final CourseRepository courseRepository;
  const EnrollInCourseUseCase(this.courseRepository);

  Future<void> call({
    required String courseId,
    required String username,
    required String userName,
  }) {
    return courseRepository.enrollInCourse(
      courseId: courseId,
      username: username,
      userName: userName,
    );
  }
}
