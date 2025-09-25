import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/courses/data/datasources/courses_remote_data_source.dart';
import 'features/courses/data/repositories/course_repository_impl.dart';
import 'features/courses/domain/usecases/get_courses_usecase.dart';
import 'features/courses/domain/usecases/create_course_usecase.dart';
import 'features/courses/domain/usecases/enroll_in_course_usecase.dart';
import 'features/courses/domain/usecases/get_course_enrollments_usecase.dart';
import 'features/courses/domain/usecases/delete_course_usecase.dart';
import 'features/courses/domain/usecases/unenroll_from_course_usecase.dart';
import 'features/courses/domain/usecases/get_courses_by_creator_usecase.dart';
import 'features/courses/domain/usecases/get_courses_by_student_usecase.dart';
import 'features/courses/domain/usecases/get_courses_by_category_usecase.dart';
import 'features/courses/presentation/providers/course_provider.dart';
import 'app_routes.dart';
import 'central.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar URLs de las APIs
  const String authApiUrl = 'https://roble.openlab.uninorte.edu.co/auth/proyectoflutter_c35bbd8fbe';
  const String coursesApiUrl = 'https://roble.openlab.uninorte.edu.co/database/proyectoflutter_c35bbd8fbe';

  // Crear datasources remotas
  final authRemoteDataSource = AuthRemoteDataSourceImpl(
    client: http.Client(),
    baseUrl: authApiUrl,
  );

  final coursesRemoteDataSource = CoursesRemoteDataSourceImpl(
    client: http.Client(),
    baseUrl: coursesApiUrl,
  );

  // Crear repositories
  final authRepo = AuthRepositoryImpl(authRemoteDataSource);
  final courseRepo = CourseRepositoryImpl(coursesRemoteDataSource);

  // Configurar GetX para Auth
  Get.put(
    AuthController(
      loginUseCase: LoginUseCase(authRepo),
      registerUseCase: RegisterUseCase(authRepo),
    ),
  );

  // Configurar Provider para Courses
  final courseProvider = CourseProvider(
    getCoursesUseCase: GetCoursesUseCase(courseRepo),
    createCourseUseCase: CreateCourseUseCase(courseRepo),
    enrollInCourseUseCase: EnrollInCourseUseCase(courseRepo),
    getCourseEnrollmentsUseCase: GetCourseEnrollmentsUseCase(courseRepo),
    deleteCourseUseCase: DeleteCourseUseCase(courseRepo),
    unenrollFromCourseUseCase: UnenrollFromCourseUseCase(courseRepo),
    getCoursesByCreatorUseCase: GetCoursesByCreatorUseCase(courseRepo),
    getCoursesByStudentUseCase: GetCoursesByStudentUseCase(courseRepo),
    getCoursesByCategoryUseCase: GetCoursesByCategoryUseCase(courseRepo),
    courseRepository: courseRepo,
  );

  // Cargar cursos iniciales
  await courseProvider.loadCourses();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: courseProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Clases App',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.login,
      getPages: AppRoutes.routes,
      home: const Central(),
    );
  }
}
