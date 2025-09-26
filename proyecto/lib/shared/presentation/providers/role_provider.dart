import 'package:flutter/foundation.dart';

class RoleProvider extends ChangeNotifier {
  bool _isProfessor = false;

  bool get isProfessor => _isProfessor;

  String get roleDisplayName => _isProfessor ? 'Profesor' : 'Estudiante';

  String get roleIcon => _isProfessor ? '👨‍🏫' : '👨‍🎓';

  void initializeRole() {
    // Por defecto, el usuario es estudiante
    _isProfessor = false;
    notifyListeners();
  }

  void switchRole() {
    _isProfessor = !_isProfessor;
    notifyListeners();
  }

  void setRole(bool isProfessor) {
    _isProfessor = isProfessor;
    notifyListeners();
  }
}
