import 'package:proyecto/features/course_management/domain/entities/course.dart';
import 'package:proyecto/features/course_management/domain/repositories/course_repository.dart';

class GetCoursesByCreatorUseCase {
  final CourseRepository courseRepository;
  const GetCoursesByCreatorUseCase(this.courseRepository);

  Future<List<CourseEntity>> call(String creatorUsername) {
    return courseRepository.getCoursesByCreator(creatorUsername);
  }
}
