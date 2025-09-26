import 'package:get/get.dart';
import 'package:proyecto/features/evaluation_system/domain/entities/evaluation.dart';
import 'package:proyecto/features/evaluation_system/domain/usecases/create_evaluation_usecase.dart';
import 'package:proyecto/features/evaluation_system/domain/usecases/update_evaluation_usecase.dart';
import 'package:proyecto/features/evaluation_system/domain/usecases/get_evaluations_by_group_usecase.dart';
import 'package:proyecto/features/evaluation_system/domain/usecases/get_pending_evaluations_usecase.dart';
import 'package:proyecto/features/evaluation_system/domain/usecases/start_evaluation_session_usecase.dart';

class EvaluationController extends GetxController {
  final CreateEvaluationUseCase createEvaluationUseCase;
  final UpdateEvaluationUseCase updateEvaluationUseCase;
  final GetEvaluationsByGroupUseCase getEvaluationsByGroupUseCase;
  final GetPendingEvaluationsUseCase getPendingEvaluationsUseCase;
  final StartEvaluationSessionUseCase startEvaluationSessionUseCase;

  // Variables reactivas
  final _evaluations = <EvaluationEntity>[].obs;
  final _pendingEvaluations = <EvaluationEntity>[].obs;
  final _completedEvaluations = <EvaluationEntity>[].obs;
  final _isLoading = false.obs;
  final _error = RxnString();
  final _selectedEvaluatedUser = RxnString();
  final _currentRatings = <String, int>{}.obs;

  EvaluationController({
    required this.createEvaluationUseCase,
    required this.updateEvaluationUseCase,
    required this.getEvaluationsByGroupUseCase,
    required this.getPendingEvaluationsUseCase,
    required this.startEvaluationSessionUseCase,
  });

  // Getters
  List<EvaluationEntity> get evaluations => _evaluations;
  List<EvaluationEntity> get pendingEvaluations => _pendingEvaluations;
  List<EvaluationEntity> get completedEvaluations => _completedEvaluations;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  String? get selectedEvaluatedUser => _selectedEvaluatedUser.value;
  Map<String, int> get currentRatings => _currentRatings;

  @override
  void onInit() {
    super.onInit();
    // loadPendingEvaluations se debe llamar con parámetros específicos
  }

  Future<void> loadPendingEvaluations({
    required String username,
    String? courseId,
    String? categoryId,
  }) async {
    _isLoading.value = true;
    _error.value = null;

    try {
      final evaluations = await getPendingEvaluationsUseCase.execute(
        username: username,
        courseId: courseId,
        categoryId: categoryId,
      );
      _pendingEvaluations.value = evaluations;
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Error al cargar evaluaciones pendientes: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadEvaluationsByGroup({
    required String courseId,
    required String categoryId,
    required String groupId,
    required String evaluatorUsername,
  }) async {
    _isLoading.value = true;
    _error.value = null;

    try {
      final evaluations = await getEvaluationsByGroupUseCase.execute(
        courseId: courseId,
        categoryId: categoryId,
        groupId: groupId,
        evaluatorUsername: evaluatorUsername,
      );
      _evaluations.value = evaluations;
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Error al cargar evaluaciones del grupo: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> createEvaluation({
    required String evaluatorId,
    required String evaluatedId,
    required String groupId,
    required String courseId,
    required String categoryId,
    required Map<String, int> ratings,
    String? comments,
  }) async {
    _isLoading.value = true;
    _error.value = null;

    try {
      final evaluation = await createEvaluationUseCase.execute(
        evaluatorUsername: evaluatorId,
        evaluatedUsername: evaluatedId,
        groupId: groupId,
        courseId: courseId,
        categoryId: categoryId,
        punctuality: ratings['punctuality'] ?? 0,
        contributions: ratings['contributions'] ?? 0,
        commitment: ratings['commitment'] ?? 0,
        attitude: ratings['attitude'] ?? 0,
      );

      _evaluations.add(evaluation);
      _pendingEvaluations.removeWhere(
        (eval) =>
            eval.evaluatedUsername == evaluatedId && eval.groupId == groupId,
      );
      _completedEvaluations.add(evaluation);

      Get.snackbar('Éxito', 'Evaluación creada exitosamente');
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Error al crear evaluación: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateEvaluation({
    required String evaluationId,
    required Map<String, int> ratings,
    String? comments,
  }) async {
    _isLoading.value = true;
    _error.value = null;

    try {
      await updateEvaluationUseCase.execute(
        evaluationId: evaluationId,
        punctuality: ratings['punctuality'] ?? 0,
        contributions: ratings['contributions'] ?? 0,
        commitment: ratings['commitment'] ?? 0,
        attitude: ratings['attitude'] ?? 0,
      );

      // Actualizar la evaluación en la lista
      final index = _evaluations.indexWhere((eval) => eval.id == evaluationId);
      if (index != -1) {
        _evaluations[index] = EvaluationEntity(
          id: evaluationId,
          evaluatorUsername: _evaluations[index].evaluatorUsername,
          evaluatedUsername: _evaluations[index].evaluatedUsername,
          groupId: _evaluations[index].groupId,
          courseId: _evaluations[index].courseId,
          categoryId: _evaluations[index].categoryId,
          punctuality: ratings['punctuality'] ?? 0,
          contributions: ratings['contributions'] ?? 0,
          commitment: ratings['commitment'] ?? 0,
          attitude: ratings['attitude'] ?? 0,
          createdAt: _evaluations[index].createdAt,
          updatedAt: DateTime.now(),
          isCompleted: true,
        );
      }

      Get.snackbar('Éxito', 'Evaluación actualizada exitosamente');
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Error al actualizar evaluación: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> startEvaluationSession({
    required String categoryId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _isLoading.value = true;
    _error.value = null;

    try {
      await startEvaluationSessionUseCase.execute(
        categoryId: categoryId,
        startDate: startDate,
        endDate: endDate,
      );

      Get.snackbar('Éxito', 'Sesión de evaluación iniciada exitosamente');
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Error al iniciar sesión de evaluación: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void selectEvaluatedUser(String userId) {
    _selectedEvaluatedUser.value = userId;
    _currentRatings.clear();
  }

  void updateRating(String criterion, int rating) {
    _currentRatings[criterion] = rating;
  }

  void clearCurrentRatings() {
    _currentRatings.clear();
  }

  void clearError() {
    _error.value = null;
  }

  // Métodos de utilidad
  EvaluationEntity? getEvaluationById(String evaluationId) {
    try {
      return _evaluations.firstWhere((eval) => eval.id == evaluationId);
    } catch (e) {
      return null;
    }
  }

  List<EvaluationEntity> getEvaluationsByEvaluator(String evaluatorId) {
    return _evaluations
        .where((eval) => eval.evaluatorUsername == evaluatorId)
        .toList();
  }

  List<EvaluationEntity> getEvaluationsByEvaluated(String evaluatedId) {
    return _evaluations
        .where((eval) => eval.evaluatedUsername == evaluatedId)
        .toList();
  }

  List<EvaluationEntity> getEvaluationsByGroup(String groupId) {
    return _evaluations.where((eval) => eval.groupId == groupId).toList();
  }

  bool hasEvaluated(String evaluatorId, String evaluatedId, String groupId) {
    return _evaluations.any(
      (eval) =>
          eval.evaluatorUsername == evaluatorId &&
          eval.evaluatedUsername == evaluatedId &&
          eval.groupId == groupId,
    );
  }

  double getAverageRating(String evaluatedId, String criterion) {
    final evaluations = getEvaluationsByEvaluated(evaluatedId);
    if (evaluations.isEmpty) return 0.0;

    final ratings = evaluations
        .map((eval) {
          switch (criterion) {
            case 'punctuality':
              return eval.punctuality;
            case 'contributions':
              return eval.contributions;
            case 'commitment':
              return eval.commitment;
            case 'attitude':
              return eval.attitude;
            default:
              return 0;
          }
        })
        .where((rating) => rating > 0)
        .toList();

    if (ratings.isEmpty) return 0.0;

    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  Map<String, double> getAllAverageRatings(String evaluatedId) {
    final evaluations = getEvaluationsByEvaluated(evaluatedId);
    if (evaluations.isEmpty) return {};

    final criteria = ['punctuality', 'contributions', 'commitment', 'attitude'];
    final averages = <String, double>{};

    for (final criterion in criteria) {
      averages[criterion] = getAverageRating(evaluatedId, criterion);
    }

    return averages;
  }

  bool isEvaluationComplete(String evaluatedUsername) {
    return _evaluations.any(
      (eval) => eval.evaluatedUsername == evaluatedUsername && eval.isCompleted,
    );
  }

  double get evaluationProgress {
    if (_evaluations.isEmpty) return 0.0;
    final completedEvaluations = _evaluations
        .where((eval) => eval.isCompleted)
        .length;
    return completedEvaluations / _evaluations.length;
  }
}
