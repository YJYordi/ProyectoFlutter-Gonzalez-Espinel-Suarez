import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/Domain/Entities/category.dart';
import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/Entities/evaluation.dart';
import 'package:proyecto/presentation/providers/evaluation_provider.dart';
import 'package:proyecto/presentation/widgets/evaluation_form_widget.dart';

class EvaluationScreen extends StatefulWidget {
  final CourseEntity course;
  final CategoryEntity category;
  final GroupEntity group;
  final String evaluatorUsername;

  const EvaluationScreen({
    super.key,
    required this.course,
    required this.category,
    required this.group,
    required this.evaluatorUsername,
  });

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  String? _selectedUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvaluations();
  }

  Future<void> _loadEvaluations() async {
    final evaluationProvider = Provider.of<EvaluationProvider>(context, listen: false);
    
    await evaluationProvider.loadEvaluationsByGroup(
      courseId: widget.course.id,
      categoryId: widget.category.id,
      groupId: widget.group.id,
      evaluatorUsername: widget.evaluatorUsername,
    );

    setState(() {
      _isLoading = false;
    });
  }

  List<String> get _availableUsers {
    return widget.group.members.where((member) => member != widget.evaluatorUsername).toList();
  }

  String _getUserName(String username) {
    // En un sistema real, esto vendría de una base de datos de usuarios
    // Por ahora, usamos el username como nombre
    return username.split('@')[0].replaceAll('.', ' ').toUpperCase();
  }


  Widget _buildUserCard(String username, bool isCompleted) {
    final userName = _getUserName(username);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCompleted ? Colors.green[100] : Colors.blue[100],
          child: Icon(
            isCompleted ? Icons.check : Icons.person,
            color: isCompleted ? Colors.green : Colors.blue,
          ),
        ),
        title: Text(
          userName,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isCompleted ? Colors.green[700] : Colors.black87,
          ),
        ),
        subtitle: Text(
          username,
          style: TextStyle(
            color: isCompleted ? Colors.green[600] : Colors.grey[600],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCompleted)
              const Icon(Icons.check_circle, color: Colors.green)
            else
              const Icon(Icons.radio_button_unchecked, color: Colors.grey),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: () {
          setState(() {
            _selectedUser = username;
          });
        },
      ),
    );
  }

  Widget _buildEvaluationForm() {
    if (_selectedUser == null) return const SizedBox.shrink();

    final evaluationProvider = Provider.of<EvaluationProvider>(context, listen: false);
    EvaluationEntity? existingEvaluation;
    try {
      existingEvaluation = evaluationProvider.evaluations.firstWhere(
        (e) => e.evaluatedUsername == _selectedUser,
      );
    } catch (e) {
      existingEvaluation = null;
    }

    return EvaluationFormWidget(
      courseId: widget.course.id,
      categoryId: widget.category.id,
      groupId: widget.group.id,
      evaluatorUsername: widget.evaluatorUsername,
      evaluatedUsername: _selectedUser!,
      evaluatedUserName: _getUserName(_selectedUser!),
      existingEvaluation: existingEvaluation,
      onSaved: () {
        setState(() {
          _selectedUser = null;
        });
        _loadEvaluations();
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Consumer<EvaluationProvider>(
      builder: (context, evaluationProvider, child) {
        final totalEvaluations = _availableUsers.length;
        final completedEvaluations = _availableUsers.where((user) => 
          evaluationProvider.isEvaluationComplete(user)).length;
        final progress = totalEvaluations > 0 ? completedEvaluations / totalEvaluations : 0.0;

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progreso de Evaluación',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  Text(
                    '$completedEvaluations / $totalEvaluations',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.blue[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toInt()}% completado',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeRemaining() {
    if (widget.category.evaluationEndDate == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final endDate = widget.category.evaluationEndDate!;
    final isOverdue = now.isAfter(endDate);
    final daysRemaining = endDate.difference(now).inDays;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isOverdue ? Colors.red[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isOverdue ? Colors.red[200]! : Colors.orange[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOverdue ? Icons.warning : Icons.access_time,
            color: isOverdue ? Colors.red[700] : Colors.orange[700],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isOverdue
                  ? 'Período de evaluación vencido'
                  : 'Días restantes: $daysRemaining',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isOverdue ? Colors.red[700] : Colors.orange[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluación de Grupo'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Información del curso y grupo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.course.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Categoría: ${widget.category.name}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Grupo ${widget.group.groupNumber}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiempo restante
                  _buildTimeRemaining(),
                  const SizedBox(height: 16),
                  
                  // Progreso de evaluación
                  _buildProgressIndicator(),
                  const SizedBox(height: 24),
                  
                  // Lista de usuarios a evaluar
                  const Text(
                    'Miembros del Grupo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Consumer<EvaluationProvider>(
                    builder: (context, evaluationProvider, child) {
                      return Column(
                        children: _availableUsers.map((username) {
                          final isCompleted = evaluationProvider.isEvaluationComplete(username);
                          return _buildUserCard(username, isCompleted);
                        }).toList(),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Formulario de evaluación
                  if (_selectedUser != null) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildEvaluationForm(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
