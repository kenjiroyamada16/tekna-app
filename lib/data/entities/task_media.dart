class TaskMedia {
  final int id;
  final String type;
  final String url;
  final String storagePath;

  TaskMedia({
    required this.id,
    required this.type,
    required this.url,
    required this.storagePath,
  });

  factory TaskMedia.fromJson(Map<String, dynamic> json) {
    return TaskMedia(
      id: json['id'],
      type: json['type'],
      url: json['url'],
      storagePath: json['storage_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'url': url,
      'storage_path': storagePath,
    };
  }

  bool get isImage => type.startsWith('image/');
  bool get isVideo => type.startsWith('video/');
}
