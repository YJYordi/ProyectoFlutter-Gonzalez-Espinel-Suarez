import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/Entities/user.dart';
import 'package:proyecto/Domain/Entities/course_enrollment.dart';
import 'package:proyecto/data/datasources/memory_data_source.dart';

class PersistentDataSource extends InMemoryDataSource {
  static const String _usersKey = 'stored_users';
  static const String _coursesKey = 'stored_courses';
  static const String _enrollmentsKey = 'stored_enrollments';
  static const String _currentUserKey = 'current_user';

  Future<void> initialize() async {
    await _loadUsers();
    await _loadCourses();
    await _loadEnrollments();
    await _loadCurrentUser();
  }

  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      final Map<String, dynamic> usersMap = jsonDecode(usersJson);
      users.clear();
      usersMap.forEach((username, userData) {
        if (userData is Map<String, dynamic>) {
          users[username] = (
            userData['name'] as String,
            userData['password'] as String,
          );
        }
      });
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
          courses.add(CourseEntity(
            id: courseData['id'] as String,
            title: courseData['title'] as String,
            description: courseData['description'] as String,
            creatorUsername: courseData['creatorUsername'] as String,
            creatorName: courseData['creatorName'] as String,
            categories: List<String>.from(courseData['categories'] as List),
            maxEnrollments: courseData['maxEnrollments'] as int,
            createdAt: DateTime.parse(courseData['createdAt'] as String),
          ));
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
      currentUser = UserEntity(
        username: userData['username'] as String,
        name: userData['name'] as String,
      );
    }
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersMap = <String, dynamic>{};
    users.forEach((username, userData) {
      usersMap[username] = {
        'name': userData.$1,
        'password': userData.$2,
      };
    });
    await prefs.setString(_usersKey, jsonEncode(usersMap));
  }

  Future<void> _saveCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final coursesList = courses.map((course) => {
      'id': course.id,
      'title': course.title,
      'description': course.description,
      'creatorUsername': course.creatorUsername,
      'creatorName': course.creatorName,
      'categories': course.categories,
      'maxEnrollments': course.maxEnrollments,
      'createdAt': course.createdAt.toIso8601String(),
    }).toList();
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
      await prefs.setString(_currentUserKey, jsonEncode({
        'username': currentUser!.username,
        'name': currentUser!.name,
      }));
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
  }) async {
    await super.createCourse(
      title: title,
      description: description,
      creatorUsername: creatorUsername,
      creatorName: creatorName,
      categories: categories,
      maxEnrollments: maxEnrollments,
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
}
