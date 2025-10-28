import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/Entities/user.dart';
import 'package:proyecto/Domain/Entities/course_enrollment.dart';
import 'package:proyecto/Domain/Entities/category.dart';
import 'package:proyecto/Domain/Entities/evaluation.dart';
import 'package:proyecto/data/datasources/memory_data_source.dart';
class PersistentDataSource extends InMemoryDataSource {
  static const String _usersKey = 'stored_users';
  static const String _coursesKey = 'stored_courses';
  static const String _enrollmentsKey = 'stored_enrollments';
  static const String _categoriesKey = 'stored_categories';
  static const String _evaluationsKey = 'stored_evaluations';
  static const String _currentUserKey = 'current_user';
  static const String _rememberUserKey = 'remember_user';
  static const String _savedUsernameKey = 'saved_username';
  static const String _savedPasswordKey = 'saved_password';

  Future<void> initialize() async {
    await _loadUsers();
    await _loadCourses();
    await _loadEnrollments();
    await _loadCategories();
    await _loadEvaluations();
    await _loadCurrentUser();
    await _loadRememberUserSettings();
    
    // Si no hay datos, cargar datos precargados
    if (users.isEmpty) {
      await _loadPreloadedData();
    }
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getString(_categoriesKey);
    if (categoriesJson != null) {
      final List<dynamic> categoriesList = jsonDecode(categoriesJson);
      categories.clear();
      for (final categoryData in categoriesList) {
        if (categoryData is Map<String, dynamic>) {
          categories.add(CategoryEntity.fromJson(categoryData));
        }
      }
    }
  }

  Future<void> _loadEvaluations() async {
    final prefs = await SharedPreferences.getInstance();
    final evaluationsJson = prefs.getString(_evaluationsKey);
    if (evaluationsJson != null) {
      final List<dynamic> evaluationsList = jsonDecode(evaluationsJson);
      evaluations.clear();
      for (final evaluationData in evaluationsList) {
        if (evaluationData is Map<String, dynamic>) {
          evaluations.add(EvaluationEntity.fromJson(evaluationData));
        }
      }
    }
  }

  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      final List<dynamic> usersList = jsonDecode(usersJson);
      users.clear();
      for (final userData in usersList) {
        if (userData is Map<String, dynamic>) {
          final user = UserEntity.fromJson(userData);
          users[user.username] = (
            user.name,
            user.password,
          );
        }
      }
    }
  }

  Future<void> _loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final coursesJson = prefs.getString(_coursesKey);
    if (coursesJson != null) {
      final List<dynamic> coursesList = jsonDecode(coursesJson);
      courses.clear();
      for (final courseData in coursesList) {
        if (courseData is Map<String, dynamic>) {
          courses.add(CourseEntity.fromJson(courseData));
        }
      }
    }
  }

  Future<void> _loadEnrollments() async {
    final prefs = await SharedPreferences.getInstance();
    final enrollmentsJson = prefs.getString(_enrollmentsKey);
    if (enrollmentsJson != null) {
      final List<dynamic> enrollmentsList = jsonDecode(enrollmentsJson);
      enrollments.clear();
      for (final enrollmentData in enrollmentsList) {
        if (enrollmentData is Map<String, dynamic>) {
          enrollments.add(CourseEnrollment(
            id: enrollmentData['id'] as String,
            courseId: enrollmentData['courseId'] as String,
            username: enrollmentData['username'] as String,
            userName: enrollmentData['userName'] as String,
            enrolledAt: DateTime.parse(enrollmentData['enrolledAt'] as String),
          ));
        }
      }
    }
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    if (userJson != null) {
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      currentUser = UserEntity.fromJson(userData);
    }
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersList = <Map<String, dynamic>>[];
    users.forEach((username, userData) {
      usersList.add({
        'username': username,
        'name': userData.$1,
        'password': userData.$2,
        'email': '$username@example.com', // Email por defecto
        'role': 'student', // Rol por defecto
        'createdAt': DateTime.now().toIso8601String(),
      });
    });
    await prefs.setString(_usersKey, jsonEncode(usersList));
  }

  Future<void> _saveCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final coursesList = courses.map((course) => course.toJson()).toList();
    await prefs.setString(_coursesKey, jsonEncode(coursesList));
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesList = categories.map((category) => category.toJson()).toList();
    await prefs.setString(_categoriesKey, jsonEncode(categoriesList));
  }

  Future<void> _saveEnrollments() async {
    final prefs = await SharedPreferences.getInstance();
    final enrollmentsList = enrollments.map((enrollment) => {
      'id': enrollment.id,
      'courseId': enrollment.courseId,
      'username': enrollment.username,
      'userName': enrollment.userName,
      'enrolledAt': enrollment.enrolledAt.toIso8601String(),
    }).toList();
    await prefs.setString(_enrollmentsKey, jsonEncode(enrollmentsList));
  }

  Future<void> _saveEvaluations() async {
    final prefs = await SharedPreferences.getInstance();
    final evaluationsList = evaluations.map((evaluation) => evaluation.toJson()).toList();
    await prefs.setString(_evaluationsKey, jsonEncode(evaluationsList));
  }

  Future<void> _saveCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (currentUser != null) {
      await prefs.setString(_currentUserKey, jsonEncode(currentUser!.toJson()));
    } else {
      await prefs.remove(_currentUserKey);
    }
  }

  @override
  Future<UserEntity?> login(String username, String password) async {
    final result = await super.login(username, password);
    if (result != null) {
      await _saveCurrentUser();
    }
    return result;
  }

  @override
  Future<void> logout() async {
    await super.logout();
    await _saveCurrentUser();
  }

  @override
  Future<UserEntity> register({required String name, required String username, required String password}) async {
    final result = await super.register(name: name, username: username, password: password);
    await _saveUsers();
    return result;
  }

  @override
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
    int? groupSize;
    await super.createCourse(
      title: title,
      description: description,
      creatorUsername: creatorUsername,
      creatorName: creatorName,
      categories: categories,
      maxEnrollments: maxEnrollments,
      isRandomAssignment: isRandomAssignment,
      groupSize: groupSize,
    );
    await _saveCourses();
  }

  @override
  Future<void> enrollInCourse({
    required String courseId,
    required String username,
    required String userName,
  }) async {
    await super.enrollInCourse(
      courseId: courseId,
      username: username,
      userName: userName,
    );
    await _saveEnrollments();
  }

  @override
  Future<void> deleteCourse(String courseId, String creatorUsername) async {
    await super.deleteCourse(courseId, creatorUsername);
    await _saveCourses();
    await _saveEnrollments();
  }

  @override
  Future<void> unenrollFromCourse(String courseId, String username) async {
    await super.unenrollFromCourse(courseId, username);
    await _saveEnrollments();
  }

  // Métodos para manejar "recordar usuario"
  Future<void> _loadRememberUserSettings() async {
    // Cargar configuración de recordar usuario si es necesaria
    // Los valores se cargan cuando se necesitan en getRememberedCredentials()
  }

  Future<void> saveRememberUserSettings({
    required bool rememberUser,
    String? username,
    String? password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberUserKey, rememberUser);
    
    if (rememberUser && username != null && password != null) {
      await prefs.setString(_savedUsernameKey, username);
      await prefs.setString(_savedPasswordKey, password);
    } else {
      await prefs.remove(_savedUsernameKey);
      await prefs.remove(_savedPasswordKey);
    }
  }

  Future<Map<String, String?>> getRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberUser = prefs.getBool(_rememberUserKey) ?? false;
    
    if (rememberUser) {
      return {
        'username': prefs.getString(_savedUsernameKey),
        'password': prefs.getString(_savedPasswordKey),
      };
    }
    
    return {'username': null, 'password': null};
  }

  // Método para cargar datos precargados
  Future<void> _loadPreloadedData() async {
    // Datos precargados de usuarios
    final preloadedUsers = [
      UserEntity(
        username: 'estudiante1',
        name: 'Ana García',
        email: 'ana.garcia@example.com',
        password: '123456',
        role: UserRole.student,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      UserEntity(
        username: 'estudiante2',
        name: 'Carlos López',
        email: 'carlos.lopez@example.com',
        password: '123456',
        role: UserRole.student,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      UserEntity(
        username: 'profesor1',
        name: 'Dr. María Rodríguez',
        email: 'maria.rodriguez@example.com',
        password: '123456',
        role: UserRole.teacher,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      UserEntity(
        username: 'profesor2',
        name: 'Prof. Juan Martínez',
        email: 'juan.martinez@example.com',
        password: '123456',
        role: UserRole.teacher,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
    ];

    // Agregar usuarios precargados
    for (final user in preloadedUsers) {
      users[user.username] = (user.name, user.password);
    }

    // Datos precargados de cursos
    final preloadedCourses = [
      CourseEntity(
        id: 'course_1',
        title: 'Programación en Flutter',
        description: 'Aprende a desarrollar aplicaciones móviles con Flutter y Dart',
        creatorUsername: 'profesor1',
        creatorName: 'Dr. María Rodríguez',
        categories: ['Programación', 'Móvil', 'Flutter'],
        maxEnrollments: 25,
        currentEnrollments: 15,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        schedule: 'Lunes y Miércoles 18:00-20:00',
        location: 'Aula 101',
        price: 150.0, 
        isRandomAssignment: false,
        groupSize: null,
      ),
      CourseEntity(
        id: 'course_2',
        title: 'Diseño UI/UX',
        description: 'Fundamentos del diseño de interfaces de usuario y experiencia',
        creatorUsername: 'profesor2',
        creatorName: 'Prof. Juan Martínez',
        categories: ['Diseño', 'UI/UX', 'Creatividad'],
        maxEnrollments: 20,
        currentEnrollments: 12,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        schedule: 'Martes y Jueves 16:00-18:00',
        location: 'Laboratorio de Diseño',
        price: 120.0, 
        isRandomAssignment: false,
        groupSize: null,
      ),
      CourseEntity(
        id: 'course_3',
        title: 'Base de Datos Avanzadas',
        description: 'Manejo avanzado de bases de datos relacionales y NoSQL',
        creatorUsername: 'profesor1',
        creatorName: 'Dr. María Rodríguez',
        categories: ['Base de Datos', 'SQL', 'NoSQL'],
        maxEnrollments: 30,
        currentEnrollments: 18,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        schedule: 'Viernes 14:00-17:00',
        location: 'Aula 205',
        price: 180.0, 
        isRandomAssignment: false,
        groupSize: null,
      ),
      CourseEntity(
        id: 'course_4',
        title: 'Inteligencia Artificial',
        description: 'Introducción a la IA y machine learning',
        creatorUsername: 'profesor2',
        creatorName: 'Prof. Juan Martínez',
        categories: ['IA', 'Machine Learning', 'Python'],
        maxEnrollments: 15,
        currentEnrollments: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        schedule: 'Sábados 09:00-12:00',
        location: 'Laboratorio de IA',
        price: 200.0, 
        isRandomAssignment: false,
        groupSize: null,
      ),
    ];

    // Agregar cursos precargados
    courses.addAll(preloadedCourses);

    // Guardar datos precargados
    await _saveUsers();
    await _saveCourses();
    await _saveCategories();
    await _saveEvaluations();
  }

  // Métodos para categorías
  @override
  Future<void> createCategory(CategoryEntity category) async {
    await super.createCategory(category);
    await _saveCategories();
  }

  @override
  Future<List<CategoryEntity>> getCategoriesByCourse(String courseId) async {
    return await super.getCategoriesByCourse(courseId);
  }

  @override
  Future<void> updateCategory(CategoryEntity category) async {
    await super.updateCategory(category);
    await _saveCategories();
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await super.deleteCategory(categoryId);
    await _saveCategories();
  }

  // Métodos para evaluaciones
  @override
  Future<void> createEvaluation(EvaluationEntity evaluation) async {
    await super.createEvaluation(evaluation);
    await _saveEvaluations();
  }

  @override
  Future<List<EvaluationEntity>> getEvaluationsByGroup({
    required String categoryId,
    required String courseId,
    required String evaluatorUsername,
    required String groupId,
  }) async {
    return await super.getEvaluationsByGroup(
      categoryId: categoryId,
      courseId: courseId,
      evaluatorUsername: evaluatorUsername,
      groupId: groupId,
    );
  }

  @override
  Future<List<EvaluationEntity>> getPendingEvaluations({
    String? categoryId,
    String? courseId,
    required String username,
  }) async {
    return await super.getPendingEvaluations(
      categoryId: categoryId,
      courseId: courseId,
      username: username,
    );
  }

  @override
  Future<void> updateEvaluation(EvaluationEntity evaluation) async {
    await super.updateEvaluation(evaluation);
    await _saveEvaluations();
  }

  @override
  Future<CategoryEntity?> getCategoryById(String categoryId) async {
    return await super.getCategoryById(categoryId);
  }

  @override
  Future<EvaluationEntity?> getEvaluationById(String evaluationId) async {
    return await super.getEvaluationById(evaluationId);
  }

  @override
  Future<EvaluationEntity?> getEvaluation({
    required String courseId,
    required String categoryId,
    required String groupId,
    required String evaluatorUsername,
    required String evaluatedUsername,
  }) async {
    return await super.getEvaluation(
      courseId: courseId,
      categoryId: categoryId,
      groupId: groupId,
      evaluatorUsername: evaluatorUsername,
      evaluatedUsername: evaluatedUsername,
    );
  }
}
