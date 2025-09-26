import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto/features/course_management/domain/entities/course.dart';
import 'package:proyecto/features/course_management/presentation/controllers/course_controller.dart';
import 'package:proyecto/shared/presentation/controllers/role_controller.dart';
import 'package:proyecto/features/course_management/presentation/screens/course_detail_screen.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final courseController = Get.find<CourseController>();
    final roleController = Get.find<RoleController>();

    return Obx(() {
      // Obtener cursos según el rol
      List<CourseEntity> filteredCourses;
      if (roleController.isProfessor) {
        // Profesor ve todos los cursos
        filteredCourses = courseController.courses;
      } else {
        // Estudiante ve solo cursos no inscritos
        final enrolledCourseIds = courseController.enrolledCourses
            .map((c) => c.id)
            .toSet();
        filteredCourses = courseController.courses
            .where((course) => !enrolledCourseIds.contains(course.id))
            .toList();
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  roleController.isProfessor
                      ? 'Todos los Cursos'
                      : 'Cursos Disponibles',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Indicador de rol
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: roleController.isProfessor
                        ? Colors.blue[50]
                        : Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: roleController.isProfessor
                          ? Colors.blue[200]!
                          : Colors.green[200]!,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        roleController.roleIcon,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        roleController.roleDisplayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: roleController.isProfessor
                              ? Colors.blue[700]
                              : Colors.green[700],
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
              roleController.isProfessor
                  ? '${filteredCourses.length} cursos en total'
                  : '${filteredCourses.length} cursos disponibles para inscribirse',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredCourses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            roleController.isProfessor
                                ? 'No hay cursos creados'
                                : 'No hay cursos disponibles',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            roleController.isProfessor
                                ? 'Crea tu primer curso para comenzar'
                                : 'Todos los cursos están llenos o ya estás inscrito',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(course.description),
                                const SizedBox(height: 4),
                                Text(
                                  'Creado por: ${course.creatorName}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Inscripciones: ${course.currentEnrollments}/${course.maxEnrollments}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Get.to(
                                  () => CourseDetailScreen(course: course),
                                );
                              },
                              child: Text(
                                roleController.isProfessor
                                    ? 'Gestionar'
                                    : 'Ver más',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }
}
