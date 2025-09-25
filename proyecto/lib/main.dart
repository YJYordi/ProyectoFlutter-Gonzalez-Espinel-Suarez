import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

// Feature Auth
import 'features/auth/auth.dart';

// Existing imports
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
import 'package:proyecto/Domain/usecases/create_category_usecase.dart';
import 'package:proyecto/Domain/usecases/delete_category_usecase.dart';
import 'package:proyecto/Domain/usecases/edit_category_usecase.dart';
import 'package:proyecto/Domain/usecases/enroll_category_usecase.dart';
import 'package:proyecto/Domain/usecases/unenroll_category_usecase.dart';
import 'package:proyecto/Domain/usecases/create_evaluation_usecase.dart';
import 'package:proyecto/Domain/usecases/update_evaluation_usecase.dart';
import 'package:proyecto/Domain/usecases/get_evaluations_by_group_usecase.dart';
import 'package:proyecto/Domain/usecases/get_pending_evaluations_usecase.dart';
import 'package:proyecto/Domain/usecases/start_evaluation_session_usecase.dart';
import 'package:proyecto/presentation/providers/auth_provider.dart';
import 'package:proyecto/presentation/providers/course_provider.dart';
import 'package:proyecto/presentation/providers/category_provider.dart';
import 'package:proyecto/presentation/providers/role_provider.dart';
import 'package:proyecto/presentation/providers/evaluation_provider.dart';
import 'package:proyecto/presentation/screens/category_courses_screen.dart';
import 'package:proyecto/presentation/screens/sign_up.dart';
import 'package:proyecto/presentation/screens/course_detail_screen.dart';
import 'package:proyecto/presentation/screens/course_management_screen.dart';
import 'package:proyecto/Domain/Entities/course.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Loggy
  Loggy.initLoggy(
    logPrinter: const PrettyPrinter(),
    logOptions: const LogOptions(LogLevel.all, stackTraceLevel: LogLevel.error),
  );

  // Inicializar dependencias de autenticación
  AuthDependencies.init();

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
            getCoursesByCategoryUseCase: GetCoursesByCategoryUseCase(
              _courseRepo,
            ),
            courseRepository: _courseRepo,
          )..loadCourses(),
        ),
        ChangeNotifierProvider<CategoryProvider>(
          create: (_) => CategoryProvider(
            repository: _courseRepo,
            createCategoryUseCase: CreateCategoryUseCase(_courseRepo),
            deleteCategoryUseCase: DeleteCategoryUseCase(_courseRepo),
            editCategoryUseCase: EditCategoryUseCase(_courseRepo),
            enrollCategoryUseCase: EnrollCategoryUseCase(_courseRepo),
            unenrollCategoryUseCase: UnenrollCategoryUseCase(_courseRepo),
          ),
        ),
        ChangeNotifierProvider<RoleProvider>(
          create: (_) => RoleProvider()..initializeRole(),
        ),
        ChangeNotifierProvider<EvaluationProvider>(
          create: (_) => EvaluationProvider(
            createEvaluationUseCase: CreateEvaluationUseCase(_courseRepo),
            updateEvaluationUseCase: UpdateEvaluationUseCase(_courseRepo),
            getEvaluationsByGroupUseCase: GetEvaluationsByGroupUseCase(
              _courseRepo,
            ),
            getPendingEvaluationsUseCase: GetPendingEvaluationsUseCase(
              _courseRepo,
            ),
            startEvaluationSessionUseCase: StartEvaluationSessionUseCase(
              _courseRepo,
            ),
          ),
        ),
      ],
      child: GetMaterialApp(
        title: 'Clases App',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        initialRoute: '/',
        getPages: [
          // Auth routes
          ...AuthRoutes.routes,
          // Existing routes
          GetPage(
            name: '/',
            page: () => const AuthPage(), // Usar la nueva página de auth
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: '/home',
            page: () => const HomePage(),
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: '/perfil',
            page: () {
              final args = Get.arguments as String? ?? 'Usuario';
              return ProfileScreen(usuario: args);
            },
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: '/signup',
            page: () => const SignUpPage(),
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: '/course_detail',
            page: () {
              final args = Get.arguments as CourseEntity;
              return CourseDetailScreen(course: args);
            },
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: '/category_courses',
            page: () {
              final args = Get.arguments as String;
              return CategoryCoursesScreen(category: args);
            },
            transition: Transition.fadeIn,
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
                return const AuthPage();
              }
              return CourseManagementScreen(
                course: course,
                currentUser: currentUser,
              );
            },
            transition: Transition.fadeIn,
          ),
        ],
        // Middleware para verificar autenticación
        routingCallback: (routing) {
          final authController = Get.find<AuthController>();
          if (routing?.current != '/login' &&
              routing?.current != '/signup' &&
              routing?.current != '/' &&
              !authController.isLogged) {
            Get.offAllNamed('/');
          }
        },
      ),
    );
  }
}
