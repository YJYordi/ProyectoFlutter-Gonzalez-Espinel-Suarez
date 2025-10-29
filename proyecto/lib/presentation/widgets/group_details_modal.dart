import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/Domain/Entities/category.dart';
import 'package:proyecto/presentation/providers/evaluation_provider.dart';

class GroupDetailsModal extends StatefulWidget {
  final GroupEntity group;
  final String categoryId;

  const GroupDetailsModal({
    super.key,
    required this.group,
    required this.categoryId,
  });

  @override
  State<GroupDetailsModal> createState() => _GroupDetailsModalState();
}

class _GroupDetailsModalState extends State<GroupDetailsModal> {
  Map<String, double> _studentAverages = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudentAverages();
    });
  }

  Future<void> _loadStudentAverages() async {
    final evaluationProvider = Provider.of<EvaluationProvider>(context, listen: false);
    
    // Obtener todas las evaluaciones completadas
    await evaluationProvider.loadCompletedEvaluations(username: '');
    
    // Filtrar evaluaciones del grupo actual
    final groupEvaluations = evaluationProvider.completedEvaluations
        .where((eval) => eval.groupId == widget.group.id)
        .toList();
    
    // Calcular promedios por estudiante
    final Map<String, List<double>> studentScores = {};
    
    for (final evaluation in groupEvaluations) {
      studentScores.putIfAbsent(evaluation.evaluatedUsername, () => []).add(evaluation.averageScore);
    }
    
    final Map<String, double> studentAverages = {};
    studentScores.forEach((student, scores) {
      studentAverages[student] = scores.reduce((a, b) => a + b) / scores.length;
    });
    
    if (mounted) {
      setState(() {
        _studentAverages = studentAverages;
        _isLoading = false;
      });
    }
  }

  String _getUserName(String username) {
    return username.split('@')[0].replaceAll('.', ' ').toUpperCase();
  }

  Color _getScoreColor(double score) {
    if (score >= 4.0) return Colors.green;
    if (score >= 3.0) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Grupo ${widget.group.groupNumber}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Información del grupo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.group, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.group.members.length}/${widget.group.maxMembers} miembros',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Lista de estudiantes con promedios
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : widget.group.members.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay miembros en este grupo',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: widget.group.members.length,
                          itemBuilder: (context, index) {
                            final student = widget.group.members[index];
                            final average = _studentAverages[student] ?? 0.0;
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getScoreColor(average),
                                  child: Text(
                                    _getUserName(student)[0],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  _getUserName(student),
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(
                                  average > 0 
                                      ? 'Promedio: ${average.toStringAsFixed(1)}'
                                      : 'Sin evaluaciones completadas',
                                  style: TextStyle(
                                    color: average > 0 ? _getScoreColor(average) : Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: average > 0
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getScoreColor(average),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          average.toStringAsFixed(1),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        'N/A',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
