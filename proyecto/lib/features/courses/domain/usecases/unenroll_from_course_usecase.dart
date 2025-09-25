import 'package:proyecto/features/courses/domain/repositories/course_repository.dart';

class UnenrollFromCourseUseCase {
  final CourseRepository courseRepository;
  const UnenrollFromCourseUseCase(this.courseRepository);

  Future<void> call(String courseId, String username) {
    return courseRepository.unenrollFromCourse(courseId, username);
  }
}
