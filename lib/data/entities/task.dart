import '../../shared/utils/extensions/date_extensions.dart';
import 'task_category.dart';
import 'task_media.dart';

class Task {
  final int id;
  final String title;
  final String status;
  final TaskMedia? media;
  final String? description;
  final TaskCategory? category;
  final DateTime? expiryDate;

  Task({
    required this.id,
    required this.title,
    required this.status,
    this.media,
    this.description,
    this.category,
    this.expiryDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      status: json['status'],
      description: json['description'],
      expiryDate: DateTime.tryParse(json['expiry_date'] ?? ''),
      category: json['category'] != null
          ? TaskCategory.fromJson(json['category'])
          : null,
      media: json['media'] != null
          ? TaskMedia.fromJson(json['media'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'status': status,
      if (media != null) 'media_id': media?.id,
      if (description != null) 'description': description,
      if (category != null) 'category_id': category?.id,
      if (expiryDate != null) 'expiry_date': expiryDate?.toDbFormat(),
    };
  }
}
