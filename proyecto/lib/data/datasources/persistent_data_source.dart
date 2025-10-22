import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/Entities/user.dart';
import 'package:proyecto/Domain/Entities/course_enrollment.dart';
import 'package:proyecto/data/datasources/memory_data_source.dart';
import 'package:proyecto/data/datasources/supabase_remote_data_source.dart';
import 'package:proyecto/data/datasources/supabase_sync_data_source.dart';
import 'package:proyecto/data/services/supabase_auth_service.dart';

class PersistentDataSource extends InMemoryDataSource {
  final SupabaseRemoteDataSource? remote;
  final SupabaseSyncDataSource? syncDataSource;
  final SupabaseAuthService? authService;
  
  PersistentDataSource({
    this.remote,
    this.syncDataSource,
    this.authService,
  });
import 'package:proyecto/data/datasources/roble_remote_data_source.dart';

class PersistentDataSource extends InMemoryDataSource {
  final RobleRemoteDataSource? remote;
  PersistentDataSource({this.remote});
  static const String _usersKey = 'stored_users';
  static const String _coursesKey = 'stored_courses';
  static const String _enrollmentsKey = 'stored_enrollments';
  static const String _currentUserKey = 'current_user';
  static const String _rememberUserKey = 'remember_user';
  static const String _savedUsernameKey = 'saved_username';
  static const String _savedPasswordKey = 'saved_password';

  Future<void> initialize() async {
    await _loadUsers();
    await _loadCourses();
    await _loadEnrollments();
    await _loadCurrentUser();
    await _loadRememberUserSettings();
    
    // Si no hay datos, cargar datos precargados
    if (users.isEmpty) {
      await _loadPreloadedData();
    }
    
    // Intentar sincronizar con Supabase si está disponible
    if (syncDataSource != null && authService != null) {
      try {
        await _syncWithSupabase();
      } catch (e) {
        print('Error syncing with Supabase: $e');
      }
    }
  }

  /// Sincronizar datos con Supabase
  Future<void> _syncWithSupabase() async {
    if (syncDataSource == null || authService == null) return;

    // Si el usuario está autenticado, descargar sus datos
    if (authService!.isLoggedIn) {
      final remoteData = await syncDataSource!.downloadAllData();
      
      // Actualizar datos locales con los remotos
      await _updateLocalDataFromRemote(remoteData);
    }
  }

  /// Actualizar datos locales con datos remotos
  Future<void> _updateLocalDataFromRemote(Map<String, dynamic> remoteData) async {
    // Actualizar usuarios
    final remoteUsers = remoteData['users'] as List<UserEntity>;
    for (final user in remoteUsers) {
      users[user.username] = (user.name, user.password);
    }

    // Actualizar cursos
    final remoteCourses = remoteData['courses'] as List<CourseEntity>;
    courses.clear();
    courses.addAll(remoteCourses);

    // Actualizar inscripciones
    final remoteEnrollments = remoteData['enrollments'] as List<CourseEnrollment>;
    enrollments.clear();
    enrollments.addAll(remoteEnrollments);

    // Guardar cambios localmente
    await _saveUsers();
    await _saveCourses();
    await _saveEnrollments();
  }

  /// Sincronizar datos locales con Supabase
  Future<void> syncToSupabase() async {
    if (syncDataSource == null) return;

    try {
      // Convertir datos locales a entidades
      final localUsers = users.entries.map((entry) {
        return UserEntity(
          username: entry.key,
          name: entry.value.$1,
          email: '${entry.key}@example.com',
          password: entry.value.$2,
          role: UserRole.student, // Por defecto
          createdAt: DateTime.now(),
        );
      }).toList();

      // Sincronizar todos los datos
      await syncDataSource!.syncAllUserData(
        users: localUsers,
        courses: courses,
        enrollments: enrollments,
        categories: [], // TODO: Agregar categorías si es necesario
      );
    } catch (e) {
      print('Error syncing to Supabase: $e');

    // Sincronizar usuarios desde Roble si está configurado
    if (remote != null) {
      try {
        final remoteUsers = await remote!.fetchUsers();
        for (final u in remoteUsers) {
          users[u.username] = (u.name, u.password);
        }
        await _saveUsers();
      } catch (_) {}
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
    // Si tenemos Supabase, intentar autenticación con Supabase
    if (authService != null) {
      try {
        // Buscar el email del usuario (asumiendo formato username@example.com)
        final email = '$username@example.com';
        final authResponse = await authService!.signIn(
          email: email,
          password: password,
        );

        if (authResponse.user != null) {
          final userEntity = authService!.getCurrentUserEntity();
          if (userEntity != null) {
            currentUser = userEntity;
            await _saveCurrentUser();
            
            // Log actividad
            if (syncDataSource != null) {
              await syncDataSource!.logUserActivity(
                type: 'login',
                payload: {'username': username},
                username: username,
              );
            }
            
            return userEntity;
          }
        }
      } catch (e) {
        print('Supabase login failed, trying local: $e');
      }
    }

    // Fallback a autenticación local
    // Si hay remoto, intentar login remoto primero
    if (remote != null) {
      try {
        final remoteUser = await remote!.login(username, password);
        if (remoteUser != null) {
          currentUser = remoteUser;
          await _saveCurrentUser();
          await remote!.insertActivity(type: 'login', payload: {'username': username}, username: username);
          return remoteUser;
        }
      } catch (_) {}
    }
    final result = await super.login(username, password);
    if (result != null) {
      await _saveCurrentUser();
      if (remote != null) {
        try {
          await remote!.insertActivity(type: 'login', payload: {'username': username}, username: username);
        } catch (_) {}
      }
    }
    return result;
  }

  @override
  Future<void> logout() async {
    // Si tenemos Supabase, cerrar sesión en Supabase también
    if (authService != null) {
      try {
        await authService!.signOut();
      } catch (e) {
        print('Error signing out from Supabase: $e');
      }
    }
    
    await super.logout();
    await _saveCurrentUser();
    
    if (remote != null) {
      try {
        await remote!.insertActivity(type: 'logout', payload: {}, username: null);
      } catch (_) {}
    }
  }

  @override
  Future<UserEntity> register({required String name, required String username, required String password}) async {
    // Si tenemos Supabase, registrar en Supabase también
    if (authService != null) {
      try {
        final email = '$username@example.com';
        final authResponse = await authService!.signUp(
          email: email,
          password: password,
          name: name,
          username: username,
          role: UserRole.student, // Por defecto
        );

        if (authResponse.user != null) {
          final userEntity = UserEntity(
            username: username,
            name: name,
            email: email,
            password: password,
            role: UserRole.student,
            createdAt: DateTime.now(),
            supabaseUserId: authResponse.user!.id,
          );

          // Agregar a usuarios locales
          users[username] = (name, password);
          await _saveUsers();

          // Log actividad
          if (syncDataSource != null) {
            await syncDataSource!.logUserActivity(
              type: 'register',
              payload: {'username': username},
              username: username,
            );
          }

          return userEntity;
        }
      } catch (e) {
        print('Supabase registration failed, trying local: $e');
      }
    }

    // Fallback a registro local
    // Si hay remoto, registrar primero en remoto
    if (remote != null) {
      try {
        final user = await remote!.register(name: name, username: username, password: password);
        users[username] = (user.name, password);
        await _saveUsers();
        await remote!.insertActivity(type: 'register', payload: {'username': username}, username: username);
        return user;
      } catch (_) {
        // fallback local
      }
    }
    final result = await super.register(name: name, username: username, password: password);
    await _saveUsers();
    if (remote != null) {
      try {
        await remote!.upsertUser(result);
        await remote!.insertActivity(type: 'register', payload: {'username': username}, username: username);
      } catch (_) {}
    }
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
  }
}
