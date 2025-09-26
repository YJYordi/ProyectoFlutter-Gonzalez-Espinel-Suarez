import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto/features/category_management/domain/entities/category.dart';
import 'package:proyecto/features/course_management/domain/repositories/course_repository.dart';
import 'package:proyecto/features/category_management/domain/usecases/create_category_usecase.dart';
import 'package:proyecto/features/category_management/domain/usecases/delete_category_usecase.dart';
import 'package:proyecto/features/category_management/domain/usecases/edit_category_usecase.dart';
import 'package:proyecto/features/category_management/domain/usecases/enroll_category_usecase.dart';
import 'package:proyecto/features/category_management/domain/usecases/unenroll_category_usecase.dart';

class CategoryController extends GetxController {
  final CourseRepository repository;
  final CreateCategoryUseCase createCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;
  final EditCategoryUseCase editCategoryUseCase;
  final EnrollCategoryUseCase enrollCategoryUseCase;
  final UnenrollCategoryUseCase unenrollCategoryUseCase;

  // Variables reactivas
  final _categories = <CategoryEntity>[].obs;
  final _isLoading = false.obs;
  final _error = RxnString();
  final _isCreatingCategory = false.obs;

  CategoryController({
    required this.repository,
    required this.createCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.editCategoryUseCase,
    required this.enrollCategoryUseCase,
    required this.unenrollCategoryUseCase,
  });

  // Getters
  List<CategoryEntity> get categories => _categories;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  bool get isCreatingCategory => _isCreatingCategory.value;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    _isLoading.value = true;
    _error.value = null;

    try {
      final categories = await repository.getCategoriesByCourse(
        '',
      ); // Necesitamos courseId
      _categories.value = categories;
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Error al cargar categorías: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> createCategory({
    required String name,
    required String description,
    required String color,
  }) async {
    _isCreatingCategory.value = true;
    _error.value = null;

    try {
      final category = await createCategoryUseCase.execute(
        courseId: '', // Necesitamos el courseId
        name: name,
        numberOfGroups: 1, // Valor por defecto
        isRandomAssignment: false, // Valor por defecto
        maxEnrollments: 50, // Valor por defecto
      );

      _categories.add(category);
      Get.snackbar('Éxito', 'Categoría creada exitosamente');
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Error al crear categoría: $e');
    } finally {
      _isCreatingCategory.value = false;
    }
  }

  Future<void> editCategory({
    required String categoryId,
    required String name,
    required String description,
    required String color,
  }) async {
    _isLoading.value = true;
    _error.value = null;

    try {
      await editCategoryUseCase.execute(
        categoryId: categoryId,
        name: name,
        numberOfGroups: 1, // Valor por defecto
        isRandomAssignment: false, // Valor por defecto
        maxEnrollments: 50, // Valor por defecto
      );

      // Actualizar la categoría en la lista
      final index = _categories.indexWhere((cat) => cat.id == categoryId);
      if (index != -1) {
        _categories[index] = CategoryEntity(
          id: categoryId,
          courseId: _categories[index].courseId,
          name: name,
          numberOfGroups: _categories[index].numberOfGroups,
          isRandomAssignment: _categories[index].isRandomAssignment,
          createdAt: _categories[index].createdAt,
          groups: _categories[index].groups,
        );
      }

      Get.snackbar('Éxito', 'Categoría actualizada exitosamente');
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Error al actualizar categoría: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    _isLoading.value = true;
    _error.value = null;

    try {
      await deleteCategoryUseCase.execute(
        categoryId: categoryId,
        courseId: '', // Necesitamos courseId
      );
      _categories.removeWhere((category) => category.id == categoryId);
      Get.snackbar('Éxito', 'Categoría eliminada exitosamente');
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Error al eliminar categoría: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> enrollInCategory(String categoryId, String username) async {
    _isLoading.value = true;
    _error.value = null;

    try {
      await enrollCategoryUseCase.execute(
        categoryId: categoryId,
        groupId: '', // Necesitamos groupId
        username: username,
      );
      Get.snackbar('Éxito', 'Te has inscrito a la categoría exitosamente');
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Error al inscribirse a la categoría: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> unenrollFromCategory(String categoryId, String username) async {
    _isLoading.value = true;
    _error.value = null;

    try {
      await unenrollCategoryUseCase.execute(
        categoryId: categoryId,
        username: username,
      );
      Get.snackbar('Éxito', 'Te has desinscrito de la categoría exitosamente');
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Error al desinscribirse de la categoría: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void clearError() {
    _error.value = null;
  }

  // Métodos de utilidad
  CategoryEntity? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  List<CategoryEntity> getCategoriesByColor(String color) {
    // El campo color no existe en CategoryEntity, retornamos todas las categorías
    return _categories.toList();
  }

  bool categoryExists(String name) {
    return _categories.any(
      (category) => category.name.toLowerCase() == name.toLowerCase(),
    );
  }

  // Métodos adicionales para course_management_screen
  CategoryEntity? editingCategory;
  VoidCallback? _scrollToFormCallback;

  void setScrollToFormCallback(VoidCallback? callback) {
    _scrollToFormCallback = callback;
  }

  void toggleCreateCategory() {
    _isCreatingCategory.value = !_isCreatingCategory.value;
    if (_isCreatingCategory.value && _scrollToFormCallback != null) {
      _scrollToFormCallback!();
    }
  }

  void startEditingCategory(CategoryEntity category, BuildContext context) {
    editingCategory = category;
    _isCreatingCategory.value = true;
    if (_scrollToFormCallback != null) {
      _scrollToFormCallback!();
    }
  }

  void cancelEditing() {
    editingCategory = null;
    _isCreatingCategory.value = false;
  }

  bool isUserEnrolledInCategory(String categoryId, String username) {
    // Implementación básica - retorna false por defecto
    return false;
  }

  GroupEntity? getUserGroupInCategory(String categoryId, String username) {
    // Implementación básica - retorna null por defecto
    return null;
  }

  Future<void> enrollInGroup({
    required String categoryId,
    required String groupId,
    required String username,
  }) async {
    // Implementación básica usando el use case existente
    await enrollInCategory(categoryId, username);
  }

  Future<void> unenrollFromGroup({
    required String categoryId,
    required String username,
  }) async {
    // Implementación básica usando el use case existente
    await unenrollFromCategory(categoryId, username);
  }
}
