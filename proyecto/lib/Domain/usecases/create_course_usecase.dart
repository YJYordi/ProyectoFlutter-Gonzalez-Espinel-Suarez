import 'package:proyecto/Domain/repositories/course_repository.dart';

class CreateCourseUseCase {
  final CourseRepository courseRepository;
  const CreateCourseUseCase(this.courseRepository);

  Future<void> call({
    required String title,
    required String description,
    required String creatorUsername,
    required String creatorName,
    required List<String> categories,
    required int maxEnrollments,
  }) {
    return courseRepository.createCourse(
      title: title,
      description: description,
      creatorUsername: creatorUsername,
      creatorName: creatorName,
      categories: categories,
      maxEnrollments: maxEnrollments,
    );
  }
}


