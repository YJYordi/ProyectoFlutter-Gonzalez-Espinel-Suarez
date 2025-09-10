import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/Entities/user.dart';
import 'package:proyecto/presentation/providers/course_provider.dart';

class CourseManagementScreen extends StatelessWidget {
  final CourseEntity course;
  final UserEntity currentUser;

  const CourseManagementScreen({
    Key? key,
    required this.course,
    required this.currentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    
    // Calcular el tamaño efectivo de los grupos según el modo de asignación
    final effectiveGroupSize = course.isRandomAssignment
        ? (course.maxEnrollments / course.categories.length).ceil()
        : course.groupSize;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Curso'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre y descripción del curso
            Text(course.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(course.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            // Cuadro informativo sobre modo de asignación
            Card(
              color: const Color(0xFF424242), // Gris oscuro como en la imagen
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  course.isRandomAssignment
                      ? "Los grupos serán asignados de forma aleatoria por el sistema. "
                          "Número de integrantes por grupo: $effectiveGroupSize"
                      : "Los usuarios pueden auto inscribirse a los grupos de las categorías. "
                          "Número de integrantes por grupo: $effectiveGroupSize",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Gestión de grupos por categoría
            ...course.categories.map((category) {
              final group = courseProvider.getGroupForCategory(course.id, category);
              final isMember = group?.members.contains(currentUser.username) ?? false;
              final isAnyGroupJoined = courseProvider.isAnyGroupJoined(course.id, currentUser.username);

              return Card(
                color: const Color(0xFF424242), // Gris oscuro como en la imagen
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            "${group?.members.length ?? 0}/$effectiveGroupSize",
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const Spacer(),
                          if (!isAnyGroupJoined)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white, // Fondo blanco como en la imagen
                                foregroundColor: Colors.black, // Texto negro
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => courseProvider.joinGroup(course.id, category, currentUser.username),
                              child: const Text('Unirse'),
                            ),
                          if (isMember) ...[
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red, // Botón rojo para salir
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => courseProvider.leaveGroup(course.id, category, currentUser.username),
                              child: const Text('Salir'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => courseProvider.showEvaluations(context, course.id, category),
                              child: const Text('Evaluar'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}