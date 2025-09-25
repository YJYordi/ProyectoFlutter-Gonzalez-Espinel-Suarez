import 'package:get/get.dart';

import '../pages/auth_page.dart';

class AuthRoutes {
  static const String login = '/login';
  static const String signup = '/signup';

  static List<GetPage> routes = [
    GetPage(
      name: login,
      page: () => const AuthPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: signup,
      page: () => const AuthPage(),
      transition: Transition.fadeIn,
    ),
  ];
}
