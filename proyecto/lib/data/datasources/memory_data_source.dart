import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/Entities/user.dart';

class InMemoryDataSource {
  UserEntity? _currentUser;

  final List<CourseEntity> _courses = <CourseEntity>[
    const CourseEntity(title: 'Flutter Básico', description: 'Aprende Flutter desde cero'),
    const CourseEntity(title: 'Dart Intermedio', description: 'Mejora tus habilidades en Dart'),
    const CourseEntity(title: 'UI Avanzada', description: 'Crea interfaces atractivas'),
    const CourseEntity(title: 'Backend con Firebase', description: 'Conecta tu app a la nube'),
  ];

  UserEntity? get currentUser => _currentUser;

  Future<UserEntity?> login(String username, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (username == 'user' && password == 'pass') {
      _currentUser = UserEntity(username: username);
      return _currentUser;
    }
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
  }

  Future<List<CourseEntity>> getCourses() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List<CourseEntity>.unmodifiable(_courses);
  }

  Future<void> createCourse({required String title, required int groupSize, String? groupPrefix}) async {
    final description = 'Tamaño grupo: $groupSize' + (groupPrefix != null ? ', Prefijo: $groupPrefix' : '');
    _courses.add(CourseEntity(title: title, description: description));
  }
}


