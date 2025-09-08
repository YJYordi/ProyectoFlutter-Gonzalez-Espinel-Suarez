import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/repositories/course_repository.dart';

class GetCoursesByStudentUseCase {
  final CourseRepository courseRepository;
  const GetCoursesByStudentUseCase(this.courseRepository);

  Future<List<CourseEntity>> call(String username) {
    return courseRepository.getCoursesByStudent(username);
  }
}
