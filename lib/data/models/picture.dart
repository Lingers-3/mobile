class Picture {
  final int id;
  final String fileName;
  final String mimeType;
  final int size;
  final DateTime createdAt;
  final String? url;

  Picture({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.size,
    required this.createdAt,
    this.url,
  });

  factory Picture.fromJson(Map<String, dynamic> json) {
    return Picture(
      id: json['id'],
      fileName: json['file_name'],
      mimeType: json['mime_type'],
      size: json['size'],
      createdAt: DateTime.parse(json['created_at']),
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'mime_type': mimeType,
      'size': size,
      'created_at': createdAt.toIso8601String(),
      'url': url,
    };
  }
}
