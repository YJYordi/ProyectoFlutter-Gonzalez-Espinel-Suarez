import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/Entities/user.dart';
import 'package:proyecto/Domain/Entities/course_enrollment.dart';

class InMemoryDataSource {
  UserEntity? _currentUser;
  final Map<String, (String name, String password)> _users = {
    'user': ('Usuario Demo', 'pass'),
  };

  final List<CourseEntity> _courses = <CourseEntity>[];
  final List<CourseEnrollment> _enrollments = <CourseEnrollment>[];

  UserEntity? get currentUser => _currentUser;
  set currentUser(UserEntity? value) => _currentUser = value;
  
  // Getters para acceso desde clases hijas
  List<CourseEntity> get courses => _courses;
  List<CourseEnrollment> get enrollments => _enrollments;
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
}


