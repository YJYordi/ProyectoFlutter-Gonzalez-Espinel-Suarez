import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/Entities/course_enrollment.dart';
import 'package:proyecto/presentation/providers/auth_provider.dart';
import 'package:proyecto/presentation/providers/course_provider.dart';
import 'package:proyecto/presentation/screens/course_management_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseEntity course;
  
  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  List<CourseEnrollment> _enrollments = [];
  bool _isEnrolled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourseDetails();
  }

  Future<void> _loadCourseDetails() async {
    final courseProvider = context.read<CourseProvider>();
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.user != null) {
      final enrollments = await courseProvider.getCourseEnrollments(widget.course.id);
      final isEnrolled = await courseProvider.isUserEnrolledInCourse(
        widget.course.id, 
        authProvider.user!.username,
      );
      
      setState(() {
        _enrollments = enrollments;
        _isEnrolled = isEnrolled;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _enrollInCourse() async {
    final authProvider = context.read<AuthProvider>();
    final courseProvider = context.read<CourseProvider>();
    
    if (authProvider.user != null) {
      try {
        await courseProvider.enrollInCourse(
          courseId: widget.course.id,
          username: authProvider.user!.username,
          userName: authProvider.user!.name,
        );
        await _loadCourseDetails();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }


  Future<void> _deleteCourse() async {
    final authProvider = context.read<AuthProvider>();
    final courseProvider = context.read<CourseProvider>();
    
    if (authProvider.user != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Eliminar curso'),
          content: const Text('¿Estás seguro de que quieres eliminar este curso? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        try {
          await courseProvider.deleteCourse(
            widget.course.id,
            authProvider.user!.username,
          );
          if (mounted) {
            Navigator.pop(context);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Botón de gestión - solo para el creador del curso
          if (authProvider.user?.username == widget.course.creatorUsername)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CourseManagementScreen(
                      course: widget.course,
                      currentUser: context.read<AuthProvider>().user!,
                    ),
                  ),
                );
              },
              child: const Text('Gestionar'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del curso
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.course.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Creado por: ${widget.course.creatorName} (@${widget.course.creatorUsername})',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Descripción:',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.course.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          // Tags
                          const Text(
                            'Tags:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.course.categories.map((category) {
                              return Chip(
                                label: Text(category),
                                backgroundColor: Colors.blue[100],
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          // Información de inscripciones
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Inscripciones: ${_enrollments.length}/${widget.course.maxEnrollments}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Creado: ${_formatDate(widget.course.createdAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Botones de acción
                  Row(
                    children: [
                      if (!_isEnrolled && _enrollments.length < widget.course.maxEnrollments)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _enrollInCourse,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Inscribirse'),
                          ),
                        )
                      else if (_isEnrolled)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Navegar a la vista del curso
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CourseManagementScreen(
                                    course: widget.course,
                                    currentUser: context.read<AuthProvider>().user!,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Empezar'),
                          ),
                        )
                      else
                        Expanded(
                          child: ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Curso lleno'),
                          ),
                        ),
                    ],
                  ),
                  
                  // Botón de eliminar (solo para el creador)
                  if (authProvider.user?.username == widget.course.creatorUsername) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _deleteCourse,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        ),
                        child: const Icon(Icons.delete),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  
                  // Lista de usuarios inscritos
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Usuarios Inscritos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_enrollments.isEmpty)
                            const Text(
                              'No hay usuarios inscritos aún.',
                              style: TextStyle(color: Colors.grey),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _enrollments.length,
                              itemBuilder: (context, index) {
                                final enrollment = _enrollments[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text(enrollment.userName[0].toUpperCase()),
                                  ),
                                  title: Text(enrollment.userName),
                                  subtitle: Text('@${enrollment.username}'),
                                  trailing: Text(
                                    _formatDate(enrollment.enrolledAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
}
