class CategoryEntity {
  final String id;
  final String courseId;
  final String name;
  final int numberOfGroups;
  final bool isRandomAssignment;
  final DateTime createdAt;
  final List<GroupEntity> groups;

  const CategoryEntity({
    required this.id,
    required this.courseId,
    required this.name,
    required this.numberOfGroups,
    required this.isRandomAssignment,
    required this.createdAt,
    required this.groups,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'name': name,
      'numberOfGroups': numberOfGroups,
      'isRandomAssignment': isRandomAssignment,
      'createdAt': createdAt.toIso8601String(),
      'groups': groups.map((group) => group.toJson()).toList(),
    };
  }

  factory CategoryEntity.fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      id: json['id'],
      courseId: json['courseId'],
      name: json['name'],
      numberOfGroups: json['numberOfGroups'],
      isRandomAssignment: json['isRandomAssignment'],
      createdAt: DateTime.parse(json['createdAt']),
      groups: (json['groups'] as List)
          .map((groupJson) => GroupEntity.fromJson(groupJson))
          .toList(),
    );
  }

  CategoryEntity copyWith({
    String? id,
    String? courseId,
    String? name,
    int? numberOfGroups,
    bool? isRandomAssignment,
    DateTime? createdAt,
    List<GroupEntity>? groups,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      name: name ?? this.name,
      numberOfGroups: numberOfGroups ?? this.numberOfGroups,
      isRandomAssignment: isRandomAssignment ?? this.isRandomAssignment,
      createdAt: createdAt ?? this.createdAt,
      groups: groups ?? this.groups,
    );
  }
}

class GroupEntity {
  final String id;
  final String categoryId;
  final int groupNumber;
  final List<String> members;
  final int maxMembers;

  const GroupEntity({
    required this.id,
    required this.categoryId,
    required this.groupNumber,
    required this.members,
    required this.maxMembers,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'groupNumber': groupNumber,
      'members': members,
      'maxMembers': maxMembers,
    };
  }

  factory GroupEntity.fromJson(Map<String, dynamic> json) {
    return GroupEntity(
      id: json['id'],
      categoryId: json['categoryId'],
      groupNumber: json['groupNumber'],
      members: List<String>.from(json['members']),
      maxMembers: json['maxMembers'],
    );
  }

  GroupEntity copyWith({
    String? id,
    String? categoryId,
    int? groupNumber,
    List<String>? members,
    int? maxMembers,
  }) {
    return GroupEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      groupNumber: groupNumber ?? this.groupNumber,
      members: members ?? this.members,
      maxMembers: maxMembers ?? this.maxMembers,
    );
  }
}
