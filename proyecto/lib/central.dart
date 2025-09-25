import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto/features/auth/presentation/controllers/auth_controller.dart';
import 'package:proyecto/features/courses/presentation/screens/courses_screen.dart';
import 'package:proyecto/features/auth/presentation/screens/login_screen.dart';

class Central extends StatelessWidget {
  const Central({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        if (authController.isLoggedIn) {
          return const CoursesScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
