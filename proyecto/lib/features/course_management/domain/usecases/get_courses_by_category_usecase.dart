import 'package:proyecto/features/course_management/domain/entities/course.dart';
import 'package:proyecto/features/course_management/domain/repositories/course_repository.dart';

class GetCoursesByCategoryUseCase {
  final CourseRepository courseRepository;
  const GetCoursesByCategoryUseCase(this.courseRepository);

  Future<List<CourseEntity>> call(String category) {
    return courseRepository.getCoursesByCategory(category);
  }
}
