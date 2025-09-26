import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'features/authentication/presentation/screens/log_in.dart';
import 'shared/presentation/screens/home_page.dart';
import 'features/profile_management/presentation/screens/profile_screen.dart';
import 'shared/data/datasources/persistent_data_source.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/data/datasources/remote_auth_data_source.dart';
import 'features/course_management/data/repositories/course_repository_impl.dart';
import 'features/authentication/presentation/controllers/auth_controller.dart';
import 'features/course_management/presentation/controllers/course_controller.dart';
import 'features/category_management/presentation/controllers/category_controller.dart';
import 'features/evaluation_system/presentation/controllers/evaluation_controller.dart';
import 'shared/presentation/controllers/role_controller.dart';
import 'features/authentication/domain/usecases/login_usecase.dart';
import 'features/authentication/domain/usecases/register_usecase.dart';
import 'features/authentication/domain/usecases/login_with_api_usecase.dart';
import 'features/authentication/domain/usecases/register_with_api_usecase.dart';
import 'features/authentication/domain/usecases/logout_with_api_usecase.dart';
import 'features/authentication/domain/usecases/refresh_token_usecase.dart';
import 'features/authentication/domain/usecases/validate_token_usecase.dart';
import 'features/course_management/domain/usecases/get_courses_usecase.dart';
import 'features/course_management/domain/usecases/create_course_usecase.dart';
import 'features/course_management/domain/usecases/enroll_in_course_usecase.dart';
import 'features/course_management/domain/usecases/get_course_enrollments_usecase.dart';
import 'features/course_management/domain/usecases/delete_course_usecase.dart';
import 'features/course_management/domain/usecases/unenroll_from_course_usecase.dart';
import 'features/course_management/domain/usecases/get_courses_by_creator_usecase.dart';
import 'features/course_management/domain/usecases/get_courses_by_student_usecase.dart';
import 'features/course_management/domain/usecases/get_courses_by_category_usecase.dart';
import 'features/category_management/domain/usecases/create_category_usecase.dart';
import 'features/category_management/domain/usecases/delete_category_usecase.dart';
import 'features/category_management/domain/usecases/edit_category_usecase.dart';
import 'features/category_management/domain/usecases/enroll_category_usecase.dart';
import 'features/category_management/domain/usecases/unenroll_category_usecase.dart';
import 'features/evaluation_system/domain/usecases/create_evaluation_usecase.dart';
import 'features/evaluation_system/domain/usecases/update_evaluation_usecase.dart';
import 'features/evaluation_system/domain/usecases/get_evaluations_by_group_usecase.dart';
import 'features/evaluation_system/domain/usecases/get_pending_evaluations_usecase.dart';
import 'features/evaluation_system/domain/usecases/start_evaluation_session_usecase.dart';
import 'features/category_management/presentation/screens/category_courses_screen.dart';
import 'features/authentication/presentation/screens/sign_up.dart';
import 'features/course_management/presentation/screens/course_detail_screen.dart';
import 'features/course_management/presentation/screens/course_management_screen.dart';
import 'features/course_management/domain/entities/course.dart';

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
  late final RemoteAuthDataSource _remoteAuthDataSource;
  late final AuthRepositoryImpl _authRepo;
  late final CourseRepositoryImpl _courseRepo;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _dataSource = PersistentDataSource();
    _remoteAuthDataSource = RemoteAuthDataSource();
    _authRepo = AuthRepositoryImpl(_dataSource, _remoteAuthDataSource);
    _courseRepo = CourseRepositoryImpl(_dataSource);
    debugPrint('Repositories initialized successfully');
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _dataSource.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
      if (mounted) {
        setState(() {
          _isInitialized =
              true; // Permitir que la app funcione incluso con errores
        });
      }
    }
  }

  void _initializeControllers() {
    debugPrint('Initializing GetX controllers');

    // AuthController
    Get.put(
      AuthController(
        loginUseCase: LoginUseCase(_authRepo),
        registerUseCase: RegisterUseCase(_authRepo),
        loginWithAPIUseCase: LoginWithAPIUseCase(_authRepo),
        registerWithAPIUseCase: RegisterWithAPIUseCase(_authRepo),
        logoutWithAPIUseCase: LogoutWithAPIUseCase(_authRepo),
        refreshTokenUseCase: RefreshTokenUseCase(_authRepo),
        validateTokenUseCase: ValidateTokenUseCase(_authRepo),
      ),
    );

    // CourseController
    Get.put(
      CourseController(
        getCoursesUseCase: GetCoursesUseCase(_courseRepo),
        createCourseUseCase: CreateCourseUseCase(_courseRepo),
        enrollInCourseUseCase: EnrollInCourseUseCase(_courseRepo),
        getCourseEnrollmentsUseCase: GetCourseEnrollmentsUseCase(_courseRepo),
        deleteCourseUseCase: DeleteCourseUseCase(_courseRepo),
        unenrollFromCourseUseCase: UnenrollFromCourseUseCase(_courseRepo),
        getCoursesByCreatorUseCase: GetCoursesByCreatorUseCase(_courseRepo),
        getCoursesByStudentUseCase: GetCoursesByStudentUseCase(_courseRepo),
        getCoursesByCategoryUseCase: GetCoursesByCategoryUseCase(_courseRepo),
        courseRepository: _courseRepo,
      ),
    );

    // CategoryController
    Get.put(
      CategoryController(
        repository: _courseRepo,
        createCategoryUseCase: CreateCategoryUseCase(_courseRepo),
        deleteCategoryUseCase: DeleteCategoryUseCase(_courseRepo),
        editCategoryUseCase: EditCategoryUseCase(_courseRepo),
        enrollCategoryUseCase: EnrollCategoryUseCase(_courseRepo),
        unenrollCategoryUseCase: UnenrollCategoryUseCase(_courseRepo),
      ),
    );

    // RoleController
    Get.put(RoleController());

    // EvaluationController
    Get.put(
      EvaluationController(
        createEvaluationUseCase: CreateEvaluationUseCase(_courseRepo),
        updateEvaluationUseCase: UpdateEvaluationUseCase(_courseRepo),
        getEvaluationsByGroupUseCase: GetEvaluationsByGroupUseCase(_courseRepo),
        getPendingEvaluationsUseCase: GetPendingEvaluationsUseCase(_courseRepo),
        startEvaluationSessionUseCase: StartEvaluationSessionUseCase(
          _courseRepo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  'Inicializando aplicación...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Inicializar controladores de GetX
    _initializeControllers();

    return GetMaterialApp(
      title: 'Clases App',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/perfil': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as String? ??
              'Usuario';
          return ProfileScreen(usuario: args);
        },
        '/signup': (context) => const SignUpPage(),
        '/course_detail': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as CourseEntity;
          return CourseDetailScreen(course: args);
        },
        '/category_courses': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String;
          return CategoryCoursesScreen(category: args);
        },
        '/course_management': (context) {
          final course =
              ModalRoute.of(context)?.settings.arguments as CourseEntity;
          final authController = Get.find<AuthController>();
          final currentUser = authController.user;
          if (currentUser == null) {
            return const LoginPage();
          }
          return CourseManagementScreen(
            course: course,
            currentUser: currentUser,
          );
        },
      },
    );
  }
}
