import 'package:get/get.dart';
import 'package:proyecto/features/course_management/domain/entities/course.dart';
import 'package:proyecto/features/course_management/domain/entities/course_enrollment.dart';
import 'package:proyecto/features/course_management/domain/usecases/create_course_usecase.dart';
import 'package:proyecto/features/course_management/domain/usecases/get_courses_usecase.dart';
import 'package:proyecto/features/course_management/domain/usecases/enroll_in_course_usecase.dart';
import 'package:proyecto/features/course_management/domain/usecases/get_course_enrollments_usecase.dart';
import 'package:proyecto/features/course_management/domain/usecases/delete_course_usecase.dart';
import 'package:proyecto/features/course_management/domain/usecases/unenroll_from_course_usecase.dart';
import 'package:proyecto/features/course_management/domain/usecases/get_courses_by_creator_usecase.dart';
import 'package:proyecto/features/course_management/domain/usecases/get_courses_by_student_usecase.dart';
import 'package:proyecto/features/course_management/domain/usecases/get_courses_by_category_usecase.dart';
import 'package:proyecto/features/course_management/domain/repositories/course_repository.dart';

class CourseController extends GetxController {
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

  // Variables reactivas
  final _courses = <CourseEntity>[].obs;
  final _createdCourses = <CourseEntity>[].obs;
  final _enrolledCourses = <CourseEntity>[].obs;
  final _filteredCourses = <CourseEntity>[].obs;
  final _searchResults = <CourseEntity>[].obs;
  final _isLoading = false.obs;
  final _selectedCategory = ''.obs;
  final _searchQuery = ''.obs;

  // Simulación de estructura de grupos por categoría
  final _courseGroups = <String, Map<String, List<String>>>{}
      .obs; // {courseId: {category: [usernames]}}

  CourseController({
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

  // Getters
  List<CourseEntity> get courses => _courses;
  List<CourseEntity> get createdCourses => _createdCourses;
  List<CourseEntity> get enrolledCourses => _enrolledCourses;
  List<CourseEntity> get filteredCourses => _filteredCourses;
  List<CourseEntity> get searchResults => _searchResults;
  bool get isLoading => _isLoading.value;
  String get selectedCategory => _selectedCategory.value;
  String get searchQuery => _searchQuery.value;
  Map<String, Map<String, List<String>>> get courseGroups => _courseGroups;

  @override
  void onInit() {
    super.onInit();
    loadCourses();
  }

  Future<void> loadCourses() async {
    _isLoading.value = true;
    try {
      final courses = await getCoursesUseCase();
      _courses.value = courses;
      _filteredCourses.value = courses;
    } catch (e) {
      Get.snackbar('Error', 'Error al cargar cursos: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> createCourse({
    required String title,
    required String description,
    required String creatorUsername,
    required String creatorName,
    required List<String> categories,
    required int maxEnrollments,
    required String schedule,
    required String location,
    required double price,
    required bool isRandomAssignment,
    int? groupSize,
  }) async {
    _isLoading.value = true;
    try {
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
      Get.snackbar('Éxito', 'Curso creado exitosamente');
    } catch (e) {
      Get.snackbar('Error', 'Error al crear curso: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> enrollInCourse(
    String courseId,
    String username,
    String userName,
  ) async {
    _isLoading.value = true;
    try {
      await enrollInCourseUseCase(
        courseId: courseId,
        username: username,
        userName: userName,
      );
      await loadCourses();
      Get.snackbar('Éxito', 'Te has inscrito al curso exitosamente');
    } catch (e) {
      Get.snackbar('Error', 'Error al inscribirse al curso: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> unenrollFromCourse(String courseId, String username) async {
    _isLoading.value = true;
    try {
      await unenrollFromCourseUseCase(courseId, username);
      await loadCourses();
      Get.snackbar('Éxito', 'Te has desinscrito del curso exitosamente');
    } catch (e) {
      Get.snackbar('Error', 'Error al desinscribirse del curso: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteCourse(String courseId) async {
    _isLoading.value = true;
    try {
      await deleteCourseUseCase(courseId, '');
      await loadCourses();
      Get.snackbar('Éxito', 'Curso eliminado exitosamente');
    } catch (e) {
      Get.snackbar('Error', 'Error al eliminar curso: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadCreatedCourses(String creatorUsername) async {
    _isLoading.value = true;
    try {
      final courses = await getCoursesByCreatorUseCase(creatorUsername);
      _createdCourses.value = courses;
    } catch (e) {
      Get.snackbar('Error', 'Error al cargar cursos creados: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadEnrolledCourses(String studentUsername) async {
    _isLoading.value = true;
    try {
      final courses = await getCoursesByStudentUseCase(studentUsername);
      _enrolledCourses.value = courses;
    } catch (e) {
      Get.snackbar('Error', 'Error al cargar cursos inscritos: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadCoursesByCategory(String category) async {
    _isLoading.value = true;
    try {
      final courses = await getCoursesByCategoryUseCase(category);
      _filteredCourses.value = courses;
    } catch (e) {
      Get.snackbar('Error', 'Error al cargar cursos por categoría: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void filterCoursesByCategory(String category) {
    _selectedCategory.value = category;
    if (category.isEmpty) {
      _filteredCourses.value = _courses;
    } else {
      _filteredCourses.value = _courses
          .where((course) => course.categories.contains(category))
          .toList();
    }
  }

  void searchCourses(String query) {
    _searchQuery.value = query;
    if (query.isEmpty) {
      _searchResults.value = _courses;
    } else {
      _searchResults.value = _courses
          .where(
            (course) =>
                course.title.toLowerCase().contains(query.toLowerCase()) ||
                course.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
  }

  void clearSearch() {
    _searchQuery.value = '';
    _searchResults.value = _courses;
  }

  void clearFilters() {
    _selectedCategory.value = '';
    _filteredCourses.value = _courses;
  }

  // Métodos para manejo de grupos
  void addUserToGroup(String courseId, String category, String username) {
    if (!_courseGroups.containsKey(courseId)) {
      _courseGroups[courseId] = {};
    }
    if (!_courseGroups[courseId]!.containsKey(category)) {
      _courseGroups[courseId]![category] = [];
    }
    if (!_courseGroups[courseId]![category]!.contains(username)) {
      _courseGroups[courseId]![category]!.add(username);
    }
  }

  void removeUserFromGroup(String courseId, String category, String username) {
    _courseGroups[courseId]?[category]?.remove(username);
  }

  List<String> getGroupMembers(String courseId, String category) {
    return _courseGroups[courseId]?[category] ?? [];
  }

  bool isUserInGroup(String courseId, String category, String username) {
    return _courseGroups[courseId]?[category]?.contains(username) ?? false;
  }

  // Métodos de utilidad
  CourseEntity? getCourseById(String courseId) {
    try {
      return _courses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      return null;
    }
  }

  bool isUserEnrolled(String courseId, String username) {
    // Este método se puede implementar usando el repositorio si es necesario
    // Por ahora retornamos false como valor por defecto
    return false;
  }

  bool isUserCreator(String courseId, String username) {
    final course = getCourseById(courseId);
    return course?.creatorUsername == username;
  }

  // Métodos adicionales para course_detail_screen
  Future<List<CourseEnrollment>> getCourseEnrollments(String courseId) async {
    try {
      return await courseRepository.getCourseEnrollments(courseId);
    } catch (e) {
      Get.snackbar('Error', 'Error al obtener inscripciones: $e');
      return [];
    }
  }

  Future<bool> isUserEnrolledInCourse(String courseId, String username) async {
    try {
      return await courseRepository.isUserEnrolledInCourse(courseId, username);
    } catch (e) {
      Get.snackbar('Error', 'Error al verificar inscripción: $e');
      return false;
    }
  }
}
