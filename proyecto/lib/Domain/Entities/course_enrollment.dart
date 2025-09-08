class CourseEnrollment {
  final String id;
  final String courseId;
  final String username;
  final String userName;
  final DateTime enrolledAt;

  const CourseEnrollment({
    required this.id,
    required this.courseId,
    required this.username,
    required this.userName,
    required this.enrolledAt,
  });
}
