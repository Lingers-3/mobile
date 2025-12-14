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
      id: json['id'] as int,
      fileName: (json['file_name'] as String?) ??
          (json['original_filename'] as String?) ??
          '',
      mimeType: (json['mime_type'] as String?) ?? '',
      size: (json['size'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      url: json['url'] as String?,
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
