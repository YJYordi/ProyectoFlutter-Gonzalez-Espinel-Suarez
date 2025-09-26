import 'package:proyecto/features/course_management/domain/entities/course.dart';
import 'package:proyecto/features/course_management/domain/repositories/course_repository.dart';

class GetCoursesUseCase {
  final CourseRepository courseRepository;
  const GetCoursesUseCase(this.courseRepository);

  Future<List<CourseEntity>> call() {
    return courseRepository.getAvailableCourses();
  }
}


