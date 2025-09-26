import 'package:flutter/material.dart';
import 'package:proyecto/features/category_management/domain/entities/category.dart';
import 'package:proyecto/features/course_management/domain/repositories/course_repository.dart';
import 'package:proyecto/features/category_management/domain/usecases/create_category_usecase.dart';
import 'package:proyecto/features/category_management/domain/usecases/delete_category_usecase.dart';
import 'package:proyecto/features/category_management/domain/usecases/edit_category_usecase.dart';
import 'package:proyecto/features/category_management/domain/usecases/enroll_category_usecase.dart';
import 'package:proyecto/features/category_management/domain/usecases/unenroll_category_usecase.dart';

class CategoryProvider with ChangeNotifier {
  final CourseRepository repository;
  final CreateCategoryUseCase createCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;
  final EditCategoryUseCase editCategoryUseCase;
  final EnrollCategoryUseCase enrollCategoryUseCase;
  final UnenrollCategoryUseCase unenrollCategoryUseCase;

  CategoryProvider({
    required this.repository,
    required this.createCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.editCategoryUseCase,
    required this.enrollCategoryUseCase,
    required this.unenrollCategoryUseCase,
  });

  List<CategoryEntity> _categories = [];
  bool _isLoading = false;
  String? _error;
  bool _isCreatingCategory = false;
  CategoryEntity? _editingCategory;
  VoidCallback? _onScrollToForm;

  List<CategoryEntity> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isCreatingCategory => _isCreatingCategory;
  CategoryEntity? get editingCategory => _editingCategory;

  Future<void> loadCategories(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await repository.getCategoriesByCourse(courseId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCategory({
    required String courseId,
    required String name,
    required int numberOfGroups,
    required bool isRandomAssignment,
    required int maxEnrollments,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final category = await createCategoryUseCase.execute(
        courseId: courseId,
        name: name,
        numberOfGroups: numberOfGroups,
        isRandomAssignment: isRandomAssignment,
        maxEnrollments: maxEnrollments,
      );
      _categories.add(category);
      _isCreatingCategory = false;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editCategory({
    required String categoryId,
    required String name,
    required int numberOfGroups,
    required bool isRandomAssignment,
    required int maxEnrollments,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedCategory = await editCategoryUseCase.execute(
        categoryId: categoryId,
        name: name,
        numberOfGroups: numberOfGroups,
        isRandomAssignment: isRandomAssignment,
        maxEnrollments: maxEnrollments,
      );
      
      // Agregar la categoría actualizada a la lista (ya fue removida visualmente)
      _categories.add(updatedCategory);
      
      // Reordenar por fecha de creación para mantener el orden
      _categories.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      // Repliegue el widget de creación
      _editingCategory = null;
      _isCreatingCategory = false;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Obtener la categoría para obtener el courseId
      final category = _categories.firstWhere((c) => c.id == categoryId);
      await deleteCategoryUseCase.execute(
        categoryId: categoryId,
        courseId: category.courseId,
      );
      _categories.removeWhere((c) => c.id == categoryId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> enrollInGroup({
    required String categoryId,
    required String groupId,
    required String username,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await enrollCategoryUseCase.execute(
        categoryId: categoryId,
        groupId: groupId,
        username: username,
      );
      
      // Recargar las categorías para reflejar el cambio
      final updatedCategory = await repository.getCategoryById(categoryId);
      if (updatedCategory != null) {
        final index = _categories.indexWhere((c) => c.id == categoryId);
        if (index != -1) {
          _categories[index] = updatedCategory;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> unenrollFromGroup({
    required String categoryId,
    required String username,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await unenrollCategoryUseCase.execute(
        categoryId: categoryId,
        username: username,
      );
      
      // Recargar las categorías para reflejar el cambio
      final updatedCategory = await repository.getCategoryById(categoryId);
      if (updatedCategory != null) {
        final index = _categories.indexWhere((c) => c.id == categoryId);
        if (index != -1) {
          _categories[index] = updatedCategory;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleCreateCategory() {
    _isCreatingCategory = !_isCreatingCategory;
    _editingCategory = null;
    notifyListeners();
  }

  void startEditingCategory(CategoryEntity category, BuildContext context) {
    // Mostrar advertencia antes de editar
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Advertencia'),
        content: const Text(
          'Cuidado: Al editar esta categoría se borrarán todas las inscripciones a grupos existentes. '
          'La categoría se eliminará temporalmente y se volverá a crear después de la edición. '
          '¿Estás seguro de que quieres continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Borrar visualmente la categoría de la lista
              _categories.removeWhere((c) => c.id == category.id);
              _editingCategory = category;
              _isCreatingCategory = true;
              notifyListeners();
              
              // Hacer scroll al formulario después de un breve delay
              Future.delayed(const Duration(milliseconds: 100), () {
                _onScrollToForm?.call();
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void cancelEditing() {
    // Si se estaba editando una categoría, restaurarla a la lista
    if (_editingCategory != null) {
      _categories.add(_editingCategory!);
      // Reordenar por fecha de creación
      _categories.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    
    _editingCategory = null;
    _isCreatingCategory = false;
    notifyListeners();
  }

  bool isUserEnrolledInCategory(String categoryId, String username) {
    final category = _categories.firstWhere((c) => c.id == categoryId);
    return category.groups.any((group) => group.members.contains(username));
  }

  GroupEntity? getUserGroupInCategory(String categoryId, String username) {
    final category = _categories.firstWhere((c) => c.id == categoryId);
    try {
      return category.groups.firstWhere((group) => group.members.contains(username));
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setScrollToFormCallback(VoidCallback callback) {
    _onScrollToForm = callback;
  }
}
