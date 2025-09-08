import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/repositories/course_repository.dart';

class GetCoursesByCreatorUseCase {
  final CourseRepository courseRepository;
  const GetCoursesByCreatorUseCase(this.courseRepository);

  Future<List<CourseEntity>> call(String creatorUsername) {
    return courseRepository.getCoursesByCreator(creatorUsername);
  }
}
