import 'package:proyecto/features/courses/domain/entities/course.dart';
import 'package:proyecto/features/courses/domain/repositories/course_repository.dart';

class GetCoursesUseCase {
  final CourseRepository courseRepository;
  const GetCoursesUseCase(this.courseRepository);

  Future<List<CourseEntity>> call() {
    return courseRepository.getAvailableCourses();
  }
}
