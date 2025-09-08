import 'package:proyecto/Domain/repositories/course_repository.dart';

class CreateCourseUseCase {
  final CourseRepository courseRepository;
  const CreateCourseUseCase(this.courseRepository);

  Future<void> call({required String title, required int groupSize, String? groupPrefix}) {
    return courseRepository.createCourse(title: title, groupSize: groupSize, groupPrefix: groupPrefix);
  }
}


