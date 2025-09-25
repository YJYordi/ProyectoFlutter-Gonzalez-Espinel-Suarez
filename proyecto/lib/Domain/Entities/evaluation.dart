class EvaluationEntity {
  final String id;
  final String courseId;
  final String categoryId;
  final String groupId;
  final String evaluatorUsername; // Quien evalúa
  final String evaluatedUsername; // Quien es evaluado
  final int punctuality; // 0-5 estrellas
  final int contributions; // 0-5 estrellas
  final int commitment; // 0-5 estrellas
  final int attitude; // 0-5 estrellas
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;

  const EvaluationEntity({
    required this.id,
    required this.courseId,
    required this.categoryId,
    required this.groupId,
    required this.evaluatorUsername,
    required this.evaluatedUsername,
    required this.punctuality,
    required this.contributions,
    required this.commitment,
    required this.attitude,
    required this.createdAt,
    required this.updatedAt,
    required this.isCompleted,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'categoryId': categoryId,
      'groupId': groupId,
      'evaluatorUsername': evaluatorUsername,
      'evaluatedUsername': evaluatedUsername,
      'punctuality': punctuality,
      'contributions': contributions,
      'commitment': commitment,
      'attitude': attitude,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory EvaluationEntity.fromJson(Map<String, dynamic> json) {
    return EvaluationEntity(
      id: json['id'],
      courseId: json['courseId'],
      categoryId: json['categoryId'],
      groupId: json['groupId'],
      evaluatorUsername: json['evaluatorUsername'],
      evaluatedUsername: json['evaluatedUsername'],
      punctuality: json['punctuality'],
      contributions: json['contributions'],
      commitment: json['commitment'],
      attitude: json['attitude'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isCompleted: json['isCompleted'],
    );
  }

  EvaluationEntity copyWith({
    String? id,
    String? courseId,
    String? categoryId,
    String? groupId,
    String? evaluatorUsername,
    String? evaluatedUsername,
    int? punctuality,
    int? contributions,
    int? commitment,
    int? attitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
  }) {
    return EvaluationEntity(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      categoryId: categoryId ?? this.categoryId,
      groupId: groupId ?? this.groupId,
      evaluatorUsername: evaluatorUsername ?? this.evaluatorUsername,
      evaluatedUsername: evaluatedUsername ?? this.evaluatedUsername,
      punctuality: punctuality ?? this.punctuality,
      contributions: contributions ?? this.contributions,
      commitment: commitment ?? this.commitment,
      attitude: attitude ?? this.attitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Calcular promedio de la evaluación
  double get averageScore {
    if (!isCompleted) return 0.0;
    return (punctuality + contributions + commitment + attitude) / 4.0;
  }

  // Verificar si la evaluación está pendiente (0 estrellas en todos los criterios)
  bool get isPending {
    return punctuality == 0 && contributions == 0 && commitment == 0 && attitude == 0;
  }
}

class EvaluationSessionEntity {
  final String id;
  final String courseId;
  final String categoryId;
  final String groupId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final List<String> evaluators; // Usuarios que deben evaluar
  final List<String> evaluated; // Usuarios que serán evaluados

  const EvaluationSessionEntity({
    required this.id,
    required this.courseId,
    required this.categoryId,
    required this.groupId,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.evaluators,
    required this.evaluated,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'categoryId': categoryId,
      'groupId': groupId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'evaluators': evaluators,
      'evaluated': evaluated,
    };
  }

  factory EvaluationSessionEntity.fromJson(Map<String, dynamic> json) {
    return EvaluationSessionEntity(
      id: json['id'],
      courseId: json['courseId'],
      categoryId: json['categoryId'],
      groupId: json['groupId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'],
      evaluators: List<String>.from(json['evaluators']),
      evaluated: List<String>.from(json['evaluated']),
    );
  }

  // Verificar si la sesión está vencida
  bool get isOverdue {
    return DateTime.now().isAfter(endDate);
  }

  // Verificar si la sesión está activa y no vencida
  bool get isCurrentlyActive {
    return isActive && !isOverdue;
  }

  // Calcular días restantes
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }
}

class EvaluationCriteriaEntity {
  final String id;
  final String name;
  final String description;
  final Map<int, String> descriptions; // 1-5 estrellas -> descripción
  final Map<int, String> spanishDescriptions; // 1-5 estrellas -> descripción en español

  const EvaluationCriteriaEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.descriptions,
    required this.spanishDescriptions,
  });

  static const List<EvaluationCriteriaEntity> defaultCriteria = [
    EvaluationCriteriaEntity(
      id: 'punctuality',
      name: 'Punctuality',
      description: 'Punctuality and attendance',
      descriptions: {
        1: 'Was late or absent for most sessions, negatively impacting the team\'s performance.',
        2: 'Was late or absent for most sessions, negatively impacting the team\'s performance.',
        3: 'Frequently arrived late or missed sessions.',
        4: 'Was generally punctual and attended most sessions.',
        5: 'Was consistently punctual and attended all team sessions.',
      },
      spanishDescriptions: {
        1: 'Llegó tarde a todas las sesiones o se estuvo ausentando constantemente lo cual afecto el trabajo del equipo.',
        2: 'Llegó tarde a todas las sesiones o se estuvo ausentando constantemente lo cual afecto el trabajo del equipo.',
        3: 'Llegó tarde con mucha frecuencia y se ausentó varias veces del trabajo del equipo.',
        4: 'En la mayoría de las sesiones llegó puntualmente y no se ausentó con frecuencia.',
        5: 'Acudió puntualmente a todas las sesiones de trabajo.',
      },
    ),
    EvaluationCriteriaEntity(
      id: 'contributions',
      name: 'Contributions',
      description: 'Contributions to team work',
      descriptions: {
        1: 'Acted mostly as a passive observer, contributed little or nothing to the team.',
        2: 'Acted mostly as a passive observer, contributed little or nothing to the team.',
        3: 'Participated occasionally in discussions and teamwork.',
        4: 'Made several contributions; could be more critical or proactive.',
        5: 'Provided relevant and enriching contributions that improved the team\'s work.',
      },
      spanishDescriptions: {
        1: 'En todo momento estuvo como observador y no aportó al trabajo del equipo.',
        2: 'En todo momento estuvo como observador y no aportó al trabajo del equipo.',
        3: 'En algunas ocasiones participó dentro del equipo y en los intercambios generales.',
        4: 'Hizo varios aportes al equipo; sin embargo, puede ser más crítico y propositivo',
        5: 'Sus aportes fueron muy acertados y enriquecieron en todo momento el trabajo del equipo',
      },
    ),
    EvaluationCriteriaEntity(
      id: 'commitment',
      name: 'Commitment',
      description: 'Commitment to tasks and roles',
      descriptions: {
        1: 'Showed little commitment to tasks or roles, both with the facilitator and teammates.',
        2: 'Showed little commitment to tasks or roles, both with the facilitator and teammates.',
        3: 'Occasionally showed lack of commitment, which affected team progress.',
        4: 'Demonstrated responsibility and commitment most of the time, though could contribute more.',
        5: 'Consistently committed to tasks and roles, showing strong engagement with the team.',
      },
      spanishDescriptions: {
        1: 'Mostró poco compromiso con las tareas y roles asignados tanto por el profesor como por los miembros del equipo.',
        2: 'Mostró poco compromiso con las tareas y roles asignados tanto por el profesor como por los miembros del equipo.',
        3: 'En algunos momentos observamos que su compromiso con el trabajo disminuyó, y le afectó para afrontar las tareas propuestas.',
        4: 'La mayor parte del tiempo asumió tareas con responsabilidad y compromiso pero pudo haber aportado más al trabajo del equipo.',
        5: 'Mostró en todo momento un compromiso serio con las tareas asignadas y los roles que tuvo en el equipo.',
      },
    ),
    EvaluationCriteriaEntity(
      id: 'attitude',
      name: 'Attitude',
      description: 'Attitude towards team work',
      descriptions: {
        1: 'Displayed a negative or indifferent attitude toward team tasks and collaboration.',
        2: 'Displayed a negative or indifferent attitude toward team tasks and collaboration.',
        3: 'Occasionally showed a positive attitude, but not enough to positively impact the team.',
        4: 'Mostly displayed a positive and open attitude that helped the team.',
        5: 'Always demonstrated a positive attitude and willingness to contribute with quality work.',
      },
      spanishDescriptions: {
        1: 'Mantuvo una actitud negativa hacia las actividades del taller y a las tareas del equipo.',
        2: 'Mantuvo una actitud negativa hacia las actividades del taller y a las tareas del equipo.',
        3: 'En algunas oportunidades tuvo una actitud abierta y positiva; pero no lo suficiente para beneficiar significativamente el trabajo del equipo.',
        4: 'La mayor parte del tiempo muestra apertura y actitud positiva hacia el trabajo, pero puede ser más constante.',
        5: 'Su actitud es positiva y demuestra deseos de realizar el trabajo con calidad.',
      },
    ),
  ];
}
