import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/repositories/course_repository.dart';

class GetCoursesByCategoryUseCase {
  final CourseRepository courseRepository;
  const GetCoursesByCategoryUseCase(this.courseRepository);

  Future<List<CourseEntity>> call(String category) {
    return courseRepository.getCoursesByCategory(category);
  }
}
