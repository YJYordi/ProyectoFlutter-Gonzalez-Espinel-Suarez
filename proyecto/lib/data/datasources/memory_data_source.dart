import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/Entities/user.dart';

class InMemoryDataSource {
  UserEntity? _currentUser;
  final Map<String, (String name, String password)> _users = {
    'user': ('Usuario Demo', 'pass'),
  };

  final List<CourseEntity> _courses = <CourseEntity>[
    const CourseEntity(title: 'Flutter Básico', description: 'Aprende Flutter desde cero'),
    const CourseEntity(title: 'Dart Intermedio', description: 'Mejora tus habilidades en Dart'),
    const CourseEntity(title: 'UI Avanzada', description: 'Crea interfaces atractivas'),
    const CourseEntity(title: 'Backend con Firebase', description: 'Conecta tu app a la nube'),
  ];

  UserEntity? get currentUser => _currentUser;
  set currentUser(UserEntity? value) => _currentUser = value;
  
  // Getters para acceso desde clases hijas
  List<CourseEntity> get courses => _courses;
  Map<String, (String name, String password)> get users => _users;

  Future<UserEntity?> login(String username, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final entry = _users[username];
    if (entry != null && entry.$2 == password) {
      _currentUser = UserEntity(username: username, name: entry.$1);
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
    return UserEntity(username: username, name: name);
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


