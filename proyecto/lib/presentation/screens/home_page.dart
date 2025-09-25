// home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../providers/course_provider.dart';
import 'course_creation.dart';
import 'course_detail_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _profesorExpanded = false;
  bool _estudianteExpanded = false;

  late AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserCourses());
  }

  void _loadUserCourses() {
    final user = _authController.user.value;
    final courseProvider = context.read<CourseProvider>();
    if (user != null) {
      courseProvider.loadCreatedCourses(user.username);
      courseProvider.loadEnrolledCourses(user.username);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authController.user.value;
    final displayName = user?.name ?? 'Usuario';
    final courseProvider = context.watch<CourseProvider>();
    final cursos = courseProvider.courses;
    final createdCourses = courseProvider.createdCourses;
    final enrolledCourses = courseProvider.enrolledCourses;

    final pages = [
      _buildHomePage(displayName, cursos, createdCourses, enrolledCourses),
      _buildExplorePage(courseProvider),
      const Center(child: Text('Pendientes', style: TextStyle(fontSize: 24))),
      const Center(child: Text('Perfil', style: TextStyle(fontSize: 24))),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
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

  Widget _buildHomePage(
    String displayName,
    List cursos,
    List createdCourses,
    List enrolledCourses,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo
            Row(
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
                    const Text(
                      'Estudiante & Profesor',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Expansion panels
            ExpansionPanelList(
              expansionCallback: (i, isExpanded) => setState(() {
                if (i == 0) _profesorExpanded = !_profesorExpanded;
                if (i == 1) _estudianteExpanded = !_estudianteExpanded;
              }),
              children: [
                ExpansionPanel(
                  canTapOnHeader: true,
                  headerBuilder: (_, __) => ListTile(
                    title: Text('Profesor (${createdCourses.length} cursos)'),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        if (createdCourses.length < 3)
                          ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CourseCreationScreen(),
                              ),
                            ).then((_) => _loadUserCourses()),
                            icon: const Icon(Icons.add),
                            label: const Text('Crear curso'),
                          )
                        else
                          const Text(
                            'Has alcanzado el límite de 3 cursos',
                            style: TextStyle(color: Colors.red),
                          ),
                        ...createdCourses.map((c) => _buildCourseCard(c, true)),
                      ],
                    ),
                  ),
                  isExpanded: _profesorExpanded,
                ),
                ExpansionPanel(
                  canTapOnHeader: true,
                  headerBuilder: (_, __) => ListTile(
                    title: Text(
                      'Estudiante (${enrolledCourses.length} cursos)',
                    ),
                  ),
                  body: Column(
                    children: enrolledCourses
                        .map((c) => _buildCourseCard(c, false))
                        .toList(),
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
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: cursos.length,
                itemBuilder: (_, i) => _buildCourseCard(cursos[i], false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(course, bool isCreated) {
    return Card(
      child: ListTile(
        title: Text(course.title),
        subtitle: isCreated ? null : Text('Por: ${course.creatorName}'),
        trailing: ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseDetailScreen(course: course),
            ),
          ).then((_) => _loadUserCourses()),
          child: const Text('Ver más'),
        ),
      ),
    );
  }

  Widget _buildExplorePage(CourseProvider courseProvider) {
    final searchResults = courseProvider.searchResults;
    final searchQuery = courseProvider.searchQuery;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar cursos...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: courseProvider.clearSearch,
                    )
                  : null,
            ),
            onChanged: courseProvider.searchCourses,
          ),
          Expanded(
            child: searchQuery.isEmpty
                ? const Center(child: Text('Escribe algo para buscar cursos'))
                : searchResults.isEmpty
                ? const Center(child: Text('No se encontraron cursos'))
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (_, i) =>
                        _buildCourseCard(searchResults[i], false),
                  ),
          ),
        ],
      ),
    );
  }
}
