import 'package:proyecto/features/course_management/domain/entities/course_enrollment.dart';
import 'package:proyecto/features/course_management/domain/repositories/course_repository.dart';

class GetCourseEnrollmentsUseCase {
  final CourseRepository courseRepository;
  const GetCourseEnrollmentsUseCase(this.courseRepository);

  Future<List<CourseEnrollment>> call(String courseId) {
    return courseRepository.getCourseEnrollments(courseId);
  }
}
