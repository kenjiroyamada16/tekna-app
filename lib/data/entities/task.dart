import 'task_media.dart';

class Task {
  final int id;
  final String title;
  final String status;
  final TaskMedia? media;
  final String? description;
  final String? categoryName;

  Task({
    required this.id,
    required this.title,
    required this.status,
    this.media,
    this.description,
    this.categoryName,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    final mediaJsonList = (json['media'] as List<dynamic>?);

    return Task(
      id: json['id'],
      title: json['title'],
      status: json['status'],
      description: json['description'],
      categoryName: json['category']?['name'],
      media: (mediaJsonList?.isNotEmpty ?? false)
          ? TaskMedia.fromJson(mediaJsonList?.first as Map<String, dynamic>)
          : null,
    );
  }
}
