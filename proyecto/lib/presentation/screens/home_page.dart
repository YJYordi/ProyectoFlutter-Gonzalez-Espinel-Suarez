import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/presentation/screens/course_creation.dart';
import 'package:proyecto/presentation/screens/course_detail_screen.dart';
import 'package:proyecto/presentation/screens/explore_page.dart';
import 'package:proyecto/presentation/providers/course_provider.dart';
import 'package:proyecto/presentation/providers/auth_provider.dart';
import 'package:proyecto/presentation/providers/role_provider.dart';

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
    final authProvider = context.read<AuthProvider>();
    final courseProvider = context.read<CourseProvider>();
    
    if (authProvider.user != null) {
      courseProvider.loadCreatedCourses(authProvider.user!.username);
      courseProvider.loadEnrolledCourses(authProvider.user!.username);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final roleProvider = context.watch<RoleProvider>();
    final String displayName = authProvider.user?.name ?? 'Usuario';

    final courseProvider = context.watch<CourseProvider>();
    final cursos = courseProvider.courses;
    final createdCourses = courseProvider.createdCourses;
    final enrolledCourses = courseProvider.enrolledCourses;

    final List<Widget> pages = [
      // INICIO
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saludo
              Consumer<RoleProvider>(
                builder: (context, roleProvider, child) {
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
                            roleProvider.isProfessor ? 'Modo Profesor' : 'Modo Estudiante',
                            style: TextStyle(
                              fontSize: 14, 
                              color: roleProvider.isProfessor ? Colors.blue[600] : Colors.green[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
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
                        title: Text('Profesor (${createdCourses.length} cursos)'),
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CourseCreationScreen()),
                                  ).then((_) => _loadUserCourses());
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
                            ...createdCourses.map((course) => _buildCourseCard(course, true)),
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
                        title: Text('Estudiante (${enrolledCourses.length} cursos)'),
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
                                ...enrolledCourses.map((course) => _buildCourseCard(course, false)),
                              ],
                            ),
                    ),
                    isExpanded: _estudianteExpanded,
                  ),
                ],
              ),
              const SizedBox(height: 24),
          // Cursos disponibles - Cambia según el rol
          Consumer<RoleProvider>(
            builder: (context, roleProvider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roleProvider.isProfessor ? 'Todos los cursos' : 'Cursos disponibles',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
          Consumer<RoleProvider>(
            builder: (context, roleProvider, child) {
              // Filtrar cursos según el rol
              List<CourseEntity> filteredCourses;
              if (roleProvider.isProfessor) {
                // Profesor ve todos los cursos
                filteredCourses = cursos;
              } else {
                // Estudiante ve solo cursos no inscritos
                final enrolledCourseIds = enrolledCourses.map((c) => c.id).toSet();
                filteredCourses = cursos.where((course) => !enrolledCourseIds.contains(course.id)).toList();
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
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: filteredCourses.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
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
                                children: curso.categories.take(3).map<Widget>((category) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(12),
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
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Botón
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CourseDetailScreen(course: curso),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(roleProvider.isProfessor ? 'Gestionar' : 'Ver más'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
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
                    onTap: () => Navigator.pushNamed(context, '/category_courses', arguments: 'Desarrollo Frontend'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.storage),
                    title: const Text('Desarrollo Backend'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.pushNamed(context, '/category_courses', arguments: 'Desarrollo Backend'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.design_services),
                    title: const Text('UX/UI'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.pushNamed(context, '/category_courses', arguments: 'UX/UI'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.web),
                    title: const Text('Diseño Web'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.pushNamed(context, '/category_courses', arguments: 'Diseño Web'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.developer_mode),
                    title: const Text('Desarrollo Web'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.pushNamed(context, '/category_courses', arguments: 'Desarrollo Web'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.all_inclusive),
                    title: const Text('Desarrollo Full Stack'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.pushNamed(context, '/category_courses', arguments: 'Desarrollo Full Stack'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Docker'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.pushNamed(context, '/category_courses', arguments: 'Docker'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.storage),
                    title: const Text('Bases de Datos'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.pushNamed(context, '/category_courses', arguments: 'Bases de Datos'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone_android),
                    title: const Text('Flutter Básico'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.pushNamed(context, '/category_courses', arguments: 'Flutter Básico'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone_android),
                    title: const Text('Flutter Intermedio'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.pushNamed(context, '/category_courses', arguments: 'Flutter Intermedio'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone_android),
                    title: const Text('Flutter Avanzado'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.pushNamed(context, '/category_courses', arguments: 'Flutter Avanzado'),
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
                  roleProvider.roleIcon,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  roleProvider.roleDisplayName,
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
            onSelected: (String value) {
              if (value == 'switch') {
                roleProvider.switchRole();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'switch',
                child: Row(
                  children: [
                    Text(roleProvider.isProfessor ? '👨‍🎓' : '👨‍🏫'),
                    const SizedBox(width: 8),
                    Text(roleProvider.isProfessor ? 'Ver como Estudiante' : 'Ver como Profesor'),
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
          if (index == 3) {
            // Navegar a la pantalla de perfil
            Navigator.pushNamed(context, '/perfil', arguments: displayName);
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorar'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Pendientes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
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
        subtitle: isCreated ? null : Column(
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(fontSize: 10, color: Colors.blue),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        trailing: Consumer<RoleProvider>(
          builder: (context, roleProvider, child) {
            return ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseDetailScreen(course: course),
                  ),
                ).then((_) => _loadUserCourses());
              },
              child: Text(roleProvider.isProfessor ? 'Gestionar' : 'Ver más'),
            );
          },
        ),
      ),
    );
  }

}
