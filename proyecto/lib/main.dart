import 'package:flutter/material.dart';
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
      child: MaterialApp(
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
            final authProvider = Provider.of<AuthProvider>(
              context,
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
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Han sido         veces:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
