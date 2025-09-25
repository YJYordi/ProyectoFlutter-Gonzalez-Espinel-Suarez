import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:proyecto/features/courses/domain/entities/course.dart';
import 'package:proyecto/features/courses/domain/entities/course_enrollment.dart';

abstract class CoursesRemoteDataSource {
  Future<List<CourseEntity>> getCourses();
  Future<CourseEntity> createCourse(CourseEntity course);
  Future<CourseEntity?> getCourseById(String courseId);
  Future<List<CourseEnrollment>> getCourseEnrollments(String courseId);
  Future<void> enrollInCourse(String courseId, String username, String userName);
  Future<void> unenrollFromCourse(String courseId, String username);
  Future<bool> isUserEnrolledInCourse(String courseId, String username);
  Future<List<CourseEntity>> getCoursesByCategory(String category);
  Future<void> deleteCourse(String courseId, String creatorUsername);
  Future<List<CourseEntity>> getCoursesByCreator(String creatorUsername);
  Future<List<CourseEntity>> getCoursesByStudent(String username);
}

class CoursesRemoteDataSourceImpl implements CoursesRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  CoursesRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<List<CourseEntity>> getCourses() async {
    final response = await client.get(
      Uri.parse('$baseUrl/courses'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['courses'] as List)
          .map((json) => CourseEntity.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al obtener cursos: ${response.statusCode}');
    }
  }

  @override
  Future<CourseEntity> createCourse(CourseEntity course) async {
    final response = await client.post(
      Uri.parse('$baseUrl/courses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return CourseEntity.fromJson(data['course']);
    } else {
      throw Exception('Error al crear curso: ${response.statusCode}');
    }
  }

  @override
  Future<CourseEntity?> getCourseById(String courseId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/courses/$courseId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CourseEntity.fromJson(data['course']);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Error al obtener curso: ${response.statusCode}');
    }
  }

  @override
  Future<List<CourseEnrollment>> getCourseEnrollments(String courseId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/courses/$courseId/enrollments'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['enrollments'] as List)
          .map((json) => CourseEnrollment(
                id: json['id'],
                courseId: json['courseId'],
                username: json['username'],
                userName: json['userName'],
                enrolledAt: DateTime.parse(json['enrolledAt']),
              ))
          .toList();
    } else {
      throw Exception('Error al obtener inscripciones: ${response.statusCode}');
    }
  }

  @override
  Future<void> enrollInCourse(String courseId, String username, String userName) async {
    final response = await client.post(
      Uri.parse('$baseUrl/courses/$courseId/enroll'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'userName': userName,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al inscribirse: ${response.statusCode}');
    }
  }

  @override
  Future<void> unenrollFromCourse(String courseId, String username) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/courses/$courseId/enroll'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al desinscribirse: ${response.statusCode}');
    }
  }

  @override
  Future<bool> isUserEnrolledInCourse(String courseId, String username) async {
    final response = await client.get(
      Uri.parse('$baseUrl/courses/$courseId/enrollments/$username'),
      headers: {'Content-Type': 'application/json'},
    );

    return response.statusCode == 200;
  }

  @override
  Future<List<CourseEntity>> getCoursesByCategory(String category) async {
    final response = await client.get(
      Uri.parse('$baseUrl/courses?category=$category'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['courses'] as List)
          .map((json) => CourseEntity.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al obtener cursos por categoría: ${response.statusCode}');
    }
  }

  @override
  Future<void> deleteCourse(String courseId, String creatorUsername) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/courses/$courseId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'creatorUsername': creatorUsername}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar curso: ${response.statusCode}');
    }
  }

  @override
  Future<List<CourseEntity>> getCoursesByCreator(String creatorUsername) async {
    final response = await client.get(
      Uri.parse('$baseUrl/courses?creator=$creatorUsername'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['courses'] as List)
          .map((json) => CourseEntity.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al obtener cursos del creador: ${response.statusCode}');
    }
  }

  @override
  Future<List<CourseEntity>> getCoursesByStudent(String username) async {
    final response = await client.get(
      Uri.parse('$baseUrl/courses?student=$username'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['courses'] as List)
          .map((json) => CourseEntity.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al obtener cursos del estudiante: ${response.statusCode}');
    }
  }
}
