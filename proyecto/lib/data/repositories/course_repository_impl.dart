import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/repositories/course_repository.dart';
import 'package:proyecto/data/datasources/memory_data_source.dart';

class CourseRepositoryImpl implements CourseRepository {
  final InMemoryDataSource dataSource;

  CourseRepositoryImpl(this.dataSource);

  @override
  Future<void> createCourse({required String title, required int groupSize, String? groupPrefix}) {
    return dataSource.createCourse(title: title, groupSize: groupSize, groupPrefix: groupPrefix);
  }

  @override
  Future<List<CourseEntity>> getAvailableCourses() {
    return dataSource.getCourses();
  }
}


