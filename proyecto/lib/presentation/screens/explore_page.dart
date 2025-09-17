import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/presentation/providers/course_provider.dart';
import 'package:proyecto/presentation/providers/role_provider.dart';
import 'package:proyecto/presentation/screens/course_detail_screen.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final roleProvider = context.watch<RoleProvider>();
    
    // Obtener cursos según el rol
    List<CourseEntity> filteredCourses;
    if (roleProvider.isProfessor) {
      // Profesor ve todos los cursos
      filteredCourses = courseProvider.courses;
    } else {
      // Estudiante ve solo cursos no inscritos
      final enrolledCourseIds = courseProvider.enrolledCourses.map((c) => c.id).toSet();
      filteredCourses = courseProvider.courses.where((course) => !enrolledCourseIds.contains(course.id)).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                roleProvider.isProfessor ? 'Todos los Cursos' : 'Cursos Disponibles',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // Indicador de rol
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: roleProvider.isProfessor ? Colors.blue[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: roleProvider.isProfessor ? Colors.blue[200]! : Colors.green[200]!,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      roleProvider.roleIcon,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      roleProvider.roleDisplayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: roleProvider.isProfessor ? Colors.blue[700] : Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            roleProvider.isProfessor 
                ? '${filteredCourses.length} cursos en total'
                : '${filteredCourses.length} cursos disponibles para inscribirse',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredCourses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          roleProvider.isProfessor ? 'No hay cursos creados' : 'No hay cursos disponibles',
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          roleProvider.isProfessor 
                              ? 'Crea tu primer curso para comenzar'
                              : 'Todos los cursos están llenos o ya estás inscrito',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredCourses.length,
                    itemBuilder: (context, index) {
                      final course = filteredCourses[index];
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
                              Text(course.description),
                              const SizedBox(height: 4),
                              Text(
                                'Creado por: ${course.creatorName}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Inscripciones: ${course.currentEnrollments}/${course.maxEnrollments}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                              );
                            },
                            child: Text(roleProvider.isProfessor ? 'Gestionar' : 'Ver más'),
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
