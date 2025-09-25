import 'package:proyecto/features/courses/domain/entities/course.dart';
import 'package:proyecto/features/courses/domain/repositories/course_repository.dart';

class GetCoursesByStudentUseCase {
  final CourseRepository courseRepository;
  const GetCoursesByStudentUseCase(this.courseRepository);

  Future<List<CourseEntity>> call(String username) {
    return courseRepository.getCoursesByStudent(username);
  }
}
