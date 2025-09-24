import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'presentation/screens/log_in.dart';
import 'presentation/screens/home_page.dart';
import 'presentation/screens/profile_screen.dart';
import 'package:proyecto/data/datasources/persistent_data_source.dart';
import 'package:proyecto/data/repositories/auth_repository_impl.dart';
import 'package:proyecto/data/repositories/course_repository_impl.dart';
import 'package:proyecto/Domain/usecases/login_usecase.dart';
import 'package:proyecto/Domain/usecases/register_usecase.dart';
import 'package:proyecto/Domain/usecases/get_courses_usecase.dart';
import 'package:proyecto/Domain/usecases/create_course_usecase.dart';
import 'package:proyecto/Domain/usecases/enroll_in_course_usecase.dart';
import 'package:proyecto/Domain/usecases/get_course_enrollments_usecase.dart';
import 'package:proyecto/Domain/usecases/delete_course_usecase.dart';
import 'package:proyecto/Domain/usecases/unenroll_from_course_usecase.dart';
import 'package:proyecto/Domain/usecases/get_courses_by_creator_usecase.dart';
import 'package:proyecto/Domain/usecases/get_courses_by_student_usecase.dart';
import 'package:proyecto/Domain/usecases/get_courses_by_category_usecase.dart';
import 'package:proyecto/presentation/providers/auth_provider.dart';
import 'package:proyecto/presentation/providers/course_provider.dart';
import 'package:proyecto/presentation/screens/category_courses_screen.dart';
import 'package:proyecto/presentation/screens/sign_up.dart';
import 'package:proyecto/presentation/screens/course_detail_screen.dart';
import 'package:proyecto/presentation/screens/course_management_screen.dart';
import 'package:proyecto/Domain/Entities/course.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final PersistentDataSource _dataSource;
  late final AuthRepositoryImpl _authRepo;
  late final CourseRepositoryImpl _courseRepo;

  @override
  void initState() {
    super.initState();
    _dataSource = PersistentDataSource();
    _authRepo = AuthRepositoryImpl(_dataSource);
    _courseRepo = CourseRepositoryImpl(_dataSource);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _dataSource.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            loginUseCase: LoginUseCase(_authRepo),
            registerUseCase: RegisterUseCase(_authRepo),
          ),
        ),
        ChangeNotifierProvider<CourseProvider>(
          create: (_) => CourseProvider(
            getCoursesUseCase: GetCoursesUseCase(_courseRepo),
            createCourseUseCase: CreateCourseUseCase(_courseRepo),
            enrollInCourseUseCase: EnrollInCourseUseCase(_courseRepo),
            getCourseEnrollmentsUseCase: GetCourseEnrollmentsUseCase(
              _courseRepo,
            ),
            deleteCourseUseCase: DeleteCourseUseCase(_courseRepo),
            unenrollFromCourseUseCase: UnenrollFromCourseUseCase(_courseRepo),
            getCoursesByCreatorUseCase: GetCoursesByCreatorUseCase(_courseRepo),
            getCoursesByStudentUseCase: GetCoursesByStudentUseCase(_courseRepo),
            getCoursesByCategoryUseCase: GetCoursesByCategoryUseCase(
              _courseRepo,
            ),
            courseRepository: _courseRepo,
          )..loadCourses(),
        ),
      ],
      child: GetMaterialApp(
        // 👈 cambiado de MaterialApp a GetMaterialApp
        title: 'Clases App',
        initialRoute: '/',
        getPages: [
          // 👈 en vez de routes normales, usamos GetX
          GetPage(name: '/', page: () => const LoginPage()),
          GetPage(name: '/home', page: () => const HomePage()),
          GetPage(
            name: '/perfil',
            page: () {
              final args = Get.arguments as String? ?? 'Usuario';
              return ProfileScreen(usuario: args);
            },
          ),
          GetPage(name: '/signup', page: () => const SignUpPage()),
          GetPage(
            name: '/course_detail',
            page: () {
              final args = Get.arguments as CourseEntity;
              return CourseDetailScreen(course: args);
            },
          ),
          GetPage(
            name: '/category_courses',
            page: () {
              final args = Get.arguments as String;
              return CategoryCoursesScreen(category: args);
            },
          ),
          GetPage(
            name: '/course_management',
            page: () {
              final course = Get.arguments as CourseEntity;
              final authProvider = Provider.of<AuthProvider>(
                Get.context!,
                listen: false,
              );
              final currentUser = authProvider.user;
              if (currentUser == null) {
                return const LoginPage();
              }
              return CourseManagementScreen(
                course: course,
                currentUser: currentUser,
              );
            },
          ),
        ],
      ),
    );
  }
}
