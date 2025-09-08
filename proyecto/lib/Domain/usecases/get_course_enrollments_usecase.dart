import 'package:proyecto/Domain/Entities/course_enrollment.dart';
import 'package:proyecto/Domain/repositories/course_repository.dart';

class GetCourseEnrollmentsUseCase {
  final CourseRepository courseRepository;
  const GetCourseEnrollmentsUseCase(this.courseRepository);

  Future<List<CourseEnrollment>> call(String courseId) {
    return courseRepository.getCourseEnrollments(courseId);
  }
}
