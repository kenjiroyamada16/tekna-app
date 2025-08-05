class TaskCategory {
  final int id;
  final String name;

  TaskCategory({required this.id, required this.name});

  factory TaskCategory.fromJson(Map<String, dynamic> json) {
    return TaskCategory(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  @override
  bool operator ==(Object other) {
    return other is TaskCategory && id == other.id;
  }

  @override
  int get hashCode => Object.hash(id, name);
}
