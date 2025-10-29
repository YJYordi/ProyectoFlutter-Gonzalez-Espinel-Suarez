import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/Domain/Entities/category.dart';
import 'package:proyecto/presentation/providers/evaluation_provider.dart';

class GroupMembersModal extends StatefulWidget {
  final GroupEntity group;
  final String currentUsername;
  final VoidCallback? onLeaveGroup;

  const GroupMembersModal({
    Key? key,
    required this.group,
    required this.currentUsername,
    this.onLeaveGroup,
  }) : super(key: key);

  @override
  State<GroupMembersModal> createState() => _GroupMembersModalState();
}

class _GroupMembersModalState extends State<GroupMembersModal> {
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
    final isCurrentUserInGroup = widget.group.members.contains(widget.currentUsername);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    shape: const CircleBorder(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Grupo ${widget.group.groupNumber}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isCurrentUserInGroup && widget.onLeaveGroup != null)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onLeaveGroup!();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Salir'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Group info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.group.members.length}/${widget.group.maxMembers} miembros',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Members list
            const Text(
              'Miembros:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : widget.group.members.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay miembros en este grupo',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: widget.group.members.length,
                          itemBuilder: (context, index) {
                            final member = widget.group.members[index];
                            final average = _studentAverages[member] ?? 0.0;
                            final isCurrentUser = member == widget.currentUsername;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isCurrentUser ? Colors.blue[50] : Colors.white,
                                border: Border.all(
                                  color: isCurrentUser ? Colors.blue : Colors.grey[300]!,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: isCurrentUser 
                                            ? Colors.blue 
                                            : average > 0 
                                                ? _getScoreColor(average)
                                                : Colors.grey[400],
                                        child: Text(
                                          _getUserName(member)[0],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _getUserName(member),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                                                color: isCurrentUser ? Colors.blue[800] : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              average > 0 
                                                  ? 'Promedio: ${average.toStringAsFixed(1)}'
                                                  : 'Sin evaluaciones completadas',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: average > 0 ? _getScoreColor(average) : Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isCurrentUser)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            'Tú',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      if (average > 0)
                                        Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getScoreColor(average),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            average.toStringAsFixed(1),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
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