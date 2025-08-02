import 'task_media.dart';

class Task {
  final int id;
  final String title;
  final String status;
  final TaskMedia? media;
  final String? description;
  final String? categoryName;
  final DateTime? expiryDate;

  Task({
    required this.id,
    required this.title,
    required this.status,
    this.media,
    this.description,
    this.categoryName,
    this.expiryDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    final mediaJsonList = (json['media'] as List<dynamic>?);

    return Task(
      id: json['id'],
      title: json['title'],
      status: json['status'],
      description: json['description'],
      categoryName: json['category']?['name'],
      expiryDate: DateTime.tryParse(json['expiry_date'] ?? ''),
      media: (mediaJsonList?.isNotEmpty ?? false)
          ? TaskMedia.fromJson(mediaJsonList?.first as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'description': description,
      'category': categoryName,
      'expiry_date': expiryDate?.toIso8601String(),
      'media': media?.toJson(),
    };
  }
}
