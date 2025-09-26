import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto/features/course_management/domain/entities/course.dart';
import 'package:proyecto/features/course_management/presentation/screens/course_creation.dart';
import 'package:proyecto/features/course_management/presentation/screens/course_detail_screen.dart';
import 'package:proyecto/shared/presentation/screens/explore_page.dart';
import 'package:proyecto/features/evaluation_system/presentation/screens/pending_evaluations_screen.dart';
import 'package:proyecto/features/evaluation_system/presentation/screens/professor_evaluations_screen.dart';
import 'package:proyecto/features/course_management/presentation/controllers/course_controller.dart';
import 'package:proyecto/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:proyecto/shared/presentation/controllers/role_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _profesorExpanded = false;
  bool _estudianteExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserCourses();
    });
  }

  void _loadUserCourses() {
    final authController = Get.find<AuthController>();
    final courseController = Get.find<CourseController>();

    if (authController.user != null) {
      courseController.loadCreatedCourses(authController.user!.username);
      courseController.loadEnrolledCourses(authController.user!.username);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final roleController = Get.find<RoleController>();
    final String displayName = authController.user?.name ?? 'Usuario';

    final courseController = Get.find<CourseController>();
    final cursos = courseController.courses;
    final createdCourses = courseController.createdCourses;
    final enrolledCourses = courseController.enrolledCourses;

    final List<Widget> pages = [
      // INICIO
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saludo
              Obx(() {
                return Row(
                  children: [
                    CircleAvatar(child: Text(displayName[0].toUpperCase())),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola, $displayName',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          roleController.isProfessor
                              ? 'Modo Profesor'
                              : 'Modo Estudiante',
                          style: TextStyle(
                            fontSize: 14,
                            color: roleController.isProfessor
                                ? Colors.blue[600]
                                : Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
              const SizedBox(height: 24),
              // Abanicos desplegables
              ExpansionPanelList(
                elevation: 2,
                expandedHeaderPadding: EdgeInsets.zero,
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    if (index == 0) {
                      _profesorExpanded = !_profesorExpanded;
                    } else {
                      _estudianteExpanded = !_estudianteExpanded;
                    }
                  });
                },
                children: [
                  ExpansionPanel(
                    canTapOnHeader: true,
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text(
                          'Profesor (${createdCourses.length} cursos)',
                        ),
                      );
                    },
                    body: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          if (createdCourses.length < 3)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Get.to(
                                    () => const CourseCreationScreen(),
                                  )?.then((_) => _loadUserCourses());
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Crear curso'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            )
                          else
                            const Text(
                              'Has alcanzado el límite de 3 cursos',
                              style: TextStyle(color: Colors.red),
                            ),
                          if (createdCourses.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Mis cursos:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...createdCourses.map(
                              (course) => _buildCourseCard(course, true),
                            ),
                          ],
                        ],
                      ),
                    ),
                    isExpanded: _profesorExpanded,
                  ),
                  ExpansionPanel(
                    canTapOnHeader: true,
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text(
                          'Estudiante (${enrolledCourses.length} cursos)',
                        ),
                      );
                    },
                    body: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8,
                      ),
                      child: enrolledCourses.isEmpty
                          ? const Text(
                              'No estás inscrito en ningún curso.',
                              style: TextStyle(color: Colors.grey),
                            )
                          : Column(
                              children: [
                                const Text(
                                  'Mis inscripciones:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ...enrolledCourses.map(
                                  (course) => _buildCourseCard(course, false),
                                ),
                              ],
                            ),
                    ),
                    isExpanded: _estudianteExpanded,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Cursos disponibles - Cambia según el rol
              Obx(() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roleController.isProfessor
                          ? 'Todos los cursos'
                          : 'Cursos disponibles',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }),
              Obx(() {
                // Filtrar cursos según el rol
                List<CourseEntity> filteredCourses;
                if (roleController.isProfessor) {
                  // Profesor ve todos los cursos
                  filteredCourses = cursos;
                } else {
                  // Estudiante ve solo cursos no inscritos
                  final enrolledCourseIds = enrolledCourses
                      .map((c) => c.id)
                      .toSet();
                  filteredCourses = cursos
                      .where((course) => !enrolledCourseIds.contains(course.id))
                      .toList();
                }

                return SizedBox(
                  height: 200,
                  child: filteredCourses.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.school, size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No hay cursos disponibles',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: filteredCourses.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final curso = filteredCourses[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                width: 240,
                                height: 200,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Título del curso
                                    Text(
                                      curso.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),

                                    // Creador
                                    Text(
                                      'Por: ${curso.creatorName}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),

                                    // Tags
                                    Expanded(
                                      child: Wrap(
                                        spacing: 4,
                                        runSpacing: 4,
                                        children: curso.categories
                                            .take(3)
                                            .map<Widget>((category) {
                                              return Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[100],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  category,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              );
                                            })
                                            .toList(),
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Botón
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Get.to(
                                            () => CourseDetailScreen(
                                              course: curso,
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          textStyle: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          roleController.isProfessor
                                              ? 'Gestionar'
                                              : 'Ver más',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                );
              }),
              const SizedBox(height: 32),
              const Text(
                'Tags',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.code),
                    title: const Text('Desarrollo Frontend'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Get.toNamed(
                      '/category_courses',
                      arguments: 'Desarrollo Frontend',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.storage),
                    title: const Text('Desarrollo Backend'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Get.toNamed(
                      '/category_courses',
                      arguments: 'Desarrollo Backend',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.design_services),
                    title: const Text('UX/UI'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () =>
                        Get.toNamed('/category_courses', arguments: 'UX/UI'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.web),
                    title: const Text('Diseño Web'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Get.toNamed(
                      '/category_courses',
                      arguments: 'Diseño Web',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.developer_mode),
                    title: const Text('Desarrollo Web'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Get.toNamed(
                      '/category_courses',
                      arguments: 'Desarrollo Web',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.all_inclusive),
                    title: const Text('Desarrollo Full Stack'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Get.toNamed(
                      '/category_courses',
                      arguments: 'Desarrollo Full Stack',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Docker'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () =>
                        Get.toNamed('/category_courses', arguments: 'Docker'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.storage),
                    title: const Text('Bases de Datos'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Get.toNamed(
                      '/category_courses',
                      arguments: 'Bases de Datos',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone_android),
                    title: const Text('Flutter Básico'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Get.toNamed(
                      '/category_courses',
                      arguments: 'Flutter Básico',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone_android),
                    title: const Text('Flutter Intermedio'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Get.toNamed(
                      '/category_courses',
                      arguments: 'Flutter Intermedio',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone_android),
                    title: const Text('Flutter Avanzado'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Get.toNamed(
                      '/category_courses',
                      arguments: 'Flutter Avanzado',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // EXPLORAR
      const ExplorePage(),
      // PENDIENTES
      const Center(child: Text('Pendientes', style: TextStyle(fontSize: 24))),
      // PERFIL
      const Center(child: Text('Perfil', style: TextStyle(fontSize: 24))),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          // Indicador de rol con opción de cambio
          PopupMenuButton<String>(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  roleController.roleIcon,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  roleController.roleDisplayName,
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
            onSelected: (String value) {
              if (value == 'switch') {
                roleController.switchRole();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'switch',
                child: Row(
                  children: [
                    Text(roleController.isProfessor ? '👨‍🎓' : '👨‍🏫'),
                    const SizedBox(width: 8),
                    Text(
                      roleController.isProfessor
                          ? 'Ver como Estudiante'
                          : 'Ver como Profesor',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 2) {
            // Navegar a la pantalla de evaluaciones según el rol
            if (roleController.isProfessor) {
              // Para profesores: mostrar todas las evaluaciones de sus cursos
              Get.to(
                () => ProfessorEvaluationsScreen(
                  course: createdCourses.isNotEmpty
                      ? createdCourses.first
                      : CourseEntity(
                          id: 'mock',
                          title: 'Mis Cursos',
                          description: 'Evaluaciones de todos los cursos',
                          creatorUsername: authController.user?.username ?? '',
                          creatorName: authController.user?.name ?? '',
                          categories: [],
                          maxEnrollments: 0,
                          currentEnrollments: 0,
                          createdAt: DateTime.now(),
                          schedule: '',
                          location: '',
                          price: 0.0,
                          isRandomAssignment: false,
                        ),
                  professorUsername: authController.user?.username ?? '',
                ),
              );
            } else {
              // Para estudiantes: mostrar evaluaciones pendientes
              Get.to(
                () => PendingEvaluationsScreen(
                  username: authController.user?.username ?? '',
                ),
              );
            }
          } else if (index == 3) {
            // Navegar a la pantalla de perfil
            Get.toNamed('/perfil', arguments: displayName);
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Explorar',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assessment),
            label: roleController.isProfessor ? 'Evaluaciones' : 'Pendientes',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(course, bool isCreated) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          course.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: isCreated
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Por: ${course.creatorName}'),
                  Text(
                    course.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: course.categories.take(2).map<Widget>((category) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
        trailing: Obx(() {
          final roleController = Get.find<RoleController>();
          return ElevatedButton(
            onPressed: () {
              Get.to(
                () => CourseDetailScreen(course: course),
              )?.then((_) => _loadUserCourses());
            },
            child: Text(roleController.isProfessor ? 'Gestionar' : 'Ver más'),
          );
        }),
      ),
    );
  }
}
