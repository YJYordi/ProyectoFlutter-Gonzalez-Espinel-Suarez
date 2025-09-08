import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/presentation/screens/course_creation.dart';
import 'package:proyecto/presentation/screens/course_detail_screen.dart';
import 'package:proyecto/presentation/providers/course_provider.dart';
import 'package:proyecto/presentation/providers/auth_provider.dart';

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
    final String usuario =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'Usuario';

    final courseProvider = context.watch<CourseProvider>();
    final cursos = courseProvider.courses;
    final createdCourses = courseProvider.createdCourses;
    final enrolledCourses = courseProvider.enrolledCourses;

    final List<Widget> _pages = [
      // INICIO
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saludo
              Row(
                children: [
                  CircleAvatar(child: Text(usuario[0].toUpperCase())),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, $usuario',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Estudiante & Profesora',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
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
          // Cursos disponibles
          const Text(
            'Cursos disponibles',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cursos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final curso = cursos[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        width: 240,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            Text(
                              'Por: ${curso.creatorName}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              curso.description,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Categorías
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: curso.categories.take(2).map<Widget>((category) {
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
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CourseDetailScreen(course: curso),
                                  ),
                                );
                              },
                              child: const Text('Ver curso'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Categorías',
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
      _buildExplorePage(),
      // CONTACTOS
      const Center(child: Text('Contactos', style: TextStyle(fontSize: 24))),
      // PENDIENTES
      const Center(child: Text('Pendientes', style: TextStyle(fontSize: 24))),
      // PERFIL
      const Center(child: Text('Perfil', style: TextStyle(fontSize: 24))),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 4) {
            // Navegar a la pantalla de perfil
            Navigator.pushNamed(context, '/perfil', arguments: usuario);
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
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Contactos'),
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
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseDetailScreen(course: course),
              ),
            ).then((_) => _loadUserCourses());
          },
          child: const Text('Ver más'),
        ),
      ),
    );
  }

  Widget _buildExplorePage() {
    final courseProvider = context.watch<CourseProvider>();
    final searchResults = courseProvider.searchResults;
    final searchQuery = courseProvider.searchQuery;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explorar Cursos',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar cursos...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => courseProvider.clearSearch(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => courseProvider.searchCourses(value),
          ),
          const SizedBox(height: 16),
          if (searchQuery.isNotEmpty)
            Text(
              'Resultados para "$searchQuery" (${searchResults.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: searchResults.isEmpty
                ? Center(
                    child: Text(
                      searchQuery.isEmpty
                          ? 'Escribe algo para buscar cursos'
                          : 'No se encontraron cursos',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final course = searchResults[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            course.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
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
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CourseDetailScreen(course: course),
                                ),
                              ).then((_) => _loadUserCourses());
                            },
                            child: const Text('Ver más'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
