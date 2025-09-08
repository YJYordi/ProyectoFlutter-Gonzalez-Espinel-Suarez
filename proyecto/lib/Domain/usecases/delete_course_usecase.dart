import 'package:proyecto/Domain/repositories/course_repository.dart';

class DeleteCourseUseCase {
  final CourseRepository courseRepository;
  const DeleteCourseUseCase(this.courseRepository);

  Future<void> call(String courseId, String creatorUsername) {
    return courseRepository.deleteCourse(courseId, creatorUsername);
  }
}
