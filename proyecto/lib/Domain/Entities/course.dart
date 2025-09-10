class CourseEntity {
  final String id;
  final String title;
  final String description;
  final String creatorUsername;
  final String creatorName;
  final List<String> categories;
  final int maxEnrollments;
  final int currentEnrollments;
  final DateTime createdAt;
  final String schedule;
  final String location;
  final double price;

  const CourseEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorUsername,
    required this.creatorName,
    required this.categories,
    required this.maxEnrollments,
    required this.currentEnrollments,
    required this.createdAt,
    required this.schedule,
    required this.location,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'creatorUsername': creatorUsername,
      'creatorName': creatorName,
      'categories': categories,
      'maxEnrollments': maxEnrollments,
      'currentEnrollments': currentEnrollments,
      'createdAt': createdAt.toIso8601String(),
      'schedule': schedule,
      'location': location,
      'price': price,
    };
  }

  factory CourseEntity.fromJson(Map<String, dynamic> json) {
    return CourseEntity(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      creatorUsername: json['creatorUsername'],
      creatorName: json['creatorName'],
      categories: List<String>.from(json['categories']),
      maxEnrollments: json['maxEnrollments'],
      currentEnrollments: json['currentEnrollments'],
      createdAt: DateTime.parse(json['createdAt']),
      schedule: json['schedule'],
      location: json['location'],
      price: json['price'].toDouble(),
    );
  }

  CourseEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? creatorUsername,
    String? creatorName,
    List<String>? categories,
    int? maxEnrollments,
    int? currentEnrollments,
    DateTime? createdAt,
    String? schedule,
    String? location,
    double? price,
  }) {
    return CourseEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      creatorUsername: creatorUsername ?? this.creatorUsername,
      creatorName: creatorName ?? this.creatorName,
      categories: categories ?? this.categories,
      maxEnrollments: maxEnrollments ?? this.maxEnrollments,
      currentEnrollments: currentEnrollments ?? this.currentEnrollments,
      createdAt: createdAt ?? this.createdAt,
      schedule: schedule ?? this.schedule,
      location: location ?? this.location,
      price: price ?? this.price,
    );
  }
}


