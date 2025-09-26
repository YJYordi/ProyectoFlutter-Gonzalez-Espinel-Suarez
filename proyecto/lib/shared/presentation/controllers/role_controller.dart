import 'package:get/get.dart';

class RoleController extends GetxController {
  // Variables reactivas
  final _isProfessor = false.obs;

  // Getters
  bool get isProfessor => _isProfessor.value;
  String get roleDisplayName => _isProfessor.value ? 'Profesor' : 'Estudiante';
  String get roleIcon => _isProfessor.value ? '👨‍🏫' : '👨‍🎓';

  @override
  void onInit() {
    super.onInit();
    initializeRole();
  }

  void initializeRole() {
    // Por defecto, el usuario es estudiante
    _isProfessor.value = false;
  }

  void switchRole() {
    _isProfessor.value = !_isProfessor.value;
  }

  void setRole(bool isProfessor) {
    _isProfessor.value = isProfessor;
  }
}
