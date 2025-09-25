import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:proyecto/features/courses/domain/entities/course.dart';
import 'package:proyecto/features/courses/domain/entities/course_enrollment.dart';
import 'package:proyecto/features/courses/domain/usecases/create_course_usecase.dart';
import 'package:proyecto/features/courses/domain/usecases/get_courses_usecase.dart';
import 'package:proyecto/features/courses/domain/usecases/enroll_in_course_usecase.dart';
import 'package:proyecto/features/courses/domain/usecases/get_course_enrollments_usecase.dart';
import 'package:proyecto/features/courses/domain/usecases/delete_course_usecase.dart';
import 'package:proyecto/features/courses/domain/usecases/unenroll_from_course_usecase.dart';
import 'package:proyecto/features/courses/domain/usecases/get_courses_by_creator_usecase.dart';
import 'package:proyecto/features/courses/domain/usecases/get_courses_by_student_usecase.dart';
import 'package:proyecto/features/courses/domain/usecases/get_courses_by_category_usecase.dart';
import 'package:proyecto/features/courses/domain/repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  final GetCoursesUseCase getCoursesUseCase;
  final CreateCourseUseCase createCourseUseCase;
  final EnrollInCourseUseCase enrollInCourseUseCase;
  final GetCourseEnrollmentsUseCase getCourseEnrollmentsUseCase;
  final DeleteCourseUseCase deleteCourseUseCase;
  final UnenrollFromCourseUseCase unenrollFromCourseUseCase;
  final GetCoursesByCreatorUseCase getCoursesByCreatorUseCase;
  final GetCoursesByStudentUseCase getCoursesByStudentUseCase;
  final GetCoursesByCategoryUseCase getCoursesByCategoryUseCase;
  final CourseRepository courseRepository;

  List<CourseEntity> _courses = <CourseEntity>[];
  List<CourseEntity> _createdCourses = <CourseEntity>[];
  List<CourseEntity> _enrolledCourses = <CourseEntity>[];
  List<CourseEntity> _filteredCourses = <CourseEntity>[];
  List<CourseEntity> _searchResults = <CourseEntity>[];
  bool _isLoading = false;
  String _selectedCategory = '';
  String _searchQuery = '';

  // Simulación de estructura de grupos por categoría
  final Map<String, Map<String, List<String>>> _courseGroups = {}; // {courseId: {category: [usernames]}}

  CourseProvider({
    required this.getCoursesUseCase,
    required this.createCourseUseCase,
    required this.enrollInCourseUseCase,
    required this.getCourseEnrollmentsUseCase,
    required this.deleteCourseUseCase,
    required this.unenrollFromCourseUseCase,
    required this.getCoursesByCreatorUseCase,
    required this.getCoursesByStudentUseCase,
    required this.getCoursesByCategoryUseCase,
    required this.courseRepository,
  });

  List<CourseEntity> get courses => _courses;
  List<CourseEntity> get createdCourses => _createdCourses;
  List<CourseEntity> get enrolledCourses => _enrolledCourses;
  List<CourseEntity> get filteredCourses => _filteredCourses;
  List<CourseEntity> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  Future<void> loadCourses() async {
    _isLoading = true;
    notifyListeners();
    _courses = await getCoursesUseCase();
    _filteredCourses = _courses;
    _searchResults = [];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCreatedCourses(String creatorUsername) async {
    _createdCourses = await getCoursesByCreatorUseCase(creatorUsername);
    notifyListeners();
  }

  Future<void> loadEnrolledCourses(String username) async {
    _enrolledCourses = await getCoursesByStudentUseCase(username);
    notifyListeners();
  }

  Future<void> createCourse({
    required String title,
    required String description,
    required String creatorUsername,
    required String creatorName,
    required List<String> categories,
    required int maxEnrollments,
    required bool isRandomAssignment,
    int? groupSize,
  }) async {
    if (_createdCourses.length >= 3) {
      throw Exception('No puedes crear más de 3 cursos');
    }
    
    await createCourseUseCase(
      title: title,
      description: description,
      creatorUsername: creatorUsername,
      creatorName: creatorName,
      categories: categories,
      maxEnrollments: maxEnrollments,
      isRandomAssignment: isRandomAssignment,
      groupSize: groupSize,
    );
    await loadCourses();
    await loadCreatedCourses(creatorUsername);
  }

  Future<List<CourseEnrollment>> getCourseEnrollments(String courseId) async {
    return await getCourseEnrollmentsUseCase(courseId);
  }

  Future<bool> isUserEnrolledInCourse(String courseId, String username) async {
    return await courseRepository.isUserEnrolledInCourse(courseId, username);
  }

  Future<void> enrollInCourse({
    required String courseId,
    required String username,
    required String userName,
  }) async {
    if (_enrolledCourses.length >= 3) {
      throw Exception('No puedes inscribirte a más de 3 cursos');
    }
    
    await enrollInCourseUseCase(
      courseId: courseId,
      username: username,
      userName: userName,
    );
    await loadEnrolledCourses(username);
  }

  Future<void> unenrollFromCourse(String courseId, String username) async {
    await unenrollFromCourseUseCase(courseId, username);
    await loadEnrolledCourses(username);
  }

  Future<void> deleteCourse(String courseId, String creatorUsername) async {
    await deleteCourseUseCase(courseId, creatorUsername);
    await loadCourses();
    await loadCreatedCourses(creatorUsername);
  }

  Future<void> updateRandomAssignment(String courseId, bool isRandom) async {
    final index = _courses.indexWhere((c) => c.id == courseId);
    if (index != -1) {
      final updatedCourse = _courses[index].copyWith(isRandomAssignment: isRandom);
      _courses[index] = updatedCourse;
      notifyListeners();
    }
  }

  Future<void> updateGroupSize(String courseId, int? groupSize) async {
    final index = _courses.indexWhere((c) => c.id == courseId);
    if (index != -1) {
      final updatedCourse = _courses[index].copyWith(groupSize: groupSize);
      _courses[index] = updatedCourse;
      notifyListeners();
    }
  }

  Future<void> filterCoursesByCategory(String category) async {
    _selectedCategory = category;
    if (category.isEmpty) {
      _filteredCourses = _courses;
    } else {
      _filteredCourses = await getCoursesByCategoryUseCase(category);
    }
    notifyListeners();
  }

  void searchCourses(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _searchResults = _courses;
    } else {
      _searchResults = _courses.where((course) {
        return course.title.toLowerCase().contains(query.toLowerCase()) ||
               course.description.toLowerCase().contains(query.toLowerCase()) ||
               course.creatorName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  void clearCategoryFilter() {
    _selectedCategory = '';
    _filteredCourses = _courses;
    notifyListeners();
  }

  // Obtener el grupo de una categoría en un curso
  GroupInfo getGroupForCategory(String courseId, String category) {
    final members = _courseGroups[courseId]?[category] ?? [];
    return GroupInfo(members: members);
  }

  // Verifica si el usuario está en algún grupo de ese curso
  bool isAnyGroupJoined(String courseId, String username) {
    final groups = _courseGroups[courseId];
    if (groups == null) return false;
    return groups.values.any((members) => members.contains(username));
  }

  // Unirse a un grupo/categoría
  void joinGroup(String courseId, String category, String username) {
    _courseGroups.putIfAbsent(courseId, () => {});
    _courseGroups[courseId]!.putIfAbsent(category, () => []);
    if (!isAnyGroupJoined(courseId, username)) {
      _courseGroups[courseId]![category]!.add(username);
      notifyListeners();
    }
  }

  // Salir de un grupo/categoría
  void leaveGroup(String courseId, String category, String username) {
    _courseGroups[courseId]?[category]?.remove(username);
    notifyListeners();
  }

  void showEvaluations(BuildContext context, String courseId, String category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Funcionalidad de evaluación pendiente')),
    );
  }
}

class GroupInfo {
  final List<String> members;
  GroupInfo({required this.members});
}
