class TaskMedia {
  final int id;
  final String type;
  final String url;

  TaskMedia({required this.id, required this.type, required this.url});

  factory TaskMedia.fromJson(Map<String, dynamic> json) {
    return TaskMedia(id: json['id'], type: json['type'], url: json['url']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'url': url,
    };
  }
}
