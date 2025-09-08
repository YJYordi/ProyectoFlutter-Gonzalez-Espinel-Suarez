import 'package:proyecto/Domain/Entities/course.dart';

abstract class CourseRepository {
  Future<List<CourseEntity>> getAvailableCourses();
  Future<void> createCourse({required String title, required int groupSize, String? groupPrefix});
}


