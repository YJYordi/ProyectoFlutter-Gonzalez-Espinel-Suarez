import 'package:proyecto/features/courses/domain/entities/course.dart';
import 'package:proyecto/features/courses/domain/repositories/course_repository.dart';

class GetCoursesByCreatorUseCase {
  final CourseRepository courseRepository;
  const GetCoursesByCreatorUseCase(this.courseRepository);

  Future<List<CourseEntity>> call(String creatorUsername) {
    return courseRepository.getCoursesByCreator(creatorUsername);
  }
}
