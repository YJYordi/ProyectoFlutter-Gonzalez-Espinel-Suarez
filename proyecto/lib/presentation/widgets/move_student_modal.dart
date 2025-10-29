import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/Domain/Entities/category.dart';
import 'package:proyecto/presentation/providers/student_management_provider.dart';

class MoveStudentModal extends StatefulWidget {
  final CategoryEntity category;
  final String studentUsername;

  const MoveStudentModal({
    super.key,
    required this.category,
    required this.studentUsername,
  });

  @override
  State<MoveStudentModal> createState() => _MoveStudentModalState();
}

class _MoveStudentModalState extends State<MoveStudentModal> {
  String? _selectedGroupId;
  bool _isLoading = false;

  String _getUserName(String username) {
    return username.split('@')[0].replaceAll('.', ' ').toUpperCase();
  }

  Future<void> _moveStudent() async {
    if (_selectedGroupId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final studentManagementProvider = Provider.of<StudentManagementProvider>(context, listen: false);
      
      await studentManagementProvider.moveStudentToGroup(
        categoryId: widget.category.id,
        studentUsername: widget.studentUsername,
        targetGroupId: _selectedGroupId!,
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Retorna true para indicar éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getUserName(widget.studentUsername)} movido exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener grupos disponibles (excluyendo el grupo actual del estudiante)
    final availableGroups = widget.category.groups.where((group) {
      // Excluir el grupo actual del estudiante
      if (group.members.contains(widget.studentUsername)) return false;
      // Solo mostrar grupos que no estén llenos
      return group.members.length < group.maxMembers;
    }).toList();

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Mover Estudiante',
                    style: const TextStyle(
                      fontSize: 18,
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
            
            // Información del estudiante
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    _getUserName(widget.studentUsername),
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Selector de grupo
            Text(
              'Seleccionar grupo destino:',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            
            if (availableGroups.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'No hay grupos disponibles para mover al estudiante',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...availableGroups.map((group) {
                return RadioListTile<String>(
                  title: Text('Grupo ${group.groupNumber}'),
                  subtitle: Text('${group.members.length}/${group.maxMembers} miembros'),
                  value: group.id,
                  groupValue: _selectedGroupId,
                  onChanged: (value) {
                    setState(() {
                      _selectedGroupId = value;
                    });
                  },
                );
              }).toList(),
            
            const SizedBox(height: 24),
            
            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading || _selectedGroupId == null ? null : _moveStudent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Mover'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
