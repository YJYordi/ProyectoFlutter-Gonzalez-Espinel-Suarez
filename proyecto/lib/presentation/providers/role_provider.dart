import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole {
  professor,
  student,
}

class RoleProvider with ChangeNotifier {
  UserRole _currentRole = UserRole.professor;
  static const String _roleKey = 'user_role';

  UserRole get currentRole => _currentRole;
  bool get isProfessor => _currentRole == UserRole.professor;
  bool get isStudent => _currentRole == UserRole.student;

  String get roleDisplayName {
    switch (_currentRole) {
      case UserRole.professor:
        return 'Profesor';
      case UserRole.student:
        return 'Estudiante';
    }
  }

  String get roleIcon {
    switch (_currentRole) {
      case UserRole.professor:
        return '👨‍🏫';
      case UserRole.student:
        return '👨‍🎓';
    }
  }

  Future<void> initializeRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleIndex = prefs.getInt(_roleKey) ?? 0; // Default to professor
    _currentRole = UserRole.values[roleIndex];
    notifyListeners();
  }

  Future<void> switchRole() async {
    _currentRole = _currentRole == UserRole.professor 
        ? UserRole.student 
        : UserRole.professor;
    
    // Persist the role change
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_roleKey, _currentRole.index);
    
    notifyListeners();
  }

  Future<void> setRole(UserRole role) async {
    if (_currentRole != role) {
      _currentRole = role;
      
      // Persist the role change
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_roleKey, _currentRole.index);
      
      notifyListeners();
    }
  }
}
