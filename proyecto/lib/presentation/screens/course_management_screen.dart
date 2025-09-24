import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/Domain/Entities/course.dart';
import 'package:proyecto/Domain/Entities/user.dart';
import 'package:proyecto/Domain/Entities/category.dart';
import 'package:proyecto/presentation/providers/category_provider.dart';
import 'package:proyecto/presentation/providers/role_provider.dart';
import 'package:proyecto/presentation/widgets/category_form_widget.dart';
import 'package:proyecto/presentation/widgets/group_members_modal.dart';
import 'package:proyecto/presentation/screens/evaluation_screen.dart';
import 'package:proyecto/presentation/screens/professor_evaluations_screen.dart';

class CourseManagementScreen extends StatefulWidget {
  final CourseEntity course;
  final UserEntity currentUser;

  const CourseManagementScreen({
    Key? key,
    required this.course,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  final GlobalKey _formWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Cargar las categorías del curso
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      categoryProvider.loadCategories(widget.course.id);
      
      // Registrar callback para hacer scroll al formulario
      categoryProvider.setScrollToFormCallback(() {
        if (_formWidgetKey.currentContext != null) {
          Scrollable.ensureVisible(
            _formWidgetKey.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoleProvider>(
      builder: (context, roleProvider, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(widget.course.title),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            actions: [
              // Botón de evaluaciones para profesores
              if (roleProvider.isProfessor) ...[
                IconButton(
                  icon: const Icon(Icons.assessment),
                  onPressed: () => _navigateToProfessorEvaluations(),
                  tooltip: 'Ver Evaluaciones',
                ),
              ],
              // Indicador de rol
              Container(
                margin: const EdgeInsets.only(right: 16),
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
          body: Consumer<CategoryProvider>(
            builder: (context, categoryProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con descripción del curso
                Text(
                  widget.course.description,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                
                // Botón Nueva Categoría (solo para profesores)
                if (roleProvider.isProfessor) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => categoryProvider.toggleCreateCategory(),
                      icon: const Icon(Icons.add),
                      label: const Text('Nueva Categoría'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Formulario de creación/edición de categoría
                if (categoryProvider.isCreatingCategory)
                  CategoryFormWidget(
                    key: _formWidgetKey,
                    editingCategory: categoryProvider.editingCategory,
                    onSubmit: ({required String name, required int numberOfGroups, required bool isRandomAssignment}) {
                      if (categoryProvider.editingCategory != null) {
                        categoryProvider.editCategory(
                          categoryId: categoryProvider.editingCategory!.id,
                          name: name,
                          numberOfGroups: numberOfGroups,
                          isRandomAssignment: isRandomAssignment,
                          maxEnrollments: widget.course.maxEnrollments,
                        );
                      } else {
                        categoryProvider.createCategory(
                          courseId: widget.course.id,
                          name: name,
                          numberOfGroups: numberOfGroups,
                          isRandomAssignment: isRandomAssignment,
                          maxEnrollments: widget.course.maxEnrollments,
                        );
                      }
                    },
                    onCancel: () => categoryProvider.cancelEditing(),
                  ),
                
                const SizedBox(height: 24),
                
                // Lista de categorías existentes
                if (categoryProvider.categories.isNotEmpty)
                  ...categoryProvider.categories.map((category) => _buildCategoryCard(category, categoryProvider)),
                
                // Mostrar error si existe
                if (categoryProvider.error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            categoryProvider.error!,
                            style: TextStyle(color: Colors.red[600]),
                          ),
                        ),
                        IconButton(
                          onPressed: () => categoryProvider.clearError(),
                          icon: const Icon(Icons.close),
                          color: Colors.red[600],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
        );
      },
    );
  }

  Widget _buildCategoryCard(CategoryEntity category, CategoryProvider categoryProvider) {
    final isUserEnrolled = categoryProvider.isUserEnrolledInCategory(category.id, widget.currentUser.username);
    final userGroup = categoryProvider.getUserGroupInCategory(category.id, widget.currentUser.username);
    
    return Consumer<RoleProvider>(
      builder: (context, roleProvider, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header de la categoría
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Botones de editar y eliminar solo para profesores
                    if (roleProvider.isProfessor) ...[
                      // Botón editar
                      IconButton(
                        onPressed: () => categoryProvider.startEditingCategory(category, context),
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Editar categoría',
                      ),
                      // Botón eliminar
                      IconButton(
                        onPressed: () => _showDeleteConfirmation(category, categoryProvider),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Eliminar categoría',
                      ),
                    ],
                  ],
                ),
              ),
          
              // Información de la categoría
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Cantidad Groups: ${category.numberOfGroups}/${category.isRandomAssignment ? "Random" : "Autoasign"}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Lista de grupos
              ...category.groups.map((group) => _buildGroupItem(group, category, categoryProvider, isUserEnrolled, userGroup)),
              
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupItem(
    GroupEntity group,
    CategoryEntity category,
    CategoryProvider categoryProvider,
    bool isUserEnrolled,
    GroupEntity? userGroup,
  ) {
    final isCurrentUserInGroup = group.members.contains(widget.currentUser.username);
    final canJoin = !isUserEnrolled && group.members.length < group.maxMembers;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Información del grupo
          Expanded(
            child: Row(
              children: [
                Text(
                  'Grupo ${group.groupNumber}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showGroupMembersModal(group),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      '${group.members.length}/${group.maxMembers}',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Botones de acción
          if (canJoin)
            ElevatedButton(
              onPressed: () => categoryProvider.enrollInGroup(
                categoryId: category.id,
                groupId: group.id,
                username: widget.currentUser.username,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: const Text('Unir'),
            )
          else if (isCurrentUserInGroup) ...[
            ElevatedButton(
              onPressed: () => categoryProvider.unenrollFromGroup(
                categoryId: category.id,
                username: widget.currentUser.username,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: const Text('Salir'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _navigateToEvaluation(category, group),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: const Text('Eval'),
            ),
          ],
        ],
      ),
    );
  }

  void _showGroupMembersModal(GroupEntity group) {
    showDialog(
      context: context,
      builder: (context) => GroupMembersModal(
        group: group,
        currentUsername: widget.currentUser.username,
        onLeaveGroup: group.members.contains(widget.currentUser.username)
            ? () {
                Navigator.of(context).pop();
                Provider.of<CategoryProvider>(context, listen: false)
                    .unenrollFromGroup(
                  categoryId: group.categoryId,
                  username: widget.currentUser.username,
                );
              }
            : null,
      ),
    );
  }

  void _navigateToEvaluation(CategoryEntity category, GroupEntity group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EvaluationScreen(
          course: widget.course,
          category: category,
          group: group,
          evaluatorUsername: widget.currentUser.username,
        ),
      ),
    );
  }

  void _navigateToProfessorEvaluations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessorEvaluationsScreen(
          course: widget.course,
          professorUsername: widget.currentUser.username,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(CategoryEntity category, CategoryProvider categoryProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Categoría'),
        content: Text('¿Estás seguro de que quieres eliminar la categoría "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              categoryProvider.deleteCategory(category.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}