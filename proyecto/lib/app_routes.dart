import 'package:get/get.dart';
import 'package:proyecto/features/auth/presentation/screens/login_screen.dart';
import 'package:proyecto/features/auth/presentation/screens/register_screen.dart';
import 'package:proyecto/features/courses/presentation/screens/courses_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String courses = '/courses';

  static List<GetPage> routes = [
    GetPage(
      name: login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: home,
      page: () => const CoursesScreen(), // Usar como home
    ),
    GetPage(
      name: courses,
      page: () => const CoursesScreen(),
    ),
  ];
}
