import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/repositories/course_repository.dart';

class GetCoursesUseCase {
  final CourseRepository courseRepository;
  const GetCoursesUseCase(this.courseRepository);

  Future<List<CourseEntity>> call() {
    return courseRepository.getAvailableCourses();
  }
}


