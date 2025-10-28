import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/presentation/providers/grades_provider.dart';
import 'package:proyecto/Domain/Entities/course.dart';

class GradesScreen extends StatefulWidget {
  final CourseEntity course;

  const GradesScreen({super.key, required this.course});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GradesProvider>().loadEvaluationsForCourse(widget.course.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calificaciones - ${widget.course.title}'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Consumer<GradesProvider>(
        builder: (context, gradesProvider, child) {
          if (gradesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (gradesProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar calificaciones',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    gradesProvider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => gradesProvider.loadEvaluationsForCourse(widget.course.id),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final gradesByCategory = gradesProvider.getGradesByCategory();

          if (gradesByCategory.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assessment, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay calificaciones disponibles',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Las calificaciones aparecerán cuando los estudiantes\ncompleten sus evaluaciones',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Selector de categoría
              Container(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar Categoría',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: gradesByCategory.keys.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ),
              
              // Lista de calificaciones
              Expanded(
                child: _selectedCategory != null
                    ? _buildGradesList(gradesByCategory[_selectedCategory]!)
                    : _buildCategorySelector(gradesByCategory.keys.toList()),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategorySelector(List<String> categories) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category, size: 64, color: Colors.blue[300]),
          const SizedBox(height: 16),
          const Text(
            'Selecciona una categoría para ver las calificaciones',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
          ...categories.map((category) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Text(category),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildGradesList(List<StudentGrade> grades) {
    if (grades.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assessment, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay calificaciones en esta categoría',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grades.length,
      itemBuilder: (context, index) {
        final grade = grades[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getGradeColor(grade.average),
              child: Text(
                grade.average.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              grade.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Promedio: ${grade.average.toStringAsFixed(2)}/5.0'),
                Text('Evaluado por: ${grade.evaluators.length} persona(s)'),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showStudentDetails(grade),
          ),
        );
      },
    );
  }

  Color _getGradeColor(double average) {
    if (average >= 4.0) return Colors.green;
    if (average >= 3.0) return Colors.orange;
    return Colors.red;
  }

  void _showStudentDetails(StudentGrade grade) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Header
              Text(
                'Detalles de ${grade.username}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Promedio: ${grade.average.toStringAsFixed(2)}/5.0',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _getGradeColor(grade.average),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Lista de evaluaciones
              const Text(
                'Evaluaciones recibidas:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: grade.evaluations.length,
                  itemBuilder: (context, index) {
                    final evaluation = grade.evaluations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Evaluado por: ${evaluation.evaluatorUsername}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  evaluation.isCompleted ? 'Completada' : 'Pendiente',
                                  style: TextStyle(
                                    color: evaluation.isCompleted ? Colors.green : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (evaluation.isCompleted) ...[
                              const SizedBox(height: 8),
                              _buildEvaluationDetails(evaluation),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEvaluationDetails(evaluation) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildRatingItem('Puntualidad', evaluation.punctuality),
            _buildRatingItem('Contribuciones', evaluation.contributions),
            _buildRatingItem('Compromiso', evaluation.commitment),
            _buildRatingItem('Actitud', evaluation.attitude),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                'Promedio: ${((evaluation.punctuality + evaluation.contributions + evaluation.commitment + evaluation.attitude) / 4).toStringAsFixed(1)}/5.0',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingItem(String label, int rating) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 16,
            );
          }),
        ),
        Text(
          '$rating/5',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

