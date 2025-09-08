class CourseEntity {
  final String id;
  final String title;
  final String description;
  final String creatorUsername;
  final String creatorName;
  final List<String> categories;
  final int maxEnrollments;
  final DateTime createdAt;

  const CourseEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorUsername,
    required this.creatorName,
    required this.categories,
    required this.maxEnrollments,
    required this.createdAt,
  });
}


