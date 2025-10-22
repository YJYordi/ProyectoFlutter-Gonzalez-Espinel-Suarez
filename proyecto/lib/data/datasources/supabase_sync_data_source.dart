import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/Entities/user.dart';
import 'package:proyecto/Domain/Entities/course_enrollment.dart';
import 'package:proyecto/Domain/Entities/category.dart';
import 'package:proyecto/data/services/supabase_auth_service.dart';

class SupabaseSyncDataSource {
  final SupabaseClient _client = Supabase.instance.client;
  final SupabaseAuthService _authService = SupabaseAuthService.instance;

  /// Sincronizar usuario con Supabase
  Future<void> syncUser(UserEntity user) async {
    if (user.supabaseUserId == null) return;

    await _client.from('profiles').upsert({
      'id': user.supabaseUserId,
      'name': user.name,
      'username': user.username,
      'email': user.email,
      'role': user.role.name,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Sincronizar curso con Supabase
  Future<void> syncCourse(CourseEntity course) async {
    await _client.from('courses').upsert({
      'id': course.id,
      'title': course.title,
      'description': course.description,
      'creator_username': course.creatorUsername,
      'creator_name': course.creatorName,
      'categories': course.categories,
      'max_enrollments': course.maxEnrollments,
      'current_enrollments': course.currentEnrollments,
      'created_at': course.createdAt.toIso8601String(),
      'schedule': course.schedule,
      'location': course.location,
      'price': course.price,
      'is_random_assignment': course.isRandomAssignment,
      'group_size': course.groupSize,
    });
  }

  /// Sincronizar inscripción con Supabase
  Future<void> syncEnrollment(CourseEnrollment enrollment) async {
    await _client.from('course_enrollments').upsert({
      'id': enrollment.id,
      'course_id': enrollment.courseId,
      'username': enrollment.username,
      'user_name': enrollment.userName,
      'enrolled_at': enrollment.enrolledAt.toIso8601String(),
    });
  }

  /// Sincronizar categoría con Supabase
  Future<void> syncCategory(CategoryEntity category) async {
    await _client.from('categories').upsert({
      'id': category.id,
      'course_id': category.courseId,
      'name': category.name,
      'number_of_groups': category.numberOfGroups,
      'is_random_assignment': category.isRandomAssignment,
      'created_at': category.createdAt.toIso8601String(),
    });

    // Sincronizar grupos
    for (final group in category.groups) {
      await _client.from('groups').upsert({
        'id': group.id,
        'category_id': group.categoryId,
        'group_number': group.groupNumber,
        'members': group.members,
        'max_members': group.maxMembers,
      });
    }
  }

  /// Obtener datos del usuario desde Supabase
  Future<List<UserEntity>> fetchUsers() async {
    try {
      final response = await _client.from('profiles').select();
      return response.map<UserEntity>((data) => UserEntity(
        username: data['username'],
        name: data['name'],
        email: data['email'],
        password: '', // No devolvemos contraseñas
        role: UserRole.values.firstWhere(
          (e) => e.name == data['role'],
          orElse: () => UserRole.student,
        ),
        createdAt: DateTime.parse(data['created_at']),
        supabaseUserId: data['id'],
      )).toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtener cursos desde Supabase
  Future<List<CourseEntity>> fetchCourses() async {
    try {
      final response = await _client.from('courses').select();
      return response.map<CourseEntity>((data) => CourseEntity(
        id: data['id'],
        title: data['title'],
        description: data['description'],
        creatorUsername: data['creator_username'],
        creatorName: data['creator_name'],
        categories: List<String>.from(data['categories']),
        maxEnrollments: data['max_enrollments'],
        currentEnrollments: data['current_enrollments'],
        createdAt: DateTime.parse(data['created_at']),
        schedule: data['schedule'],
        location: data['location'],
        price: data['price']?.toDouble() ?? 0.0,
        isRandomAssignment: data['is_random_assignment'],
        groupSize: data['group_size'],
      )).toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtener inscripciones desde Supabase
  Future<List<CourseEnrollment>> fetchEnrollments() async {
    try {
      final response = await _client.from('course_enrollments').select();
      return response.map<CourseEnrollment>((data) => CourseEnrollment(
        id: data['id'],
        courseId: data['course_id'],
        username: data['username'],
        userName: data['user_name'],
        enrolledAt: DateTime.parse(data['enrolled_at']),
      )).toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtener categorías desde Supabase
  Future<List<CategoryEntity>> fetchCategories() async {
    try {
      final response = await _client.from('categories').select();
      final categories = <CategoryEntity>[];

      for (final data in response) {
        // Obtener grupos de la categoría
        final groupsResponse = await _client
            .from('groups')
            .select()
            .eq('category_id', data['id']);

        final groups = groupsResponse.map<GroupEntity>((groupData) => GroupEntity(
          id: groupData['id'],
          categoryId: groupData['category_id'],
          groupNumber: groupData['group_number'],
          members: List<String>.from(groupData['members']),
          maxMembers: groupData['max_members'],
        )).toList();

        categories.add(CategoryEntity(
          id: data['id'],
          courseId: data['course_id'],
          name: data['name'],
          numberOfGroups: data['number_of_groups'],
          isRandomAssignment: data['is_random_assignment'],
          createdAt: DateTime.parse(data['created_at']),
          groups: groups,
        ));
      }

      return categories;
    } catch (e) {
      return [];
    }
  }

  /// Registrar actividad del usuario
  Future<void> logUserActivity({
    required String type,
    required Map<String, dynamic> payload,
    String? username,
  }) async {
    try {
      final currentUser = _authService.currentUser;
      await _client.from('user_activities').insert({
        'user_id': currentUser?.id,
        'username': username ?? currentUser?.userMetadata?['username'],
        'activity_type': type,
        'payload': payload,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Log error but don't throw to avoid breaking the app
      print('Error logging activity: $e');
    }
  }

  /// Obtener actividades del usuario
  Future<List<Map<String, dynamic>>> getUserActivities(String username) async {
    try {
      final response = await _client
          .from('user_activities')
          .select()
          .eq('username', username)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// Sincronizar todos los datos del usuario
  Future<void> syncAllUserData({
    required List<UserEntity> users,
    required List<CourseEntity> courses,
    required List<CourseEnrollment> enrollments,
    required List<CategoryEntity> categories,
  }) async {
    try {
      // Sincronizar usuarios
      for (final user in users) {
        await syncUser(user);
      }

      // Sincronizar cursos
      for (final course in courses) {
        await syncCourse(course);
      }

      // Sincronizar inscripciones
      for (final enrollment in enrollments) {
        await syncEnrollment(enrollment);
      }

      // Sincronizar categorías
      for (final category in categories) {
        await syncCategory(category);
      }
    } catch (e) {
      print('Error syncing data: $e');
    }
  }

  /// Descargar todos los datos desde Supabase
  Future<Map<String, dynamic>> downloadAllData() async {
    try {
      final users = await fetchUsers();
      final courses = await fetchCourses();
      final enrollments = await fetchEnrollments();
      final categories = await fetchCategories();

      return {
        'users': users,
        'courses': courses,
        'enrollments': enrollments,
        'categories': categories,
      };
    } catch (e) {
      return {
        'users': <UserEntity>[],
        'courses': <CourseEntity>[],
        'enrollments': <CourseEnrollment>[],
        'categories': <CategoryEntity>[],
      };
    }
  }
}

