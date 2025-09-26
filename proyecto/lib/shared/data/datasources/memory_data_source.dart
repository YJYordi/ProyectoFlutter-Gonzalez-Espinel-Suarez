import 'package:proyecto/features/course_management/domain/entities/course.dart';
import 'package:proyecto/features/authentication/domain/entities/user.dart';
import 'package:proyecto/features/course_management/domain/entities/course_enrollment.dart';
import 'package:proyecto/features/category_management/domain/entities/category.dart';
import 'package:proyecto/features/evaluation_system/domain/entities/evaluation.dart';

class InMemoryDataSource {
  UserEntity? _currentUser;
  final Map<String, (String name, String password)> _users = {
    'user': ('Usuario Demo', 'pass'),
    'a@a.com': ('Profesor A', '123456'),
    'b@a.com': ('Estudiante B', '123456'),
    'c@a.com': ('Estudiante C', '123456'),
  };

  final List<CourseEntity> _courses = <CourseEntity>[];
  final List<CourseEnrollment> _enrollments = <CourseEnrollment>[];
  final List<CategoryEntity> _categories = <CategoryEntity>[];
  final List<EvaluationEntity> _evaluations = <EvaluationEntity>[];

  UserEntity? get currentUser => _currentUser;
  set currentUser(UserEntity? value) => _currentUser = value;
  
  void setCurrentUser(UserEntity user) {
    _currentUser = user;
  }
  
  // Getters para acceso desde clases hijas
  List<CourseEntity> get courses => _courses;
  List<CourseEnrollment> get enrollments => _enrollments;
  List<CategoryEntity> get categories => _categories;
  List<EvaluationEntity> get evaluations => _evaluations;
  Map<String, (String name, String password)> get users => _users;

  Future<UserEntity?> login(String username, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final entry = _users[username];
    if (entry != null && entry.$2 == password) {
      _currentUser = UserEntity(
        username: username, 
        name: entry.$1,
        email: '$username@example.com',
        password: password,
        role: UserRole.student, // Los usuarios pueden ser tanto estudiantes como profesores
        createdAt: DateTime.now(),
      );
      return _currentUser;
    }
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
  }

  Future<UserEntity> register({required String name, required String username, required String password}) async {
    if (_users.containsKey(username)) {
      throw ArgumentError('El usuario ya existe');
    }
    _users[username] = (name, password);
    return UserEntity(
      username: username, 
      name: name,
      email: '$username@example.com',
      password: password,
      role: UserRole.student, // Los usuarios pueden ser tanto estudiantes como profesores
      createdAt: DateTime.now(),
    );
  }

  Future<List<CourseEntity>> getCourses() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List<CourseEntity>.unmodifiable(_courses);
  }

  Future<void> createCourse({
    required String title,
    required String description,
    required String creatorUsername,
    required String creatorName,
    required List<String> categories,
    required int maxEnrollments, required bool isRandomAssignment, int? groupSize,
  }) async {
    final courseId = DateTime.now().millisecondsSinceEpoch.toString();
    final course = CourseEntity(
      id: courseId,
      title: title,
      description: description,
      creatorUsername: creatorUsername,
      creatorName: creatorName,
      categories: categories,
      maxEnrollments: maxEnrollments,
      currentEnrollments: 0,
      createdAt: DateTime.now(),
      schedule: 'Por definir',
      location: 'Por definir',
      price: 0.0, 
      isRandomAssignment: false, // o false según corresponda
      groupSize: null, // o un valor entero si aplica
    );
    _courses.add(course);
  }

  Future<CourseEntity?> getCourseById(String courseId) async {
    try {
      return _courses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      return null;
    }
  }

  Future<List<CourseEnrollment>> getCourseEnrollments(String courseId) async {
    return _enrollments.where((enrollment) => enrollment.courseId == courseId).toList();
  }

  Future<void> enrollInCourse({
    required String courseId,
    required String username,
    required String userName,
  }) async {
    final enrollmentId = DateTime.now().millisecondsSinceEpoch.toString();
    final enrollment = CourseEnrollment(
      id: enrollmentId,
      courseId: courseId,
      username: username,
      userName: userName,
      enrolledAt: DateTime.now(),
    );
    _enrollments.add(enrollment);
  }

  Future<bool> isUserEnrolledInCourse(String courseId, String username) async {
    return _enrollments.any((enrollment) => 
        enrollment.courseId == courseId && enrollment.username == username);
  }

  Future<List<CourseEntity>> getCoursesByCategory(String category) async {
    return _courses.where((course) => course.categories.contains(category)).toList();
  }

  Future<void> deleteCourse(String courseId, String creatorUsername) async {
    final courseIndex = _courses.indexWhere((course) => course.id == courseId);
    if (courseIndex != -1 && _courses[courseIndex].creatorUsername == creatorUsername) {
      _courses.removeAt(courseIndex);
      // También eliminar todas las inscripciones del curso
      _enrollments.removeWhere((enrollment) => enrollment.courseId == courseId);
    } else {
      throw ArgumentError('Curso no encontrado o no tienes permisos para eliminarlo');
    }
  }

  Future<void> unenrollFromCourse(String courseId, String username) async {
    _enrollments.removeWhere((enrollment) => 
        enrollment.courseId == courseId && enrollment.username == username);
  }

  Future<List<CourseEntity>> getCoursesByCreator(String creatorUsername) async {
    return _courses.where((course) => course.creatorUsername == creatorUsername).toList();
  }

  Future<List<CourseEntity>> getCoursesByStudent(String username) async {
    final enrolledCourseIds = _enrollments
        .where((enrollment) => enrollment.username == username)
        .map((enrollment) => enrollment.courseId)
        .toSet();
    
    return _courses.where((course) => enrolledCourseIds.contains(course.id)).toList();
  }

  // Category management methods
  Future<List<CategoryEntity>> getCategoriesByCourse(String courseId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _categories.where((category) => category.courseId == courseId).toList();
  }

  Future<CategoryEntity?> getCategoryById(String categoryId) async {
    try {
      return _categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  Future<void> createCategory(CategoryEntity category) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _categories.add(category);
  }

  Future<void> updateCategory(CategoryEntity category) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _categories.removeWhere((category) => category.id == categoryId);
  }

  // Método para limpiar todos los cursos (útil para testing)
  Future<void> clearAllCourses() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _courses.clear();
    _enrollments.clear();
    _categories.clear();
    _evaluations.clear();
  }

  // Evaluation management methods
  Future<void> createEvaluation(EvaluationEntity evaluation) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _evaluations.add(evaluation);
  }

  Future<void> updateEvaluation(EvaluationEntity evaluation) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final index = _evaluations.indexWhere((e) => e.id == evaluation.id);
    if (index != -1) {
      _evaluations[index] = evaluation;
    }
  }

  Future<EvaluationEntity?> getEvaluationById(String evaluationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    try {
      return _evaluations.firstWhere((e) => e.id == evaluationId);
    } catch (e) {
      return null;
    }
  }

  Future<EvaluationEntity?> getEvaluation({
    required String courseId,
    required String categoryId,
    required String groupId,
    required String evaluatorUsername,
    required String evaluatedUsername,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    try {
      return _evaluations.firstWhere((e) =>
          e.courseId == courseId &&
          e.categoryId == categoryId &&
          e.groupId == groupId &&
          e.evaluatorUsername == evaluatorUsername &&
          e.evaluatedUsername == evaluatedUsername);
    } catch (e) {
      return null;
    }
  }

  Future<List<EvaluationEntity>> getEvaluationsByGroup({
    required String courseId,
    required String categoryId,
    required String groupId,
    required String evaluatorUsername,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _evaluations.where((e) =>
        e.courseId == courseId &&
        e.categoryId == categoryId &&
        e.groupId == groupId &&
        e.evaluatorUsername == evaluatorUsername).toList();
  }

  Future<List<EvaluationEntity>> getPendingEvaluations({
    required String username,
    String? courseId,
    String? categoryId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _evaluations.where((e) {
      if (e.evaluatorUsername != username) return false;
      if (courseId != null && e.courseId != courseId) return false;
      if (categoryId != null && e.categoryId != categoryId) return false;
      return e.isPending;
    }).toList();
  }

  Future<List<EvaluationEntity>> getCompletedEvaluations({
    required String username,
    String? courseId,
    String? categoryId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _evaluations.where((e) {
      if (e.evaluatorUsername != username) return false;
      if (courseId != null && e.courseId != courseId) return false;
      if (categoryId != null && e.categoryId != categoryId) return false;
      return e.isCompleted;
    }).toList();
  }
}


