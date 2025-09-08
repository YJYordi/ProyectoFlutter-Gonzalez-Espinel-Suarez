import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/Entities/user.dart';
import 'package:proyecto/data/datasources/memory_data_source.dart';

class PersistentDataSource extends InMemoryDataSource {
  static const String _usersKey = 'stored_users';
  static const String _coursesKey = 'stored_courses';
  static const String _currentUserKey = 'current_user';

  Future<void> initialize() async {
    await _loadUsers();
    await _loadCourses();
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
            title: courseData['title'] as String,
            description: courseData['description'] as String,
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
      'title': course.title,
      'description': course.description,
    }).toList();
    await prefs.setString(_coursesKey, jsonEncode(coursesList));
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
  Future<void> createCourse({required String title, required int groupSize, String? groupPrefix}) async {
    await super.createCourse(title: title, groupSize: groupSize, groupPrefix: groupPrefix);
    await _saveCourses();
  }
}
