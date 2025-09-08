import 'package:flutter/foundation.dart';
import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/usecases/create_course_usecase.dart';
import 'package:proyecto/Domain/usecases/get_courses_usecase.dart';

class CourseProvider extends ChangeNotifier {
  final GetCoursesUseCase getCoursesUseCase;
  final CreateCourseUseCase createCourseUseCase;

  List<CourseEntity> _courses = <CourseEntity>[];
  bool _isLoading = false;

  CourseProvider({required this.getCoursesUseCase, required this.createCourseUseCase});

  List<CourseEntity> get courses => _courses;
  bool get isLoading => _isLoading;

  Future<void> loadCourses() async {
    _isLoading = true;
    notifyListeners();
    _courses = await getCoursesUseCase();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createCourse({required String title, required int groupSize, String? groupPrefix}) async {
    await createCourseUseCase(title: title, groupSize: groupSize, groupPrefix: groupPrefix);
    await loadCourses();
  }
}


