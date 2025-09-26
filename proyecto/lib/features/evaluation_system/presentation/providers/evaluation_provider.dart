import 'package:flutter/foundation.dart';
import 'package:proyecto/features/evaluation_system/domain/entities/evaluation.dart';
import 'package:proyecto/features/evaluation_system/domain/usecases/create_evaluation_usecase.dart';
import 'package:proyecto/features/evaluation_system/domain/usecases/update_evaluation_usecase.dart';
import 'package:proyecto/features/evaluation_system/domain/usecases/get_evaluations_by_group_usecase.dart';
import 'package:proyecto/features/evaluation_system/domain/usecases/get_pending_evaluations_usecase.dart';
import 'package:proyecto/features/evaluation_system/domain/usecases/start_evaluation_session_usecase.dart';

class EvaluationProvider extends ChangeNotifier {
  final CreateEvaluationUseCase createEvaluationUseCase;
  final UpdateEvaluationUseCase updateEvaluationUseCase;
  final GetEvaluationsByGroupUseCase getEvaluationsByGroupUseCase;
  final GetPendingEvaluationsUseCase getPendingEvaluationsUseCase;
  final StartEvaluationSessionUseCase startEvaluationSessionUseCase;

  EvaluationProvider({
    required this.createEvaluationUseCase,
    required this.updateEvaluationUseCase,
    required this.getEvaluationsByGroupUseCase,
    required this.getPendingEvaluationsUseCase,
    required this.startEvaluationSessionUseCase,
  });

  List<EvaluationEntity> _evaluations = [];
  List<EvaluationEntity> _pendingEvaluations = [];
  List<EvaluationEntity> _completedEvaluations = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedEvaluatedUser;
  Map<String, int> _currentRatings = {};

  // Getters
  List<EvaluationEntity> get evaluations => _evaluations;
  List<EvaluationEntity> get pendingEvaluations => _pendingEvaluations;
  List<EvaluationEntity> get completedEvaluations => _completedEvaluations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedEvaluatedUser => _selectedEvaluatedUser;
  Map<String, int> get currentRatings => _currentRatings;

  // Calcular progreso de evaluación
  double get evaluationProgress {
    if (_evaluations.isEmpty) return 0.0;
    final completed = _evaluations.where((e) => e.isCompleted).length;
    return completed / _evaluations.length;
  }

  // Obtener evaluaciones de un grupo
  Future<void> loadEvaluationsByGroup({
    required String courseId,
    required String categoryId,
    required String groupId,
    required String evaluatorUsername,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _evaluations = await getEvaluationsByGroupUseCase.execute(
        courseId: courseId,
        categoryId: categoryId,
        groupId: groupId,
        evaluatorUsername: evaluatorUsername,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener evaluaciones pendientes
  Future<void> loadPendingEvaluations({
    required String username,
    String? courseId,
    String? categoryId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingEvaluations = await getPendingEvaluationsUseCase.execute(
        username: username,
        courseId: courseId,
        categoryId: categoryId,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener evaluaciones completadas
  Future<void> loadCompletedEvaluations({
    required String username,
    String? courseId,
    String? categoryId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _completedEvaluations = await getPendingEvaluationsUseCase.execute(
        username: username,
        courseId: courseId,
        categoryId: categoryId,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear nueva evaluación
  Future<void> createEvaluation({
    required String courseId,
    required String categoryId,
    required String groupId,
    required String evaluatorUsername,
    required String evaluatedUsername,
    required int punctuality,
    required int contributions,
    required int commitment,
    required int attitude,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final evaluation = await createEvaluationUseCase.execute(
        courseId: courseId,
        categoryId: categoryId,
        groupId: groupId,
        evaluatorUsername: evaluatorUsername,
        evaluatedUsername: evaluatedUsername,
        punctuality: punctuality,
        contributions: contributions,
        commitment: commitment,
        attitude: attitude,
      );

      // Actualizar la lista de evaluaciones
      final index = _evaluations.indexWhere((e) => e.id == evaluation.id);
      if (index != -1) {
        _evaluations[index] = evaluation;
      } else {
        _evaluations.add(evaluation);
      }

      // Actualizar evaluaciones pendientes
      _pendingEvaluations.removeWhere((e) => e.id == evaluation.id);
      if (evaluation.isCompleted) {
        _completedEvaluations.add(evaluation);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar evaluación existente
  Future<void> updateEvaluation({
    required String evaluationId,
    required int punctuality,
    required int contributions,
    required int commitment,
    required int attitude,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final evaluation = await updateEvaluationUseCase.execute(
        evaluationId: evaluationId,
        punctuality: punctuality,
        contributions: contributions,
        commitment: commitment,
        attitude: attitude,
      );

      // Actualizar la lista de evaluaciones
      final index = _evaluations.indexWhere((e) => e.id == evaluation.id);
      if (index != -1) {
        _evaluations[index] = evaluation;
      }

      // Actualizar evaluaciones pendientes y completadas
      _pendingEvaluations.removeWhere((e) => e.id == evaluation.id);
      if (evaluation.isCompleted) {
        final completedIndex = _completedEvaluations.indexWhere((e) => e.id == evaluation.id);
        if (completedIndex != -1) {
          _completedEvaluations[completedIndex] = evaluation;
        } else {
          _completedEvaluations.add(evaluation);
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Iniciar sesión de evaluación (para profesores)
  Future<void> startEvaluationSession({
    required String categoryId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await startEvaluationSessionUseCase.execute(
        categoryId: categoryId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Seleccionar usuario a evaluar
  void selectEvaluatedUser(String username) {
    _selectedEvaluatedUser = username;
    _currentRatings = {};
    
    // Cargar calificaciones existentes si las hay
    final existingEvaluation = _evaluations.firstWhere(
      (e) => e.evaluatedUsername == username,
      orElse: () => EvaluationEntity(
        id: '',
        courseId: '',
        categoryId: '',
        groupId: '',
        evaluatorUsername: '',
        evaluatedUsername: '',
        punctuality: 0,
        contributions: 0,
        commitment: 0,
        attitude: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCompleted: false,
      ),
    );

    if (existingEvaluation.id.isNotEmpty) {
      _currentRatings = {
        'punctuality': existingEvaluation.punctuality,
        'contributions': existingEvaluation.contributions,
        'commitment': existingEvaluation.commitment,
        'attitude': existingEvaluation.attitude,
      };
    }

    notifyListeners();
  }

  // Actualizar calificación
  void updateRating(String criterion, int rating) {
    _currentRatings[criterion] = rating;
    notifyListeners();
  }

  // Guardar evaluación
  Future<void> saveEvaluation({
    required String courseId,
    required String categoryId,
    required String groupId,
    required String evaluatorUsername,
    required String evaluatedUsername,
  }) async {
    if (_selectedEvaluatedUser == null) return;

    final punctuality = _currentRatings['punctuality'] ?? 0;
    final contributions = _currentRatings['contributions'] ?? 0;
    final commitment = _currentRatings['commitment'] ?? 0;
    final attitude = _currentRatings['attitude'] ?? 0;

    // Verificar si ya existe una evaluación
    final existingEvaluation = _evaluations.firstWhere(
      (e) => e.evaluatedUsername == evaluatedUsername,
      orElse: () => EvaluationEntity(
        id: '',
        courseId: '',
        categoryId: '',
        groupId: '',
        evaluatorUsername: '',
        evaluatedUsername: '',
        punctuality: 0,
        contributions: 0,
        commitment: 0,
        attitude: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCompleted: false,
      ),
    );

    if (existingEvaluation.id.isNotEmpty) {
      // Actualizar evaluación existente
      await updateEvaluation(
        evaluationId: existingEvaluation.id,
        punctuality: punctuality,
        contributions: contributions,
        commitment: commitment,
        attitude: attitude,
      );
    } else {
      // Crear nueva evaluación
      await createEvaluation(
        courseId: courseId,
        categoryId: categoryId,
        groupId: groupId,
        evaluatorUsername: evaluatorUsername,
        evaluatedUsername: evaluatedUsername,
        punctuality: punctuality,
        contributions: contributions,
        commitment: commitment,
        attitude: attitude,
      );
    }
  }

  // Limpiar estado
  void clearState() {
    _evaluations.clear();
    _pendingEvaluations.clear();
    _completedEvaluations.clear();
    _selectedEvaluatedUser = null;
    _currentRatings.clear();
    _error = null;
    notifyListeners();
  }

  // Obtener usuarios disponibles para evaluar
  List<String> getAvailableUsersToEvaluate(List<String> groupMembers, String evaluatorUsername) {
    return groupMembers.where((member) => member != evaluatorUsername).toList();
  }

  // Verificar si una evaluación está completa
  bool isEvaluationComplete(String username) {
    final evaluation = _evaluations.firstWhere(
      (e) => e.evaluatedUsername == username,
      orElse: () => EvaluationEntity(
        id: '',
        courseId: '',
        categoryId: '',
        groupId: '',
        evaluatorUsername: '',
        evaluatedUsername: '',
        punctuality: 0,
        contributions: 0,
        commitment: 0,
        attitude: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCompleted: false,
      ),
    );

    return evaluation.isCompleted;
  }
}
