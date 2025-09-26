import 'package:proyecto/features/course_management/domain/entities/course.dart';
import 'package:proyecto/features/course_management/domain/repositories/course_repository.dart';

class GetCoursesByStudentUseCase {
  final CourseRepository courseRepository;
  const GetCoursesByStudentUseCase(this.courseRepository);

  Future<List<CourseEntity>> call(String username) {
    return courseRepository.getCoursesByStudent(username);
  }
}
